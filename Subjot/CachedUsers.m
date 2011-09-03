//
//  CachedUsers.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "CachedUsers.h"


@implementation CachedUsers

+ (CachedUsers*)sharedInstance
{
    static dispatch_once_t once;
    static CachedUsers *instance;
    dispatch_once(&once, ^{
        instance = [[CachedUsers alloc] init];
    });
    
    return instance;
}

@end
