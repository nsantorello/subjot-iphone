//
//  JotDetailTableCell.h
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jot.h"

@interface JotDetailTableCell : UITableViewCell {
    
}

@property (nonatomic, retain) IBOutlet UILabel* jotLabel;
@property (nonatomic, retain) IBOutlet UILabel* publishedLabel;

- (void)setJot:(Jot*)jot;

@end
