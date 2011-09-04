//
//  JotDetailController.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "JotDetailController.h"
#import "ImageCache.h"

@implementation JotDetailController

@synthesize jot, name, username, subject, pic, writingAbout;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (jot)
    {
        name.text = jot.author.name;
        subject.text = jot.subject;
        pic.image = [ImageCache getImageByUrl:jot.author.profilePicUrl];
        CGFloat nameWidth = [jot.author.name sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0] 
                                        constrainedToSize:CGSizeMake(250, 500) lineBreakMode:UILineBreakModeWordWrap].width;
        CGRect newFrame = writingAbout.frame;
        newFrame.origin.x += nameWidth;
        writingAbout.frame = newFrame;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
