//
//  DetailedUser.m
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "DetailedUser.h"


@implementation DetailedUser

#define kBioField @"bio"

@synthesize subjects, bio, totalJots;

+ (BOOL)dictIsDetailedUser:(NSDictionary *)dict
{
    return [dict valueForKey:kBioField] != nil;
}

- (void)populateFromDict:(NSDictionary*)dict
{
    [super populateFromDict:dict];
    
    self.subjects = [dict valueForKey:@"subjects"];
    self.totalJots = [dict valueForKey:@"total_jots"];
    self.bio = [dict valueForKey:kBioField];
}

+ (DetailedUser*)fromDictionary:(NSDictionary *)dict
{
    DetailedUser* user = [[[DetailedUser alloc] init] autorelease];
    [user populateFromDict:dict];
    return user;
}

- (BOOL)isDetailed
{
    return TRUE;
}

- (void)dealloc
{
    self.totalJots = nil;
    self.bio = nil;
    self.subjects = nil;
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Detailed User - ID: %@. Name: %@. Username: %@. Profile Pic Url: %@. Bio: %@", self.userId, self.name, self.username, self.profilePicUrl, self.bio];
}

@end
