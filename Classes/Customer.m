//
//  Customer.m
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

#import "Customer.h"

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;

@implementation Customer

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) sqlite3_finalize(insert_statement), insert_statement = nil;
    if (init_statement) sqlite3_finalize(init_statement), init_statement = nil;
    if (delete_statement) sqlite3_finalize(delete_statement), delete_statement = nil;
    if (hydrate_statement) sqlite3_finalize(hydrate_statement), hydrate_statement = nil;
    if (dehydrate_statement) sqlite3_finalize(dehydrate_statement), dehydrate_statement = nil;
    
}

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
    self = [super init];
    if (self) {
        primaryKey = pk;
        database = db;
        if (init_statement == nil) {
            const char *sql = "SELECT DisplayValue FROM Customer WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        sqlite3_bind_int(init_statement, 1, primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			char * str = (char *)sqlite3_column_text(init_statement, 0);
            self.displayValue = (str) ? [NSString stringWithUTF8String:str] : @"";
        } else {
            self.displayValue = @"...";
        }
        sqlite3_reset(init_statement);
        dirty = NO;
    }
    return self;
}

- (void)insertIntoDatabase:(sqlite3 *)db {
    database = db;
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO Customer (DisplayValue) VALUES(?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(insert_statement, 1, [displayValue UTF8String], -1, SQLITE_TRANSIENT);
    int success = sqlite3_step(insert_statement);
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    } else {
        primaryKey = sqlite3_last_insert_rowid(database);
    }
    hydrated = YES;
}

- (void)dealloc {
    [displayValue release];
	displayValue = nil;
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
    [super dealloc];
}

- (void)deleteFromDatabase {
    if (delete_statement == nil) {
        const char *sql = "DELETE FROM Customer WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_int(delete_statement, 1, primaryKey);
    int success = sqlite3_step(delete_statement);
    sqlite3_reset(delete_statement);
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)hydrate {
    if (hydrated) return;
    if (hydrate_statement == nil) {
        const char *sql = "SELECT displayValue, sortOrder FROM Customer WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_int(hydrate_statement, 1, primaryKey);
    int success =sqlite3_step(hydrate_statement);
    if (success == SQLITE_ROW) {
        char *str = (char *)sqlite3_column_text(hydrate_statement, 0);
        self.displayValue = (str) ? [NSString stringWithUTF8String:str] : @"";
        self.sortOrder = sqlite3_column_int(hydrate_statement, 1);
    } else {
        self.displayValue = @"...";
        self.sortOrder= 0;
    }
    sqlite3_reset(hydrate_statement);
    hydrated = YES;
}

- (void)dehydrate {
    if (dirty) {
        if (dehydrate_statement == nil) {
            const char *sql = "UPDATE Customer SET DisplayValue=?, SortOrder=? WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        sqlite3_bind_text(dehydrate_statement, 1, [displayValue UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(dehydrate_statement, 2, sortOrder);
        
        sqlite3_bind_int(dehydrate_statement, 3, primaryKey);
        int success = sqlite3_step(dehydrate_statement);
        sqlite3_reset(dehydrate_statement);
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
        dirty = NO;
    }
    [displayValue release];
    displayValue = nil;
    hydrated = NO;
}

#pragma mark Properties

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
