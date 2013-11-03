How this app was created
=========================

1. Download the latest tar from http://dev.mysql.com/downloads/mysql/

You should end up with something like: `mysql-connector-c-6.1.2-osx10.7-x86_64`

2. Drag `libmysqlclient.a` into your project

Inside the `lib` folder, you'll see the file `libmysqlclient.a`.  Drag that from the finder into your project, and include it in the Target (main app)

3. Drag `mysql.h` *and other header files* into your project

Working through compiler errors, I determined that these are the required files, some of which are in `include`, `include/mysql`, and `include/mysql/psi`:

* `psi_base.h`
* `psi_memory.h`
* `my_alloc.h`
* `typelib.h`
* `plugin_auth_common.h`
* `mysql.h`
* `mysql_com.h`
* `mysql_time.h`
* `mysql_version.h`
* `client_plugin.h`
* `my_list.h`

4. Add `libc++.dylib` to your project.

Click on the topmost item of the project, so you can select your application target. In "Linked Frameworks and Libraries", click the `+` button, and search for `libc++.dylib`.  In the confirmation, make sure the target is selected.

5. Add 4 `MySQLKit*.*` files to your project.

Drag them into XCode from the finder:

* `MySQLKitDatabase.h`
* `MySQLKitDatabase.m`
* `MySQLKitQuery.h`
* `MySQLKitQuery.m`

6. Implement your own database code somewhere

```objective-c
    MySQLKitDatabase* db = [[MySQLKitDatabase alloc] init];
    db.socket = @"/tmp/mysql/mysql.sock";
    db.serverName = @"localhost";
    db.dbName = @"sampledb";
    db.userName = @"root";
    db.password = @"12345";
    db.port = 8889;
    @try{
        [db connect];
        MySQLKitQuery *query = [[MySQLKitQuery alloc] initWithDatabase:db];
        query.sql = @"select * from table1 order by id";
        [query execQuery];
        NSInteger len = query.recordCount;
        for(NSInteger i = 0; i < len; i++){
            NSInteger id1 = [query integerValFromRow:i Column:0];
            NSString *stringV1 = [query stringValFromRow:i Column:1];
            //...
        }
    }
    @catch (NSException *exception) {
        // ...
        [db errorMessage];
    }
```

7. You should be off to the races now!

Note: credit to http://macbug.org/macosxsample/mysql for helping get us off the ground!