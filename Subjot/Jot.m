//
//  Jot.m
//  Subjot
//
//  Created by Noah Santorello on 9/2/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "Jot.h"
#import "Comment.h"

@implementation Jot

@synthesize jotId, author, text, published, comments, subject;

+ (Jot*)fromDictionary:(NSDictionary*)dict
{
    Jot* jot = [[[Jot alloc] init] autorelease];
    jot.jotId = [dict valueForKey:@"id"];
    jot.author = [UserCache getUserFromDict:[dict valueForKey:@"user"]];
    jot.text = [dict valueForKey:@"content"];
    jot.published = [NSDate fromJsonString:[dict valueForKey:@"created_at"]];
    jot.comments = [[Comment commentArrayFromDictionary:[dict valueForKey:@"comments"] forJot:jot] retain];
    jot.subject = [SubjectCache getSubjectFromDict:[dict valueForKey:@"subject"]];
    return jot;
}

- (void)dealloc
{
    self.jotId = nil;
    self.comments = nil;
    self.author = nil;
    self.text = nil;
    self.subject = nil;
    self.published = nil;
    [super dealloc];
}

- (CGFloat)streamTextHeight
{
    return [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0] constrainedToSize:CGSizeMake(250, 500) lineBreakMode:UILineBreakModeWordWrap].height;
}

- (CGFloat)detailTextHeight
{
    return [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0] constrainedToSize:CGSizeMake(302, 500) lineBreakMode:UILineBreakModeWordWrap].height;
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"ID: %@. Author Info: (%@). Text: %@. Published: %@. Num Comments: %i. Subject: %@.", jotId, author, text, published, [comments count], subject];
}

@end
