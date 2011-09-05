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

@synthesize jot, name, username, subject, pic, writingAbout, jotDetailTableCell, commentTableCell;

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
    jot = nil;
    username = nil;
    subject = nil;
    pic = nil;
    writingAbout = nil;
    jotDetailTableCell = nil;
    commentTableCell = nil;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *jdtCellIdentifier = @"JotDetailTableCell";
    static NSString *ctCellIdentifier = @"CommentTableCell";
    static NSString *addCellIdentifier = @"AddCellIdentifier";
    
    NSString* identifier = indexPath.section == 0 ? jdtCellIdentifier : ctCellIdentifier;
    identifier = (indexPath.section != 0 && indexPath.row >= [jot.comments count]) ? addCellIdentifier : identifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        if (indexPath.section != 0 && indexPath.row >= [jot.comments count])
        {
           cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:identifier owner: self options: nil];
            if (indexPath.section == 0)
            {
                cell = jotDetailTableCell;
                jotDetailTableCell = nil;
            }
            else
            {
                cell = commentTableCell;
                commentTableCell = nil;
            }
        }
    }
    
    // Configure the cell...
    switch (indexPath.section)
    {
        case 0:
        {
            JotDetailTableCell* jd = (JotDetailTableCell*)cell;
            [jd setJot:jot];
        }
            break;
        case 1:
        {
            if (indexPath.row < [jot.comments count])
            {
                CommentTableCell* com = (CommentTableCell*)cell;
                [com setComment:[jot.comments objectAtIndex:indexPath.row]];
            }
            else
            {
                UITableViewCell* blank = (UITableViewCell*)cell;
                blank.textLabel.text = @"Add a comment";
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : ([jot.comments count] + 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? nil : ([jot.comments count] == 0 ? @"No Comments" : @"Comments");
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self numberOfSectionsInTableView:tableView] == (section+1)){
        return [[UIView new] autorelease];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 24 + [jot detailTextHeight];
        case 1:
        {
            if (indexPath.row < [jot.comments count])
            {
                Comment* com = [jot.comments objectAtIndex:indexPath.row];
                CGFloat textHeight = [com.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0] 
                                                constrainedToSize:CGSizeMake(250, 500) lineBreakMode:UILineBreakModeWordWrap].height;
                return MAX(45, 22 + textHeight);
            }
            else
            {
                return 35;
            }
        }
            break;
        default:
            break;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* selected = [tableView cellForRowAtIndexPath:indexPath];
    [selected setSelected:NO animated:YES];
    
    if (indexPath.section == 1 && indexPath.row >= [jot.comments count])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Add comment" message:@"Will be implemented soon.  :)" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Aww, well get on it!", nil];
        [alert show];
        [alert release];
    }
}

@end
