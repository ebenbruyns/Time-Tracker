//
//  AddNewItemViewController.h
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

#import <UIKit/UIKit.h>
#import "LookupEditViewController.h"
#import "TimeTrackerAppDelegate.h"

@class SelectionListViewController, Item;

@interface AddNewItemViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>{
    UITableView *tableView;
	LookupEditViewController *lookupEditViewController;

	SelectionListViewController *customersListViewController;
	SelectionListViewController *projectsListViewController;
	SelectionListViewController *tasksListViewController;
	Item *internalItem;
	Item *itemToEdit;
	NSDateFormatter *dateFormatter;
	NSDateFormatter *timeFormatter;
	NSNumberFormatter *numberFormatter;
	BOOL isNew;
	BOOL isHistoric;
	IBOutlet UIToolbar *toolbar;
	NSMutableArray *reportItems;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) SelectionListViewController *customersListViewController;
@property (nonatomic, retain) SelectionListViewController *projectsListViewController;
@property (nonatomic, retain) SelectionListViewController *tasksListViewController;
@property (nonatomic, retain) LookupEditViewController *lookupEditViewController;
@property (nonatomic, retain) NSMutableArray *reportItems;
//@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) Item *itemToEdit;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, assign) BOOL isHistoric;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)delete:(id)sender;
@end
