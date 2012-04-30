//
//  Item.h
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
#import "Customer.h"
#import "Report.h"

@class Report;
@interface Item : NSObject {
	// Opaque reference to the underlying database.
    sqlite3 *database;
    // Primary key in the database.
    NSInteger primaryKey;
    // Attributes.
    NSString *customer;
    NSString *project;
	NSString *task;
	NSString *comment;
    NSDate *startDate;
    NSDate *createDate;
	double duration;
	BOOL started;
	BOOL invoiced;
    // Internal state variables. Hydrated tracks whether attribute data is in the object or the database.
    BOOL hydrated;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
 	
}

@property (assign, nonatomic, readonly) NSInteger primaryKey;
// The remaining attributes are copied rather than retained because they are value objects.
@property (copy, nonatomic) NSString *customer;
@property (copy, nonatomic) NSString *project;
@property (copy, nonatomic) NSString *task;
@property (copy, nonatomic) NSString *comment;
@property (assign, nonatomic) double duration;
@property (assign, nonatomic) BOOL invoiced;
@property (assign, nonatomic) BOOL started;

@property (copy, nonatomic) NSDate *startDate;
@property (copy, nonatomic) NSDate *createDate;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
// Inserts the book into the database and stores its primary key.
- (void)insertIntoDatabase:(sqlite3 *)database;

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)hydrate;
// Flushes all but the primary key and title out to the database.
- (void)dehydrate;
// Remove the book complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase;

- (void)start;
- (void)stop;
-(NSString *) csvLine;
+(NSString *) csvHeader;
@end
