//
//  User.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "User.h"


@implementation User

@synthesize userId, name, username, profilePicUrl;

- (void)dealloc
{
    userId = nil;
    name = username = profilePicUrl = nil;
    [super dealloc];
}

@end
