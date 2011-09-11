//
//  HomeStreamController.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamViewController.h"
#import "ResponseBase.h"

@interface HomeStreamController : UIViewController<SubjotResponseDelegate> {
    IBOutlet StreamViewController* streamViewController;
}

@end
