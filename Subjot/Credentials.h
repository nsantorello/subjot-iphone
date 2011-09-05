//
//  Credentials.h
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Credentials : NSObject {
    
}

@property (retain) User* authedUser;

+ (Credentials*)sharedInstance;

+ (User*)authedUser;
+ (void)loginAs:(User*)user;
+ (void)logout;

@end
