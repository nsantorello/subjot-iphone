//
//  UILabel+Sizing.m
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "UILabel+Sizing.h"


@implementation UILabel (Sizing)

- (CGSize)calculatedSize:(CGSize)maxDimensions
{
    return [self.text sizeWithFont:self.font
                    constrainedToSize:maxDimensions 
                    lineBreakMode:self.lineBreakMode]; 
    
}

- (void)adjustHeightToTextSize
{
    CGRect newFrame = self.frame;
    newFrame.size.height = [self calculatedSize:CGSizeMake(self.frame.size.width, 9999)].height;
    self.frame = newFrame;
}

@end
