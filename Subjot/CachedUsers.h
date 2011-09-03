//
//  CachedUsers.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface CachedUsers : NSObject {
    NSMutableDictionary* userCache;
}

+ (CachedUsers*)sharedInstance;

+ (User*)getUserFromDict:(NSDictionary*)dict;
+ (User*)getUserById:(NSNumber*)userId;

@end