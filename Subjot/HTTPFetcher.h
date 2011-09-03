//
//  HTTPFetcher.h
//  AuditionBooth
//
//  Created by Noah Santorello on 2/23/11.
//  Copyright 2011 AuditionBooth LLC. All rights reserved.
//

#import "GTMHTTPFetcher.h"

@interface HTTPFetcher : NSObject {
	id delegate;
}

@property (nonatomic, assign) id delegate;

+ (void)beginRequestWithURL:(NSURL*)url andDelegate:(id)del;
+ (void)beginRequestWithURL:(NSURL*)url andDelegate:(id)del andPostData:(NSString*)postData;

@end
