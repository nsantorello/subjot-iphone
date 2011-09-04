//
//  ImageCache.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageCache : NSObject {
    NSMutableDictionary* imageCache;
}

+ (ImageCache*)sharedInstance;

+ (UIImage*)getImageByUrl:(NSString*)url;

@end
