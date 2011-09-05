//
//  JotDetailController.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jot.h"
#import "JotDetailTableCell.h"
#import "CommentTableCell.h"

@interface JotDetailController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    
}

@property (retain) Jot* jot;
@property (nonatomic, retain) IBOutlet UILabel* username;
@property (nonatomic, retain) IBOutlet UILabel* name;
@property (nonatomic, retain) IBOutlet UILabel* subject;
@property (nonatomic, retain) IBOutlet UILabel* writingAbout;
@property (nonatomic, retain) IBOutlet UIImageView* pic;
@property (nonatomic, retain) IBOutlet JotDetailTableCell* jotDetailTableCell;
@property (nonatomic, retain) IBOutlet CommentTableCell* commentTableCell;

@end
