//
//  DetailedReportViewController.m
//  TimeTracker
//
//  Created by Eben Bruyns on 20/08/08.
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

#import "DetailedReportViewController.h"


@implementation DetailedReportViewController

@synthesize addNewItemViewController,items, tableView, report;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = @"Detailed History";
		UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:) ];
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
		
	}
	return self;
}
- (NSString *)buildDetailCsv {
	NSMutableString *csv = [[NSMutableString alloc] init];
	[csv autorelease];
	int i;
		
	[csv appendString:[Item csvHeader]];
	
	for(i = 0; i < [items count]; i++)
	{
		Item *item = (Item *)[items objectAtIndex:i];
		[item hydrate];
		[csv appendString:[item csvLine]];
	}
	
	return [NSString stringWithString:csv];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		[report deleteReport];
		[items removeAllObjects];
		[tableView reloadData];
		
		//[self rebuildReport];
		[appDelegate reloadItems];
	}
}
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *body;
	NSString *subject;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *email  = [defaults stringForKey:@"defaultEmail"];
	TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIAlertView *alert = [[UIAlertView alloc] init];
	NSString * filter;
	if(report.invoicedMode == 0)
		filter = @" (All items) ";
	else if(report.invoicedMode == 1)
		filter = @" (Invoiced) ";
	else //if(report.invoicedMode == 2)
		filter = @" (Not invoiced) ";
	//Pass that temp directory location in attachment=
	//NSString *outMailtoPath;
	switch (buttonIndex	) {
		case 0:
			alert.title = @"Delete Item?";
			[alert addButtonWithTitle:@"OK"];
			[alert addButtonWithTitle:@"Cancel"];
			alert.message = @"Are you sure you want to delete all the items in this report?";
			alert.delegate = self;
			
			[alert show];
			break;
		case 1:
			body = [self buildDetailCsv];
			subject = [NSString stringWithFormat:@"Time Tracker detailed report%@: %@ to %@", filter,
										 [dateFormatter stringFromDate:self.report.startDate], 
										 [dateFormatter stringFromDate:self.report.endDate]];
			MFMailComposeViewController *mail;
            if([MFMailComposeViewController canSendMail])
            {
                mail = [[MFMailComposeViewController alloc] init];
                [mail setMailComposeDelegate:self];
                [mail setSubject:subject];
                if(email)
                    [mail setToRecipients:[NSArray arrayWithObject:email]];
                [mail addAttachmentData:[body dataUsingEncoding:NSUnicodeStringEncoding] mimeType:@"text/csv" fileName:@"Report.csv"];
                [self.tabBarController presentModalViewController:mail animated:YES];
                [mail release],mail=nil;
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't send mail from this device" message:@"Unable to send mail from this device, check your mail client configuration" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
            }
			//outMailtoPath = [NSString stringWithFormat:@"mailto:%@?body=%@&subject=%@", email,body,subject, nil];
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:outMailtoPath]];
			break;
		case 2:
			[report markAsInvoiced];
			self.items = [report buildDetailedReport];
			[appDelegate reloadItems];
			[tableView reloadData];
			break;
		case 3:
			[report markAsNotInvoiced];
			self.items = [report buildDetailedReport];
			[appDelegate reloadItems];
			[tableView reloadData];
			break;
		default:
			break;
	}
	[alert release];
}
- (void)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
	[actionSheet addButtonWithTitle:@"Delete All"];
	[actionSheet addButtonWithTitle:@"Email Details"];
	[actionSheet addButtonWithTitle:@"Mark as Invoiced"];
	[actionSheet addButtonWithTitle:@"Mark as not Invoiced"];
	[actionSheet addButtonWithTitle:@"Cancel"];
	actionSheet.destructiveButtonIndex = 0;
	actionSheet.cancelButtonIndex = 4;
	[actionSheet setDelegate:self];
	
	[actionSheet showFromTabBar:(UITabBar *)self.tabBarController.view];
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
	[dateFormatter release];
	[numberFormatter release];
	[report release];

	[super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *MyIdentifier = @"DetailedReportCell";
	
	DetailReportViewCell *cell = (DetailReportViewCell *)[tv dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[DetailReportViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
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
	double dur = (double)item.duration;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL fractions  = [defaults boolForKey:@"hoursAsFractions"];
	
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
		
		//cell.durationLabel.text = [timeFormatter stringFromDate:tmpDate];
	}
	cell.createDateLabel.text = [dateFormatter stringFromDate:item.createDate]; 
	cell.commentLabel.text = item.comment;
	//cell.text = @"test";
	return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	/*TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	Item * item = [items objectAtIndex:indexPath.row];
	BOOL shouldStart = !item.started;
	[appDelegate stopAll];
	
	if(shouldStart) {
		[item start];
	}
	[tableView reloadData];*/
	//[item release];
	
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	self.addNewItemViewController.itemToEdit = (Item *)[self.items objectAtIndex:indexPath.row];
	self.addNewItemViewController.isNew = NO;
	self.addNewItemViewController.isHistoric = YES;
	self.addNewItemViewController.reportItems = items;
	[[self navigationController] pushViewController:self.addNewItemViewController animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];	
	[[NSUserDefaults standardUserDefaults] setObject:@"d" forKey:@"mode"];

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)aTableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	/*
	Item* item = (Item *)[items objectAtIndex:indexPath.row];
	[item hydrate];
	if(item.started)
		return UITableViewCellAccessoryCheckmark;
	else*/
		return UITableViewCellAccessoryDetailDisclosureButton;
}



@end
