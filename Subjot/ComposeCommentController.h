//
//  ComposeCommentController.h
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jot.h"

@interface ComposeCommentController : UIViewController<UIActionSheetDelegate, UITextViewDelegate> {
    UIActionSheet* cancelSheet;
}

@property (nonatomic, retain) IBOutlet UITextView* commentText;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* postCommentBtn;
@property (retain) Jot* jot;
@property (assign) id composeCommentDelegate;

- (IBAction)composeCanceled;
- (IBAction)commentPosted;

@end
