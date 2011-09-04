//
//  NSString+Util.h
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Util)
    
- (CGSize)calculatedSize:(CGSize)maxDimensions forFont:(UIFont*)font andLineBreakMode:(UILineBreakMode)mode;

@end
