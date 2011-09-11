//
//  SubjectCache.m
//  Subjot
//
//  Created by Noah Santorello on 9/11/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "SubjectCache.h"


@implementation SubjectCache

+ (SubjectCache*)sharedInstance
{
    static dispatch_once_t once;
    static SubjectCache *instance;
    dispatch_once(&once, ^{
        instance = [[SubjectCache alloc] init];
        instance->subjectCache = [[NSMutableDictionary alloc] init];
    });
    
    return instance;
}

- (Subject*)createSubjectFromDict:(NSDictionary*)dict
{
    Subject* sub = [Subject fromDictionary:dict];
    SubjectCache* cache = [SubjectCache sharedInstance];
    [cache->subjectCache setValue:sub forKey:[sub.subjectId stringValue]];
    return sub;
}

+ (Subject*)getSubjectFromDict:(NSDictionary*)dict
{
    if (!dict)
    {
        return nil;
    }
    
    SubjectCache* subjects = [SubjectCache sharedInstance];
    Subject* sub = [subjects->subjectCache objectForKey:[dict valueForKey:@"id"]];
    if (!sub) // existing user is a User and the dict represents a DetailedUser
    {
        sub = [subjects createSubjectFromDict:dict];
    }
    
    return sub;
}

+ (Subject*)getSubjectById:(NSNumber*)subId
{
    SubjectCache* subjects = [SubjectCache sharedInstance];
    return [subjects->subjectCache objectForKey:[subId stringValue]];
}

- (void)dealloc
{
    [subjectCache release];
    [super dealloc];
}

@end
