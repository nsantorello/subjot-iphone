//
//  RequestBase.h
//  Aditlo
//
//  Created by Noah Santorello on 2/19/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestBase : NSObject 
{
    NSString* responseClass;
}

@property (nonatomic, assign) id delegate;

- (id)initWithDelegate:(id)del;
- (void)beginRequestWithURL:(NSURL*)url andDelegate:(id)del;
- (void)beginRequestWithURL:(NSURL*)url andDelegate:(id)del andPostData:(NSString*)postData;

@end
