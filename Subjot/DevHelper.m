//
//  DevHelper.m
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "DevHelper.h"


@implementation DevHelper

+ (void)showNotImplAlert
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"TBD" message:@"Not implemented yet, silly!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Aww...", nil];
    [alert show];
    [alert release];
}

@end
