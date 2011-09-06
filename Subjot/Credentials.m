//
//  Credentials.m
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "Credentials.h"
#import "UserCache.h"

#define kAuthedUser @"Credentials.authedUser"

@implementation Credentials

@synthesize authedUser;

+ (Credentials*)sharedInstance
{
    static dispatch_once_t once;
    static Credentials *instance;
    dispatch_once(&once, ^{
        instance = [[Credentials alloc] init];
        NSDictionary* authedUserRawData = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthedUser];
        instance.authedUser = [UserCache getUserFromDict:authedUserRawData];
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
    [[NSUserDefaults standardUserDefaults] setObject:user.rawData forKey:kAuthedUser];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)logout
{
    Credentials* cred = [Credentials sharedInstance];
    cred.authedUser = nil;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kAuthedUser];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc
{
    authedUser = nil;
    [super dealloc];
}

@end
