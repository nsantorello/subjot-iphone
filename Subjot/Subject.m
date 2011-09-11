//
//  Subject.m
//  Subjot
//
//  Created by Noah Santorello on 9/11/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "Subject.h"


@implementation Subject

@synthesize subjectId, name;

+ (Subject*)fromDictionary:(NSDictionary*)dict
{
    Subject* sub = [[[Subject alloc] init] autorelease];
    sub.subjectId = [dict valueForKey:@"id"];
    sub.name = [dict valueForKey:@"name"];
    return sub;
}

- (void)dealloc
{
    self.subjectId = nil;
    self.name = nil;
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"ID: %@. Name: %@.", self.subjectId, self.name, nil];
}

@end
