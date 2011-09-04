//
//  StreamResponse.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseBase.h"

@interface StreamResponse : ResponseBase {
    
}

@property (retain) NSArray* jots;
@property (retain) NSArray* users;

- (void)setData:(NSDictionary*)response;

@end
