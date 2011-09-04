//
//  JotDetailTableCell.m
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "JotDetailTableCell.h"


@implementation JotDetailTableCell

@synthesize jotLabel, publishedLabel;

- (void)dealloc
{
    jotLabel = publishedLabel = nil;
    [super dealloc];
}

- (void)setJot:(Jot *)jot
{
    jotLabel.text = jot.text;
    publishedLabel.text = [jot.published description];
    
    CGFloat jotTextHeight = [jot detailTextHeight];

    CGRect newFrame = publishedLabel.frame;
    newFrame.origin.y += jotTextHeight;
    publishedLabel.frame = newFrame;
    
    [jotLabel sizeToFit];
}

@end
