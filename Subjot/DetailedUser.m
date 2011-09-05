//
//  DetailedUser.m
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "DetailedUser.h"


@implementation DetailedUser

@synthesize subjects, latestJots, location;

+ (DetailedUser*)fromDictionary:(NSDictionary*)dict
{
    
    DetailedUser* user = [[[DetailedUser alloc] init] autorelease];
    // Need to do some refactoring, but reuse fromDictionary impl from User class
    return user;
}

- (void)dealloc
{
    subjects = latestJots = nil;
    location = nil;
    [super dealloc];
}

@end
