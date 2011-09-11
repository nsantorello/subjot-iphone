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

- (UIImage*)downloadImage:(NSString*)url
{
    NSURL* loc = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSData* imageData = [[NSData alloc] initWithContentsOfURL:loc];
    UIImage* img = [UIImage imageWithData:imageData];
    if (img)
    {
        [imageCache setObject:img forKey:url];
    }
    [imageData release];
    return img;
}

+ (UIImage*)getImageByUrl:(NSString*)url
{
    ImageCache* images = [ImageCache sharedInstance];
    UIImage* img = [images->imageCache objectForKey:url];
    if (!img)
    {
        img = [images downloadImage:url];
    }
    
    return img;
}

@end
