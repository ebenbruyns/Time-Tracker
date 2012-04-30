//
//  HistoryViewController.h
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

#import <UIKit/UIKit.h>

#import "LabelCell.h"
#import "Report.h"
#import "LookupEditViewController.h"
#import "ReportViewController.h"
#import "TimeTrackerAppDelegate.h"
#import "DetailedReportViewController.h"
#import "StaticSelectionListViewController.h"

@class ReportViewController;
@class DetailedReportViewController;
@class StaticSelectionListViewController;

@interface HistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
	NSDateFormatter *dateFormatter;
	NSNumberFormatter *numberFormatter;
	NSInteger invoicedFlag;
	Report *report;
	LookupEditViewController *lookupEditViewController;
	ReportViewController *customerReportViewController;
	ReportViewController *projectReportViewController;
	ReportViewController *taskReportViewController;
	DetailedReportViewController *detailedReportViewController;
	StaticSelectionListViewController *staticSelectionListViewController;
	IBOutlet UITableView *tableView;
	NSMutableArray *invoicedItems;
}
@property (nonatomic, retain) LookupEditViewController *lookupEditViewController;
@property (nonatomic, retain) ReportViewController *customerReportViewController;
@property (nonatomic, retain) ReportViewController *projectReportViewController;
@property (nonatomic, retain) ReportViewController *taskReportViewController;
@property (nonatomic, retain) StaticSelectionListViewController *staticSelectionListViewController;
@property (nonatomic, retain) DetailedReportViewController *detailedReportViewController;
@property (nonatomic, assign) NSInteger invoicedFlag;

@property (nonatomic, retain) UITableView *tableView;

- (void)restoreState;
@end
