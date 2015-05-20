//
//  DBHelper.h
//  DBInfo
//
//  Created by Francesca Corsini on 09/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHelper : NSObject

+ (NSArray*)getTablesFromDBFile:(NSString*)dbFile;
+ (float)getTableSize:(NSString*)tableName dbFile:(NSString*)dbFile;


@end
