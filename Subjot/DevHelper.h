//
//  DevHelper.h
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DevHelper : NSObject {
    
}

+ (void)showNotImplAlert;

@end

@interface NSDate (DateDiff)

- (NSString *)dateDiff;
+ (NSDate*)fromJsonString:(NSString*)str;

@end
