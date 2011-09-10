//
//  CreateCommentRequest.m
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "CreateCommentRequest.h"

@implementation CreateCommentRequest

- (id)initWithDelegate:(id)del
{
	self = [self init];
	self.delegate = del;
    responseClass = NSStringFromClass([[[[CreateCommentResponse alloc] init] autorelease] class]);
	return self;
}

+ (void)requestWithDelegate:(id)del forJot:(Jot*)jot andComment:(NSString*)commentText
{
	CreateCommentRequest* req = [[CreateCommentRequest alloc] initWithDelegate:del];	
    NSArray* postDataValues = [[NSArray alloc] initWithObjects:jot.jotId, commentText, nil];
    NSArray* postDataKeys = [[NSArray alloc] initWithObjects:@"jot_id", @"comment_text", nil];
    NSDictionary* postData = [[NSDictionary alloc] initWithObjects:postDataValues forKeys:postDataKeys];
	[req beginRequestWithURL:[NSURL URLWithString:[C createCommentUrl]] andDelegate:req andPostData:postData];
	[req release];
}

@end
