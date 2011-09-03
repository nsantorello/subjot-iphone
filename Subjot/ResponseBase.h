//
//  ResponseBase.h
//  AuditionBooth
//
//  Created by Noah Santorello on 2/23/11.
//  Copyright 2011 AuditionBooth LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ResponseBase : NSObject {
	BOOL succeeded;
	NSString* errorString;
}

@property (assign) BOOL succeeded;
@property (copy) NSString* errorString;

@end
