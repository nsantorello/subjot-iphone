//
//  ComposeJotController.h
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ComposeJotController : UIViewController<UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    int selectedSubjectPickerRow;
}

@property (nonatomic, retain) IBOutlet UITextView* jotText;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* addBtn;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* subjectBtn;

- (IBAction)composeCanceled;
- (IBAction)jotCompleted;
- (IBAction)chooseSubjectClicked;
- (IBAction)addButtonClicked;

@end
