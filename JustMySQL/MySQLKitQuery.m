//
//  MySQLKitQuery.m
//  JustMySQL
//
//  Created by Matthew Moore on 11/2/13.
//  Copyright (c) 2013 Example Inc. All rights reserved.
//

#import "MySQLKitQuery.h"

@implementation MySQLKitQuery
@synthesize sql;

- (id)initWithDatabase:(MySQLKitDatabase*)dbase
{
    self = [super init];
    if (self) {
        db = dbase;
        rowsArray = [NSMutableArray array];
    }
    return self;
}

-(void)execQuery
{
    [rowsArray removeAllObjects];
    num_fields = 0;
    if(mysql_query(db.mysql, sql.UTF8String))
        [db mysqlError];
    MYSQL_RES* res = mysql_use_result(db.mysql);
    if(res){
        num_fields = mysql_num_fields(res);
        MYSQL_ROW row;
        while ((row = mysql_fetch_row(res))){
            for(NSInteger i=0;i<num_fields;i++){
                NSString* sField = [NSString stringWithUTF8String:row[i]];
                [rowsArray addObject:sField];
            }
        }
        
        mysql_free_result(res);
    }
}

- (NSInteger)recordCount
{
    NSInteger result;
    if(num_fields){
        result = rowsArray.count / num_fields;
    }
    else
        result = 0;
    return result;
}

- (NSString*)stringValFromRow:(int)row Column:(int)col
{
    NSString* result = nil;
    if(num_fields && col < num_fields){
        NSInteger objidx = row * num_fields + col;
        result = [rowsArray objectAtIndex:objidx];
    }
    return result;
}

- (NSInteger)integerValFromRow:(int)row Column:(int)col
{
    NSString* s = [self stringValFromRow:row Column:col];
    return s.integerValue;
}

- (double)doubleValFromRow:(int)row Column:(int)col
{
    NSString* s = [self stringValFromRow:row Column:col];
    return s.doubleValue;
}
@end
