//
//  NSString+ParsedBool.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "NSString+ParsedBool.h"


@implementation NSString (ParsedBool)

- (BOOL)parsedBool
{
    return [self boolValue] || [[self lowercaseString] isEqualToString:@"true"];
}

@end
