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
        instance->jotCache = [[NSMutableDictionary alloc] init];
    });
    
    return instance;
}

- (Jot*)createJotFromDict:(NSDictionary*)dict
{
    Jot* jot = [Jot fromDictionary:dict];
    [jotCache setValue:jot forKey:[jot.jotId stringValue]];
    return jot;
}


+ (Jot*)getJotFromDict:(NSDictionary*)dict
{
    CachedJots* jots = [CachedJots sharedInstance];
    Jot* jot = [jots->jotCache objectForKey:[dict valueForKey:@"id"]];
    if (!jot)
    {
        jot = [jots createJotFromDict:dict];
    }
    
    return jot;
}

+ (Jot*)getJotById:(NSNumber*)jotId
{
    CachedJots* jots = [CachedJots sharedInstance];
    return [jots->jotCache objectForKey:[jotId stringValue]];
}

- (void)dealloc
{
    [jotCache release];
    [super dealloc];
}

@end
