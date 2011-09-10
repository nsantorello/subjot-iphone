//
//  ComposeCommentController.m
//  Subjot
//
//  Created by Noah Santorello on 9/10/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "ComposeCommentController.h"
#import "CreateCommentRequest.h"

@implementation ComposeCommentController

#define kDeleteButtonIndex 0

@synthesize commentText, jot, composeCommentDelegate;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [commentText becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.commentText = nil;
    self.jot = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dismissView
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)composeCanceled
{
    cancelSheet = [[UIActionSheet alloc] 
                                  initWithTitle:nil
                                  delegate:self cancelButtonTitle:@"Continue editing" destructiveButtonTitle:@"Delete comment" otherButtonTitles:nil];
    [cancelSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet isEqual:cancelSheet])
    {
        // Go back to jot detail view
        if (buttonIndex == kDeleteButtonIndex)
        {
            [self dismissView];
        }
    }
}

- (IBAction)commentPosted
{
    [CreateCommentRequest requestWithDelegate:composeCommentDelegate forJot:jot andComment:commentText.text];
    [self dismissView];
}

@end
