//
//  SettingsController.h
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyValueTableCell.h"
#import "ButtonTableCell.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsController : UITableViewController<UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate> {
    
}

@property (retain) NSArray* values;
@property (retain) NSArray* keys;
@property (nonatomic, retain) IBOutlet KeyValueTableCell* kvtCell;
@property (nonatomic, retain) IBOutlet ButtonTableCell* buttonCell;

@end
