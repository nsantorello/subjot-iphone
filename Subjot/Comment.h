//
//  Comment.h
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jot.h"

@interface Comment : NSObject {
    
}

@property (copy) NSNumber* commentId;
@property (retain) Jot* jot;
@property (retain) User* author;
@property (copy) NSString* text;
@property (copy) NSDate* published;

+ (Comment*)fromDictionary:(NSDictionary*)dict forJot:(Jot*)j;
+ (NSArray*)commentArrayFromDictionary:(NSArray*)commentData forJot:(Jot*)j;

@end
