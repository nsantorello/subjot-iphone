//
//  ResponseBase.h
//  AuditionBooth
//
//  Created by Noah Santorello on 2/23/11.
//  Copyright 2011 AuditionBooth LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ResponseBase : NSObject {
    NSDictionary* responseData;
}

@property (assign) BOOL succeeded;
@property (copy) NSString* apiVersion;
@property (copy) NSString* errorString;

- (void)setData:(NSDictionary*)response;

@end
