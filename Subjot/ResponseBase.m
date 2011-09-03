//
//  ResponseBase.m
//  AuditionBooth
//
//  Created by Noah Santorello on 2/23/11.
//  Copyright 2011 AuditionBooth LLC. All rights reserved.
//

#import "ResponseBase.h"


@implementation ResponseBase

@synthesize succeeded, errorString;

- (void)dealloc
{
	[errorString release];
	[super dealloc];
}

@end
