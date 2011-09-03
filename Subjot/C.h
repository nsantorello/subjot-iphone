//
//  C.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface C : NSObject {
    
}

+ (NSString*)subjotAPIUrl;
+ (NSString*)homeStreamUrl;
+ (NSString*)allStreamUrl;
+ (NSString*)subjectStreamUrl:(NSString*)subject;
+ (NSString*)exploreStreamUrl:(NSString*)topic;

@end