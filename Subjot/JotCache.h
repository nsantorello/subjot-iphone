//
//  CachedJots.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jot.h"

@interface JotCache : NSObject {
    NSMutableDictionary* jotCache;
}

+ (JotCache*)sharedInstance;

+ (Jot*)getJotFromDict:(NSDictionary*)dict;
+ (Jot*)getJotById:(NSNumber*)jotId;

@end
