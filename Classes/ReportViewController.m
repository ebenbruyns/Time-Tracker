//
//  ReportViewController.m
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

#import "ReportViewController.h"

@implementation ReportViewController

@synthesize report,tableView,items,subReportViewController, parent;

- (void) restoreState {
	NSString *mode = [[NSUserDefaults standardUserDefaults] stringForKey:@"mode"];
	NSString *cust = [[NSUserDefaults standardUserDefaults] stringForKey:@"customer"];
	NSString *proj = [[NSUserDefaults standardUserDefaults] stringForKey:@"project"];
	
	
	
	if([report.mode isEqualToString:@"c"] && ([mode isEqualToString:@"cp"] || [mode isEqualToString:@"cpt"])) {
		Report *subReport = [[Report alloc] init];
		subReport.startDate = report.startDate;
		subReport.endDate = report.endDate;
		
		ReportViewController *controller =  self.subReportViewController;
		subReport.mode = @"cp";
		subReport.customer = cust;
		controller.items = [subReport buildReport];
		controller.report = subReport;
		controller.title = @"Cust... / Project";
		[subReport release];
		[self.navigationController pushViewController:controller animated:NO];
		if([mode isEqualToString:@"cpt"]) {
			[controller restoreState];
		}
		[controller release];
	} else
		if([report.mode isEqualToString:@"p"] && [mode isEqualToString:@"pt"]) {
			Report *subReport = [[Report alloc] init];
			subReport.startDate = report.startDate;
			subReport.endDate = report.endDate;
			
			ReportViewController *controller =  self.subReportViewController;
			subReport.mode = @"pt";
			subReport.project = proj;
			controller.items = [subReport buildReport];
			controller.report = subReport;
			controller.title = @"Proj... / Tasks";
			[subReport release];
			[self.navigationController pushViewController:controller animated:NO];
			[controller release];
		} else
			if([report.mode isEqualToString:@"cp"] && [mode isEqualToString:@"cpt"]) {
				Report *subReport = [[Report alloc] init];
				subReport.startDate = report.startDate;
				subReport.endDate = report.endDate;
				
				ReportViewController *controller =  self.subReportViewController;
				controller = controller.subReportViewController;
				subReport.mode = @"cpt";
				subReport.customer = cust;
				subReport.project = proj;
				controller.items = [subReport buildReport];
				controller.report = subReport;
				controller.title = @"C... / P... / Tasks";
				[subReport release];
				[self.navigationController pushViewController:controller animated:NO];
				
				[controller release];
				
			}
}
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (NSString *)buildSummaryCsv {
	NSMutableString *csv = [[[NSMutableString alloc] init] autorelease];
	int i;
	if([report.mode isEqualToString:@"c"])
	{
		[csv appendString:@"Customer, Duration\n"];
	}
	if([report.mode isEqualToString:@"p"] || [report.mode isEqualToString:@"cp"])
	{
		[csv appendString:@"Project, Duration\n"];
	}
	if([report.mode isEqualToString:@"cpt"] || [report.mode isEqualToString:@"pt"] || [report.mode isEqualToString:@"t"])
	{
		[csv appendString:@"Task, Duration\n"];
	}
	for(i = 0; i < [items count]; i++)
	{
		ReportItem *item = (ReportItem *)[items objectAtIndex:i];
		[csv appendString:[item csvLine]];
	}
	return [NSString stringWithString:csv];
}
- (NSString *)buildDetailCsv {
	NSMutableString *csv = [[NSMutableString alloc] init];
	[csv autorelease];
	int i;
	NSMutableArray *detailItems = [report buildDetailedReportByMode];
	
	[csv appendString:[Item csvHeader]];
	
	for(i = 0; i < [detailItems count]; i++)
	{
		Item *item = (Item *)[detailItems objectAtIndex:i];
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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *body;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *email  = [defaults stringForKey:@"defaultEmail"];
	TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	//NSString *outMailtoPath;
	NSString *subject;
	UIAlertView *alert = [[UIAlertView alloc] init];
	NSMutableString *filter = [[NSMutableString alloc] init];
	if([report.mode isEqualToString:@"c"]) {
		[filter appendFormat:@" %@",@"Customers"];
	}
	if([report.mode isEqualToString:@"cp"]) {
		[filter appendFormat:@" %@/%@",report.customer, @"Projects"];
	}
	if([report.mode isEqualToString:@"cpt"]) {
		[filter appendFormat:@" %@/%@/%@",report.customer, report.project,@"Tasks"];
	}
	if([report.mode isEqualToString:@"p"]) {
		[filter appendFormat:@" %@",@"Projects"];
	}
	if([report.mode isEqualToString:@"pt"]) {
		[filter appendFormat:@" %@/%@",report.project, @"Tasks"];
	}
	if([report.mode isEqualToString:@"t"]) {
		[filter appendFormat:@" %@",@"Tasks"];
	}
	
	if(report.invoicedMode == 0)
		[filter appendString:@" (All items) "];
	else if(report.invoicedMode == 1)
		[filter appendString:@" (Invoiced) "];
	else if(report.invoicedMode == 2)
	[filter appendString:@" (Not invoiced) "];
	MFMailComposeViewController *mail; 
	switch (buttonIndex	) {
		case 0:
			alert.title = @"Delete Items?";
			[alert addButtonWithTitle:@"OK"];
			[alert addButtonWithTitle:@"Cancel"];
			alert.message = @"Are you sure you want to delete all the items in this report?";
			alert.delegate = self;
			
			[alert show];
			
			break;
		case 1:
			subject = [NSString stringWithFormat:@"Time Tracker detailed report%@: %@ to %@",[NSString stringWithString:filter], 
										 [dateFormatter stringFromDate:self.report.startDate], 
										 [dateFormatter stringFromDate:self.report.endDate]];
			

			body = [self buildDetailCsv];
            
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
			subject = [NSString stringWithFormat:@"Time Tracker summary report%@: %@ to %@",[NSString stringWithString:filter], 
										 [dateFormatter stringFromDate:self.report.startDate], 
										 [dateFormatter stringFromDate:self.report.endDate]];
			
			body = [self buildSummaryCsv];
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
		case 3:
			[report markAsInvoiced];
			[self rebuildReport];
			[appDelegate reloadItems];
			break;
		case 4:
			[report markAsNotInvoiced];
			[self rebuildReport];
			[appDelegate reloadItems];
			break;
		default:
			break;
	}
	[filter release];
	[alert release];
}
- (void)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
	[actionSheet addButtonWithTitle:@"Delete All"];
	[actionSheet addButtonWithTitle:@"Email Details"];
	[actionSheet addButtonWithTitle:@"Email Summary"];
	[actionSheet addButtonWithTitle:@"Mark as Invoiced"];
	[actionSheet addButtonWithTitle:@"Mark as not Invoiced"];
	[actionSheet addButtonWithTitle:@"Cancel"];
	actionSheet.destructiveButtonIndex = 0;
	actionSheet.cancelButtonIndex = 5;
	[actionSheet setDelegate:self];
	//ooch-1[actionSheet showFromTabBar:(UITabBar *)self.tabBarController.view];
	[actionSheet showInView:self.tabBarController.view];
	
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Initialization code
		UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:) ];
		self.navigationItem.rightBarButtonItem = modalButton;
		[modalButton release];
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
		parent = nil;
	}
	return self;
}

- (ReportViewController *) subReportViewController {
	if (subReportViewController == nil) {
        ReportViewController *controller = [[ReportViewController alloc] initWithNibName:@"ReportView" bundle:nil];
        self.subReportViewController = controller;
        [controller release];
    }
    return subReportViewController;
	
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
	[items release];
	[numberFormatter release];
	[timeFormatter release];
	[parent release];
	[report release];
	[tableView release];
	//[subReportViewController release];
	[super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // The number of sections is based on the number of items in the data property list.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return [items count] + 1;
}
- (void)viewWillAppear:(BOOL)animated {
	[[NSUserDefaults standardUserDefaults] setObject:report.customer forKey:@"customer"];
	[[NSUserDefaults standardUserDefaults] setObject:report.project forKey:@"project"];
	[[NSUserDefaults standardUserDefaults] setObject:report.mode forKey:@"mode"];
	[self rebuildReport];
	[tableView reloadData];
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row < [items count])
	{
		ReportCell *cell = (ReportCell *)[tv dequeueReusableCellWithIdentifier:@"ReportCell"];
		if (cell == nil) {
			cell = [[[ReportCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ReportCell"] autorelease];
			//cell.hidesAccessoryWhenEditing = NO;
		}
		ReportItem *item = (ReportItem*)[items objectAtIndex:indexPath.row];
		cell.titleLabel.text = item.name;
		
		double dur = (double)item.duration;
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
			double days =  dur /86400;
			int wholeDays = (int)days;
			
			
			cell.contentLabel.text = [NSString stringWithFormat:@"%d %@", wholeDays, [timeFormatter stringFromDate:tmpDate]];
			
			//cell.contentLabel.text = [timeFormatter stringFromDate:tmpDate];
		}
		
		if(indexPath.row == [items count])
			cell.accessoryType = UITableViewCellAccessoryNone;
		if([report.mode isEqualToString:@"c"]) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else if([report.mode isEqualToString:@"cp"]) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else if([report.mode isEqualToString:@"p"]) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}else
			cell.accessoryType = UITableViewCellAccessoryNone;
		return cell;
	}
	else if( indexPath.row == [items count] )
	{
		TotalCell *cell = (TotalCell *)[tv dequeueReusableCellWithIdentifier:@"TotalCell"];
		if (cell == nil) {
			cell = [[[TotalCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TotalCell"] autorelease];
			//cell.hidesAccessoryWhenEditing = NO;
		}
		if([report.mode isEqualToString:@"t"] || [report.mode isEqualToString:@"cpt"] || [report.mode isEqualToString:@"pt"])
			cell.disclosureOffset = NO;
		else
			cell.disclosureOffset = YES;
		double dur = 0.0;
		int i = 0;
		cell.titleLabel.text = @"Total";
		for(i = 0; i < [items count]; i++)
		{		
			ReportItem *item = (ReportItem*)[items objectAtIndex:i];
		
			dur += (double)item.duration;
		}
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
			double days =  dur /86400;
			int wholeDays = (int)days;
			
			
			cell.contentLabel.text = [NSString stringWithFormat:@"%d %@", wholeDays, [timeFormatter stringFromDate:tmpDate]];
			
			//cell.contentLabel.text = [timeFormatter stringFromDate:tmpDate];
		}
		return cell;
	}
	return nil; //should never reach here.
}
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (indexPath.section == 0 && indexPath.row < [items count]) {
		
		Report *subReport = [[Report alloc] init];
		subReport.startDate = report.startDate;
		subReport.endDate = report.endDate;
		subReport.invoicedMode = report.invoicedMode;
		ReportViewController *controller =  [[ReportViewController alloc] initWithNibName:@"ReportView" bundle:nil];
		
		ReportItem *item = (ReportItem *)[items objectAtIndex:indexPath.row];
		if([report.mode isEqualToString:@"c"]) {
			subReport.mode = @"cp";
			subReport.customer = item.name;
			
			controller.title = @"Cust... / Project";
		} else if([report.mode isEqualToString:@"cp"]) {
			subReport.mode = @"cpt";
			subReport.customer = report.customer;
			subReport.project = item.name;
			controller.title = @"C... / P... / Tasks";
		} else if([report.mode isEqualToString:@"p"]) {
			subReport.mode = @"pt";
			subReport.project = item.name;
			controller.title = @"Proj... / Tasks";
		}
		if([report.mode isEqualToString:@"c"] || [report.mode isEqualToString:@"cp"] || [report.mode isEqualToString:@"p"])
		{
			[appDelegate saveItems];
			controller.items = [subReport buildReport];
			//[report buildReport];
			controller.report = subReport;
			controller.parent = self;
			[self.navigationController pushViewController:controller animated:YES];
		}
		[controller release];
		[subReport release];
	}
}
- (void) rebuildReport {
	[items release];
	items = nil;
	self.items = [report buildReport];
	if(self.parent != nil)
		[parent rebuildReport];
	[tableView reloadData];
}
/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)aTableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row == [items count])
		return UITableViewCellAccessoryNone;
	if([report.mode isEqualToString:@"c"]) {
		return UITableViewCellAccessoryDisclosureIndicator;
	} else if([report.mode isEqualToString:@"cp"]) {
		return UITableViewCellAccessoryDisclosureIndicator;
	} else if([report.mode isEqualToString:@"p"]) {
		return UITableViewCellAccessoryDisclosureIndicator;
	}else
		return UITableViewCellAccessoryNone;
}
 */


@end
