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

@implementation NSDate (DateDiff)

- (NSString *)dateDiff
{
    NSDate *convertedDate = self;
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
        return @"never";
    } else      if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
        return @"never";
    }   
}

// Courtesy of http://borkware.com/quickies/one?topic=NSDate
+ (NSDate*)fromJsonString:(NSString*)dateTime
{
    static NSDateFormatter *xsdDateTimeFormatter;
    if (!xsdDateTimeFormatter) {
        xsdDateTimeFormatter = [[NSDateFormatter alloc] init];  // Keep around forever
        xsdDateTimeFormatter.timeStyle = NSDateFormatterFullStyle;
        xsdDateTimeFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:sszzz";
    }
    
    // Date formatters don't grok a single trailing Z, so make it "GMT".
    if ([dateTime hasSuffix: @"Z"]) {
        dateTime = [[dateTime substringToIndex: dateTime.length - 1]
                    stringByAppendingString: @"GMT"];
    }
    
    NSDate *date = [xsdDateTimeFormatter dateFromString: dateTime];
    
    return (date);
}

@end
