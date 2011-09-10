//
//  CreateCommentRequest.h
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestBase.h"
#import "CreateCommentResponse.h"
#import "Jot.h"

@interface CreateCommentRequest : RequestBase {
    
}

+ (void)requestWithDelegate:(id)del forJot:(Jot*)jot andComment:(NSString*)commentText;

@end
