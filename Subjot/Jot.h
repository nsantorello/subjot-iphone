//
//  Jot.h
//  Subjot
//
//  Created by Noah Santorello on 9/2/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCache.h"

@interface Jot : NSObject {
    
}

@property (copy) NSNumber* jotId;
@property (retain) User* author;
@property (copy) NSString* text;
@property (copy) NSDate* published;
@property (copy) NSArray* comments;
@property (copy) NSString* subject;

+ (Jot*)fromDictionary:(NSDictionary*)dict;
- (CGFloat)streamTextHeight;
- (CGFloat)detailTextHeight;

@end
