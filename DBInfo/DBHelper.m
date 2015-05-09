//
//  DBHelper.m
//  DBInfo
//
//  Created by Francesca Corsini on 09/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "DBHelper.h"
#import <sqlite3.h>

static sqlite3 *dbHandle = nil;

@implementation DBHelper

+ (NSArray*)getTablesFromDBFile:(NSString*)dbFile
{
	NSMutableArray *list = @[].mutableCopy;
	int result = sqlite3_open([dbFile UTF8String], &dbHandle);
	if (result == SQLITE_OK)
	{
		const char *sql = "SELECT name FROM sqlite_master WHERE type = 'table'";
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(dbHandle, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
				[list addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)]];
			}
		}
		sqlite3_finalize(selectstmt);
		
	} else
	{
		NSLog(@"Failure in connecting to the database with result %d",result);
		sqlite3_close(dbHandle);
	}
	
	return list;
}

+ (NSArray*)getColumnsFromTable:(NSString*)tableName dbFile:(NSString*)dbFile
{
	NSMutableArray *list = @[].mutableCopy;
	int result = sqlite3_open([dbFile UTF8String], &dbHandle);
	if (result == SQLITE_OK)
	{
		const char *sql = [[NSString stringWithFormat:@"pragma table_info('%s')",[tableName UTF8String]] UTF8String];
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(dbHandle, sql, -1, &selectstmt, NULL) == SQLITE_OK)
		{
			while (sqlite3_step(selectstmt)==SQLITE_ROW)
			{
				[list addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)]];
			}
		}
		sqlite3_finalize(selectstmt);
		
		
	} else
	{
		NSLog(@"Failure in connecting to the database with result %d",result);
		sqlite3_close(dbHandle);
	}
	
	return list;
}

+ (float)getColumnSize:(NSString*)columnName tableName:(NSString*)tableName dbFile:(NSString*)dbFile
{
	float columnSize = 0;
	sqlite3_config(SQLITE_CONFIG_SERIALIZED);
	int result = sqlite3_open([dbFile UTF8String], &dbHandle);
	if (result != SQLITE_OK)
	{
		sqlite3_close(dbHandle);
		NSLog(@"Failure in connecting to the database with result %d",result);
	}
	else
	{
		NSLog(@ "Successfully opened connection to DB") ;
		NSString *query = [NSString stringWithFormat:@"SELECT length(HEX(%@))/2 FROM %@", columnName, tableName];
		const char *sql3 = [query cStringUsingEncoding:NSUTF8StringEncoding];
		sqlite3_stmt *sql1Statement;
		int returnCode;
		if (sqlite3_prepare_v2(dbHandle, sql3, -1, &sql1Statement, NULL) != SQLITE_OK)
		{
			NSLog(@"Problem with prepare statement: %s", sqlite3_errmsg(dbHandle));
		}
		else
		{
			while ((returnCode = sqlite3_step(sql1Statement)) == SQLITE_ROW)
			{
				columnSize+=sqlite3_column_double(sql1Statement, 0);
			}
			if (returnCode != SQLITE_DONE)
				NSLog(@"Problem with step statement: %s", sqlite3_errmsg(dbHandle));
			sqlite3_finalize(sql1Statement);
		}
	}
	
	NSLog(@"TOTAL SIZE for %@ in %@ : %f", columnName, tableName, columnSize);
	
	
	return columnSize;
}

+ (float)getTableSize:(NSString*)tableName dbFile:(NSString*)dbFile
{
	__block float tableSize = 0;
	NSArray *columns = [DBHelper getColumnsFromTable:tableName dbFile:dbFile];
	[columns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *columnName = (NSString*)obj;
		float columnSize = [DBHelper getColumnSize:columnName tableName:tableName dbFile:dbFile];
		tableSize = tableSize + columnSize;
	}];
	
	
	return tableSize;
}



@end
