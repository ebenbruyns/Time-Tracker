//
//  AddNewItemViewController.m
//  TimeTracker
//
//  Created by Eben Bruyns on 10/08/08.
//  
//  Copyright (c) 2008-2013, SDK Innovation Ltd.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met: 
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer. 
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution. 
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies, 
//  either expressed or implied, of the FreeBSD Project.

#import "AddNewItemViewController.h"
#import	"LabelCell.h"
#import "SelectionListViewController.h"
#import "TimeTrackerAppDelegate.h"
#import "Item.h"

@implementation AddNewItemViewController

@synthesize tableView, customersListViewController,projectsListViewController,tasksListViewController;
@synthesize dateFormatter,lookupEditViewController, itemToEdit,isNew,toolbar,isHistoric, reportItems;


- (IBAction)cancel:(id)sender {
    // cancel edits
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
	
	TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	//if(isNew)
	//	itemToEdit = [[Item alloc]init];
	
	itemToEdit.comment = [internalItem.comment copy];
	itemToEdit.createDate = internalItem.createDate;
	itemToEdit.customer = [internalItem.customer copy];
	itemToEdit.duration = internalItem.duration;
	itemToEdit.invoiced = internalItem.invoiced;
	itemToEdit.project = [internalItem.project copy];
	itemToEdit.startDate = internalItem.startDate;
	itemToEdit.started = internalItem.started;
	itemToEdit.task = [internalItem.task copy];
	if(isNew)
	{
		[appDelegate addItem:itemToEdit];
		//[itemToEdit release];
	}
	if(isHistoric)
	{
		[appDelegate dehydrateItems];
		[itemToEdit dehydrate];
		[itemToEdit hydrate];
		[appDelegate hydrateItems];
	}
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)delete:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] init];
	alert.title = @"Delete Item?";
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	alert.message = @"Are you sure you want to delete this item?";
	alert.delegate = self;
	
	[alert show];
    [alert release];
	
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
	{
		// the user clicked one of the OK/Cancel buttons
		if (buttonIndex == 0)
		{
			TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate removeItem:itemToEdit];
			if(isHistoric)
			{
				[appDelegate removeItemWithPrimaryKey:itemToEdit.primaryKey];
				[reportItems removeObject:itemToEdit];
			}
			//[itemToEdit release];
			[self.navigationController popViewControllerAnimated:YES];		
		}
		else
		{
		}
		
	}


- (void)viewWillAppear:(BOOL)animated {
	[[self toolbar] setHidden:isNew];
	
	if(self.isNew){
		self.title = @"Add Item";
		//[self.toolbar];
	}
	else {
		self.title = @"Edit Item";
		//[self.toolbar setVisible:YES];
		
	}
	[tableView reloadData];
	
}
-(void)setItemToEdit:(Item *)item {
	if(itemToEdit != nil)
		[itemToEdit release];
	itemToEdit = [item retain];
	//[self.itemToEdit autorelease];
	internalItem.comment = [itemToEdit.comment copy];
	
	internalItem.createDate = itemToEdit.createDate;
	internalItem.customer = [itemToEdit.customer copy];
	internalItem.duration = itemToEdit.duration;
	internalItem.invoiced = itemToEdit.invoiced;
	internalItem.project = [itemToEdit.project copy];
	internalItem.startDate = itemToEdit.startDate;
	internalItem.started = itemToEdit.started;
	internalItem.task = [itemToEdit.task copy];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		internalItem = [[Item alloc] init];
		dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setMaximumFractionDigits:2];
		[numberFormatter setMinimumIntegerDigits:1];
		[numberFormatter setMinimumFractionDigits:2];
		timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[timeFormatter setDateFormat:@"HH:mm"];
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
		self.navigationItem.rightBarButtonItem = saveButton;
		[saveButton release];
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
		//self.editing = YES;
	}
	return self;
}



/*
 Implement loadView if you want to create a view hierarchy programmatically
 - (void)loadView {
 }
 */


- (void)viewDidLoad {
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[toolbar release];
	[itemToEdit release];
	[numberFormatter release];
	[dateFormatter release];
	[customersListViewController release];
	[projectsListViewController release];
	[tasksListViewController release];
	[lookupEditViewController release];
	[internalItem release];
	[reportItems release];
	tableView.delegate = nil;
    tableView.dataSource = nil;
    [tableView release];
	[super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // The number of sections is based on the number of items in the data property list.
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0:
			return 3;
			break;
		case 1:
			return 3;
			break;
		default:
			return 0;
	}
}
/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 return [[data objectAtIndex:section] objectForKey:@"name"];
 }
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.0;
}	
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.0;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
    if (cell == nil) {
        cell = [[[LabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LabelCell"] autorelease];
       // cell.hidesAccessoryWhenEditing = NO;
    }
    // The DetailCell has two modes of display - either a type/name pair or a prompt for creating a new item of a type
    // The type derives from the section, the name from the item.
	if(indexPath.section == 0)
	{
		switch (indexPath.row) {
			case 0:
				cell.titleLabel.text = @"Customer";
				cell.contentLabel.text = internalItem.customer;
				
				break;
				
			case 1:
				cell.titleLabel.text = @"Project";
				cell.contentLabel.text = internalItem.project;
				break;
				
			case 2:
				cell.titleLabel.text = @"Task";
				cell.contentLabel.text = internalItem.task;
				break;
			default:
				break;
		}
	}
	else if(indexPath.section == 1)
	{
		switch (indexPath.row) {
			case 0:
				
				cell.titleLabel.text = @"Hours";
				double dur = (double)internalItem.duration;
				
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				BOOL fractions  = [defaults boolForKey:@"hoursAsFractions"];

				if(fractions)
				{
					
					dur = dur /3600;
					NSNumber *num = [[NSNumber alloc] initWithDouble:dur];
					cell.contentLabel.text = [numberFormatter stringFromNumber:num];	
					[num release];
					
				}
				else
				{
					NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceReferenceDate:dur];
					
					cell.contentLabel.text = [timeFormatter stringFromDate:tmpDate];
				}
				
				
				break;
				
			case 1:
				cell.titleLabel.text = @"Date";
				cell.contentLabel.text = [dateFormatter stringFromDate:internalItem.createDate]; 
				break;
				
			case 2:
				cell.titleLabel.text = @"Comment";
				cell.contentLabel.text = internalItem.comment;
				break;
			default:
				break;
		}
		
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (SelectionListViewController *) projectsListViewController {
	if (projectsListViewController == nil) {
        SelectionListViewController *controller = [[SelectionListViewController alloc] initWithNibName:@"SelectionList" bundle:nil];
        self.projectsListViewController = controller;
        [controller release];
    }
    return projectsListViewController;
	
}

- (SelectionListViewController *) customersListViewController {
	if (customersListViewController == nil) {
        SelectionListViewController *controller = [[SelectionListViewController alloc] initWithNibName:@"SelectionList" bundle:nil];
        self.customersListViewController = controller;
        [controller release];
    }
    return customersListViewController;
	
}

- (SelectionListViewController *) tasksListViewController {
	if (tasksListViewController == nil) {
        SelectionListViewController *controller = [[SelectionListViewController alloc] initWithNibName:@"SelectionList" bundle:nil];
        self.tasksListViewController = controller;
        [controller release];
    }
    return tasksListViewController;
	
}

- (LookupEditViewController *) lookupEditViewController {
	if (lookupEditViewController == nil) {
        LookupEditViewController *controller = [[LookupEditViewController alloc] initWithNibName:@"LookupEdit" bundle:nil];
        self.lookupEditViewController = controller;
        [controller release];
    }
    return lookupEditViewController;
	
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (indexPath.section == 0) {
		// Make a local reference to the editing view controller.
		SelectionListViewController *controller;
		
		//[controller release];
		switch(indexPath.row)
		{
			case 0:
				controller = self.customersListViewController;
				controller.title = @"Customers";
				controller.customers = appDelegate.customers;
				controller.editingItem = internalItem;
				break;
			case 1:
				controller = self.projectsListViewController;

				controller.title = @"Projects";
				controller.projects = appDelegate.projects;
				controller.editingItem = internalItem;
				break;
			case 2:
            default:
				controller = self.tasksListViewController;

				controller.title = @"Tasks";
				controller.tasks = appDelegate.tasks;
				controller.editingItem = internalItem;
				break;
			
		}
		[self.navigationController pushViewController:controller animated:YES];
	}
	else if(indexPath.section == 1) {
		LookupEditViewController *controller = self.lookupEditViewController;
		
		switch(indexPath.row)
		{
			case 0:
				controller.lookUpList = nil;
				controller.editedObject = internalItem;
				//controller.textValue = [NSString stringWithFormat: @"%d", internalItem.duration];
				controller.editedFieldKey = @"duration";
				controller.editTitle = @"Duration";
				controller.item = internalItem;
				controller.dateEditing = NO;
				controller.isNumber = YES;
				controller.isNew = NO;
				break;
			case 1:
				controller.lookUpList = nil;
				controller.editedObject = internalItem;
				controller.textValue = [dateFormatter stringFromDate:internalItem.createDate];
				controller.editedFieldKey = @"createDate";
				controller.editTitle = @"Date";
				controller.dateValue = internalItem.createDate;
				controller.dateEditing = YES;
				controller.isNumber = NO;
				controller.isNew = NO;
				break;
				
			case 2:
				controller.lookUpList = nil;
				controller.editedObject = internalItem;
				controller.textValue = internalItem.comment;
				controller.editedFieldKey = @"comment";
				controller.editTitle = @"Comment";
				controller.isNumber = NO;
				controller.dateEditing = NO;
				controller.isNew = NO;
				break;
				
			default:
				break;
		}
		[self.navigationController pushViewController:controller animated:YES];
	}
}


@end
