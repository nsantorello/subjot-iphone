//
//  JotTableCell.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jot.h"

@interface JotTableCell : UITableViewCell {
    
}

@property (nonatomic, retain) Jot* jot;
@property (nonatomic, retain) IBOutlet UIImageView *pic;
@property (nonatomic, retain) IBOutlet UILabel *username;
@property (nonatomic, retain) IBOutlet UILabel *jotText;
@property (nonatomic, retain) IBOutlet UILabel *published;
@property (nonatomic, retain) IBOutlet UILabel *comments;

- (void)setJot:(Jot*)jot;

@end
