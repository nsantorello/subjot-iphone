//
//  StreamViewController.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JotTableCell.h"

@interface StreamViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource> {
    
}

@property (retain) NSArray* jots;
@property (nonatomic, retain) IBOutlet JotTableCell* jotTableCell;
@property (nonatomic, retain) IBOutlet UIViewController* hostingController;

@end
