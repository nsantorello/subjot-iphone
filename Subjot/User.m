//
//  User.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "User.h"


@implementation User

@synthesize userId, name, username, profilePicUrl, subjects, bio, totalJots, rawData;

- (void)populateFromDict:(NSDictionary*)dict
{
    name = [dict valueForKey:@"name"];
    profilePicUrl = [dict valueForKey:@"profile_pic_url"];
    userId = [NSNumber numberWithInt:[[dict valueForKey:@"id"] intValue]];
    username = [dict valueForKey:@"username"];
    rawData = dict;
}

+ (User*)fromDictionary:(NSDictionary *)dict
{
    User* user = [[[User alloc] init] autorelease];
    [user populateFromDict:dict];
    return user;
}

- (BOOL)isDetailed
{
    return FALSE;
}

- (void)dealloc
{
    userId = totalJots = nil;
    name = username = profilePicUrl = bio = nil;
    subjects = nil;
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"ID: %@. Name: %@. Username: %@. Profile Pic Url: %@.", userId, name, username, profilePicUrl];
}

@end
