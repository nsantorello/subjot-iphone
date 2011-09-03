//
//  Jot.m
//  Subjot
//
//  Created by Noah Santorello on 9/2/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "Jot.h"


@implementation Jot

@synthesize jotId, author, text, published, numComments, subject;

+ (Jot*)fromDictionary:(NSDictionary*)dict
{
    Jot* jot = [[[Jot alloc] init] autorelease];
    jot.jotId = [dict valueForKey:@"id"];
    //jot.author = [dict valueForKey:@"id"];
    jot.text = [dict valueForKey:@"text"];
    jot.published = [dict valueForKey:@"published"];
    jot.numComments = [dict valueForKey:@"numComments"];
    jot.subject = [dict valueForKey:@"subject"];
    return jot;
}

- (void)dealloc
{
    jotId = numComments = nil;
    author = nil;
    text = subject = nil;
    published = nil;
    [super dealloc];
}

@end
