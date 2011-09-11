//
//  Subject.h
//  Subjot
//
//  Created by Noah Santorello on 9/11/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Subject : NSObject {
    
}

@property (copy) NSString* name;
@property (copy) NSNumber* subjectId;

+ (Subject*)fromDictionary:(NSDictionary*)dict;

@end
