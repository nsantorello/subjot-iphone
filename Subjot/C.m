//
//  C.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "C.h"

@implementation C

+ (NSString*)subjotAPIUrl
{
    return SubjotAPIUrl;
}

+ (NSString*)appendTo:(NSString*)str theString:(NSString*)str2
{
    return [NSString stringWithFormat:@"%@%@", str, str2];
}

+ (NSString*)apiCallUrl:(NSString*)appendedUrl
{
    return [C appendTo:[C subjotAPIUrl] theString:appendedUrl];
}

+ (NSString*)authUserUrl:(NSString*)username password:(NSString*)password
{
    // TODO: (ns): eventually add username/password to URL.  Make URL string in Constants.m a formatted string with %@'s that you can insert into NSString stringWithFormat
    return [C apiCallUrl:APIUrl_Auth];
}

+ (NSString*)userDetailUrl:(NSArray*)ids
{
    // TODO: (ns): eventually add user ID to URL.  Make URL string in Constants.m a formatted string with %@'s that you can insert into NSString stringWithFormat
    return [C apiCallUrl:APIUrl_User_Detail];
}

+ (NSString*)homeStreamUrl
{
    return [C apiCallUrl:APIUrl_Streams_Home];
}

+ (NSString*)allStreamUrl
{
    return [C apiCallUrl:APIUrl_Streams_All];
}

+ (NSString*)subjectStreamUrl:(NSString*)subject;
{
    return [C appendTo:[C apiCallUrl:APIUrl_Streams_Subjects] theString:subject];
}

+ (NSString*)exploreStreamUrl:(NSString*)topic;
{
    return [C appendTo:[C apiCallUrl:APIUrl_Streams_Explore] theString:topic];
}

@end
