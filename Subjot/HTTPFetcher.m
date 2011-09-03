//
//  HTTPFetcher.m
//  AuditionBooth
//
//  Created by Noah Santorello on 2/23/11.
//  Copyright 2011 AuditionBooth LLC. All rights reserved.
//

#import "HTTPFetcher.h"
#import "ResponseBase.h"

@implementation HTTPFetcher

@synthesize delegate;

+ (void)beginRequestWithURL:(NSURL*)url andDelegate:(id)del andPostData:(NSString*)postData
{
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
	if (postData)
	{
		[fetcher setPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(fetcher:finishedWithData:error:)];
}

+ (void)beginRequestWithURL:(NSURL*)url andDelegate:(id)del
{
	[self beginRequestWithURL:url andDelegate:del andPostData:nil];
}

- (NSDictionary *)dictionaryFromData:(NSData *)data errorString:(NSString**)errorString
{
	NSDictionary *result = [NSDictionary dictionaryWithDictionary:[NSPropertyListSerialization propertyListFromData:data 
																								   mutabilityOption:NSPropertyListImmutable 
																											 format:nil 
																								   errorDescription:errorString]];
	return result;
}


- (void)requestFinished:(NSData*)data
{
	if ([delegate respondsToSelector:@selector(requestFinishedBase:)])
	{
		[delegate performSelector:@selector(requestFinishedBase:) withObject:data];
	}
}

- (void)requestFailed:(NSString*)errorString
{
	if ([delegate respondsToSelector:@selector(requestFailed:)])
	{
		[delegate performSelector:@selector(requestFailed:)];
	}
}

- (void)fetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *) retrievedData error:(NSError *)error {
	if (!error) 
	{
		NSString *errorString = nil;
		NSDictionary *result = [self dictionaryFromData:retrievedData errorString:&errorString];
		if (errorString) 
		{
			// Invalidly-formatted plist returned.
			[self requestFailed:@"Invalidly formatted API result."];
			return;
		}
		
        ResponseBase* response;
        
		if (response.succeeded)
		{
			
		}
		else
		{
            // If it didn't succeed, report the error from the API.
			[self requestFailed:response.errorString];
		}
	} 
	else 
	{
		// Error related to the network connection.  (e.g. invalid SSL cert, dropped connection, etc)
		[self requestFailed:[error localizedDescription]];
	}
}

@end
