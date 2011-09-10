//
//  UserDetailRequest.h
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestBase.h"
#import "UserDetailResponse.h"


@interface UserDetailRequest : RequestBase {
    
}

+ (void)userDetailRequestWithDelegate:(id)del andUserIds:(NSArray*)ids;

@end