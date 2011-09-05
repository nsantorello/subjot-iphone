//
//  AuthUserRequest.h
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestBase.h"
#import "AuthUserResponse.h"


@interface AuthUserRequest : RequestBase {
    
}

+ (void)authUserRequestWithDelegate:(id)del andUsername:(NSString*)username andPassword:(NSString*)password;

@end