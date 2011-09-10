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
    
    subjects = [dict valueForKey:@"subjects"];
    totalJots = [dict valueForKey:@"total_jots"];
    bio = [dict valueForKey:kBioField];
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
    totalJots = nil;
    bio = nil;
    subjects = nil;
    [super dealloc];
}

@end
