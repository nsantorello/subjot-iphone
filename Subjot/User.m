//
//  User.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "User.h"


@implementation User

@synthesize userId, name, username, profilePicUrl, subjects, bio, totalJots, token, rawData;

+ (User*)fromDictionary:(NSDictionary *)dict
{
    User* user = [[[User alloc] init] autorelease];
    user.name = [dict valueForKey:@"name"];
    user.profilePicUrl = [dict valueForKey:@"profile_pic_url"];
    user.userId = [NSNumber numberWithInt:[[dict valueForKey:@"id"] intValue]];
    user.username = [dict valueForKey:@"username"];
    user.subjects = [dict valueForKey:@"subjects"];
    user.totalJots = [dict valueForKey:@"total_jots"];
    user.bio = [dict valueForKey:@"bio"];
    user.token = [dict valueForKey:@"token"];
    user.rawData = dict;
    return user;
}

- (void)dealloc
{
    userId = totalJots = nil;
    name = username = profilePicUrl = bio = token = nil;
    subjects = nil;
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"ID: %@. Name: %@. Username: %@. Profile Pic Url: %@.", userId, name, username, profilePicUrl];
}

@end
