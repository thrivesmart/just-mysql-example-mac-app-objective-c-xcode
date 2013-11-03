//
//  MySQLKitDatabase.m
//  JustMySQL
//
//  Created by Matthew Moore on 11/2/13.
//  Copyright (c) 2013 Example Inc. All rights reserved.
//

#import "MySQLKitDatabase.h"

@implementation MySQLKitDatabase

@synthesize socket;
@synthesize serverName;
@synthesize dbName;
@synthesize port;
@synthesize userName;
@synthesize password;
@synthesize mysql;

- (id)init
{
    self = [super init];
    if (self) {
        if (mysql_library_init(0, NULL, NULL)) {
            NSLog(@"Database didn't connect");
            return nil;
        }
    }
    return self;
}


- (void)finalize
{
    mysql_library_end();
}

- (void)connect
{
    mysql = mysql_init(NULL);
    const char* prms[5];
    if(socket)
        prms[0] = socket.UTF8String;
    else
        prms[0] = NULL;
    if(serverName)
        prms[1] = serverName.UTF8String;
    else
        prms[1] = "localhost";
    if(dbName)
        prms[2] = dbName.UTF8String;
    else
        prms[2] = NULL;
    if(!port)
        port = 3306;
    if(userName)
        prms[3] = userName.UTF8String;
    else
        prms[3] = "root";
    if(password)
        prms[4] = password.UTF8String;
    else
        prms[4] = "";
    if(!mysql_real_connect(mysql, prms[1], prms[3], prms[4], prms[2], port, prms[0], 0)){
        [self mysqlError];
    }
    // if use UTF-8
    if(mysql_set_character_set(mysql, "utf8"))
        [self mysqlError];
}

- (void)mysqlError
{
    const char* ch = mysql_error(mysql);
    if(ch){
        lastError = [NSString stringWithUTF8String:ch];
        if(lastError.length){
            NSLog(@"Error connection: %@",lastError);
            NSException* exc = [NSException exceptionWithName:@"Error MySQL database" reason:lastError userInfo:nil];
            @throw exc;
        }
    }
}

- (void)disconnect
{
    if(mysql){
        mysql_close(mysql);
        mysql = nil;
    }
}

- (NSString*) r_escape:(NSString*)s
{
    NSInteger len = [s lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if(len){
        NSInteger l = (len<<1)+2; // the maximum length in UTF-8 encoding
        char toch[l];
        char* to = toch;
        memset(to, 0, l);
        mysql_real_escape_string(mysql, to, s.UTF8String,len);
        return [NSString stringWithUTF8String:to];
    }
    return s;
}

- (NSInteger) autoincrementID
{
    NSInteger result = mysql_insert_id(mysql);
    return result;
}

- (BOOL) connected
{
    if(mysql_stat(mysql))
        return YES;
    else
        return NO;
}

- (void) errorMessage
{
    if(lastError){
        NSAlert* alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"MySQL error"];
        [alert setInformativeText:lastError];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        lastError = nil;
    }
}
@end
