//
//  Credentials.m
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "Credentials.h"


@implementation Credentials

@synthesize authedUser;

+ (Credentials*)sharedInstance
{
    static dispatch_once_t once;
    static Credentials *instance;
    dispatch_once(&once, ^{
        instance = [[Credentials alloc] init];
    });
    
    return instance;
}

+ (User*)authedUser
{
    return [[Credentials sharedInstance] authedUser];
}

+ (void)loginAs:(User*)user
{
    Credentials* cred = [Credentials sharedInstance];
    cred.authedUser = user;
}

+ (void)logout
{
    Credentials* cred = [Credentials sharedInstance];
    cred.authedUser = nil;
}

- (void)dealloc
{
    authedUser = nil;
    [super dealloc];
}

@end
