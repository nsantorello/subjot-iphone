//
//  RequestBase.m
//  Aditlo
//
//  Created by Noah Santorello on 2/19/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "RequestBase.h"
#import "ResponseBase.h"
#import "GTMHTTPFetcher.h"

@implementation RequestBase

@synthesize delegate;

- (id)initWithDelegate:(id)del
{
	self = [self init];
	self.delegate = del;
	return self;
}

- (void)requestFinished:(ResponseBase*)response
{
	if ([delegate respondsToSelector:@selector(requestFinishedBase:)])
	{
		[delegate performSelector:@selector(requestFinishedBase:) withObject:response];
	}
}

- (void)requestFailed:(NSString*)errorString
{
	if ([delegate respondsToSelector:@selector(requestFailed:)])
	{
		[delegate performSelector:@selector(requestFailed:)];
	}
}



- (void)requestFinishedBase:(NSData*)dledData
{
	// Convert to NSDictionary.
	
	// Check to see if there was an API error.
	
	// Notify subclasses of success.
	if ([delegate respondsToSelector:@selector(requestFinished:)])
	{
		[delegate performSelector:@selector(requestFinished:) withObject:dledData];
	}
}

- (void)fetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *) retrievedData error:(NSError *)error {
	if (!error) 
	{
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary* result = [parser objectWithData:retrievedData];
		if (result) 
		{
			// Invalidly-formatted plist returned.
			[self requestFailed:@"Invalid JSON returned from API."];
			return;
		}
        
        ResponseBase* response = [[NSClassFromString(responseClass) alloc] init];
        [response setData:result];
        
        if (response.succeeded)
        {
            [self requestFinished:response];
        }
        else
        {
            [self requestFailed:response.errorString];
        }
	} 
	else 
	{
		// Error related to the network connection.  (e.g. invalid SSL cert, dropped connection, etc)
		[self requestFailed:[error localizedDescription]];
	}
}

- (void)beginRequestWithURL:(NSURL*)url andDelegate:(id)del andPostData:(NSString*)postData
{
#ifdef LIVE_API
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
	if (postData)
	{
		[fetcher setPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(fetcher:finishedWithData:error:)];
#else
    NSData* fileContents = [NSData dataWithContentsOfURL:url];
    [self fetcher:nil finishedWithData:fileContents error:nil];
#endif
}

- (void)beginRequestWithURL:(NSURL*)url andDelegate:(id)del
{
	[self beginRequestWithURL:url andDelegate:del andPostData:nil];
}

@end
