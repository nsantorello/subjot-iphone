//
//  Comment.m
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "Comment.h"
#import "NSArray+Extensions.h"

@implementation Comment

@synthesize commentId, jot, author, published, text;

+ (Comment*)fromDictionary:(NSDictionary*)dict forJot:(Jot*)j
{
    Comment* comment = [[[Comment alloc] init] autorelease];
    comment.commentId = [dict valueForKey:@"id"];
    comment.author = [UserCache getUserFromDict:[dict valueForKey:@"author"]];
    comment.text = [dict valueForKey:@"text"];
    comment.published = [dict valueForKey:@"published"];
    comment.jot = j;
    return comment;
}

+ (NSArray*)commentArrayFromDictionary:(NSArray*)commentData forJot:(Jot*)j
{
    NSArray* comments = [[commentData map:^id(id obj) {
        return [[Comment fromDictionary:obj forJot:j] retain];
    }] autorelease];
    
    return comments;
}

- (void)dealloc
{
    jot = nil;
    author = nil;
    published = nil;
    text = nil;
    commentId = nil;
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ID: %@. Comment Text: '%@'.  Jot Text: '%@'.  Author Name: %@. Published: %@.", commentId, text, jot.text, author.name, published];
}

@end
