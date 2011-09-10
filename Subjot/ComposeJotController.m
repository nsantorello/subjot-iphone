//
//  ComposeJotController.m
//  Subjot
//
//  Created by Noah Santorello on 9/5/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "ComposeJotController.h"


@implementation ComposeJotController

@synthesize jotText, addBtn, subjectBtn;

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
    [self.jotText becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.jotText = nil;
    self.addBtn = self.subjectBtn = nil;
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
    [self dismissView];
}

- (IBAction)jotCompleted
{
    [self dismissView];
}

- (IBAction)chooseSubjectClicked
{
    NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:[NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"Choose a subject", @"")]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Select", nil];
    [actionSheet showInView:self.view];
    UIPickerView *bankPicker = [[[UIPickerView alloc] init] autorelease];
    bankPicker.dataSource = self;
    bankPicker.delegate = self;
    bankPicker.showsSelectionIndicator = YES;
    [bankPicker selectRow:selectedSubjectPickerRow inComponent:0 animated:NO];
    [actionSheet addSubview:bankPicker];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*if ([actionSheet isEqual:bankAccountSheet])
    {
        [bankAccountButton setTitleAndCenter:selectedBankAccount];
        [self updateSendPaymentButton];
        bankAccountSheet = nil;
    }
    else if ([actionSheet isEqual:confirmationSheet])
    {
        if (buttonIndex == 0)  // "Send Now" clicked
        {
            [self goToConfirmation];
            confirmationSheet = nil;
        }
    }*/
}

-(NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component 
{    
    return @"hello";//[bankAccounts objectAtIndex:row];
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;//[bankAccounts count];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	//selectedBankAccount = [bankAccounts objectAtIndex:row];
    //selectedPickerRow = row;
}

-(IBAction)submitPayment
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:nil
                                  delegate:self cancelButtonTitle:@"Go Back" destructiveButtonTitle:nil otherButtonTitles:@"Send Now", nil];
    [actionSheet showInView:self.view];
    //confirmationSheet = actionSheet;
}

- (IBAction)addButtonClicked
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:nil
                                  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a photo", @"Attach from library", nil];
    [actionSheet showInView:self.view];
}

@end
