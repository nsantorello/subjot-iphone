//
//  Constants.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#ifdef LIVE_API

NSString* const SubjotAPIUrl = @"https://api.subjot.com/";

NSString* const APIUrl_Streams_Home = @"streams/home";
NSString* const APIUrl_Streams_Subjects = @"streams/subjects/";
NSString* const APIUrl_Streams_Explore = @"streams/explore/";
NSString* const APIUrl_Streams_All = @"streams/all";

#else

NSString* const SubjotAPIUrl = @"";

NSString* const APIUrl_Streams_Home = @"home";
NSString* const APIUrl_Streams_Subjects = @"subjects";
NSString* const APIUrl_Streams_Explore = @"explore/";
NSString* const APIUrl_Streams_All = @"all";

#endif
