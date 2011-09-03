//
//  Settings.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "Settings.h"


@implementation Settings

- (id) init
{
    self = [super init];
    // Set member vars here
    return self;
}

+ (Settings*)sharedInstance
{
    static dispatch_once_t once;
    static Settings *instance;
    dispatch_once(&once, ^{
        instance = [[Settings alloc] init];
    });
    
    return instance;
}

@end
