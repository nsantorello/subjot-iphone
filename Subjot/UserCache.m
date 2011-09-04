//
//  CachedUsers.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "UserCache.h"


@implementation UserCache

+ (UserCache*)sharedInstance
{
    static dispatch_once_t once;
    static UserCache *instance;
    dispatch_once(&once, ^{
        instance = [[UserCache alloc] init];
        instance->userCache = [[NSMutableDictionary alloc] init];
    });
    
    return instance;
}

- (User*)createUserFromDict:(NSDictionary*)dict
{
    User* user = [User fromDictionary:dict];
    [userCache setValue:user forKey:[user.userId stringValue]];
    return user;
}

+ (User*)getUserFromDict:(NSDictionary*)dict
{
    UserCache* users = [UserCache sharedInstance];
    User* user = [users->userCache objectForKey:[dict valueForKey:@"id"]];
    if (!user)
    {
        user = [users createUserFromDict:dict];
    }
    
    return user;
}

+ (User*)getUserById:(NSNumber*)userId
{
    UserCache* users = [UserCache sharedInstance];
    return [users->userCache objectForKey:[userId stringValue]];
}

- (void)dealloc
{
    [userCache release];
    [super dealloc];
}

@end
