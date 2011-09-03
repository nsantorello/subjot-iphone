//
//  ResponseBase.m
//  AuditionBooth
//
//  Created by Noah Santorello on 2/23/11.
//  Copyright 2011 AuditionBooth LLC. All rights reserved.
//

#import "ResponseBase.h"
#import "NSString+ParsedBool.h"

@implementation ResponseBase

@synthesize succeeded, errorString, apiVersion;

- (void)setData:(NSDictionary*)response
{
    responseData = [response retain];
    succeeded = [[response valueForKey:@"success"] boolValue];
    apiVersion = [response valueForKey:@"version"];
    errorString = [response valueForKey:@"error_string"];
}

- (void)dealloc
{
	errorString = apiVersion = nil;
    [responseData release];
	[super dealloc];
}

@end
