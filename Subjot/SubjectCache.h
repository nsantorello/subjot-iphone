//
//  SubjectCache.h
//  Subjot
//
//  Created by Noah Santorello on 9/11/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Subject.h"

@interface SubjectCache : NSObject {
    NSMutableDictionary* subjectCache;
}

+ (SubjectCache*)sharedInstance;

+ (Subject*)getSubjectFromDict:(NSDictionary*)dict;
+ (Subject*)getSubjectById:(NSNumber*)subId;

@end
