//
//  TimeTrackerAppDelegate.h
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
#import <sqlite3.h>

#import "ItemsViewController.h"
#import "HistoryViewController.h"
#import "Customer.h"
#import "Project.h"
#import	"Task.h"
#import "Item.h"

@class ItemsViewController;
@class TimeTrackerViewController;

@interface TimeTrackerAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	NSMutableArray *customers;
	NSMutableArray *projects;
	NSMutableArray *tasks;
	NSMutableArray *items;
	sqlite3 *database;	
	UITabBarController *tabBarController;
	ItemsViewController *itemsViewController;
	//NSDictionary *outlineData;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *customers;
@property (nonatomic, retain) NSMutableArray *projects;
@property (nonatomic, retain) NSMutableArray *tasks;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) UITabBarController *tabBarController;
//@property (nonatomic, retain) NSDictionary *outlineData;

- (void) restoreState;
- (void) saveAllData;
- (void) saveItems;
- (void) saveCustomers;
- (void) saveProjects;
- (void) saveTasks;

- (void)hydrateItems;
- (void)dehydrateItems;

- (void)removeCustomer:(Customer *)customer;
- (void)addCustomer:(Customer *)customer;

- (void)removeProject:(Project *)project;
- (void)addProject:(Project *)project;

- (void)removeTask:(Task *)task;
- (void)addTask:(Task *)task;

- (void)removeItem:(Item *)item;
- (void)addItem:(Item *)item;
- (void)removeItemWithPrimaryKey:(int)key;

- (void)stopAll;
- (void) reloadItems;
-(void) commitData;

@end
