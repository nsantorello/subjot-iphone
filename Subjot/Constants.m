//
//  Constants.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#ifdef LIVE_API

NSString* const SubjotAPIUrl = @"https://api.dev.subjot.com/v1/";

NSString* const APIUrl_Auth = @"auth";

NSString* const APIUrl_User_Detail = @"user/";

NSString* const APIUrl_Streams_Home = @"feed.json";
NSString* const APIUrl_Streams_Subjects = @"streams/subjects/";
NSString* const APIUrl_Streams_Explore = @"streams/explore/";
NSString* const APIUrl_Streams_All = @"streams/all";

NSString* const APIUrl_Create_Comment = @"what goes here?";

#else

NSString* const SubjotAPIUrl = @"";

NSString* const APIUrl_Auth = @"auth_user";

NSString* const APIUrl_User_Detail = @"user_detail";

NSString* const APIUrl_Streams_Home = @"home";
NSString* const APIUrl_Streams_Subjects = @"subjects";
NSString* const APIUrl_Streams_Explore = @"home";
NSString* const APIUrl_Streams_All = @"all";

NSString* const APIUrl_Create_Comment = @"post_comment";

#endif
