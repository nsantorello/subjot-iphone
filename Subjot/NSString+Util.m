//
//  NSString+Util.m
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "NSString+Util.h"


@implementation NSString (Util)

- (CGSize)calculatedSize:(CGSize)maxDimensions forFont:(UIFont*)font andLineBreakMode:(UILineBreakMode)mode
{
    return [self sizeWithFont:font
                 constrainedToSize:maxDimensions 
                 lineBreakMode:mode]; 
    
}

@end
