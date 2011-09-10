//
//  DetailedUser.h
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface DetailedUser : User {
    
}
@property (retain) NSArray* subjects;
@property (copy) NSNumber* totalJots;
@property (copy) NSString* bio;

+ (DetailedUser*)fromDictionary:(NSDictionary*)dict;
+ (BOOL)dictIsDetailedUser:(NSDictionary*)dict;

- (BOOL)isDetailed;
- (void)populateFromDict:(NSDictionary*)dict;

@end
