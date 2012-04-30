//
//  Task.m
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

#import "Task.h"

static sqlite3_stmt *insert_statement_task = nil;
static sqlite3_stmt *init_statement_task = nil;
static sqlite3_stmt *delete_statement_task = nil;
static sqlite3_stmt *hydrate_statement_task = nil;
static sqlite3_stmt *dehydrate_statement_task = nil;

@implementation Task
// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement_task) sqlite3_finalize(insert_statement_task), insert_statement_task = nil;
    if (init_statement_task) sqlite3_finalize(init_statement_task), init_statement_task = nil;
    if (delete_statement_task) sqlite3_finalize(delete_statement_task), delete_statement_task = nil;
    if (hydrate_statement_task) sqlite3_finalize(hydrate_statement_task), hydrate_statement_task = nil;
    if (dehydrate_statement_task) sqlite3_finalize(dehydrate_statement_task), dehydrate_statement_task = nil;
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
    self = [super init];
    if (self) {
        primaryKey = pk;
        database = db;
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (init_statement_task == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT DisplayValue FROM Task WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement_task, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement_task, 1, primaryKey);
        if (sqlite3_step(init_statement_task) == SQLITE_ROW) {
			char *str = (char *)sqlite3_column_text(init_statement_task, 0);
            self.displayValue = (str) ? [NSString stringWithUTF8String:str] : @"";
        } else {
            self.displayValue = @"...";
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement_task);
        dirty = NO;
    }
    return self;
}

- (void)insertIntoDatabase:(sqlite3 *)db {
    database = db;
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (insert_statement_task == nil) {
        static char *sql = "INSERT INTO Task (DisplayValue) VALUES(?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement_task, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(insert_statement_task, 1, [displayValue UTF8String], -1, SQLITE_TRANSIENT);
    int success = sqlite3_step(insert_statement_task);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement_task);
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
    [displayValue release];
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
    [super dealloc];
}

- (void)deleteFromDatabase {
    // Compile the delete statement if needed.
    if (delete_statement_task == nil) {
        const char *sql = "DELETE FROM Task WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement_task, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement_task, 1, primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_statement_task);
    // Reset the statement for future use.
    sqlite3_reset(delete_statement_task);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)hydrate {
    // Check if action is necessary.
    if (hydrated) return;
    // Compile the hydration statement, if needed.
    if (hydrate_statement_task == nil) {
        const char *sql = "SELECT displayValue, sortOrder FROM Task WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement_task, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(hydrate_statement_task, 1, primaryKey);
    // Execute the query.
    int success =sqlite3_step(hydrate_statement_task);
    if (success == SQLITE_ROW) {
        char *str = (char *)sqlite3_column_text(hydrate_statement_task, 0);
        self.displayValue = (str) ? [NSString stringWithUTF8String:str] : @"";
        self.sortOrder = sqlite3_column_int(hydrate_statement_task, 1);
    } else {
        // The query did not return 
        self.displayValue = @"...";
        self.sortOrder= 0;
    }
    // Reset the query for the next use.
    sqlite3_reset(hydrate_statement_task);
    // Update object state with respect to hydration.
    hydrated = YES;
}

// Flushes all but the primary key and title out to the database.
- (void)dehydrate {
    if (dirty) {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (dehydrate_statement_task == nil) {
            const char *sql = "UPDATE Task SET DisplayValue=?, SortOrder=? WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement_task, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
        sqlite3_bind_text(dehydrate_statement_task, 1, [displayValue UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(dehydrate_statement_task, 2, sortOrder);
        
        sqlite3_bind_int(dehydrate_statement_task, 3, primaryKey);
        // Execute the query.
        int success = sqlite3_step(dehydrate_statement_task);
        // Reset the query for the next use.
        sqlite3_reset(dehydrate_statement_task);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
        // Update the object state with respect to unwritten changes.
        dirty = NO;
    }
    // Release member variables to reclaim memory. Set to nil to avoid over-releasing them 
    // if dehydrate is called multiple times.
    [displayValue release];
    displayValue = nil;
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

- (NSString *)displayValue {
    return displayValue;
}

- (void)setDisplayValue:(NSString *)aString {
    if ((!displayValue && !aString) || (displayValue && aString && [displayValue isEqualToString:aString])) return;
    dirty = YES;
    [displayValue release];
    displayValue = [aString copy];
}

- (NSInteger)sortOrder {
    return sortOrder;
}

- (void)setSortOrder:(NSInteger)aNumber {
    if (sortOrder == aNumber) return;
    dirty = YES;
    sortOrder = aNumber;
}


@end
