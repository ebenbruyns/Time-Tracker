//
//  ItemsViewController.m
//  TimeTracker
//
//  Created by Eben Bruyns on 18/08/08.
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

#import "ItemsViewController.h"


@implementation ItemsViewController
@synthesize addNewItemViewController,items, tableView;

-(NSMutableArray *)items
{
	if(items == nil)
	{
		TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.items = appDelegate.items;
	}
	return items;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = @"Items";	
		UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMostRecent tag:1];
		self.tabBarItem = tabBarItem;
		[tabBarItem release];
		
		UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddNewItem:) ];
		self.navigationItem.rightBarButtonItem = modalButton;
		
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
		BOOL autoUpdateTimers  = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoUpdateTimers"];
		if(autoUpdateTimers) {
			NSTimer *timer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(reloadTable:) userInfo:nil repeats:YES];
		
			[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
			//[timer release];
		}
		
	}
	return self;
}
- (void)reloadTable:(id)sender {
	[tableView reloadData];
}

- (AddNewItemViewController *)addNewItemViewController {
	if(addNewItemViewController == nil)
	{
		AddNewItemViewController *controller = [[AddNewItemViewController alloc] initWithNibName:@"AddNewItem" bundle:nil];
		self.addNewItemViewController = controller;
		[controller release];
	}
	return addNewItemViewController;
}

- (IBAction) showAddNewItem:(id)sender {
	
	self.addNewItemViewController.isNew = YES;
	self.addNewItemViewController.isHistoric = NO;
	
	Item *tmp = [[Item alloc] init];
	[tmp autorelease];
	self.addNewItemViewController.itemToEdit = tmp;
	[[self navigationController] pushViewController:self.addNewItemViewController animated:YES];
	
}


- (void)awakeFromNib {
	
	
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
	[dateFormatter release];
	[numberFormatter release];
	//[addNewItemViewController release];
	[super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *MyIdentifier = @"ItemCell";
	
	ItemViewCell *cell = (ItemViewCell *)[tv dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[ItemViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
		//cell.hidesAccessoryWhenEditing = NO;
	}
	
	Item* item = (Item *)[items objectAtIndex:indexPath.row];
	[item hydrate];
	cell.customerLabel.text = item.customer;
	cell.projectLabel.text = item.project;
	cell.taskLabel.text	= item.task;
	if(item.started) {
		cell.indicator.text = @"";
		
	}
	else {
		cell.indicator.text = @"";
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL fractions  = [defaults boolForKey:@"hoursAsFractions"];
	
	double dur = (double)item.duration;
	if(fractions)
	{
		if(item.started) {
			dur += [[NSDate date] timeIntervalSinceDate:item.startDate];
		}
		dur = dur /3600;
		NSNumber *num = [[NSNumber alloc] initWithDouble:dur];
		cell.durationLabel.text = [numberFormatter stringFromNumber:num];	
		[num release];
		
	}
	else
	{
		NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceReferenceDate:dur];
		double days =  dur /86400;
		int wholeDays = (int)days;
		
		
		cell.durationLabel.text = [NSString stringWithFormat:@"%d %@", wholeDays, [timeFormatter stringFromDate:tmpDate]];
	}
	cell.createDateLabel.text = [dateFormatter stringFromDate:item.createDate]; 
	
	if(item.started)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	//cell.text = @"test";
	return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	Item * item = [items objectAtIndex:indexPath.row];
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *createDateComponents =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:item.createDate]; 
	
	NSDateComponents *currentDateComponents =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
	
	BOOL shouldStart = !item.started;
	BOOL multiTimers  = [[NSUserDefaults standardUserDefaults] boolForKey:@"multiTimers"];
	if(!multiTimers)
	{
		[appDelegate stopAll];
	}
	if( [createDateComponents year] == [currentDateComponents year] &&
	   [createDateComponents month] == [currentDateComponents month] &&
	   [createDateComponents day] == [currentDateComponents day] )
	{
		
		if(shouldStart) {
			[item start];
		}
		else {
			if(multiTimers) {
				[item stop];
			}
		}
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] init];
		alert.title = @"Create New Item?";
		[alert addButtonWithTitle:@"Cancel"];
		[alert addButtonWithTitle:@"OK"];
		alert.message = @"This item is not current would you like to create a current copy?";
		alert.delegate = self;
		if(item.started)
			[item stop];
		newItem = [[Item alloc] init];
		newItem.comment = item.comment;
		newItem.createDate = [NSDate date];
		newItem.customer = item.customer;
		newItem.duration = 0;
		newItem.project = item.project;
		newItem.task = item.task;
		[newItem start];		
		[alert show];
        [alert release];
		
		
	}
	[tableView reloadData];
	//[item release];
	[gregorian release];
	
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 1)
	{
		TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate addItem:newItem];
		[tableView reloadData];
	}
	[newItem release];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	self.addNewItemViewController.itemToEdit = (Item *)[self.items objectAtIndex:indexPath.row];
	self.addNewItemViewController.isNew = NO;
	self.addNewItemViewController.isHistoric = NO;
	[[self navigationController] pushViewController:self.addNewItemViewController animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

/*

- (UITableViewCellAccessoryType)tableView:(UITableView *)aTableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	Item* item = (Item *)[items objectAtIndex:indexPath.row];
	[item hydrate];
	if(item.started)
		return UITableViewCellAccessoryCheckmark;
	else
		return UITableViewCellAccessoryDetailDisclosureButton;
}
*/

@end
