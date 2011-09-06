//
//  User.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface User : NSObject {
    
}

@property (copy) NSNumber* userId;
@property (copy) NSString* name;
@property (copy) NSString* username;
@property (copy) NSString* profilePicUrl;
@property (retain) NSArray* subjects;
@property (copy) NSNumber* totalJots;
@property (copy) NSString* bio;
@property (copy) NSString* token;

@property (retain) NSDictionary* rawData;

+ (User*)fromDictionary:(NSDictionary*)dict;

@end
