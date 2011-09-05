//
//  LoginController.h
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthUserRequest.h"

@interface LoginController : UIViewController<UITextFieldDelegate, SubjotResponseDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UITabBarController* authedContentController;
@property (nonatomic, retain) IBOutlet UITextField* usernameField;
@property (nonatomic, retain) IBOutlet UITextField* passwordField;

- (IBAction)loginClicked;

@end
