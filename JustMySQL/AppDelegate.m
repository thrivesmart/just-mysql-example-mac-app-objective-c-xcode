//
//  AppDelegate.m
//  JustMySQL
//
//  Created by Matthew Moore on 11/2/13.
//  Copyright (c) 2013 Example Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MySQLKitDatabase.h"
#import "MySQLKitQuery.h"


@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    NSString *dbName = @"ensembl_production_72";
    
    MySQLKitDatabase* server = [[MySQLKitDatabase alloc] init];
    // db.socket = @"/tmp/mysql/mysql.sock";
    server.serverName = @"useastdb.ensembl.org";
    server.dbName = @"";
    server.userName = @"anonymous";
    server.password = @"";
    server.port = 3306;
    @try{
        [server connect];
        
        MySQLKitQuery *query = [[MySQLKitQuery alloc] initWithDatabase:server];
        query.sql = @"show databases";
        [query execQuery];
        NSInteger len = query.recordCount;
        for(int i = 0; i < len; i++){
            NSString *currentDbName = [query stringValFromRow:i Column:0];
            NSLog(@"Database: %@", currentDbName);
        }
        
        MySQLKitQuery *query2 = [[MySQLKitQuery alloc] initWithDatabase:server];
        query2.sql = [NSString stringWithFormat:@"show tables in %@", dbName];
        [query2 execQuery];
        len = query2.recordCount;
        for(int i = 0; i < len; i++){
            NSString *currentTableName = [query2 stringValFromRow:i Column:0];
            NSLog(@"Table: %@ in DB %@", currentTableName, dbName);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        NSLog(@"ERROR! Message: %@", [server errorMessage]);
        [server alertIfError];
    }
    @finally {
        [server disconnect];
    }
    
    
    MySQLKitDatabase* db = [[MySQLKitDatabase alloc] init];
    // db.socket = @"/tmp/mysql/mysql.sock";
    db.serverName = @"useastdb.ensembl.org";
    db.dbName = dbName;
    db.userName = @"anonymous";
    db.password = @"";
    db.port = 3306;
    @try{
        [db connect];
        
        MySQLKitQuery *query3 = [[MySQLKitQuery alloc] initWithDatabase:db];
        NSString *selectSql = [NSString stringWithFormat:@"select * from `%@` limit 10", @"species"];
        NSLog(@"Querying: `%@`", selectSql);
        query3.sql = selectSql;
        [query3 execQuery];
        NSInteger len = query3.recordCount;
        NSLog(@"Number of records in species: %ld", (long)len);
        for(int i = 0; i < len; i++){
            NSInteger col0 = [query3 integerValFromRow:i Column:0];
            NSString *col1 = [query3 stringValFromRow:i Column:1];
            NSLog(@"Entry: %ld\t%@", (long)col0,col1);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        NSLog(@"ERROR! Message: %@", [db errorMessage]);
        [db alertIfError];
    }
    @finally {
        [db disconnect];
    }
    

}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.example.JustMySQL" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.example.JustMySQL"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"JustMySQL" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"JustMySQL.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
