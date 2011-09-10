//
//  User.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "User.h"


@implementation User

@synthesize userId, name, username, profilePicUrl, rawData;

- (void)populateFromDict:(NSDictionary*)dict
{
    self.name = [dict valueForKey:@"name"];
    self.profilePicUrl = [dict valueForKey:@"profile_pic_url"];
    self.userId = [NSNumber numberWithInt:[[dict valueForKey:@"id"] intValue]];
    self.username = [dict valueForKey:@"username"];
    self.rawData = dict;
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
    self.userId = nil;
    self.name = self.username = self.profilePicUrl = nil;
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"User - ID: %@. Name: %@. Username: %@. Profile Pic Url: %@.", self.userId, self.name, self.username, self.profilePicUrl];
}

@end
