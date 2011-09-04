//
//  CachedJots.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "JotCache.h"


@implementation JotCache

+ (JotCache*)sharedInstance
{
    static dispatch_once_t once;
    static JotCache *instance;
    dispatch_once(&once, ^{
        instance = [[JotCache alloc] init];
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
    JotCache* jots = [JotCache sharedInstance];
    Jot* jot = [jots->jotCache objectForKey:[dict valueForKey:@"id"]];
    if (!jot)
    {
        jot = [jots createJotFromDict:dict];
    }
    
    return jot;
}

+ (Jot*)getJotById:(NSNumber*)jotId
{
    JotCache* jots = [JotCache sharedInstance];
    return [jots->jotCache objectForKey:[jotId stringValue]];
}

- (void)dealloc
{
    [jotCache release];
    [super dealloc];
}

@end
