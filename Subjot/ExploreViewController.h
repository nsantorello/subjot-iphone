//
//  ExploreViewController.h
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ExploreViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource> {

}

@property (retain) NSArray* subjects;
@property (retain) NSArray* featured;

@end
