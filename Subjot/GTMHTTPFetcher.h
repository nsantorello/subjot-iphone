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
//  GTMHTTPFetcher.h
//

// This is essentially a wrapper around NSURLConnection for POSTs and GETs.
// If setPostData: is called, then POST is assumed.
//
// When would you use this instead of NSURLConnection?
//
// - When you just want the result from a GET or POST
// - When you want the "standard" behavior for connections (redirection handling
//   an so on)
// - When you want automatic retry on failures
// - When you want to avoid cookie collisions with Safari and other applications
// - When you are fetching resources with ETags and want to avoid the overhead
//   of repeated fetches of unchanged data
// - When you need to set a credential for the http operation
//
// This is assumed to be a one-shot fetch request; don't reuse the object
// for a second fetch.
//
// The fetcher may be created auto-released, in which case it will release
// itself after the fetch completion callback.  The fetcher
// is implicitly retained as long as a connection is pending.
//
// But if you may need to cancel the fetcher, allocate it with initWithRequest:
// and have the delegate release the fetcher in the callbacks.
//
// Sample usage:
//
//  NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
//  GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
//
//  // optional post data
//  [myFetcher setPostData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
//
//  [myFetcher beginFetchWithDelegate:self
//                  didFinishSelector:@selector(myFetcher:finishedWithData:error:)];
//
//  Upon fetch completion, the callback selector is invoked; it should have
//  this signature (you can use any callback method name you want so long as
//  the signature matches this):
//
//  - (void)myFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error;
//
//  The block callback version looks like:
//
//  [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
//    if (error != nil) {
//      // status code or network error
//    } else {
//      // succeeded
//    }
//  }];

//
// NOTE:  Fetches may retrieve data from the server even though the server
//        returned an error.  The failure selector is called when the server
//        status is >= 300, with an NSError having domain
//        kGTMHTTPFetcherStatusDomain and code set to the server status.
//
//        Status codes are at <http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html>
//
//
// Proxies:
//
// Proxy handling is invisible so long as the system has a valid credential in
// the keychain, which is normally true (else most NSURL-based apps would have
// difficulty.)  But when there is a proxy authetication error, the the fetcher
// will call the failedWithError: method with the NSURLChallenge in the error's
// userInfo. The error method can get the challenge info like this:
//
//  NSURLAuthenticationChallenge *challenge
//     = [[error userInfo] objectForKey:kGTMHTTPFetcherErrorChallengeKey];
//  BOOL isProxyChallenge = [[challenge protectionSpace] isProxy];
//
// If a proxy error occurs, you can ask the user for the proxy username/password
// and call fetcher's setProxyCredential: to provide those for the
// next attempt to fetch.
//
//
// Cookies:
//
// There are three supported mechanisms for remembering cookies between fetches.
//
// By default, GTMHTTPFetcher uses a mutable array held statically to track
// cookies for all instantiated fetchers. This avoids server cookies being set
// by servers for the application from interfering with Safari cookie settings,
// and vice versa.  The fetcher cookies are lost when the application quits.
//
// To rely instead on WebKit's global NSHTTPCookieStorage, call
// setCookieStorageMethod: with kGTMHTTPFetcherCookieStorageMethodSystemDefault.
//
// If the fetcher is created from a GTMHTTPFetcherService object
// then the cookie storage mechanism is set to use the cookie storage in the
// service object rather than the static storage.
//
//
// Fetching for periodic checks:
//
// The fetcher object tracks ETag headers from responses and
// provide an "If-None-Match" header. This allows the server to save
// bandwidth by providing a status message instead of repeated response
// data.
//
// To get this behavior, create the fetcher from an GTMHTTPFetcherService object
// and look for a fetch callback error with code 304
// (kGTMHTTPFetcherStatusNotModified) like this:
//
// - (void)myFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
//    if ([error code] == kGTMHTTPFetcherStatusNotModified) {
//      // |data| is empty; use the data from the previous finishedWithData: for this URL
//    } else {
//      // handle other server status code
//    }
// }
//
//
// Monitoring received data
//
// The optional received data selector can be set with setReceivedDataSelector:
// and should have the signature
//
//  - (void)myFetcher:(GTMHTTPFetcher *)fetcher receivedData:(NSData *)dataReceivedSoFar;
//
// The bytes received so far are [dataReceivedSoFar length]. This number may go
// down if a redirect causes the download to begin again from a new server.
//
// If supplied by the server, the anticipated total download size is available as
//    [[myFetcher response] expectedContentLength] (may be -1 for unknown
//    download sizes.)
//
//
// Automatic retrying of fetches
//
// The fetcher can optionally create a timer and reattempt certain kinds of
// fetch failures (status codes 408, request timeout; 503, service unavailable;
// 504, gateway timeout; networking errors NSURLErrorTimedOut and
// NSURLErrorNetworkConnectionLost.)  The user may set a retry selector to
// customize the type of errors which will be retried.
//
// Retries are done in an exponential-backoff fashion (that is, after 1 second,
// 2, 4, 8, and so on.)
//
// Enabling automatic retries looks like this:
//  [myFetcher setRetryEnabled:YES];
//
// With retries enabled, the success or failure callbacks are called only
// when no more retries will be attempted. Calling the fetcher's stopFetching
// method will terminate the retry timer, without the finished or failure
// selectors being invoked.
//
// Optionally, the client may set the maximum retry interval:
//  [myFetcher setMaxRetryInterval:60.0]; // in seconds; default is 60 seconds
//                                        // for downloads, 600 for uploads
//
// Also optionally, the client may provide a callback selector to determine
// if a status code or other error should be retried.
//  [myFetcher setRetrySelector:@selector(myFetcher:willRetry:forError:)];
//
// If set, the retry selector should have the signature:
//   -(BOOL)fetcher:(GTMHTTPFetcher *)fetcher willRetry:(BOOL)suggestedWillRetry forError:(NSError *)error
// and return YES to set the retry timer or NO to fail without additional
// fetch attempts.
//
// The retry method may return the |suggestedWillRetry| argument to get the
// default retry behavior.  Server status codes are present in the
// error argument, and have the domain kGTMHTTPFetcherStatusDomain. The
// user's method may look something like this:
//
//  -(BOOL)myFetcher:(GTMHTTPFetcher *)fetcher willRetry:(BOOL)suggestedWillRetry forError:(NSError *)error {
//
//    // perhaps examine [error domain] and [error code], or [fetcher retryCount]
//    //
//    // return YES to start the retry timer, NO to proceed to the failure
//    // callback, or |suggestedWillRetry| to get default behavior for the
//    // current error domain and code values.
//    return suggestedWillRetry;
//  }



#pragma once

#import <Foundation/Foundation.h>

#if defined(GTL_TARGET_NAMESPACE)
  // we're using target namespace macros
  #import "GTLDefines.h"
#else
  #if TARGET_OS_IPHONE
    #ifndef GTM_FOUNDATION_ONLY
      #define GTM_FOUNDATION_ONLY 1
    #endif
    #ifndef GTM_IPHONE
      #define GTM_IPHONE 1
    #endif
  #endif
#endif


#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GTMHTTPFETCHER_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// notifications
//
// fetch started and stopped, and fetch retry delay started and stopped
_EXTERN NSString* const kGTMHTTPFetcherStartedNotification           _INITIALIZE_AS(@"kGTMHTTPFetcherStartedNotification");
_EXTERN NSString* const kGTMHTTPFetcherStoppedNotification           _INITIALIZE_AS(@"kGTMHTTPFetcherStoppedNotification");
_EXTERN NSString* const kGTMHTTPFetcherRetryDelayStartedNotification _INITIALIZE_AS(@"kGTMHTTPFetcherRetryDelayStartedNotification");
_EXTERN NSString* const kGTMHTTPFetcherRetryDelayStoppedNotification _INITIALIZE_AS(@"kGTMHTTPFetcherRetryDelayStoppedNotification");

// callback constants
_EXTERN NSString* const kGTMHTTPFetcherErrorDomain       _INITIALIZE_AS(@"com.google.GTMHTTPFetcher");
_EXTERN NSString* const kGTMHTTPFetcherStatusDomain      _INITIALIZE_AS(@"com.google.HTTPStatus");
_EXTERN NSString* const kGTMHTTPFetcherErrorChallengeKey _INITIALIZE_AS(@"challenge");
_EXTERN NSString* const kGTMHTTPFetcherStatusDataKey     _INITIALIZE_AS(@"data");                        // data returned with a kGTMHTTPFetcherStatusDomain error

enum {
  kGTMHTTPFetcherErrorDownloadFailed = -1,
  kGTMHTTPFetcherErrorAuthenticationChallengeFailed = -2,
  kGTMHTTPFetcherErrorChunkUploadFailed = -3,
  kGTMHTTPFetcherErrorFileHandleException = -4,

  kGTMHTTPFetcherStatusNotModified = 304,
  kGTMHTTPFetcherStatusPreconditionFailed = 412
};

// cookie storage methods
enum {
  kGTMHTTPFetcherCookieStorageMethodStatic = 0,
  kGTMHTTPFetcherCookieStorageMethodFetchHistory = 1,
  kGTMHTTPFetcherCookieStorageMethodSystemDefault = 2,
  kGTMHTTPFetcherCookieStorageMethodNone = 3
};

void AssertSelectorNilOrImplementedWithArguments(id obj, SEL sel, ...);

@protocol GTMCookieStorageProtocol <NSObject>
- (NSArray *)cookiesForURL:(NSURL *)theURL;
- (void)setCookies:(NSArray *)newCookies;
@end

@protocol GTMHTTPFetchHistoryProtocol <NSObject>
- (void)updateRequest:(NSMutableURLRequest *)request isHTTPGet:(BOOL)isHTTPGet;
- (BOOL)shouldCacheETaggedData;
- (NSData *)cachedDataForRequest:(NSURLRequest *)request;
- (id <GTMCookieStorageProtocol>)cookieStorage;
- (void)updateFetchHistoryWithRequest:(NSURLRequest *)request
                             response:(NSURLResponse *)response
                       downloadedData:(NSData *)downloadedData;
- (void)removeCachedDataForRequest:(NSURLRequest *)request;
@end

// async retrieval of an http get or post
@interface GTMHTTPFetcher : NSObject {
 @protected
  NSMutableURLRequest *request_;
  NSURLConnection *connection_;
  NSMutableData *downloadedData_;
  NSFileHandle *downloadFileHandle_;
  NSURLCredential *credential_;     // username & password
  NSURLCredential *proxyCredential_; // credential supplied to proxy servers
  NSData *postData_;
  NSInputStream *postStream_;
  NSMutableData *loggedStreamData_;
  NSURLResponse *response_;         // set in connection:didReceiveResponse:
  id delegate_;
  SEL finishedSEL_;                 // should by implemented by delegate
  SEL sentDataSEL_;                 // optional, set with setSentDataSelector
  SEL receivedDataSEL_;             // optional, set with setReceivedDataSelector
#if NS_BLOCKS_AVAILABLE
  void (^completionBlock_)(NSData *, NSError *);
  void (^receivedDataBlock_)(NSData *);
  void (^sentDataBlock_)(NSInteger, NSInteger, NSInteger);
  BOOL (^retryBlock_)(BOOL, NSError *);
#elif !__LP64__
  // placeholders: for 32-bit builds, keep the size of the object's ivar section
  // the same with and without blocks
  id completionPlaceholder_;
  id receivedDataPlaceholder_;
  id sentDataPlaceholder_;
  id retryPlaceholder_;
#endif
  BOOL hasConnectionEnded_;         // set if the connection need not be cancelled
  BOOL isCancellingChallenge_;      // set only when cancelling an auth challenge
  BOOL isStopNotificationNeeded_;   // set when start notification has been sent
  id userData_;                     // retained, if set by caller
  NSMutableDictionary *properties_; // more data retained for caller
  NSArray *runLoopModes_;           // optional, for 10.5 and later
  id <GTMHTTPFetchHistoryProtocol> fetchHistory_; // if supplied by the caller, used for Last-Modified-Since checks and cookies
  NSInteger cookieStorageMethod_;   // constant from above
  id <GTMCookieStorageProtocol> cookieStorage_;

  BOOL isRetryEnabled_;             // user wants auto-retry
  SEL retrySEL_;                    // optional; set with setRetrySelector
  NSTimer *retryTimer_;
  NSUInteger retryCount_;
  NSTimeInterval maxRetryInterval_; // default 600 seconds
  NSTimeInterval minRetryInterval_; // random between 1 and 2 seconds
  NSTimeInterval retryFactor_;      // default interval multiplier is 2
  NSTimeInterval lastRetryInterval_;
}

// create a fetcher
//
// fetcherWithRequest will return an autoreleased fetcher, but if
// the connection is successfully created, the connection should retain the
// fetcher for the life of the connection as well. So the caller doesn't have
// to retain the fetcher explicitly unless they want to be able to cancel it.
+ (GTMHTTPFetcher *)fetcherWithRequest:(NSURLRequest *)request;

// designated initializer
- (id)initWithRequest:(NSURLRequest *)request;

// fetcher request
//
// the underlying request is mutable and may be modified by the caller
@property (retain) NSMutableURLRequest *mutableRequest;

// setting the credential is optional; it is used if the connection receives
// an authentication challenge
@property (retain) NSURLCredential *credential;

// setting the proxy credential is optional; it is used if the connection
// receives an authentication challenge from a proxy
@property (retain) NSURLCredential *proxyCredential;

// if post data or stream is not set, then a GET retrieval method is assumed
@property (retain) NSData *postData;
@property (retain) NSInputStream *postStream;

// the default cookie storage method is kGTMHTTPFetcherCookieStorageMethodStatic
// without a fetch history set, and kGTMHTTPFetcherCookieStorageMethodFetchHistory
// with a fetch history set
@property (assign) NSInteger cookieStorageMethod;

// the delegate is retained during the connection
@property (retain) id delegate;

// the delegate's optional sentData selector has a signature like:
//  - (void)myFetcher:(GTMHTTPFetcher *)fetcher
//              didSendBytes:(NSInteger)bytesSent
//            totalBytesSent:(NSInteger)totalBytesSent
//  totalBytesExpectedToSend:(NSInteger)totalBytesExpectedToSend;
//
// +doesSupportSentDataCallback indicates if this delegate method is supported
+ (BOOL)doesSupportSentDataCallback;

@property (assign) SEL sentDataSelector;

// the delegate's optional receivedData selector has a signature like:
//  - (void)myFetcher:(GTMHTTPFetcher *)fetcher receivedData:(NSData *)dataReceivedSoFar;
//
// The dataReceived argument will be nil when downloading to a file handle
@property (assign) SEL receivedDataSelector;

#if NS_BLOCKS_AVAILABLE
// the full interface to the block is provided rather than just a typedef for
// its parameter list in order to get more useful code completion in the Xcode
// editor
- (void)setSentDataBlock:(void (^)(NSInteger bytesSent, NSInteger totalBytesSent, NSInteger bytesExpectedToSend))block;

// The dataReceived argument will be nil when downloading to a file handle
- (void)setReceivedDataBlock:(void (^)(NSData *dataReceivedSoFar))block;
#endif

// retrying; see comments at the top of the file.  Calling
// setRetryEnabled(YES) resets the min and max retry intervals.
@property (assign, getter=isRetryEnabled) BOOL retryEnabled;

// retry selector or block is optional for retries.
//
// If present, it should have the signature:
//   -(BOOL)fetcher:(GTMHTTPFetcher *)fetcher willRetry:(BOOL)suggestedWillRetry forError:(NSError *)error
// and return YES to cause a retry.  See comments at the top of this file.
@property (assign) SEL retrySelector;

#if NS_BLOCKS_AVAILABLE
- (void)setRetryBlock:(BOOL (^)(BOOL suggestedWillRetry, NSError *error))block;
#endif

// retry intervals must be strictly less than maxRetryInterval, else
// they will be limited to maxRetryInterval and no further retries will
// be attempted.  Setting maxRetryInterval to 0.0 will reset it to the
// default value, 600 seconds.

@property (assign) NSTimeInterval maxRetryInterval;

// Starting retry interval.  Setting minRetryInterval to 0.0 will reset it
// to a random value between 1.0 and 2.0 seconds.  Clients should normally not
// call this except for unit testing.
@property (assign) NSTimeInterval minRetryInterval;

// Multiplier used to increase the interval between retries, typically 2.0.
// Clients should not need to call this.
@property (assign) double retryFactor;

// number of retries attempted
@property (readonly) NSUInteger retryCount;

// interval delay to precede next retry
@property (readonly) NSTimeInterval nextRetryInterval;

// Begin fetching the request
//
// The delegate can optionally implement the finished selectors or pass NULL
// for it.
//
// Returns YES if the fetch is initiated.  The delegate is retained between
// the beginFetch call until after the finish callback.
//
// An error is passed to the callback for server statuses 300 or
// higher, with the status stored as the error object's code.
//
// finishedSEL has a signature like:
//   - (void)fetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;
//

- (BOOL)beginFetchWithDelegate:(id)delegate
             didFinishSelector:(SEL)finishedSEL;

#if NS_BLOCKS_AVAILABLE
- (BOOL)beginFetchWithCompletionHandler:(void (^)(NSData *data, NSError *error))handler;
#endif


// Returns YES if this is in the process of fetching a URL
- (BOOL)isFetching;

// Cancel the fetch of the request that's currently in progress
- (void)stopFetching;

// return the status code from the server response
@property (readonly) NSInteger statusCode;

// return the http headers from the response
@property (retain, readonly) NSDictionary *responseHeaders;

// the response, once it's been received
@property (retain) NSURLResponse *response;

// buffer of currently-downloaded data
@property (readonly) NSData *downloadedData;

// if downloadFileHandle is set, data received is immediately appended to
// the file handle rather than being accumulated in the downloadedData property
//
// The file handle supplied must allow writing and support seekToFileOffset:,
// and must be set before downloading begins.
@property (retain) NSFileHandle *downloadFileHandle;

// if the caller supplies a mutable dictionary, it's used for Last-Modified-Since
//  checks and for cookie storage
//  side effect: setting fetch history implicitly calls setCookieStorageMethod:
@property (retain) id <GTMHTTPFetchHistoryProtocol> fetchHistory;

// userData is retained for the convenience of the caller
@property (retain) id userData;

// stored property values are retained for the convenience of the caller
@property (retain) NSDictionary *properties;

- (void)setProperty:(id)obj forKey:(NSString *)key; // pass nil obj to remove property
- (id)propertyForKey:(NSString *)key;

- (void)addPropertiesFromDictionary:(NSDictionary *)dict;

// using the fetcher while a modal dialog is displayed requires setting the
// run-loop modes to include NSModalPanelRunLoopMode
@property (retain) NSArray *runLoopModes;

// users who wish to replace GTMHTTPFetcher's use of NSURLConnection
// can do so globally here.  The replacement should be a subclass of
// NSURLConnection.
+ (Class)connectionClass;
+ (void)setConnectionClass:(Class)theClass;

#if STRIP_GTM_FETCH_LOGGING
// if logging is stripped, provide a stub for the main method
// for controlling logging
+ (void)setLoggingEnabled:(BOOL)flag;
#endif // STRIP_GTM_FETCH_LOGGING

@end
