//
//  MasterViewController.m
//  HelloWorld
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "MasterViewController.h"
#import <sqlite3.h>

static sqlite3 *dbHandle = nil;

@interface MasterViewController ()
{
    NSArray *tables;
    NSString *dbPath;
}

@property (weak) IBOutlet NSComboBox *tableCombo;
@property (weak) IBOutlet NSTextField *sizeLabel;

@end

@implementation MasterViewController

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)loadView
{
	[super loadView];
}

#pragma mark - Actions

- (IBAction)openButton:(id)sender
{
	NSOpenPanel *opanel = [NSOpenPanel openPanel];
	NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	[opanel setDirectoryURL:[NSURL fileURLWithPath:documentFolderPath]];
	
	[opanel setCanChooseFiles:TRUE];
	[opanel setCanChooseDirectories:FALSE];
	//[opanel setAllowsMultipleSelection:FALSE];
	//[opanel setAllowsOtherFileTypes:FALSE];
	//[opanel setAllowedFileTypes:@[@"txt"]];
	[opanel setAllowedFileTypes:nil];

	// Sets the prompt of the default Open button
	[opanel setPrompt:@"Open"];
	// Sets the title of the panel
	[opanel setTitle:@"Open file"];
	// Sets the message text displayed in the panel
	[opanel setMessage:@"Please select a path where to open file"];
	
	if ([opanel runModal] == NSOKButton)
	{
		dbPath = [[opanel URL] path];
        tables = [self getTables:dbPath];
        [self.tableCombo reloadData];
	}
}

#pragma mark - SQlite

- (NSArray*)getTables:(NSString*)dbFile
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

- (NSArray*)getColumnsFromTable:(NSString*)tableName dbFile:(NSString*)dbFile
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

- (float)getTableSize:(NSString*)tableName dbFile:(NSString*)dbFile
{
    __block float tableSize = 0;
    NSArray *columns = [self getColumnsFromTable:tableName dbFile:dbFile];
    [columns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *columnName = (NSString*)obj;
        float columnSize = [self getColumnSize:columnName tableName:tableName dbFile:dbFile];
        tableSize = tableSize + columnSize;
    }];
    
    
    return tableSize;
}

- (float)getColumnSize:(NSString*)columnName tableName:(NSString*)tableName dbFile:(NSString*)dbFile
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

#pragma mark - NSComboBox

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [tables count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return tables[index];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSComboBox *comboBox = (NSComboBox *)[notification object];
    NSString *tableSelected = tables[comboBox.indexOfSelectedItem];
    float tableSize = [self getTableSize:tableSelected dbFile:dbPath];
    [self.sizeLabel setStringValue:[NSString stringWithFormat:@"%f KB", roundf(tableSize/1024)]];
}



@end
