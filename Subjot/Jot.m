//
//  Jot.m
//  Subjot
//
//  Created by Noah Santorello on 9/2/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "Jot.h"
#import "UserCache.h"

@implementation Jot

@synthesize jotId, author, text, published, numComments, subject;

+ (Jot*)fromDictionary:(NSDictionary*)dict
{
    Jot* jot = [[[Jot alloc] init] autorelease];
    jot.jotId = [dict valueForKey:@"id"];
    jot.author = [UserCache getUserFromDict:[dict valueForKey:@"author"]];
    jot.text = [dict valueForKey:@"text"];
    jot.published = [dict valueForKey:@"published"];
    jot.numComments = [dict valueForKey:@"num_comments"];
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

- (NSString*)description
{
    return [NSString stringWithFormat:@"ID: %@. Author Name: %@. Text: %@. Published: %@. Num Comments: %@. Subject: %@.", jotId, author.name, text, published, numComments, subject];
}

@end
