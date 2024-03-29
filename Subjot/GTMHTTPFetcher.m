/* Copyright (c) 2010 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTMHTTPFetcher.m
//

#define GTMHTTPFETCHER_DEFINE_GLOBALS 1

#import "GTMHTTPFetcher.h"

SEL const kUnifiedFailureCallback = (SEL) (void *) -1;

static id <GTMCookieStorageProtocol> gGTMFetcherStaticCookieStorage = nil;
static Class gGTMFetcherConnectionClass = nil;

// the default max retry interview is 10 minutes for uploads (POST/PUT/PATCH),
// 1 minute for downloads
const NSTimeInterval kUnsetMaxRetryInterval = -1;
const NSTimeInterval kDefaultMaxDownloadRetryInterval = 60.0;
const NSTimeInterval kDefaultMaxUploadRetryInterval = 60.0 * 10.;

//
// GTMHTTPFetcher
//

@interface GTMHTTPFetcher ()
- (void)stopFetchReleasingCallbacks:(BOOL)shouldReleaseCallbacks;
- (BOOL)shouldReleaseCallbacksUponCompletion;

- (void)handleCookiesForResponse:(NSURLResponse *)response;
- (void)setCookieStorage:(id <GTMCookieStorageProtocol> )obj;

- (void)logNowWithError:(NSError *)error;

- (void)invokeFetchCallback:(SEL)sel
                     target:(id)target
                       data:(NSData *)data
                      error:(NSError *)error;
- (void)releaseCallbacks;

- (BOOL)shouldRetryNowForStatus:(NSInteger)status error:(NSError *)error;
- (void)destroyRetryTimer;
- (void)beginRetryTimer;
- (void)primeRetryTimerWithNewTimeInterval:(NSTimeInterval)secs;
- (void)sendStopNotificationIfNeeded;
- (void)retryFetch;
- (void)retryTimerFired:(NSTimer *)timer;
@end

@interface GTMHTTPFetcher (GTMHTTPFetcherLoggingInternal)
- (void)setupStreamLogging;
- (void)logFetchWithError:(NSError *)error;
@end

@implementation GTMHTTPFetcher

+ (GTMHTTPFetcher *)fetcherWithRequest:(NSURLRequest *)request {
  return [[[[self class] alloc] initWithRequest:request] autorelease];
}

+ (void)initialize {
  // note that initialize is guaranteed by the runtime to be called in a
  // thread-safe manner
  if (!gGTMFetcherStaticCookieStorage) {
    Class cookieStorageClass = NSClassFromString(@"GTMCookieStorage");
    if (cookieStorageClass) {
      gGTMFetcherStaticCookieStorage = [[cookieStorageClass alloc] init];
    }
  }
}

- (id)init {
  return [self initWithRequest:nil];
}

- (id)initWithRequest:(NSURLRequest *)request {
  if ((self = [super init]) != nil) {

    request_ = [request mutableCopy];

    if (gGTMFetcherStaticCookieStorage != nil) {
      // the user has compiled with the cookie storage class available;
      // default to static cookie storage, so our cookies are independent
      // of the cookies of other apps
      [self setCookieStorageMethod:kGTMHTTPFetcherCookieStorageMethodStatic];
    } else {
      // default to system default cookie storage
      [self setCookieStorageMethod:kGTMHTTPFetcherCookieStorageMethodSystemDefault];
    }
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  // disallow use of fetchers in a copy property
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#if !GTM_IPHONE
- (void)finalize {
  [self stopFetchReleasingCallbacks:YES]; // releases connection_, destroys timers
  [super finalize];
}
#endif

- (void)dealloc {
  // note: if a connection or a retry timer was pending, then this instance
  // would be retained by those so it wouldn't be getting dealloc'd,
  // hence we don't need to stopFetch here

  [request_ release];
  [connection_ release];
  [downloadedData_ release];
  [downloadFileHandle_ release];
  [credential_ release];
  [proxyCredential_ release];
  [postData_ release];
  [postStream_ release];
  [loggedStreamData_ release];
  [response_ release];
#if NS_BLOCKS_AVAILABLE
  [completionBlock_ release];
  [receivedDataBlock_ release];
  [sentDataBlock_ release];
  [retryBlock_ release];
#endif
  [userData_ release];
  [properties_ release];
  [runLoopModes_ release];
  [fetchHistory_ release];
  [cookieStorage_ release];

  [retryTimer_ invalidate];
  [retryTimer_ release];

  [super dealloc];
}

#pragma mark -

// Begin fetching the URL.  The delegate is retained for the duration of
// the fetch connection.
//
// The delegate must provide and implement the finished and failed selectors.
//
// finishedSEL has a signature like:
//   - (void)fetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;
//
// Server errors (status >= 300) are reported as the code of the error object.


- (BOOL)beginFetchWithDelegate:(id)delegate
             didFinishSelector:(SEL)finishedSEL {
  AssertSelectorNilOrImplementedWithArguments(delegate, finishedSEL, @encode(GTMHTTPFetcher *), @encode(NSData *), @encode(NSError *), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, receivedDataSEL_, @encode(GTMHTTPFetcher *), @encode(NSData *), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, retrySEL_, @encode(GTMHTTPFetcher *), @encode(BOOL), @encode(NSError *), 0);

  if (connection_ != nil) {
    NSAssert1(connection_ != nil, @"fetch object %@ being reused; this should never happen", self);
    goto CannotBeginFetch;
  }

  if (request_ == nil) {
    NSAssert(request_ != nil, @"beginFetchWithDelegate requires a request");
    goto CannotBeginFetch;
  }

  [downloadedData_ release];
  downloadedData_ = nil;

  finishedSEL_ = finishedSEL;

  NSString *effectiveHTTPMethod = [request_ valueForHTTPHeaderField:@"X-HTTP-Method-Override"];
  if (effectiveHTTPMethod == nil) {
    effectiveHTTPMethod = [request_ HTTPMethod];
  }
  BOOL isEffectiveHTTPGet = (effectiveHTTPMethod == nil
                             || [effectiveHTTPMethod isEqual:@"GET"]);

  if (postData_ || postStream_) {
    if (isEffectiveHTTPGet) {
      [request_ setHTTPMethod:@"POST"];
      isEffectiveHTTPGet = NO;
    }

    if (postData_) {
      [request_ setHTTPBody:postData_];
    } else {
      if ([self respondsToSelector:@selector(setupStreamLogging)]) {
        [self performSelector:@selector(setupStreamLogging)];
      }

      [request_ setHTTPBodyStream:postStream_];
    }
  }

  [fetchHistory_ updateRequest:request_ isHTTPGet:isEffectiveHTTPGet];

  // set the default upload or download retry interval, if necessary
  if (isRetryEnabled_
      && maxRetryInterval_ <= kUnsetMaxRetryInterval) {
    if (isEffectiveHTTPGet || [effectiveHTTPMethod isEqual:@"HEAD"]) {
      [self setMaxRetryInterval:kDefaultMaxDownloadRetryInterval];
    } else {
      [self setMaxRetryInterval:kDefaultMaxUploadRetryInterval];
    }
  }

  // get cookies for this URL from our storage array, if
  // we have a storage array
  if (cookieStorageMethod_ != kGTMHTTPFetcherCookieStorageMethodSystemDefault
      && cookieStorageMethod_ != kGTMHTTPFetcherCookieStorageMethodNone) {

    NSArray *cookies = [cookieStorage_ cookiesForURL:[request_ URL]];
    if ([cookies count]) {

      NSDictionary *headerFields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
      NSString *cookieHeader = [headerFields objectForKey:@"Cookie"]; // key used in header dictionary
      if (cookieHeader) {
        [request_ addValue:cookieHeader forHTTPHeaderField:@"Cookie"]; // header name
      }
    }
  }

  // finally, start the connection

  Class connectionClass = [[self class] connectionClass];

  NSArray *runLoopModes = nil;

  // use the connection-specific run loop modes, if they were provided,
  // or else use the GTMHTTPFetcher default run loop modes, if any
  if (runLoopModes_) {
    runLoopModes = runLoopModes_;
  }

  if ([runLoopModes count] == 0) {

    // if no run loop modes were specified, then we'll start the connection
    // on the current run loop in the current mode
   connection_ = [[connectionClass connectionWithRequest:request_
                                                 delegate:self] retain];
  } else {

    // schedule on current run loop in the specified modes
    connection_ = [[connectionClass alloc] initWithRequest:request_
                                                  delegate:self
                                          startImmediately:NO];
    for (NSString *mode in runLoopModes) {
      [connection_ scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
    }
    [connection_ start];
  }
  hasConnectionEnded_ = NO;

  if (!connection_) {
    NSAssert(connection_ != nil, @"beginFetchWithDelegate could not create a connection");
    goto CannotBeginFetch;
  }

  // We'll retain the delegate only during the outstanding connection (similar
  // to what Cocoa does with performSelectorOnMainThread:) since we'd crash
  // if the delegate was released in the interim.
  [self setDelegate:delegate];

  if (downloadFileHandle_ != nil) {
    // downloading to a file, so downloadedData_ remains nil
  } else {
    downloadedData_ = [[NSMutableData alloc] init];
  }

  // once connection_ is non-nil we can send the start notification
  isStopNotificationNeeded_ = YES;
  NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
  [defaultNC postNotificationName:kGTMHTTPFetcherStartedNotification
                           object:self];
  return YES;

CannotBeginFetch:
  {
    NSError *error = [NSError errorWithDomain:kGTMHTTPFetcherErrorDomain
                                         code:kGTMHTTPFetcherErrorDownloadFailed
                                     userInfo:nil];
    if (finishedSEL) {
      [[self retain] autorelease]; // in case the callback releases us

      [self invokeFetchCallback:finishedSEL
                         target:delegate
                           data:nil
                          error:error];
    }

#if NS_BLOCKS_AVAILABLE
    if (completionBlock_) {
      completionBlock_(nil, error);
    }
#endif
    [self releaseCallbacks];
  }
  return NO;
}


#if NS_BLOCKS_AVAILABLE
- (BOOL)beginFetchWithCompletionHandler:(void (^)(NSData *data, NSError *error))handler {
  completionBlock_ = [handler copy];

  // the user may have called setDelegate: earlier if they want to use other
  // delegate-style callbacks during the fetch; otherwise, the delegate is nil,
  // which is fine
  return [self beginFetchWithDelegate:[self delegate]
                    didFinishSelector:nil];
}
#endif


// Returns YES if this is in the process of fetching a URL, or waiting to
// retry
- (BOOL)isFetching {
  return (connection_ != nil || retryTimer_ != nil);
}

// Returns the status code set in connection:didReceiveResponse:
- (NSInteger)statusCode {

  NSInteger statusCode;

  if (response_ != nil
    && [response_ respondsToSelector:@selector(statusCode)]) {

    statusCode = [(NSHTTPURLResponse *)response_ statusCode];
  } else {
    //  Default to zero, in hopes of hinting "Unknown" (we can't be
    //  sure that things are OK enough to use 200).
    statusCode = 0;
  }
  return statusCode;
}

- (NSDictionary *)responseHeaders {
  if (response_ != nil
      && [response_ respondsToSelector:@selector(allHeaderFields)]) {

    NSDictionary *headers = [(NSHTTPURLResponse *)response_ allHeaderFields];
    return headers;
  }
  return nil;
}

- (void)releaseCallbacks {
  [delegate_ autorelease];
  delegate_ = nil;

#if NS_BLOCKS_AVAILABLE
  [completionBlock_ autorelease];
  completionBlock_ = nil;

  [self setSentDataBlock:nil];
  [self setReceivedDataBlock:nil];
  [self setRetryBlock:nil];
#endif
}

// Cancel the fetch of the URL that's currently in progress.
- (void)stopFetchReleasingCallbacks:(BOOL)shouldReleaseCallbacks {
  // if the connection or the retry timer is all that's retaining the fetcher,
  // we want to be sure this instance survives stopping at least long enough for
  // the stack to unwind
  [[self retain] autorelease];

  [self destroyRetryTimer];

  if (connection_) {
    // in case cancelling the connection calls this recursively, we want
    // to ensure that we'll only release the connection and delegate once,
    // so first set connection_ to nil
    NSURLConnection* oldConnection = connection_;
    connection_ = nil;

    if (!hasConnectionEnded_) {
      [oldConnection cancel];
    }

    // this may be called in a callback from the connection, so use autorelease
    [oldConnection autorelease];

    // send the stopped notification
    [self sendStopNotificationIfNeeded];
  }

  if (shouldReleaseCallbacks) {
    [self releaseCallbacks];
  }
}

// external stop method
- (void)stopFetching {
  [self stopFetchReleasingCallbacks:YES];
}

- (void)sendStopNotificationIfNeeded {
  if (isStopNotificationNeeded_) {
    isStopNotificationNeeded_ = NO;

    NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC postNotificationName:kGTMHTTPFetcherStoppedNotification
                             object:self];
  }
}

- (void)retryFetch {

  [self stopFetchReleasingCallbacks:NO];

  [self beginFetchWithDelegate:delegate_
             didFinishSelector:finishedSEL_];
}

#pragma mark NSURLConnection Delegate Methods

//
// NSURLConnection Delegate Methods
//

// This method just says "follow all redirects", which _should_ be the default behavior,
// According to file:///Developer/ADC%20Reference%20Library/documentation/Cocoa/Conceptual/URLLoadingSystem
// but the redirects were not being followed until I added this method.  May be
// a bug in the NSURLConnection code, or the documentation.
//
// In OS X 10.4.8 and earlier, the redirect request doesn't
// get the original's headers and body. This causes POSTs to fail.
// So we construct a new request, a copy of the original, with overrides from the
// redirect.
//
// Docs say that if redirectResponse is nil, just return the redirectRequest.

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)redirectRequest
            redirectResponse:(NSURLResponse *)redirectResponse {

  if (redirectRequest && redirectResponse) {
    NSMutableURLRequest *newRequest = [[request_ mutableCopy] autorelease];
    // copy the URL
    NSURL *redirectURL = [redirectRequest URL];
    NSURL *url = [newRequest URL];

    // disallow scheme changes (say, from https to http)
    NSString *redirectScheme = [url scheme];
    NSString *newScheme = [redirectURL scheme];
    NSString *newResourceSpecifier = [redirectURL resourceSpecifier];

    if ([redirectScheme caseInsensitiveCompare:@"http"] == NSOrderedSame
        && newScheme != nil
        && [newScheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {

      // allow the change from http to https
      redirectScheme = newScheme;
    }

    NSString *newUrlString = [NSString stringWithFormat:@"%@:%@",
      redirectScheme, newResourceSpecifier];

    NSURL *newURL = [NSURL URLWithString:newUrlString];
    [newRequest setURL:newURL];

    // any headers in the redirect override headers in the original.
    NSDictionary *redirectHeaders = [redirectRequest allHTTPHeaderFields];
    for (NSString *key in redirectHeaders) {
      NSString *value = [redirectHeaders objectForKey:key];
      [newRequest setValue:value forHTTPHeaderField:key];
    }
    redirectRequest = newRequest;

    // save cookies from the response
    [self handleCookiesForResponse:redirectResponse];

    // log the response we just received
    [self setResponse:redirectResponse];
    [self logNowWithError:nil];

    // update the request for future logging
    NSMutableURLRequest *mutable = [[redirectRequest mutableCopy] autorelease];
    [self setMutableRequest:mutable];
}
  return redirectRequest;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  // this method is called when the server has determined that it
  // has enough information to create the NSURLResponse
  // it can be called multiple times, for example in the case of a
  // redirect, so each time we reset the data.
  [downloadedData_ setLength:0];
  [downloadFileHandle_ truncateFileAtOffset:0];

  [self setResponse:response];

  // save cookies from the response
  [self handleCookiesForResponse:response];
}


// handleCookiesForResponse: handles storage of cookies for responses passed to
// connection:willSendRequest:redirectResponse: and connection:didReceiveResponse:
- (void)handleCookiesForResponse:(NSURLResponse *)response {

  if (cookieStorageMethod_ == kGTMHTTPFetcherCookieStorageMethodSystemDefault
    || cookieStorageMethod_ == kGTMHTTPFetcherCookieStorageMethodNone) {

    // do nothing special for NSURLConnection's default storage mechanism
    // or when we're ignoring cookies

  } else if ([response respondsToSelector:@selector(allHeaderFields)]) {

    // grab the cookies from the header as NSHTTPCookies and store them either
    // into our static array or into the fetchHistory

    NSDictionary *responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
    if (responseHeaderFields) {

      NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:responseHeaderFields
                                                                forURL:[response URL]];
      if ([cookies count] > 0) {
        [cookieStorage_ setCookies:cookies];
      }
    }
  }
}

-(void)connection:(NSURLConnection *)connection
       didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

  if ([challenge previousFailureCount] <= 2) {

    NSURLCredential *credential = credential_;

    if ([[challenge protectionSpace] isProxy] && proxyCredential_ != nil) {
      credential = proxyCredential_;
    }

    // Here, if credential is still nil, then we *could* try to get it from
    // NSURLCredentialStorage's defaultCredentialForProtectionSpace:.
    // We don't, because we're assuming:
    //
    // - for server credentials, we only want ones supplied by the program
    //   calling http fetcher
    // - for proxy credentials, if one were necessary and available in the
    //   keychain, it would've been found automatically by NSURLConnection
    //   and this challenge delegate method never would've been called
    //   anyway

    if (credential) {
      // try the credential
      [[challenge sender] useCredential:credential
             forAuthenticationChallenge:challenge];
      return;
    }
  }

  // If we don't have credentials, or we've already failed auth 3x,
  // report the error, putting the challenge as a value in the userInfo
  // dictionary
#if DEBUG
  NSAssert(!isCancellingChallenge_, @"isCancellingChallenge_ unexpected");
#endif
  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:challenge
                                                       forKey:kGTMHTTPFetcherErrorChallengeKey];
  NSError *error = [NSError errorWithDomain:kGTMHTTPFetcherErrorDomain
                                       code:kGTMHTTPFetcherErrorAuthenticationChallengeFailed
                                   userInfo:userInfo];

  // cancelAuthenticationChallenge seems to indirectly call
  // connection:didFailWithError: now, though that isn't documented
  //
  // we'll use an ivar to make the indirect invocation of the
  // delegate method do nothing
  isCancellingChallenge_ = YES;
  [[challenge sender] cancelAuthenticationChallenge:challenge];
  isCancellingChallenge_ = NO;

  [self connection:connection didFailWithError:error];
}

- (void)invokeFetchCallback:(SEL)sel
                     target:(id)target
                       data:(NSData *)data
                      error:(NSError *)error {
  NSMethodSignature *sig = [target methodSignatureForSelector:sel];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
  [invocation setSelector:sel];
  [invocation setTarget:target];
  [invocation setArgument:&self atIndex:2];
  [invocation setArgument:&data atIndex:3];
  [invocation setArgument:&error atIndex:4];
  [invocation invoke];
}

- (void)invokeSentDataCallback:(SEL)sel
                        target:(id)target
               didSendBodyData:(NSInteger)bytesWritten
             totalBytesWritten:(NSInteger)totalBytesWritten
     totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {

  NSMethodSignature *sig = [target methodSignatureForSelector:sel];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
  [invocation setSelector:sel];
  [invocation setTarget:target];
  [invocation setArgument:&self atIndex:2];
  [invocation setArgument:&bytesWritten atIndex:3];
  [invocation setArgument:&totalBytesWritten atIndex:4];
  [invocation setArgument:&totalBytesExpectedToWrite atIndex:5];
  [invocation invoke];
}

- (BOOL)invokeRetryCallback:(SEL)sel
                     target:(id)target
                  willRetry:(BOOL)willRetry
                      error:(NSError *)error {
  NSMethodSignature *sig = [target methodSignatureForSelector:sel];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
  [invocation setSelector:sel];
  [invocation setTarget:target];
  [invocation setArgument:&self atIndex:2];
  [invocation setArgument:&willRetry atIndex:3];
  [invocation setArgument:&error atIndex:4];
  [invocation invoke];

  [invocation getReturnValue:&willRetry];
  return willRetry;
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {

  SEL sel = [self sentDataSelector];
  if (delegate_ && sel) {
    [self invokeSentDataCallback:sel
                          target:delegate_
                 didSendBodyData:bytesWritten
               totalBytesWritten:totalBytesWritten
       totalBytesExpectedToWrite:totalBytesExpectedToWrite];
  }

#if NS_BLOCKS_AVAILABLE
  if (sentDataBlock_) {
    sentDataBlock_(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
  }
#endif
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
#if DEBUG
  // the download file handle should be set before the fetch is started, not
  // after
  NSAssert((downloadFileHandle_ == nil) != (downloadedData_ == nil),
           @"received data accumulates as NSData or NSFileHandle, not both");
#endif

  if (downloadFileHandle_ != nil) {
    // append to file
    @try {
      [downloadFileHandle_ writeData:data];
    }
    @catch (NSException *exc) {
      // couldn't write to file, probably due to a full disk
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[exc reason]
                                                           forKey:NSLocalizedDescriptionKey];
      NSError *error = [NSError errorWithDomain:kGTMHTTPFetcherStatusDomain
                                           code:kGTMHTTPFetcherErrorFileHandleException
                                       userInfo:userInfo];
      [self connection:connection didFailWithError:error];
      return;
    }
  } else {
    // append to mutable data
    [downloadedData_ appendData:data];
  }

  if (receivedDataSEL_) {
    [delegate_ performSelector:receivedDataSEL_
                    withObject:self
                    withObject:downloadedData_];
  }

#if NS_BLOCKS_AVAILABLE
  if (receivedDataBlock_) {
    receivedDataBlock_(downloadedData_);
  }
#endif
}


// For error 304's ("Not Modified") where we've cached the data, return
// status 200 ("OK") to the caller (but leave the fetcher status as 304)
// and copy the cached data.
//
// For other errors or if there's no cached data, just return the actual status.
- (NSInteger)statusAfterHandlingNotModifiedError {

  NSInteger status = [self statusCode];
  if (status == kGTMHTTPFetcherStatusNotModified
      && [fetchHistory_ shouldCacheETaggedData]) {

    NSData *cachedData = [fetchHistory_ cachedDataForRequest:request_];
    if (cachedData) {
      // forge the status to pass on to the delegate
      status = 200;

      // copy our stored data
      if (downloadFileHandle_ != nil) {
        @try {
          // Downloading to a file handle won't save to the cache (the data is
          // likely inappropriately large for caching), but will still read from
          // the cache, on the unlikely chance that the response was Not Modified
          // and the URL response was indeed present in the cache.
          [downloadFileHandle_ truncateFileAtOffset:0];
          [downloadFileHandle_ writeData:cachedData];
        }
        @catch (NSException *) {
          // Failed to write data, likely due to lack of disk space
          status = kGTMHTTPFetcherErrorFileHandleException;
        }
      } else {
        [downloadedData_ setData:cachedData];
      }
    }
  }
  return status;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  // we no longer need to cancel the connection
  hasConnectionEnded_ = YES;

  // skip caching ETagged results when the data is being saved to a file
  if (downloadFileHandle_ == nil) {
    [fetchHistory_ updateFetchHistoryWithRequest:request_
                                        response:response_
                                  downloadedData:downloadedData_];
  } else {
    [fetchHistory_ removeCachedDataForRequest:request_];
  }

  [[self retain] autorelease]; // in case the callback releases us

  [self logNowWithError:nil];

  NSInteger status = [self statusAfterHandlingNotModifiedError];

  // we want to send the stop notification before calling the delegate's
  // callback selector, since the callback selector may release all of
  // the fetcher properties that the client is using to track the fetches
  //
  // We'll also stop now so that, to any observers watching the notifications,
  // it doesn't look like our wait for a retry (which may be long,
  // 30 seconds or more) is part of the network activity
  [self sendStopNotificationIfNeeded];

  BOOL shouldStopFetching = YES;
  NSError *error = nil;

  if (status >= 0 && status < 300) {
    // success
  } else {
    // status over 300; retry or notify the delegate of failure
    if ([self shouldRetryNowForStatus:status error:nil]) {
      // retrying
      [self beginRetryTimer];
      shouldStopFetching = NO;
    } else {
      error = [NSError errorWithDomain:kGTMHTTPFetcherStatusDomain
                                  code:status
                              userInfo:nil];
    }
  }

  if (shouldStopFetching) {
    // call the callbacks
    if (finishedSEL_) {
      [self invokeFetchCallback:finishedSEL_
                         target:delegate_
                           data:downloadedData_
                          error:error];
    }

#if NS_BLOCKS_AVAILABLE
    if (completionBlock_) {
      completionBlock_(downloadedData_, error);
    }
#endif

    BOOL shouldRelease = [self shouldReleaseCallbacksUponCompletion];
    [self stopFetchReleasingCallbacks:shouldRelease];
  }
}

- (BOOL)shouldReleaseCallbacksUponCompletion {
  // a subclass can override this to keep callbacks around after the
  // connection has finished successfully
  return YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  // prevent the failure callback from being called twice, since the stopFetch
  // call below (either the explicit one at the end of this method, or the
  // implicit one when the retry occurs) will release the delegate
  if (connection_ == nil) return;

  // if this method was invoked indirectly by cancellation of an authentication
  // challenge, defer this until it is called again with the proper error object
  if (isCancellingChallenge_) return;

  // we no longer need to cancel the connection
  hasConnectionEnded_ = YES;

  [self logNowWithError:error];

  // see comment about sendStopNotificationIfNeeded
  // in connectionDidFinishLoading:
  [self sendStopNotificationIfNeeded];

  if ([self shouldRetryNowForStatus:0 error:error]) {

    [self beginRetryTimer];

  } else {

    [[self retain] autorelease]; // in case the callback releases us

    if (finishedSEL_) {
      [self invokeFetchCallback:finishedSEL_
                         target:delegate_
                           data:nil
                          error:error];
    }

#if NS_BLOCKS_AVAILABLE
    if (completionBlock_) {
      completionBlock_(nil, error);
    }
#endif

    [self stopFetchReleasingCallbacks:YES];
  }
}

- (void)logNowWithError:(NSError *)error {
  // if the logging category is available, then log the current request,
  // response, data, and error
  if ([self respondsToSelector:@selector(logFetchWithError:)]) {
    [self performSelector:@selector(logFetchWithError:) withObject:error];
  }
}

#pragma mark Retries

- (BOOL)isRetryError:(NSError *)error {

  struct retryRecord {
    NSString *const domain;
    int code;
  };

  // Previously we also retried for
  //   { NSURLErrorDomain, NSURLErrorNetworkConnectionLost }
  // but at least on 10.4, once that happened, retries would keep failing
  // with the same error.

  struct retryRecord retries[] = {
    { kGTMHTTPFetcherStatusDomain, 408 }, // request timeout
    { kGTMHTTPFetcherStatusDomain, 503 }, // service unavailable
    { kGTMHTTPFetcherStatusDomain, 504 }, // request timeout
    { NSURLErrorDomain, NSURLErrorTimedOut },
    { nil, 0 }
  };

  // NSError's isEqual always returns false for equal but distinct instances
  // of NSError, so we have to compare the domain and code values explicitly

  for (int idx = 0; retries[idx].domain != nil; idx++) {

    if ([[error domain] isEqual:retries[idx].domain]
        && [error code] == retries[idx].code) {

      return YES;
    }
  }
  return NO;
}


// shouldRetryNowForStatus:error: returns YES if the user has enabled retries
// and the status or error is one that is suitable for retrying.  "Suitable"
// means either the isRetryError:'s list contains the status or error, or the
// user's retrySelector: is present and returns YES when called.
- (BOOL)shouldRetryNowForStatus:(NSInteger)status
                          error:(NSError *)error {

  if ([self isRetryEnabled]) {

    if ([self nextRetryInterval] < [self maxRetryInterval]) {

      if (error == nil) {
        // make an error for the status
       error = [NSError errorWithDomain:kGTMHTTPFetcherStatusDomain
                                   code:status
                               userInfo:nil];
      }

      BOOL willRetry = [self isRetryError:error];

      if (retrySEL_) {
        willRetry = [self invokeRetryCallback:retrySEL_
                                       target:delegate_
                                    willRetry:willRetry
                                        error:error];
      }

#if NS_BLOCKS_AVAILABLE
      if (retryBlock_) {
        willRetry = retryBlock_(willRetry, error);
      }
#endif

      return willRetry;
    }
  }

  return NO;
}

- (void)beginRetryTimer {

  NSTimeInterval nextInterval = [self nextRetryInterval];
  NSTimeInterval maxInterval = [self maxRetryInterval];

  NSTimeInterval newInterval = MIN(nextInterval, maxInterval);

  [self primeRetryTimerWithNewTimeInterval:newInterval];
}

- (void)primeRetryTimerWithNewTimeInterval:(NSTimeInterval)secs {

  [self destroyRetryTimer];

  lastRetryInterval_ = secs;

  retryTimer_ = [NSTimer scheduledTimerWithTimeInterval:secs
                                  target:self
                                selector:@selector(retryTimerFired:)
                                userInfo:nil
                                 repeats:NO];
  [retryTimer_ retain];

  NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
  [defaultNC postNotificationName:kGTMHTTPFetcherRetryDelayStartedNotification
                           object:self];
}

- (void)retryTimerFired:(NSTimer *)timer {

  [self destroyRetryTimer];

  retryCount_++;

  [self retryFetch];
}

- (void)destroyRetryTimer {
  if (retryTimer_) {
    [retryTimer_ invalidate];
    [retryTimer_ autorelease];
    retryTimer_ = nil;

    NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC postNotificationName:kGTMHTTPFetcherRetryDelayStoppedNotification
                             object:self];
  }
}

- (NSUInteger)retryCount {
  return retryCount_;
}

- (NSTimeInterval)nextRetryInterval {
  // the next wait interval is the factor (2.0) times the last interval,
  // but never less than the minimum interval
  NSTimeInterval secs = lastRetryInterval_ * retryFactor_;
  secs = MIN(secs, maxRetryInterval_);
  secs = MAX(secs, minRetryInterval_);

  return secs;
}

- (BOOL)isRetryEnabled {
  return isRetryEnabled_;
}

- (void)setRetryEnabled:(BOOL)flag {

  if (flag && !isRetryEnabled_) {
    // We defer initializing these until the user calls setRetryEnabled
    // to avoid using the random number generator if it's not needed.
    // However, this means min and max intervals for this fetcher are reset
    // as a side effect of calling setRetryEnabled.
    //
    // make an initial retry interval random between 1.0 and 2.0 seconds
    [self setMinRetryInterval:0.0];
    [self setMaxRetryInterval:kUnsetMaxRetryInterval];
    [self setRetryFactor:2.0];
    lastRetryInterval_ = 0.0;
  }
  isRetryEnabled_ = flag;
};

#if NS_BLOCKS_AVAILABLE
- (void)setRetryBlock:(BOOL (^)(BOOL, NSError *))block {
  [retryBlock_ autorelease];
  retryBlock_ = [block copy];
}
#endif

- (NSTimeInterval)maxRetryInterval {
  return maxRetryInterval_;
}

- (void)setMaxRetryInterval:(NSTimeInterval)secs {
  if (secs > 0) {
    maxRetryInterval_ = secs;
  } else {
    maxRetryInterval_ = kUnsetMaxRetryInterval;
  }
}

- (double)minRetryInterval {
  return minRetryInterval_;
}

- (void)setMinRetryInterval:(NSTimeInterval)secs {
  if (secs > 0) {
    minRetryInterval_ = secs;
  } else {
    // set min interval to a random value between 1.0 and 2.0 seconds
    // so that if multiple clients start retrying at the same time, they'll
    // repeat at different times and avoid overloading the server
    minRetryInterval_ = 1.0 + ((double)(arc4random() & 0x0FFFF) / (double) 0x0FFFF);
  }
}

#pragma mark Getters and Setters

@dynamic cookieStorageMethod;
@dynamic retryEnabled;
@dynamic maxRetryInterval;
@dynamic minRetryInterval;
@dynamic retryCount;
@dynamic nextRetryInterval;
@dynamic statusCode;
@dynamic responseHeaders;
@dynamic fetchHistory;
@dynamic userData;
@dynamic properties;

@synthesize mutableRequest = request_;
@synthesize credential = credential_;
@synthesize proxyCredential = proxyCredential_;
@synthesize postData = postData_;
@synthesize postStream = postStream_;
@synthesize delegate = delegate_;
@synthesize sentDataSelector = sentDataSEL_;
@synthesize receivedDataSelector = receivedDataSEL_;
@synthesize retrySelector = retrySEL_;
@synthesize retryFactor = retryFactor_;
@synthesize response = response_;
@synthesize downloadedData = downloadedData_;
@synthesize downloadFileHandle = downloadFileHandle_;
@synthesize runLoopModes = runLoopModes_;

- (NSInteger)cookieStorageMethod {
  return cookieStorageMethod_;
}

- (void)setCookieStorageMethod:(NSInteger)method {

  cookieStorageMethod_ = method;

  if (method == kGTMHTTPFetcherCookieStorageMethodSystemDefault) {
    // system default
    [request_ setHTTPShouldHandleCookies:YES];

    // no need for a cookie storage object
    [self setCookieStorage:nil];

  } else {
    // not system default
    [request_ setHTTPShouldHandleCookies:NO];

    if (method == kGTMHTTPFetcherCookieStorageMethodStatic) {
      // store cookies in the static array
      [self setCookieStorage:gGTMFetcherStaticCookieStorage];
    } else if (method == kGTMHTTPFetcherCookieStorageMethodFetchHistory) {
      // store cookies in the fetch history
      [self setCookieStorage:[fetchHistory_ cookieStorage]];
    } else {
      // kGTMHTTPFetcherCookieStorageMethodNone - ignore cookies
      [self setCookieStorage:nil];
    }
  }
}

+ (BOOL)doesSupportSentDataCallback {
#if GTM_IPHONE
  // NSURLConnection's didSendBodyData: delegate support appears to be
  // available starting in iPhone OS 3.0
  return (NSFoundationVersionNumber >= 678.47);
#else
  // per WebKit's MaxFoundationVersionWithoutdidSendBodyDataDelegate
  //
  // indicates if NSURLConnection will invoke the didSendBodyData: delegate
  // method
  return (NSFoundationVersionNumber > 677.21);
#endif
}

#if NS_BLOCKS_AVAILABLE
- (void)setSentDataBlock:(void (^)(NSInteger, NSInteger, NSInteger))block {
  [sentDataBlock_ autorelease];
  sentDataBlock_ = [block copy];
}

- (void)setReceivedDataBlock:(void (^)(NSData *))block {
  [receivedDataBlock_ autorelease];
  receivedDataBlock_ = [block copy];
}
#endif

- (id <GTMHTTPFetchHistoryProtocol>)fetchHistory {
  return fetchHistory_;
}

- (void)setFetchHistory:(id <GTMHTTPFetchHistoryProtocol>)fetchHistory {
  [fetchHistory_ autorelease];
  fetchHistory_ = [fetchHistory retain];

  if (fetchHistory_ != nil) {
    // set the fetch history's cookie array to be the cookie store
    [self setCookieStorageMethod:kGTMHTTPFetcherCookieStorageMethodFetchHistory];

  } else {
    // the fetch history was removed
    if (cookieStorageMethod_ == kGTMHTTPFetcherCookieStorageMethodFetchHistory) {
      // fall back to static storage
      [self setCookieStorageMethod:kGTMHTTPFetcherCookieStorageMethodStatic];
    }
  }
}

- (void)setCookieStorage:(id <GTMCookieStorageProtocol>)obj {
  [cookieStorage_ autorelease];
  cookieStorage_ = [obj retain];
}

- (id <GTMCookieStorageProtocol>)cookieStorage {
  return cookieStorage_;
}

- (id)userData {
  return userData_;
}

- (void)setUserData:(id)theObj {
  [userData_ autorelease];
  userData_ = [theObj retain];
}

- (void)setProperties:(NSDictionary *)dict {
  [properties_ autorelease];
  properties_ = [dict mutableCopy];
}

- (NSDictionary *)properties {
  return properties_;
}

- (void)setProperty:(id)obj forKey:(NSString *)key {

  if (properties_ == nil && obj != nil) {
    [self setProperties:[NSDictionary dictionary]];
  }

  [properties_ setValue:obj forKey:key];
}

- (id)propertyForKey:(NSString *)key {
  return [properties_ objectForKey:key];
}

- (void)addPropertiesFromDictionary:(NSDictionary *)dict {
  if (properties_ == nil && dict != nil) {
    [self setProperties:dict];
  } else {
    [properties_ addEntriesFromDictionary:dict];
  }
}

+ (Class)connectionClass {
  if (gGTMFetcherConnectionClass == nil) {
    gGTMFetcherConnectionClass = [NSURLConnection class];
  }
  return gGTMFetcherConnectionClass;
}

+ (void)setConnectionClass:(Class)theClass {
  gGTMFetcherConnectionClass = theClass;
}

#if STRIP_GTM_FETCH_LOGGING
+ (void)setLoggingEnabled:(BOOL)flag {
}
#endif // STRIP_GTM_FETCH_LOGGING

@end

#ifdef GTM_FOUNDATION_ONLY
#define Debugger()
#endif

void AssertSelectorNilOrImplementedWithArguments(id obj, SEL sel, ...) {

  // verify that the object's selector is implemented with the proper
  // number and type of arguments
#if DEBUG
  va_list argList;
  va_start(argList, sel);

  if (obj && sel) {
    // check that the selector is implemented
    if (![obj respondsToSelector:sel]) {
      NSLog(@"\"%@\" selector \"%@\" is unimplemented or misnamed",
                             NSStringFromClass([obj class]),
                             NSStringFromSelector(sel));
      Debugger();
    } else {
      const char *expectedArgType;
      unsigned int argCount = 2; // skip self and _cmd
      NSMethodSignature *sig = [obj methodSignatureForSelector:sel];

      // check that each expected argument is present and of the correct type
      while ((expectedArgType = va_arg(argList, const char*)) != 0) {

        if ([sig numberOfArguments] > argCount) {
          const char *foundArgType = [sig getArgumentTypeAtIndex:argCount];

          if(0 != strncmp(foundArgType, expectedArgType, strlen(expectedArgType))) {
            NSLog(@"\"%@\" selector \"%@\" argument %d should be type %s",
                  NSStringFromClass([obj class]),
                  NSStringFromSelector(sel), (argCount - 2), expectedArgType);
            Debugger();
          }
        }
        argCount++;
      }

      // check that the proper number of arguments are present in the selector
      if (argCount != [sig numberOfArguments]) {
        NSLog( @"\"%@\" selector \"%@\" should have %d arguments",
                       NSStringFromClass([obj class]),
                       NSStringFromSelector(sel), (argCount - 2));
        Debugger();
      }
    }
  }

  va_end(argList);
#endif
}
