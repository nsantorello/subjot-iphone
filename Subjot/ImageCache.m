//
//  ImageCache.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "ImageCache.h"


@implementation ImageCache

+ (ImageCache*)sharedInstance
{
    static dispatch_once_t once;
    static ImageCache *instance;
    dispatch_once(&once, ^{
        instance = [[ImageCache alloc] init];
        instance->imageCache = [[NSMutableDictionary alloc] init];
    });
    
    return instance;
}

@end
