//
//  StreamViewController.m
//  Subjot
//
//  Created by Noah Santorello on 9/3/11.
//  Copyright 2011 Noah Santorello. All rights reserved.
//

#import "StreamViewController.h"
#import "JotTableCell.h"
#import "JotDetailController.h"

@implementation StreamViewController

@synthesize jots, jotTableCell, hostingController;

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
    jots = nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    
    JotTableCell* cell = (JotTableCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed: @"JotTableCell" owner: self options: nil];
        cell = jotTableCell;
		jotTableCell = nil;
    }
    
    // Set name and contact info.
    Jot* jot = [jots objectAtIndex:indexPath.row];
    [cell setJot:jot];
    [cell.jotText sizeToFit];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [jots count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Jot* j = [jots objectAtIndex:indexPath.row];
    return 40 + [j streamTextHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* selected = [tableView cellForRowAtIndexPath:indexPath];
    [selected setSelected:NO animated:YES];
    
    JotDetailController* jotDetailController = [[JotDetailController alloc] init];
    jotDetailController.jot = [jots objectAtIndex:indexPath.row];
    [hostingController.navigationController pushViewController:jotDetailController animated:YES];
    [jotDetailController release];
}


@end
