//
//  MasterViewController.m
//  HelloWorld
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "MasterViewController.h"
#import "DBHelper.h"

@interface MasterViewController ()
{
    NSArray *tables;
    NSString *dbPath;
}

@property (weak) IBOutlet NSComboBox *tableCombo;
@property (weak) IBOutlet NSTextField *sizeLabel;
@property (weak) IBOutlet NSTextField *dbNameLabel;

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
	[opanel setAllowedFileTypes:nil];
	[opanel setPrompt:@"Open"];
	[opanel setTitle:@"Open file"];
	[opanel setMessage:@"Please select a path where to open file"];
	if ([opanel runModal] == NSOKButton)
	{
		[self.dbNameLabel setStringValue:[[[opanel URL] pathComponents] lastObject]];
		dbPath = [[opanel URL] path];
		tables = [DBHelper getTablesFromDBFile:dbPath];
        [self.tableCombo reloadData];
	}
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
	float tableSize = [DBHelper getTableSize:tableSelected dbFile:dbPath];
    [self.sizeLabel setStringValue:[NSString stringWithFormat:@"%f KB", roundf(tableSize/1024)]];
}



@end
