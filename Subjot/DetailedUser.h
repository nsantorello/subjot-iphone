//
//  DetailedUser.h
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

// Detailed user objects replace user objects in the UserCache 
// when you get more info about a user (so that that info is cached)
@interface DetailedUser : User {
    
}

@property (retain) NSArray* subjects;
@property (retain) NSArray* latestJots;
@property (copy) NSString* location;
// Etc... all properties that are not included in
// jot info but are included on user's profile page.

+ (DetailedUser*)fromDictionary:(NSDictionary*)dict;

@end
