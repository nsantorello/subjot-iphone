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
#import "NSArray+Extensions.h"

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
	if ([delegate respondsToSelector:@selector(requestFinished:)])
	{
		[delegate performSelector:@selector(requestFinished:) withObject:response];
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
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary* result = [parser objectWithData:retrievedData];
		if (!result) 
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

+ (NSString*)postDataFromDict:(NSDictionary*)dict
{
    return (NSString*)[[dict allKeys] reduce:@"" fn:^id(id acc, id obj) {
        NSString* key = (NSString*)obj;
        return [NSString stringWithFormat:@"%@=%@&%@", key, [dict valueForKey:key], acc];
    }];
}

- (void)beginRequestWithURL:(NSURL*)url andDelegate:(id)del andPostData:(NSDictionary*)postData
{
#ifdef LIVE_API
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
	if (postData)
	{
		[fetcher setPostData:[[RequestBase postDataFromDict:postData] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(fetcher:finishedWithData:error:)];
#else
    NSError* error = nil;
    NSString* path = [[NSBundle mainBundle] pathForResource:[url lastPathComponent] ofType:@""];
    NSData* fileContents = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&error];
    NSString* postDataCheck = [RequestBase postDataFromDict:postData];
    if (error)
    {
        [self requestFailed:[error localizedDescription]];
        return;
    }
    [self fetcher:nil finishedWithData:fileContents error:nil];
#endif
}

- (void)beginRequestWithURL:(NSURL*)url andDelegate:(id)del
{
	[self beginRequestWithURL:url andDelegate:del andPostData:nil];
}

@end
