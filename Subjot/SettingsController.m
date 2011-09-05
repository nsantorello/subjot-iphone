//
//  SettingsController.m
//  Subjot
//
//  Created by Noah Santorello on 9/4/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "SettingsController.h"

@implementation SettingsController

@synthesize keys, values, kvtCell, buttonCell;

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
    keys = values = nil;
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
    
    keys = [[NSArray arrayWithObjects:@"Username", @"App Version", nil] retain];
    values = [[NSArray arrayWithObjects:@"nsantorello", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], nil] retain];
    self.title = @"Settings";
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [keys count];
        case 1:
            return 1;
        case 2:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kvtIdentifier = @"KeyValueTableCell";
    static NSString *buttonIdentifier = @"ButtonTableCell";
    
    NSString* identifier = indexPath.section == 0 ? kvtIdentifier : buttonIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:identifier owner: self options: nil];
        if (indexPath.section == 0)
        {
            cell = kvtCell;
            kvtCell = nil;
        }
        else
        {
            cell = buttonCell;
            buttonCell = nil;
        }
    }
    
    // Configure the cell...
    switch (indexPath.section)
    {
        case 0:
        {
            KeyValueTableCell* kvt = (KeyValueTableCell*)cell;
            kvt.keyLabel.text = [NSString stringWithFormat:@"%@:", [keys objectAtIndex:indexPath.row]];
            kvt.valueLabel.text = [NSString stringWithFormat:@"%@", [values objectAtIndex:indexPath.row]];
        }
            break;
        case 1:
            // Hide this button if email not configured on device.
        {
            ButtonTableCell* btn = (ButtonTableCell*)cell;
            btn.textLabel.text = @"Send feedback to Subjot";   
        }
            break;
        case 2:
        {
            ButtonTableCell* btn = (ButtonTableCell*)cell;
            btn.textLabel.text = @"Logout";
        }
        default:
            break;
    }
    
    return cell;
}

-(void)sendMail
{
	if ([MFMailComposeViewController canSendMail]) 
	{
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
		NSArray *toRecipients = [[NSArray alloc] initWithObjects:@"feedback@subjot.com", nil];
		[mailViewController setToRecipients:toRecipients];
		[mailViewController setSubject:@"Subjot iOS App"];
		[mailViewController setMessageBody:@"" isHTML:NO];
		
		[self presentModalViewController:mailViewController animated:YES];
		[toRecipients release];
		[mailViewController release];
	}
	else 
	{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Feedback" message:@"Email not configured on this device.  Please email feedback@subjot.com to provide feedback." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
    if (result == MFMailComposeResultSent)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Feedback" message:@"Thank you for providing feedback!  It is very valuable to us.  :)" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"You're welcome!", nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* selected = [tableView cellForRowAtIndexPath:indexPath];
    [selected setSelected:NO animated:YES];
    
    switch (indexPath.section) {
        case 1:
            [self sendMail];
            break;
        default:
            break;
    }
}

@end
