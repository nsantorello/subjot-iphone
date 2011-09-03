//
//  CachedJots.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "CachedJots.h"


@implementation CachedJots

+ (CachedJots*)sharedInstance
{
    static dispatch_once_t once;
    static CachedJots *instance;
    dispatch_once(&once, ^{
        instance = [[CachedJots alloc] init];
    });
    
    return instance;
}

@end
