//
//  ViewController.m
//  sqlite3Demo
//
//  Created by cs on 2019/3/9.
//  Copyright © 2019 cs. All rights reserved.
//

#import "ViewController.h"
#include "sqlite_db.h"

using namespace hilive::media;

@interface ViewController ()

@end

@implementation ViewController {
    std::unique_ptr<SqliteDB> db1;
    std::unique_ptr<SqliteDB> db2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    db1 = SqliteDB::Create();
    db2 = SqliteDB::Create();

    // Do any additional setup after loading the view, typically from a nib.
    // 1.打开数据库
    [self openSqlDataBase];
    // 2.插入数据
    [self insertData];
    // 3.查询数据
    [self sqlData];
}

// 打开数据库
- (void)openSqlDataBase {
    // db是数据库的句柄,即数据库的象征,如果对数据库进行增删改查,就得操作这个示例

    // 获取数据库文件的路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [docPath stringByAppendingPathComponent:@"student.db"];
    NSLog(@"fileNamePath = %@",fileName);
    // 将 OC 字符串转换为 C 语言的字符串

    db1->Init([fileName UTF8String]);
    db2->Init([fileName UTF8String]);

  //  db1.Query("DROP TABLE t_students;");
    // 创建表
    const char *sql = "CREATE TABLE IF NOT EXISTS t_students (id integer PRIMARY KEY AUTOINCREMENT,name text NOT NULL unique,age integer NOT NULL);";
    db1->Query(sql);
    db1->Query(sql);
}

// 插入数据
- (void)insertData {
    for (int i = 0; i < 5; i++) {
        NSString *name = [NSString stringWithFormat:@"韩雪%d", i];
        int age = arc4random_uniform(20) + 10;

        // 拼接 sql 语句
        NSString *sql = [NSString stringWithFormat:@"replace INTO t_students (name,age) VALUES ('%@',%d);", name, age];

        std::deque<DbObjectResult> ret;
        db1->Query([sql UTF8String], ret);
        db2->Query([sql UTF8String], ret);
    }
}

// 查询操作
- (void)sqlData {
    // sql语句
    //const char* sql="SELECT id,name,age FROM t_students WHERE age<20;";
    const char* sql="SELECT id,name,age FROM t_students;";

    std::deque<DbObjectResult> ret1;
    db1->Query(sql, ret1);
    for (auto& obj : ret1) {
        printf("%s:%lld %s:%s %s:%lld \n",
               obj.values[0].get_name().c_str(), obj.values[0].get_i64(), obj.values[1].get_name().c_str(), obj.values[1].get_str().c_str(), obj.values[2].get_name().c_str(), obj.values[2].get_i64());
    }

    std::deque<DbObjectResult> ret2;
    db2->Query(sql, ret2);
    for (auto& obj : ret2) {
        printf("%s:%lld %s:%s %s:%lld \n",
               obj.values[0].get_name().c_str(), obj.values[0].get_i64(), obj.values[1].get_name().c_str(), obj.values[1].get_str().c_str(), obj.values[2].get_name().c_str(), obj.values[2].get_i64());
    }
}

@end
