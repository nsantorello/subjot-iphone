//
//  CommentTableCell.h
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface CommentTableCell : UITableViewCell {
    
}

@property (nonatomic, retain) IBOutlet UILabel* usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel* publishedLabel;
@property (nonatomic, retain) IBOutlet UILabel* commentTextLabel;
@property (nonatomic, retain) IBOutlet UIImageView* commentAuthorImage;

- (void)setComment:(Comment*)comment;

@end
