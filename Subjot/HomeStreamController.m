//
//  HomeStreamController.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "HomeStreamController.h"
#import "StreamRequest.h"
#import "JotCache.h"
#import "ComposeJotController.h"

@implementation HomeStreamController

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

    
    [StreamRequest homeRequestWithDelegate:nil];
    streamViewController.jots = [NSArray arrayWithObjects:[JotCache getJotById:[NSNumber numberWithInt:1]], [JotCache getJotById:[NSNumber numberWithInt:2]], [JotCache getJotById:[NSNumber numberWithInt:3]], [JotCache getJotById:[NSNumber numberWithInt:4]], [JotCache getJotById:[NSNumber numberWithInt:5]], [JotCache getJotById:[NSNumber numberWithInt:6]], nil];
    self.title = @"Latest";
}

- (IBAction)composeJotClicked
{
    ComposeJotController* composeJotController = [[ComposeJotController alloc] init];
    self.modalViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:composeJotController animated:YES];
    [composeJotController release];
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
