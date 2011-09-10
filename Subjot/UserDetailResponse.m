//
//  UserDetailResponse.m
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "UserDetailResponse.h"
#import "NSArray+Extensions.h"

@implementation UserDetailResponse

@synthesize users;

- (void)setData:(NSDictionary*)response
{
    [super setData:response];
    
    // Deserialize jot data from API result into jot objects.
    NSArray* userData = [response valueForKey:@"users"];
    users = [userData map:^id(id obj) {
        return [UserCache getUserFromDict:obj];
    }];
}

- (void)dealloc
{
    users = nil;
    [super dealloc];
}

@end
