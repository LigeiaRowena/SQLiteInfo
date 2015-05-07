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
@property (weak) IBOutlet NSComboBox *tableCombo;
@property (weak) IBOutlet NSTextField *sizeLabel;

@end

@implementation MasterViewController

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
		NSString* path = [[opanel URL] path];
        [self readTables:path];
	}
}

- (void)readTables:(NSString*)dbFile
{
    if (sqlite3_open([dbFile UTF8String], &dbHandle) == SQLITE_OK) {
        
        // query SQL
        //const char *sql = "select * from PERSONA";
        const char *sql = "select ID, Nome, Cognome from PERSONA";
        sqlite3_stmt *selectstmt;
        if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
            
            //aggiungo tutti gli elementi del db all'array
            while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                idPersona = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
                nome = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)];
                cognome = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)];
                
                dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:idPersona, @"id", nome, @"nome", cognome, @"cognome", nil];
                
                [listaTemp addObject:dictionary];
            }
        }
        self.lista = listaTemp;
        
        //rilascio la memoria del db
        sqlite3_finalize(selectstmt);
        
        
    } else {
        //chiudo il db
        sqlite3_close(database);
    }
}

- (void)readDB:(NSString*)dbFile
{
    //TODO: take dinamically tablename and field names
    NSString *tableName = @"Documents";
    NSString *fieldName = @"title";

    float size;
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
        NSString *query = [NSString stringWithFormat:@"SELECT length(HEX(%@))/2 FROM %@", fieldName, tableName];
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
                NSLog(@"SIZE : %f",sqlite3_column_double(sql1Statement, 0));
                size+=sqlite3_column_double(sql1Statement, 0);
            }
            if (returnCode != SQLITE_DONE)
                NSLog(@"Problem with step statement: %s", sqlite3_errmsg(dbHandle));
            
            sqlite3_finalize(sql1Statement);
        }
    }
    
    NSLog(@"TOTAL SIZE for %@ in %@ : %f", fieldName, tableName, size);
}


@end
