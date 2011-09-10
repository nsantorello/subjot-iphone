//
//  UserDetailResponse.h
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseBase.h"
#import "User.h"

@interface UserDetailResponse : ResponseBase {
    
}

@property (retain) User* users;

@end
