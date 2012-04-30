//
//  HistoryViewController.m
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

#import "HistoryViewController.h"


@implementation HistoryViewController
@synthesize lookupEditViewController, tableView, taskReportViewController,customerReportViewController,projectReportViewController,detailedReportViewController;
@synthesize staticSelectionListViewController,invoicedFlag;

/*- (void)invoicedFlag:(NSInteger) newValue {
	invoicedFlag = newValue;
	NSString *tmp = (NSString *)[invoicedItems objectAtIndex:invoicedFlag];
	
}*/
- (void)restoreState {
	invoicedFlag =  [[NSUserDefaults standardUserDefaults] integerForKey:@"invoicedFlag"];
	double tmp =  [[NSUserDefaults standardUserDefaults] doubleForKey:@"startDate"];
	report.invoicedMode = invoicedFlag;
	if(tmp == 0) {
		report.endDate = [NSDate date];
	}
	else {
		report.startDate = [NSDate dateWithTimeIntervalSince1970:tmp];
	}
	tmp =  [[NSUserDefaults standardUserDefaults] doubleForKey:@"endDate"];
	
	if(tmp == 0) {
		double interval = [report.endDate timeIntervalSince1970];
		interval -= 60*60*24*7;
		report.startDate = [NSDate dateWithTimeIntervalSince1970:interval];
	}	
	else {
		report.endDate = [NSDate dateWithTimeIntervalSince1970:tmp];
	}
	NSString *mode = [[NSUserDefaults standardUserDefaults] stringForKey:@"mode"];
	NSString *cust = [[NSUserDefaults standardUserDefaults] stringForKey:@"customer"];
	NSString *proj = [[NSUserDefaults standardUserDefaults] stringForKey:@"project"];
	report.customer = cust;
	report.project = proj;
	if([mode isEqualToString:@"d"]) {
		DetailedReportViewController *controller =  self.detailedReportViewController;
		controller.items = [report buildDetailedReport];
		controller.report = report;
		[self.navigationController pushViewController:controller animated:NO];
	} else if ([mode isEqualToString:@"c"] || [mode isEqualToString:@"cp"] ||  [mode isEqualToString:@"cpt"]) {
		report.mode = @"c";
		ReportViewController *controller;
		controller = self.customerReportViewController;
		controller.title = @"Customers";
		controller.items = [report buildReport];
		controller.report = report;
		
		[self.navigationController pushViewController:controller animated:NO];
		[controller restoreState];
	} else if ([mode isEqualToString:@"p"] || [mode isEqualToString:@"pt"]) {
		report.mode = @"p";
		ReportViewController *controller;
		controller = self.customerReportViewController;
		controller.title = @"Projects";
		controller.items = [report buildReport];
		controller.report = report;
		//[controller restoreState];
		[self.navigationController pushViewController:controller animated:NO];
		[controller restoreState];
	} else if ([mode isEqualToString:@"t"]) {
		report.mode	= @"t";
		ReportViewController *controller;
		controller = self.customerReportViewController;
		controller.title = @"Tasks";
		controller.items = [report buildReport];
		controller.report = report;
		//[controller restoreState];
		[self.navigationController pushViewController:controller animated:NO];
		[controller restoreState];
	}
	
	   
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = @"History";
		UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:0];
		self.tabBarItem = tabBarItem;
		[tabBarItem release];
		
		invoicedItems = [[NSMutableArray alloc] init];
		[invoicedItems addObject:@"All"];
		[invoicedItems addObject:@"Yes"];
		[invoicedItems addObject:@"No"];
		
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setMaximumFractionDigits:2];
		[numberFormatter setMinimumIntegerDigits:1];
		[numberFormatter setMinimumFractionDigits:2];
		report = [[Report alloc] init];
		report.endDate = [NSDate date];
		double interval = [report.endDate timeIntervalSince1970];
		interval -= 60*60*24*7;
		report.startDate = [NSDate dateWithTimeIntervalSince1970:interval];
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // The number of sections is based on the number of items in the data property list.
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0:
			return 3;
			break;
		case 1:
			return 3;
			break;
		case 2:
			return 1;
			break;
		default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
	if(indexPath.section == 0)
	{
		LabelCell *cell = (LabelCell *)[tv dequeueReusableCellWithIdentifier:@"LabelCell"];
		if (cell == nil) {
			cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LabelCell"] autorelease];
			//cell.hidesAccessoryWhenEditing = NO;
			
		}
		switch (indexPath.row) {
			case 0:
				cell.titleLabel.text = @"Start date";
				cell.contentLabel.text = [dateFormatter stringFromDate:report.startDate]; 
				
				break;
				
			case 1:
				cell.titleLabel.text = @"End date";
				cell.contentLabel.text = [dateFormatter stringFromDate:report.endDate]; 
			break;
			case 2:
				cell.titleLabel.text = @"Invoiced";
				cell.contentLabel.text =(NSString *)[invoicedItems objectAtIndex:invoicedFlag]; 
				break;
			default:
				break;
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		 return cell;
	}
	else if(indexPath.section == 1)
	{
		UITableViewCell *cell = (UITableViewCell *)[tv dequeueReusableCellWithIdentifier:@"SingleItem"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SingleItem"] autorelease];
			//cell.hidesAccessoryWhenEditing = NO;
		}
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"By customer";
				
				break;
				
			case 1:
				cell.textLabel.text = @"By project";
				break;
				
			case 2:
				cell.textLabel.text = @"By task";
				break;
			default:
				break;
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		 return cell;
	}
	else if(indexPath.section == 2) {
		UITableViewCell *cell = (UITableViewCell *)[tv dequeueReusableCellWithIdentifier:@"SingleItem"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SingleItem"] autorelease];
			//cell.hidesAccessoryWhenEditing = NO;
		}
		cell.textLabel.text = @"Detailed";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
	
	return nil; //should never reach here - just keeping the compiler happy.
}
- (LookupEditViewController *) lookupEditViewController {
	if (lookupEditViewController == nil) {
        LookupEditViewController *controller = [[LookupEditViewController alloc] initWithNibName:@"LookupEdit" bundle:nil];
        self.lookupEditViewController = controller;
        [controller release];
    }
    return lookupEditViewController;
	
}
- (ReportViewController *) projectReportViewController {
	if (projectReportViewController == nil) {
        ReportViewController *controller = [[ReportViewController alloc] initWithNibName:@"ReportView" bundle:nil];
        self.projectReportViewController = controller;
        [controller release];
    }
    return projectReportViewController;
	
}
- (ReportViewController *) taskReportViewController {
	if (taskReportViewController == nil) {
        ReportViewController *controller = [[ReportViewController alloc] initWithNibName:@"ReportView" bundle:nil];
        self.taskReportViewController = controller;
        [controller release];
    }
    return taskReportViewController;
	
}
- (ReportViewController *) customerReportViewController {
	if (customerReportViewController == nil) {
        ReportViewController *controller = [[ReportViewController alloc] initWithNibName:@"ReportView" bundle:nil];
        self.customerReportViewController = controller;
        [controller release];
    }
    return customerReportViewController;
	
}
- (DetailedReportViewController *) detailedReportViewController {
	if (detailedReportViewController == nil) {
        DetailedReportViewController *controller = [[DetailedReportViewController alloc] initWithNibName:@"DetailedReportView" bundle:nil];
        self.detailedReportViewController = controller;
        [controller release];
    }
    return detailedReportViewController;
	
}

- (StaticSelectionListViewController *) staticSelectionListViewController {
	if (staticSelectionListViewController == nil) {
        StaticSelectionListViewController *controller = [[StaticSelectionListViewController alloc] initWithNibName:@"StaticSelectionList" bundle:nil];
        self.staticSelectionListViewController = controller;
		staticSelectionListViewController.items = invoicedItems;

        [controller release];
    }
    return staticSelectionListViewController;
	
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (indexPath.section == 0) {
		// Make a local reference to the editing view controller.
		LookupEditViewController *controller = self.lookupEditViewController;
		StaticSelectionListViewController *listController = self.staticSelectionListViewController;
		
		switch(indexPath.row)
		{
			case 0:
				controller.lookUpList = nil;
				controller.editedObject = report;
				controller.textValue = [dateFormatter stringFromDate:report.startDate];
				controller.editedFieldKey = @"startDate";
				controller.editTitle = @"Start Date";
				controller.dateValue = report.startDate;
				controller.dateEditing = YES;
				controller.isNumber = NO;
				controller.isNew = NO;
				[self.navigationController pushViewController:controller animated:YES];
				break;
			case 1:
				controller.lookUpList = nil;
				controller.editedObject = report;
				controller.textValue = [dateFormatter stringFromDate:report.endDate];
				controller.editedFieldKey = @"endDate";
				controller.editTitle = @"End Date";
				controller.dateValue = report.endDate;
				controller.dateEditing = YES;
				controller.isNumber = NO;
				controller.isNew = NO;
				[self.navigationController pushViewController:controller animated:YES];
				break;
			case 2:
            default:
				listController.historyViewController = self;
				listController.selectedIndex = invoicedFlag;
				[self.navigationController pushViewController:listController animated:YES];
				break;
			
			//	break;
		}
		
	}
	else if(indexPath.section == 1) {
		ReportViewController *controller;

		
		switch(indexPath.row)
		{
			case 0:
				controller = self.customerReportViewController;
				report.mode = @"c";
				report.invoicedMode = invoicedFlag;
				controller.title = @"Customers";
				break;
			case 1:
				controller = self.projectReportViewController;
				report.mode = @"p";
				report.invoicedMode = invoicedFlag;
				controller.title = @"Projects";
				break;
				
			case 2:
            default:
				controller = self.taskReportViewController;
				report.mode = @"t";
				report.invoicedMode = invoicedFlag;
				controller.title = @"Tasks";
				break;
				
			
		}
		[appDelegate saveItems];
		controller.items = [report buildReport];
		//[report buildReport];
		controller.report = report;
		[self.navigationController pushViewController:controller animated:YES];
	}
	else if(indexPath.section == 2) {
		DetailedReportViewController *controller =  self.detailedReportViewController;
		
		
		switch(indexPath.row)
		{
			case 0:
				report.invoicedMode = invoicedFlag;
				controller.items = [report buildDetailedReport];
				controller.report = report;
				
				break;
				
			default:
				break;
		}
		[appDelegate saveItems];
		//controller.report = report;
		[self.navigationController pushViewController:controller animated:YES];
	}
	
	
}




// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
	[[NSUserDefaults standardUserDefaults] setDouble:[report.startDate timeIntervalSince1970] forKey:@"startDate"];
	[[NSUserDefaults standardUserDefaults] setDouble:[report.endDate timeIntervalSince1970] forKey:@"endDate"];
	[[NSUserDefaults standardUserDefaults] setObject:report.customer forKey:@"customer"];
	[[NSUserDefaults standardUserDefaults] setObject:report.project forKey:@"project"];
	[[NSUserDefaults standardUserDefaults] setObject:@"n" forKey:@"mode"];
	[[NSUserDefaults standardUserDefaults] setInteger:invoicedFlag forKey:@"invoicedFlag"];
	[tableView reloadData];
}

@end
