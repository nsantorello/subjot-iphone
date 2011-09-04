//
//  StreamResponse.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "StreamResponse.h"
#import "NSArray+Extensions.h"
#import "Jot.h"
#import "JotCache.h"
#import "UserCache.h"

@implementation StreamResponse

@synthesize jots, users;

- (void)setData:(NSDictionary*)response
{
    [super setData:response];
    
    // Deserialize jot data from API result into jot objects.
    NSArray* userData = [response valueForKey:@"user_refs"];
    users = [userData map:^id(id obj) {
        return [UserCache getUserFromDict:obj];
    }];
    
    NSArray* jotData = [response valueForKey:@"jots"];
    jots = [jotData map:^id(id obj) {
        return [JotCache getJotFromDict:obj];
    }];
}

- (void)dealloc
{
    jots = users = nil;
    [super dealloc];
}

@end
