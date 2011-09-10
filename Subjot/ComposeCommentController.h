//
//  ComposeCommentController.h
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ComposeCommentController : UIViewController<UIActionSheetDelegate> {
    UIActionSheet* cancelSheet;
}

@property (nonatomic, retain) IBOutlet UITextView* commentText;

- (IBAction)composeCanceled;
- (IBAction)commentPosted;

@end
