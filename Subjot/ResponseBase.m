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
    succeeded = TRUE;
    responseData = [response retain];
    errorString = [response valueForKey:@"error_string"];
}

- (void)dealloc
{
	errorString = apiVersion = nil;
    [responseData release];
	[super dealloc];
}

@end
