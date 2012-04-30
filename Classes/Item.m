//
//  Item.m
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

#import "Item.h"

static sqlite3_stmt *insert_statement_item = nil;
static sqlite3_stmt *init_statement_item = nil;
static sqlite3_stmt *delete_statement_item = nil;
static sqlite3_stmt *hydrate_statement_item = nil;
static sqlite3_stmt *dehydrate_statement_item = nil;

@implementation Item

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement_item) sqlite3_finalize(insert_statement_item),insert_statement_item = nil;
    if (init_statement_item) sqlite3_finalize(init_statement_item),init_statement_item = nil;
    if (delete_statement_item) sqlite3_finalize(delete_statement_item),delete_statement_item =nil;
    if (hydrate_statement_item) sqlite3_finalize(hydrate_statement_item),hydrate_statement_item=nil;
    if (dehydrate_statement_item) sqlite3_finalize(dehydrate_statement_item),dehydrate_statement_item = nil;
}
-(id)init {
	[super init];
	self.customer = @"";
	self.project = @"";
	self.task = @"";
	self.comment = @"";
	self.createDate = [NSDate date];
	self.startDate = [NSDate date];
	self.invoiced = NO;
	self.started = NO;
	self.duration = 0;
	return self;
}


-(NSString *) csvLine {
	double dur = duration;
	NSString *tmpDuration;
	[self hydrate];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setMaximumFractionDigits:2];
	[numberFormatter setMinimumIntegerDigits:1];
	[numberFormatter setMinimumFractionDigits:2];
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[timeFormatter setDateFormat:@"HH:mm"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL fractions  = [defaults boolForKey:@"hoursAsFractions"];
	
	if(fractions)
	{
		dur = dur /3600;
		NSNumber *num = [[NSNumber alloc] initWithDouble:dur];
		tmpDuration = [numberFormatter stringFromNumber:num];	
		[num release];
	}
	else
	{
		NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceReferenceDate:dur];	
		double days =  dur /86400;
		int wholeDays = (int)days;
		tmpDuration = [NSString stringWithFormat:@"%d %@", wholeDays, [timeFormatter stringFromDate:tmpDate]];
	}
	NSString *tmpCustomer = [Report csvEncode:self.customer];
	NSString *tmpProject = [Report csvEncode:self.project];
	NSString *tmpTask = [Report csvEncode:self.task];
	NSString *tmpComment = [Report csvEncode:self.comment];
	NSString *tmpCreateDate = [Report csvEncode:[dateFormatter stringFromDate:self.createDate]];
	NSString *tmpStartDate = [Report csvEncode:[dateFormatter stringFromDate:self.startDate]];
	NSString *tmpInvoiced = [Report csvEncode:[NSString stringWithFormat:@"%d", self.invoiced]];
	NSString *tmpStarted = [Report csvEncode:[NSString stringWithFormat:@"%d",self.started]];
	tmpDuration = [Report csvEncode:tmpDuration];
	[timeFormatter release];
    [numberFormatter release];
    [dateFormatter release];
	return [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
			tmpCustomer, 
			tmpProject, 
			tmpTask, 
			tmpComment, 
			tmpCreateDate,
			tmpStartDate,
			tmpInvoiced,
			tmpStarted,
			tmpDuration,
			nil];
	
	}

+(NSString *) csvHeader {
	return [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
			@"Customer", 
			@"Project", 
			@"Task", 
			@"Comment", 
			@"CreateDate",
			@"StartDate",
			@"Invoiced",
			@"Started",
			@"Duration",
			nil];
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
    self = [super init];
    if (self) {
        primaryKey = pk;
        database = db;
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (init_statement_item == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT Customer,Project,Task,Duration,Invoiced,StartTime,CreateDate,Started FROM Item WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement_item, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement_item, 1, primaryKey);
        if (sqlite3_step(init_statement_item) == SQLITE_ROW) {
			char * str;
			
			str = (char *)sqlite3_column_text(init_statement_item, 0);
			self.customer = (str) ? [NSString stringWithUTF8String:str] : @"";
			
			str = (char *)sqlite3_column_text(init_statement_item, 1);
			self.project = (str) ? [NSString stringWithUTF8String:str] : @"";
            
			str = (char *)sqlite3_column_text(init_statement_item, 2);
			self.task = (str) ? [NSString stringWithUTF8String:str] : @"";
			
            self.duration = sqlite3_column_double(init_statement_item, 3);
            self.invoiced = sqlite3_column_int(init_statement_item, 4);
			self.startDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement_item, 5)];
			self.createDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(init_statement_item, 6)];
            self.started = sqlite3_column_int(init_statement_item, 7);
		} else {
            self.customer = @"<not found>";
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement_item);
        dirty = NO;
    }
    return self;
}

- (void)insertIntoDatabase:(sqlite3 *)db {
    database = db;
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (insert_statement_item == nil) {
        static char *sql = "INSERT INTO Item (Customer,Project,Task,Duration,Invoiced,StartTime,CreateDate,Started) VALUES(?,?,?,?,?,?,?,?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement_item, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(insert_statement_item, 1, [customer UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement_item, 2, [project UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement_item, 3, [task UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(insert_statement_item, 4, duration);
    sqlite3_bind_int(insert_statement_item, 5, invoiced);
	sqlite3_bind_double(insert_statement_item, 6, [startDate timeIntervalSince1970]);
	sqlite3_bind_double(insert_statement_item, 7, [createDate timeIntervalSince1970]);
    sqlite3_bind_int(insert_statement_item, 8, started);
    int success = sqlite3_step(insert_statement_item);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement_item);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    } else {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        primaryKey = sqlite3_last_insert_rowid(database);
    }
    // All data for the book is already in memory, but has not be written to the database
    // Mark as hydrated to prevent empty/default values from overwriting what is in memory
    hydrated = YES;
}

- (void)dealloc {
    [customer release];
	[project release];
	[task release];
	[comment release];
	[startDate release];
	[createDate release];
	/*if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }*/
    [super dealloc];
}

- (void)deleteFromDatabase {
    // Compile the delete statement if needed.
    if (delete_statement_item == nil) {
        const char *sql = "DELETE FROM Item WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement_item, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement_item, 1, primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_statement_item);
    // Reset the statement for future use.
    sqlite3_reset(delete_statement_item);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}
- (void)start {
	self.started = YES;
	self.startDate = [NSDate date];
}

- (void)stop {
	if(self.started)
	{
		self.started = NO;
		self.duration += [[NSDate date] timeIntervalSinceDate:startDate];
	}
	
}

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)hydrate {
    // Check if action is necessary.
    if (hydrated) return;
    // Compile the hydration statement, if needed.
    if (hydrate_statement_item == nil) {
        const char *sql = "SELECT Customer,Project,Task,Comment,Duration,Invoiced,StartTime,CreateDate,Started FROM Item WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement_item, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(hydrate_statement_item, 1, primaryKey);
    // Execute the query.
    int success =sqlite3_step(hydrate_statement_item);
    if (success == SQLITE_ROW) {
		char * str;
		
		str = (char *)sqlite3_column_text(hydrate_statement_item, 0);
		self.customer = (str) ? [NSString stringWithUTF8String:str] : @"";
		
		str = (char *)sqlite3_column_text(hydrate_statement_item, 1) ;
		self.project = (str) ? [NSString stringWithUTF8String:str] : @"";
		
		str = (char *)sqlite3_column_text(hydrate_statement_item, 2);
		self.task = (str) ? [NSString stringWithUTF8String:str] : @"";
		
		str = (char *)sqlite3_column_text(hydrate_statement_item, 3);
		self.comment = (str) ? [NSString stringWithUTF8String:str] : @"";
		
		self.duration = sqlite3_column_double(hydrate_statement_item, 4);
		self.invoiced = sqlite3_column_int(hydrate_statement_item, 5);
		double dcd = sqlite3_column_double(hydrate_statement_item, 7);
		self.startDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(hydrate_statement_item, 6)];
		self.createDate = [NSDate dateWithTimeIntervalSince1970:dcd];
		self.started = sqlite3_column_int(hydrate_statement_item, 8);
    } else {
        // The query did not return 
        self.customer = @"<not found>";
    }
    // Reset the query for the next use.
    sqlite3_reset(hydrate_statement_item);
    // Update object state with respect to hydration.
    hydrated = YES;
}

// Flushes all but the primary key and title out to the database.
- (void)dehydrate {
	
    if (dirty) {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (dehydrate_statement_item == nil) {
            const char *sql = "UPDATE Item SET Customer =?, Project = ?, Task = ?, Comment = ?, Duration = ?, Invoiced = ?, StartTime = ?, CreateDate = ?, Started = ? WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement_item, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
		sqlite3_bind_text(dehydrate_statement_item, 1, [customer UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement_item, 2, [project UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement_item, 3, [task UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement_item, 4, [comment UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_double(dehydrate_statement_item, 5, duration);
		sqlite3_bind_int(dehydrate_statement_item, 6, invoiced);
		double startTime =  [startDate timeIntervalSince1970];
		double createTime = [createDate timeIntervalSince1970];
		sqlite3_bind_double(dehydrate_statement_item, 7, startTime);
		sqlite3_bind_double(dehydrate_statement_item, 8, createTime);
		sqlite3_bind_int(dehydrate_statement_item, 9, started);

        sqlite3_bind_int(dehydrate_statement_item, 10, primaryKey);
        // Execute the query.
        int success = sqlite3_step(dehydrate_statement_item);
        // Reset the query for the next use.
        sqlite3_reset(dehydrate_statement_item);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
        // Update the object state with respect to unwritten changes.
        dirty = NO;
    }
    // Release member variables to reclaim memory. Set to nil to avoid over-releasing them 
    // if dehydrate is called multiple times.
    [customer release];
	customer = nil;
	[project release];
	project = nil;
	[task release];
	task = nil;
	[comment release];
	comment = nil;
	[startDate release];
	startDate = nil;
	[createDate release];
	createDate = nil;
    // Update the object state with respect to hydration.
    hydrated = NO;
}

#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

- (NSInteger)primaryKey {
    return primaryKey;
}

- (NSString *)customer {
    return customer;
}


- (void)setCustomer:(NSString *)aString {
    if ((!customer && !aString) || (customer && aString && [customer isEqualToString:aString])) return;
    dirty = YES;
    [customer release];
    customer = [aString copy];
}
- (NSString *)project {
    return project;
}


- (void)setProject:(NSString *)aString {
    if ((!project && !aString) || (project && aString && [project isEqualToString:aString])) return;
    dirty = YES;
    [project release];
    project = [aString copy];
}
- (NSString *)task {
    return task;
}


- (void)setTask:(NSString *)aString {
    if ((!task && !aString) || (task && aString && [task isEqualToString:aString])) return;
    dirty = YES;
    [task release];
    task = [aString copy];
}
- (NSString *)comment {
    return comment;
}


- (void)setComment:(NSString *)aString {
    if ((!comment && !aString) || (comment && aString && [comment isEqualToString:aString])) return;
    dirty = YES;
    [comment release];
    comment = [aString copy];
}

- (double)duration {
    return duration;
}

- (void)setDuration:(double)aNumber {
    if (duration == aNumber) return;
    dirty = YES;
    duration = aNumber;
}

- (BOOL)invoiced {
    return invoiced;
}

- (void)setInvoiced:(BOOL)aBool {
    if (invoiced == aBool) return;
    dirty = YES;
    invoiced = aBool;
}

- (NSDate *)startDate {
    return startDate;
}

- (void)setStartDate:(NSDate *)aDate {
    if ((!startDate && !aDate) || (startDate && aDate && [startDate isEqualToDate:aDate])) return;
    dirty = YES;
    [startDate release];
    startDate = [aDate copy];
}

- (NSDate *)createDate {
    return createDate;
}

- (void)setCreateDate:(NSDate *)aDate {
    if ((!createDate && !aDate) || (createDate && aDate && [createDate isEqualToDate:aDate])) return;
    dirty = YES;
    [createDate release];
    createDate = [aDate copy];
}

- (BOOL)started {
    return started;
}

- (void)setStarted:(BOOL)aBool {
    if (started == aBool) return;
    dirty = YES;
    started = aBool;
}


@end
