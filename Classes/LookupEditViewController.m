//
//  LookupEditViewController.m
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

#import "LookupEditViewController.h"
#import "Customer.h"
#import "Project.h"
#import	"Task.h"

#import "TimeTrackerAppDelegate.h"

@implementation LookupEditViewController
@synthesize textValue, editedObject, editedFieldKey, dateEditing, dateValue, textField, dateFormatter,lookUpList,isNew,editTitle,isNumber,item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Create a date formatter to convert the date to a string format.
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setMaximumFractionDigits:2];
		[numberFormatter setMinimumIntegerDigits:1];
		[numberFormatter setMinimumFractionDigits:2];
		timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[timeFormatter setDateFormat:@"HH:mm"];
		
		[datePicker setDate:[NSDate date]];
        datePicker.timeZone = [NSTimeZone localTimeZone];
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
		self.navigationItem.rightBarButtonItem = saveButton;
		[saveButton release];
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    if (theTextField == textField) {
        [textField resignFirstResponder];
        // Invoke the method that changes the greeting.
        [self doSave];
    }
    return YES;
}

- (void)viewDidLoad {
    // Adjust the text field size and font.
    CGRect frame = textField.frame;
    frame.size.height += 10;
    textField.frame = frame;
    textField.font = [UIFont boldSystemFontOfSize:16];
    // Set the view background to match the grouped tables in the other views.
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[item release];
	[lookUpList release];
    [dateFormatter release];
	[numberFormatter release];
    [datePicker release];
    [textValue release];
    [editedObject release];
    [editedFieldKey release];
    [dateValue release];
    [super dealloc];
}

- (IBAction)cancel:(id)sender {
    // cancel edits
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
[self doSave];
}
- (void)doSave {
	// save edits
	if([textField.text isEqualToString:@""])
		return;
    if (dateEditing) {
        [editedObject setValue:datePicker.date forKey:editedFieldKey];
    } else if(isNumber) {
		item.duration = datePicker.countDownDuration;
		
		//item.duration = [NSNumber n initWithString: textField.text];
	} else {
        [editedObject setValue:textField.text forKey:editedFieldKey];
    }
	if(lookUpList != nil && isNew)
	{
		TimeTrackerAppDelegate *appDelegate = (TimeTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
		if([editTitle isEqualToString: @"Customer"]) {
			[appDelegate addCustomer:editedObject];
		} else if([editTitle isEqualToString: @"Project"]) {
			[appDelegate addProject:editedObject];
		} else if([editTitle isEqualToString: @"Task"]) {
			[appDelegate addTask:editedObject];
		}
	}
    [self.navigationController popViewControllerAnimated:YES];
}	

- (void)viewWillAppear:(BOOL)animated {
    NSString *capitalizedEditTitle = [editTitle capitalizedString];
    self.title = capitalizedEditTitle;
    textField.placeholder = capitalizedEditTitle;
	
    if (dateEditing) {
        textField.enabled = NO;
		[datePicker setHidden:NO];
        if (dateValue == nil) self.dateValue = [NSDate date];
        textField.text = [dateFormatter stringFromDate:dateValue];
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.date = dateValue;
        datePicker.timeZone = [NSTimeZone localTimeZone];
    } else if(isNumber) {
		textField.enabled = NO;
		datePicker.countDownDuration = item.duration;
        datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
		[datePicker setHidden:NO];
		double dur = (double)item.duration;
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL fractions  = [defaults boolForKey:@"hoursAsFractions"];
		[datePicker setMinuteInterval:[defaults integerForKey:@"timeInterval"]];
		
		if(fractions)
		{
			dur = dur /3600;
			NSNumber *num = [[NSNumber alloc] initWithDouble:dur];
			textField.text = [numberFormatter stringFromNumber:num];	
			[num release];
		}
		else
		{
			NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceReferenceDate:dur];			
			textField.text = [timeFormatter stringFromDate:tmpDate];
		}
		
		
				
		
	} else {
		[textField setKeyboardType:UIKeyboardTypeAlphabet];
        textField.enabled = YES;
        textField.text = textValue;
		[datePicker setHidden:YES];
        [textField becomeFirstResponder];
    }
	
}

- (IBAction)dateChanged:(id)sender {
    if (dateEditing) textField.text = [dateFormatter stringFromDate:datePicker.date];
	if (isNumber) {
		double dur = (double)datePicker.countDownDuration;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL fractions  = [defaults boolForKey:@"hoursAsFractions"];
		
		if(fractions)
		{
			dur = dur /3600;
			NSNumber *num = [[NSNumber alloc] initWithDouble:dur];
			textField.text = [numberFormatter stringFromNumber:num];	
			[num release];
		}
		else
		{
			NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceReferenceDate:dur];			
			textField.text = [timeFormatter stringFromDate:tmpDate];
		}
		
	}
}
@end
