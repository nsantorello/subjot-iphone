//
//  AuthUserResponse.m
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "AuthUserResponse.h"
#import "UserCache.h"
#import "Credentials.h"

@implementation AuthUserResponse

@synthesize user;

- (void)setData:(NSDictionary*)response
{
    [super setData:response];
    
    // Deserialize jot data from API result into jot objects.
    user = [UserCache getUserFromDict:[response valueForKey:@"user"]];
}

- (void)dealloc
{
    user = nil;
    [super dealloc];
}

@end
