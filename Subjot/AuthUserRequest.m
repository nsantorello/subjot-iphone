//
//  AuthUserRequest.m
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "AuthUserRequest.h"


@implementation AuthUserRequest

- (id)initWithDelegate:(id)del
{
	self = [self init];
	self.delegate = del;
    responseClass = NSStringFromClass([[[[AuthUserResponse alloc] init] autorelease] class]);
	return self;
}

+ (void)requestWithDelegate:(id)del andUrl:(NSString*)url
{
	AuthUserRequest* req = [[AuthUserRequest alloc] initWithDelegate:del];	
	[req beginRequestWithURL:[NSURL URLWithString:url] andDelegate:req];
	[req release];
}

+ (void)authUserRequestWithDelegate:(id)del andUsername:(NSString*)username andPassword:(NSString*)password
{
    [AuthUserRequest requestWithDelegate:del andUrl:[C authUserUrl:username password:password]];
}

@end
