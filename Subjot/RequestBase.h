//
//  RequestBase.h
//  Aditlo
//
//  Created by Noah Santorello on 2/19/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPFetcher.h"

@interface RequestBase : NSObject 
{
	id delegate;
}

@property (nonatomic, assign) id delegate;

- (id)initWithDelegate:(id)del;

@end
