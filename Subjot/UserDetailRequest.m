//
//  UserDetailRequest.m
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "UserDetailRequest.h"


@implementation UserDetailRequest

- (id)initWithDelegate:(id)del
{
	self = [self init];
	self.delegate = del;
    responseClass = NSStringFromClass([[[[UserDetailResponse alloc] init] autorelease] class]);
	return self;
}

+ (void)requestWithDelegate:(id)del andUrl:(NSString*)url
{
	UserDetailRequest* req = [[UserDetailRequest alloc] initWithDelegate:del];	
	[req beginRequestWithURL:[NSURL URLWithString:url] andDelegate:req];
	[req release];
}


+ (void)userDetailRequestWithDelegate:(id)del andUserIds:(NSArray*)ids
{
    [UserDetailRequest requestWithDelegate:del andUrl:[C userDetailUrl:ids]];
}

@end
