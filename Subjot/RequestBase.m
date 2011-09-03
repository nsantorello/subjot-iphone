//
//  RequestBase.m
//  Aditlo
//
//  Created by Noah Santorello on 2/19/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "RequestBase.h"


@implementation RequestBase

@synthesize delegate;

- (id)initWithDelegate:(id)del
{
	self = [self init];
	self.delegate = del;
	return self;
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

- (void)requestFailed:(NSString*)errorString
{
	if ([delegate respondsToSelector:@selector(requestFailed:)])
	{
		[delegate performSelector:@selector(requestFailed:)];
	}
}

@end
