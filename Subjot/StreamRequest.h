//
//  StreamRequest.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestBase.h"


@interface StreamRequest : RequestBase {
    
}

+ (void)homeRequestWithDelegate:(id)del;
+ (void)subjectRequestWithDelegate:(id)del andSubject:(NSString*)subject;
+ (void)exploreRequestWithDelegate:(id)del andTopic:(NSString*)topic;
+ (void)allRequestWithDelegate:(id)del;

@end
