//
//  C.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface C : NSObject {
    
}

+ (NSString*)subjotAPIUrl;
+ (NSString*)authUserUrl:(NSString*)username password:(NSString*)password;
+ (NSString*)userDetailUrl:(NSNumber*)userId;
+ (NSString*)homeStreamUrl;
+ (NSString*)allStreamUrl;
+ (NSString*)subjectStreamUrl:(NSString*)subject;
+ (NSString*)exploreStreamUrl:(NSString*)topic;

@end
