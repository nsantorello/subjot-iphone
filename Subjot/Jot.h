//
//  Jot.h
//  Subjot
//
//  Created by Noah Santorello on 9/2/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Jot : NSObject {
    
}

@property (copy) NSNumber* jotId;
@property (retain) User* author;
@property (copy) NSString* text;
@property (copy) NSDate* published;
@property (copy) NSNumber* numComments;
@property (copy) NSString* subject;

+ (Jot*)fromDictionary:(NSDictionary*)dict;
- (CGFloat)textHeight;

@end
