//
//  MySQLKitQuery.h
//  JustMySQL
//
//  Created by Matthew Moore on 11/2/13.
//  Copyright (c) 2013 Example Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MySQLKitDatabase.h"

@interface MySQLKitQuery : NSObject
{
    MySQLKitDatabase* db;
    NSMutableArray* rowsArray;
    NSInteger num_fields;
}
- (id)initWithDatabase:(MySQLKitDatabase*)dbase; // initializer
- (void)execQuery; // execute query with sql
- (NSInteger)recordCount; // return number rows in result query
- (NSString*)stringValFromRow:(int)row Column:(int)col; // return string from row and column col
- (NSInteger)integerValFromRow:(int)row Column:(int)col;//return NSInteger from row and column col
- (double)doubleValFromRow:(int)row Column:(int)col; // return double from row and column col

@property (copy)NSString* sql;

@end
