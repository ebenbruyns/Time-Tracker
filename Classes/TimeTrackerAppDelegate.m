//
//  TimeTrackerAppDelegate.m
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

#import "TimeTrackerAppDelegate.h"

@interface TimeTrackerAppDelegate (hidden)
- (void)initializeItems;
- (void)createEditableCopyOfDatabaseIfNeeded;
@end

@implementation TimeTrackerAppDelegate

@synthesize window;
@synthesize customers,projects, tasks,items,tabBarController;//, outlineData;

/*
- (id)init
{
	self = [super init];
	if (self)
	{
NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:@"outline.plist"];
		outlineData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
	}
	return self;
}
*/

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	
	[self createEditableCopyOfDatabaseIfNeeded];
	[self initializeItems];
	
	UITabBarController *tmpTabBarController = [[UITabBarController alloc] init];
	self.tabBarController = tmpTabBarController;
	[tmpTabBarController release];
	itemsViewController = [[ItemsViewController alloc] initWithNibName:@"ItemsView" bundle:nil];
	HistoryViewController *historyViewController = [[HistoryViewController alloc] initWithNibName:@"HistoryView" bundle:nil];
	
	UINavigationController *itemsNavController = [[[UINavigationController alloc] initWithRootViewController:itemsViewController] autorelease];
		
	UINavigationController *historyNavController = [[[UINavigationController alloc] initWithRootViewController:historyViewController] autorelease];
	[historyViewController release];
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:itemsNavController, historyNavController, nil];
	//tabBarController.selectedIndex = 1; 
	
	[self restoreState];	
	[historyViewController restoreState];
	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	//[self setApplicationBadge:@"1"];
	
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self initializeItems];   
    //[self restoreState];	
	//[historyViewController restoreState];
}

- (void) restoreState {
		
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger selectedTab = [defaults integerForKey:@"selectedTab"];
	
	tabBarController.selectedIndex = selectedTab;
	

}

- (void)initializeCustomers {
    NSMutableArray *customerArray = [[NSMutableArray alloc] init];
    self.customers = customerArray;
    [customerArray release];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = "SELECT pk FROM customer order by SortOrder";
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int primaryKey = sqlite3_column_int(statement, 0);
                Customer *customer = [[Customer alloc] initWithPrimaryKey:primaryKey database:database];
                [customers addObject:customer];
                [customer release];
            }
        }
        sqlite3_finalize(statement);
    } else {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)initializeProjects {
	
    NSMutableArray *projectArray = [[NSMutableArray alloc] init];
    self.projects = projectArray;
    [projectArray release];
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        // Get the primary key for all books.
        const char *sql = "SELECT pk FROM Project order by SortOrder";
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                // The second parameter indicates the column index into the result set.
                int primaryKey = sqlite3_column_int(statement, 0);
                // We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
                // autorelease is slightly more expensive than release. This design choice has nothing to do with
                // actual memory management - at the end of this block of code, all the book objects allocated
                // here will be in memory regardless of whether we use autorelease or release, because they are
                // retained by the books array.
                Project *project = [[Project alloc] initWithPrimaryKey:primaryKey database:database];
                [projects addObject:project];
                [project release];
            }
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

- (void)initializeTasks {
	
    NSMutableArray *taskArray = [[NSMutableArray alloc] init];
    self.tasks = taskArray;
    [taskArray release];
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        // Get the primary key for all books.
        const char *sql = "SELECT pk FROM Task order by SortOrder";
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                // The second parameter indicates the column index into the result set.
                int primaryKey = sqlite3_column_int(statement, 0);
                // We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
                // autorelease is slightly more expensive than release. This design choice has nothing to do with
                // actual memory management - at the end of this block of code, all the book objects allocated
                // here will be in memory regardless of whether we use autorelease or release, because they are
                // retained by the books array.
                Task *task = [[Task alloc] initWithPrimaryKey:primaryKey database:database];
                [tasks addObject:task];
                [task release];
            }
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

- (void)initializeItems {
	
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    self.items = itemArray;
    [itemArray release];
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        BOOL invoiced  = [[NSUserDefaults standardUserDefaults] boolForKey:@"showInvoicedInList"];
		
        const char *sql;
		NSString *sqlString = @"SELECT pk FROM Item %@ order by CreateDate desc Limit 25";
		if(invoiced)
			sql = [[NSString stringWithFormat:sqlString, @""] UTF8String];
		else
			sql = [[NSString stringWithFormat:sqlString, @" where Invoiced = 0 "] UTF8String];
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.   
		int sqlResult = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        if ( sqlResult == SQLITE_OK) {
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                // The second parameter indicates the column index into the result set.
                int primaryKey = sqlite3_column_int(statement, 0);
                // We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
                // autorelease is slightly more expensive than release. This design choice has nothing to do with
                // actual memory management - at the end of this block of code, all the book objects allocated
                // here will be in memory regardless of whether we use autorelease or release, because they are
                // retained by the books array.
                Item *item = [[Item alloc] initWithPrimaryKey:primaryKey database:database];
                [items addObject:item];
                [item release];
            }
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

- (void)setBadge {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		
        const char *sql = "SELECT count(pk) FROM Item where Started = 1";
		sqlite3_stmt *statement;
        //int sqlResult = 
		sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
		//if (sqlResult == SQLITE_OK) {

			if (sqlite3_step(statement) == SQLITE_ROW) {
				int count = sqlite3_column_int(statement, 0);
				[[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];           
			}
		//}
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}


- (NSMutableArray *) customers {
	if(customers == nil)
		[self initializeCustomers];
	return customers;
}

- (NSMutableArray *) projects {
	if(projects == nil)
		[self initializeProjects];
	return projects;
}

- (NSMutableArray *) tasks {
	if(tasks == nil)
		[self initializeTasks];
	return tasks;
}

- (NSMutableArray *) items {
	if(items == nil)
		[self initializeItems];
	return items;
}
- (void) reloadItems {
	if(items == nil)
		return;
	[items release];
	items = nil;
	[self initializeItems];
	itemsViewController.items = nil;

}

- (void)removeCustomer:(Customer *)customer {
	@try {
		[customer deleteFromDatabase];
		[customers removeObject:customer];
	}
	@catch (NSException *exception) {
		
	}
}

- (void)addCustomer:(Customer *)customer {
    [customer insertIntoDatabase:database];
	customer.sortOrder = [customers count];
    [customers addObject:customer];
}

- (void)removeProject:(Project *)project {
	@try {
		[project deleteFromDatabase];
		[projects removeObject:project];
	}
	@catch (NSException *exception) {
		
	}
}

- (void)addProject:(Project *)project {
    [project insertIntoDatabase:database];
	project.sortOrder = [projects count];
    [projects addObject:project];
}

- (void)removeTask:(Task *)task {
	@try {
		[task deleteFromDatabase];
		[tasks removeObject:task];
	}
	@catch (NSException *exception) {
		
	}
}

- (void)addTask:(Task *)task {
    [task insertIntoDatabase:database];
	task.sortOrder = [tasks count];
    [tasks addObject:task];
}
- (void)removeItem:(Item *)item {
	[item deleteFromDatabase];
    [items removeObject:item];
}
- (void)removeItemWithPrimaryKey:(int)key {
	int count = [items count];
	int i = 0;
	for( i = 0; i < count; i++ )
	{
		Item * item = (Item *)[items objectAtIndex:i];
		if(item.primaryKey == key)
		{
			[items removeObject:item];
			break;
		}
	}
		
}
- (void)addItem:(Item *)item{
    [item insertIntoDatabase:database];
    [items insertObject:item atIndex:0];
}

- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"tt.db.rsd"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    [self commitData];
}
 
- (void)applicationWillTerminate:(UIApplication *)application {
 [self commitData];
}
-(void) commitData
{
    // Save changes.
	[self saveAllData];
	[self setBadge];
    [Customer finalizeStatements];
    [Project finalizeStatements];
    [Task finalizeStatements];
	[Item finalizeStatements];
    // Close the database.
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//NSUserDefaults *tmp = [defaults mutableCopy];
	[defaults setInteger:tabBarController.selectedIndex forKey:@"selectedTab"];
	
		
	[[NSUserDefaults standardUserDefaults] synchronize];
	//[[NSUserDefaults standardUserDefaults] setObject:savedLocation forKey:kRestoreLocationKey];

}
- (void)saveAllData {
    [customers makeObjectsPerformSelector:@selector(dehydrate)];
    [projects makeObjectsPerformSelector:@selector(dehydrate)];
    [tasks makeObjectsPerformSelector:@selector(dehydrate)];
	[items makeObjectsPerformSelector:@selector(dehydrate)];
}

- (void)saveItems {
	[items makeObjectsPerformSelector:@selector(dehydrate)];
	[items makeObjectsPerformSelector:@selector(hydrate)];
}
- (void) saveCustomers {
	[customers makeObjectsPerformSelector:@selector(dehydrate)];
	[customers makeObjectsPerformSelector:@selector(hydrate)];
}
- (void) saveProjects {
	[projects makeObjectsPerformSelector:@selector(dehydrate)];
	[projects makeObjectsPerformSelector:@selector(hydrate)];
}
- (void) saveTasks {
	[tasks makeObjectsPerformSelector:@selector(dehydrate)];
	[tasks makeObjectsPerformSelector:@selector(hydrate)];
}
- (void)hydrateItems {
	[items makeObjectsPerformSelector:@selector(hydrate)];
}
- (void)dehydrateItems {
	[items makeObjectsPerformSelector:@selector(dehydrate)];
}

- (void)stopAll {
	[items makeObjectsPerformSelector:@selector(stop)];
}
- (void)dealloc {
	[tasks release];
	[projects release];
	[customers release];
	[itemsViewController release];
 	[window release];
	[super dealloc];
}


@end
