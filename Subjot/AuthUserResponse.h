//
//  AuthUserResponse.h
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseBase.h"
#import "User.h"

@interface AuthUserResponse : ResponseBase {
    
}

@property (retain) User* user;

- (void)setData:(NSDictionary*)response;

@end
