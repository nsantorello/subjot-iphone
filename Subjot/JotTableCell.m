//
//  JotTableCell.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "JotTableCell.h"
#import "ImageCache.h"

@implementation JotTableCell

@synthesize pic, username, jotText, comments, published, jot, subject;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setJot:(Jot *)j
{
    pic.image = [ImageCache getImageByUrl:j.author.profilePicUrl];
    username.text = j.author.username;
    jotText.text = j.text;
    comments.text = [NSString stringWithFormat:@"%@ comments", j.numComments];
    subject.text = j.subject;
    //published.text = j.published;
}

- (void)dealloc
{
    jot = nil;
    [super dealloc];
}

@end
