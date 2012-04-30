//
//  Report.m
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

#import "Report.h"

@implementation Report

@synthesize startDate, endDate, mode, customer, project, invoicedMode;

/*- (void)init {
	items = [[Report alloc] init];
}*/

- (NSMutableArray *)buildReport {
	NSMutableArray *items = [[NSMutableArray alloc] init];
	//[items autorelease];
	
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
	double lowerBound = 0;
	double upperBound = 0;
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate]; 
	//[gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];

	NSDate *date = [gregorian dateFromComponents:components];
	
	lowerBound = [date timeIntervalSince1970];
	
	components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:endDate]; 
	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];
	
	date = [gregorian dateFromComponents:components];
		
	upperBound = [date timeIntervalSince1970];
	[gregorian release];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		NSString *isInvoiced = @" and Invoiced = 1 ";
		NSString *isNotInvoiced = @" and Invoiced = 0 ";
		NSString *sqlString;
        const char *sql;
		if([mode isEqualToString:@"c"]) {
			sqlString = @"SELECT Customer, sum(duration) FROM Item where CreateDate >= ? and CreateDate <= ? %@ group by Customer order by Customer";
		} else if([mode isEqualToString:@"p"]) {
			sqlString = @"SELECT Project, sum(duration) FROM Item where CreateDate >= ? and CreateDate <= ? %@group by Project order by Project";
		} else if([mode isEqualToString:@"t"]) {
			sqlString = @"SELECT Task, sum(duration) FROM Item where CreateDate >= ? and CreateDate <= ? %@group by Task order by Task";
		}  else if([mode isEqualToString:@"cp"]) {
			sqlString = @"SELECT Project, sum(duration) FROM Item where CreateDate >= ? and CreateDate <= ? and Customer = ? %@group by Project order by Project";
		} else if([mode isEqualToString:@"cpt"]) {
			sqlString = @"SELECT Task, sum(duration) FROM Item where CreateDate >= ? and CreateDate <= ? and Customer = ? and Project = ? %@group by Task order by Task";
		} else{ // if([mode isEqualToString:@"pt"]) {
			sqlString = @"SELECT Task, sum(duration) FROM Item where CreateDate >= ? and CreateDate <= ? and Project = ? %@group by Task order by Task";
		}
		if(invoicedMode == 0)
			sql = [[NSString stringWithFormat:sqlString, @""] UTF8String];
		else if(invoicedMode == 1)
			sql = [[NSString stringWithFormat:sqlString, isInvoiced] UTF8String];
		else //if(invoicedMode == 2)
			sql = [[NSString stringWithFormat:sqlString, isNotInvoiced] UTF8String];
	    sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			int count = 1;
			sqlite3_bind_double(statement, count, lowerBound);
			count++;
			sqlite3_bind_double(statement, count, upperBound);
			count++;
			
			if([mode isEqualToString:@"cpt"] ||[mode isEqualToString:@"cp"] ) {
				sqlite3_bind_text(statement, count, [customer UTF8String], -1, SQLITE_TRANSIENT);
				count++;
			}
			
			if([mode isEqualToString:@"cpt"] || [mode isEqualToString:@"pt"]) {
				sqlite3_bind_text(statement, count, [project UTF8String], -1, SQLITE_TRANSIENT);
				//count ++;
			}
			
            while (sqlite3_step(statement) == SQLITE_ROW) {
				ReportItem *item = [[ReportItem alloc] init];
				char *str = (char *)sqlite3_column_text(statement, 0);
				item.name = (str) ? [NSString stringWithUTF8String:str] : @"";
				item.duration = sqlite3_column_double(statement, 1);
                [items addObject:item];
                [item release];
            }
        }
        sqlite3_finalize(statement);
    } else {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
	return [items autorelease];
}
+ (NSString *) csvEncode: (NSString *) string {

	if([string rangeOfString:@"\""].location != NSNotFound || [string rangeOfString:@"\n"].location  != NSNotFound || [string rangeOfString:@","].location  != NSNotFound ) {
		NSMutableString *newString = [[string mutableCopy] autorelease];
		[newString replaceOccurrencesOfString:@"\"" withString:@"\"\"" options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
		[newString insertString:@"\"" atIndex:0];
		[newString appendString:@"\""];
		return [NSString stringWithString:newString];
	}
	return string;
}
/*
+ (NSString *) urlencode: (NSString *) url {
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*", @"\n", @"\"", @" ", @"-", @"<", @">", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A", @"%0A", @"%22", @"%20", @"%2D", @"%3C", @"%3E", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *out = [NSString stringWithString: temp];
	[temp release];
    return out;
}
 */
- (void)deleteReport {
	//[items autorelease];
	
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
	double lowerBound = 0;
	double upperBound = 0;
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate]; 
	//[gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	NSDate *date = [gregorian dateFromComponents:components];
	
	lowerBound = [date timeIntervalSince1970];
	
	components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:endDate]; 
	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];
	
	date = [gregorian dateFromComponents:components];
	
	upperBound = [date timeIntervalSince1970];
	[gregorian release];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql;
		NSString *isInvoiced = @" and Invoiced = 1 ";
		NSString *isNotInvoiced = @" and Invoiced = 0 ";
		NSString *sqlString;
		if([mode isEqualToString:@"c"]) {
			sqlString = @"DELETE FROM Item where CreateDate >= ? and CreateDate <= ? %@";
		} else if([mode isEqualToString:@"p"]) {
			sqlString = @"DELETE FROM Item where CreateDate >= ? and CreateDate <= ? %@";
		} else if([mode isEqualToString:@"t"]) {
			sqlString = @"DELETE FROM Item where CreateDate >= ? and CreateDate <= ? %@";
		}  else if([mode isEqualToString:@"cp"]) {
			sqlString = @"DELETE FROM Item where CreateDate >= ? and CreateDate <= ? and Customer = ? %@";
		} else if([mode isEqualToString:@"cpt"]) {
			sqlString = @"DELETE FROM Item where CreateDate >= ? and CreateDate <= ? and Customer = ? and Project = ? %@";
		} else if([mode isEqualToString:@"pt"]) {
			sqlString = @"DELETE FROM Item where CreateDate >= ? and CreateDate <= ? and Project = ? %@";
		} else {
			sqlString = @"DELETE FROM Item where CreateDate >= ? and CreateDate <= ? %@";
		}
		if(invoicedMode == 0)
			sql = [[NSString stringWithFormat:sqlString, @""] UTF8String];
		else if(invoicedMode == 1)
			sql = [[NSString stringWithFormat:sqlString, isInvoiced] UTF8String];
		else //if(invoicedMode == 2)
			sql = [[NSString stringWithFormat:sqlString, isNotInvoiced] UTF8String];
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			int count = 1;
			sqlite3_bind_double(statement, count, lowerBound);
			count++;
			sqlite3_bind_double(statement, count, upperBound);
			count++;
			
			if([mode isEqualToString:@"cpt"] ||[mode isEqualToString:@"cp"] ) {
				sqlite3_bind_text(statement, count, [customer UTF8String], -1, SQLITE_TRANSIENT);
				count++;
			}
			
			if([mode isEqualToString:@"cpt"] || [mode isEqualToString:@"pt"]) {
				sqlite3_bind_text(statement, count, [project UTF8String], -1, SQLITE_TRANSIENT);
				//count ++;
			}
			
           sqlite3_step(statement);        
		}
        sqlite3_finalize(statement);
    } else {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)markAsNotInvoiced {
	//[items autorelease];
	
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
	double lowerBound = 0;
	double upperBound = 0;
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate]; 
	//[gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	NSDate *date = [gregorian dateFromComponents:components];
	
	lowerBound = [date timeIntervalSince1970];
	
	components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:endDate]; 
	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];
	
	date = [gregorian dateFromComponents:components];
	
	upperBound = [date timeIntervalSince1970];
	[gregorian release];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql;
		if([mode isEqualToString:@"c"]) {
			sql = "update Item set Invoiced = 0 where CreateDate >= ? and CreateDate <= ?";
		} else if([mode isEqualToString:@"p"]) {
			sql = "update Item set Invoiced = 0 where CreateDate >= ? and CreateDate <= ?";
		} else if([mode isEqualToString:@"t"]) {
			sql = "update Item set Invoiced = 0 where CreateDate >= ? and CreateDate <= ?";
		}  else if([mode isEqualToString:@"cp"]) {
			sql = "update Item set Invoiced = 0 where CreateDate >= ? and CreateDate <= ? and Customer = ?";
		} else if([mode isEqualToString:@"cpt"]) {
			sql = "update Item set Invoiced = 0 where CreateDate >= ? and CreateDate <= ? and Customer = ? and Project = ?";
		} else if([mode isEqualToString:@"pt"]) {
			sql = "update Item set Invoiced = 0 where CreateDate >= ? and CreateDate <= ? and Project = ?";
		} else {
			sql = "update Item set Invoiced = 0 where CreateDate >= ? and CreateDate <= ?";
		}
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			int count = 1;
			sqlite3_bind_double(statement, count, lowerBound);
			count++;
			sqlite3_bind_double(statement, count, upperBound);
			count++;
			
			if([mode isEqualToString:@"cpt"] ||[mode isEqualToString:@"cp"] ) {
				sqlite3_bind_text(statement, count, [customer UTF8String], -1, SQLITE_TRANSIENT);
				count++;
			}
			
			if([mode isEqualToString:@"cpt"] || [mode isEqualToString:@"pt"]) {
				sqlite3_bind_text(statement, count, [project UTF8String], -1, SQLITE_TRANSIENT);
				//count ++;
			}
			
			sqlite3_step(statement);        
		}
        sqlite3_finalize(statement);
    } else {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
}
- (void)markAsInvoiced {
	//[items autorelease];
	
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
	double lowerBound = 0;
	double upperBound = 0;
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate]; 
	//[gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	NSDate *date = [gregorian dateFromComponents:components];
	
	lowerBound = [date timeIntervalSince1970];
	
	components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:endDate]; 
	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];
	
	date = [gregorian dateFromComponents:components];
	
	upperBound = [date timeIntervalSince1970];
	[gregorian release];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql;
		if([mode isEqualToString:@"c"]) {
			sql = "update Item set Invoiced = 1 where CreateDate >= ? and CreateDate <= ?";
		} else if([mode isEqualToString:@"p"]) {
			sql = "update Item set Invoiced = 1 where CreateDate >= ? and CreateDate <= ?";
		} else if([mode isEqualToString:@"t"]) {
			sql = "update Item set Invoiced = 1 where CreateDate >= ? and CreateDate <= ?";
		}  else if([mode isEqualToString:@"cp"]) {
			sql = "update Item set Invoiced = 1 where CreateDate >= ? and CreateDate <= ? and Customer = ?";
		} else if([mode isEqualToString:@"cpt"]) {
			sql = "update Item set Invoiced = 1 where CreateDate >= ? and CreateDate <= ? and Customer = ? and Project = ?";
		} else if([mode isEqualToString:@"pt"]) {
			sql = "update Item set Invoiced = 1 where CreateDate >= ? and CreateDate <= ? and Project = ?";
		} else {
			sql = "update Item set Invoiced = 1 where CreateDate >= ? and CreateDate <= ?";
		}
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			int count = 1;
			sqlite3_bind_double(statement, count, lowerBound);
			count++;
			sqlite3_bind_double(statement, count, upperBound);
			count++;
			
			if([mode isEqualToString:@"cpt"] ||[mode isEqualToString:@"cp"] ) {
				sqlite3_bind_text(statement, count, [customer UTF8String], -1, SQLITE_TRANSIENT);
				count++;
			}
			
			if([mode isEqualToString:@"cpt"] || [mode isEqualToString:@"pt"]) {
				sqlite3_bind_text(statement, count, [project UTF8String], -1, SQLITE_TRANSIENT);
				//count ++;
			}
			
			sqlite3_step(statement);        
		}
        sqlite3_finalize(statement);
    } else {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (NSMutableArray *)buildDetailedReportByMode {
	
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
	
	double lowerBound = 0;
	double upperBound = 0;
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate]; 
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	NSDate *date = [gregorian dateFromComponents:components];
	
	lowerBound = [date timeIntervalSince1970];
	
	components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:endDate]; 
	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];
	
	date = [gregorian dateFromComponents:components];
	upperBound = [date timeIntervalSince1970];
	[gregorian release];
	
	NSString *isInvoiced = @" and Invoiced = 1 ";
	NSString *isNotInvoiced = @" and Invoiced = 0 ";
	NSString *sqlString;
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql;
		if([mode isEqualToString:@"c"]) {
			sqlString = @"SELECT pk FROM Item where CreateDate >= ? and CreateDate <= ? %@order by CreateDate";
		} else if([mode isEqualToString:@"p"]) {
			sqlString = @"SELECT pk FROM Item where CreateDate >= ? and CreateDate <= ? %@order by CreateDate";
		} else if([mode isEqualToString:@"t"]) {
			sqlString = @"SELECT pk FROM Item where CreateDate >= ? and CreateDate <= ? %@order by CreateDate";
		}  else if([mode isEqualToString:@"cp"]) {
			sqlString = @"SELECT pk FROM Item where CreateDate >= ? and CreateDate <= ? and Customer = ? %@order by CreateDate";
		} else if([mode isEqualToString:@"cpt"]) {
			sqlString = @"SELECT pk FROM Item where CreateDate >= ? and CreateDate <= ? and Customer = ? and Project = ? %@order by CreateDate";
		} else{// if([mode isEqualToString:@"pt"]) {
			sqlString = @"SELECT pk FROM Item where CreateDate >= ? and CreateDate <= ? and Project = ? %@order by CreateDate";
		}
		if(invoicedMode == 0)
			sql = [[NSString stringWithFormat:sqlString, @""] UTF8String];
		else if(invoicedMode == 1)
			sql = [[NSString stringWithFormat:sqlString, isInvoiced] UTF8String];
		else //if(invoicedMode == 2)
			sql = [[NSString stringWithFormat:sqlString, isNotInvoiced] UTF8String];
		
        sqlite3_stmt *statement;
		int sqlResult = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
		
        if ( sqlResult == SQLITE_OK) {
			int count = 1;
			sqlite3_bind_double(statement, count, lowerBound);
			count++;
			sqlite3_bind_double(statement, count, upperBound);
			count++;
			
			if([mode isEqualToString:@"cpt"] ||[mode isEqualToString:@"cp"] ) {
				sqlite3_bind_text(statement, count, [customer UTF8String], -1, SQLITE_TRANSIENT);
				count++;
			}
			
			if([mode isEqualToString:@"cpt"] || [mode isEqualToString:@"pt"]) {
				sqlite3_bind_text(statement, count, [project UTF8String], -1, SQLITE_TRANSIENT);
				//count ++;
			}
			
			
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int primaryKey = sqlite3_column_int(statement, 0);
                Item *item = [[Item alloc] initWithPrimaryKey:primaryKey database:database];
                [items addObject:item];
                [item release];
            }
        }
        sqlite3_finalize(statement);
    } else {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
	return [items autorelease];
}
- (NSMutableArray *)buildDetailedReport {
	
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tt.db.rsd"];
	
	double lowerBound = 0;
	double upperBound = 0;
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate]; 
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	NSDate *date = [gregorian dateFromComponents:components];
	
	lowerBound = [date timeIntervalSince1970];
	
	components =
	[gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:endDate]; 
	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];
	
	date = [gregorian dateFromComponents:components];
	upperBound = [date timeIntervalSince1970];
	[gregorian release];
	NSString *isInvoiced = @" and Invoiced = 1 ";
	NSString *isNotInvoiced = @" and Invoiced = 0 ";
	NSString *sqlString;
	
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		const char *sql;
        sqlString = @"SELECT pk FROM Item where CreateDate >= ? and CreateDate <= ? %@order by CreateDate";
		if(invoicedMode == 0)
			sql = [[NSString stringWithFormat:sqlString, @""] UTF8String];
		else if(invoicedMode == 1)
			sql = [[NSString stringWithFormat:sqlString, isInvoiced] UTF8String];
		else //if(invoicedMode == 2)
			sql = [[NSString stringWithFormat:sqlString, isNotInvoiced] UTF8String];
		//[sqlString release];
        sqlite3_stmt *statement;
		int sqlResult = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
		
        if ( sqlResult == SQLITE_OK) {
			int count = 1;
			sqlite3_bind_double(statement, count, lowerBound);
			count++;
			sqlite3_bind_double(statement, count, upperBound);
			//count++;
			
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int primaryKey = sqlite3_column_int(statement, 0);
                Item *item = [[Item alloc] initWithPrimaryKey:primaryKey database:database];
                [items addObject:item];
                [item release];
            }
        }
        sqlite3_finalize(statement);
    } else {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
	return [items autorelease];
}

- (void) dealloc {
	[startDate release];
	[endDate release];
	[mode release];
	[customer release];
	[project release];
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
	
	[super dealloc];
}

@end
