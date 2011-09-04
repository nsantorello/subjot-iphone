//
//  UILabel+Sizing.h
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UILabel (Sizing)

- (CGSize)calculatedSize:(CGSize)maxDimensions;
- (void)adjustHeightToTextSize;

@end
