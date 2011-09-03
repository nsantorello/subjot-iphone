//
//  StreamResponse.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "StreamResponse.h"
#import "NSArray+Extensions.h"
#import "Jot.h"

@implementation StreamResponse

@synthesize jots;

- (void)setData:(NSDictionary*)response
{
    [super setData:response];
    
    // Deserialize jot data from API result into jot objects.
    NSArray* jotData = [response valueForKey:@"jots"];
    jots = [jotData map:^id(id obj) {
        return [[Jot fromDictionary:obj] retain];
    }];
}

- (void)dealloc
{
    jots = nil;
    [super dealloc];
}

@end
