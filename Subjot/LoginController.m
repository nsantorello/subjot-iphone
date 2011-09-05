//
//  LoginController.m
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "LoginController.h"
#import "Credentials.h"

@implementation LoginController

@synthesize authedContentController, usernameField, passwordField;

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
    usernameField = passwordField = nil;
    authedContentController = nil;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)loginClicked
{
    [usernameField endEditing:YES];
    [passwordField endEditing:YES];
    
    authedContentController.selectedIndex = 0;
    
    User* user = [Credentials authenticateUser:usernameField.text andPassword:passwordField.text];
    if (user)
    {
        [self.navigationController pushViewController:authedContentController animated:YES];
        usernameField.text = passwordField.text = @"";
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"The credentials you entered are incorrect.  Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameField)
    {
        [passwordField becomeFirstResponder];
    }
    else if (textField == passwordField)
    {
        [self loginClicked];
    }
    
    return YES;
}

@end
