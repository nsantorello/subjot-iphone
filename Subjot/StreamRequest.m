//
//  StreamRequest.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "StreamRequest.h"

@implementation StreamRequest

- (id)initWithDelegate:(id)del
{
	self = [self init];
	self.delegate = del;
    responseClass = NSStringFromClass([[[[StreamResponse alloc] init] autorelease] class]);
	return self;
}

+ (void)requestWithDelegate:(id)del andUrl:(NSString*)url
{
	StreamRequest* req = [[StreamRequest alloc] initWithDelegate:del];	
	[req beginRequestWithURL:[NSURL URLWithString:url] andDelegate:req];
	[req release];
}

+ (void)homeRequestWithDelegate:(id)del
{
    [StreamRequest requestWithDelegate:del andUrl:[C homeStreamUrl]];
}

+ (void)subjectRequestWithDelegate:(id)del andSubject:(NSString*)subject
{
    [StreamRequest requestWithDelegate:del andUrl:[C subjectStreamUrl:subject]];
}

+ (void)exploreRequestWithDelegate:(id)del andTopic:(NSString*)topic
{
    [StreamRequest requestWithDelegate:del andUrl:[C exploreStreamUrl:topic]];
}

+ (void)allRequestWithDelegate:(id)del
{
    [StreamRequest requestWithDelegate:del andUrl:[C allStreamUrl]];
}

@end
