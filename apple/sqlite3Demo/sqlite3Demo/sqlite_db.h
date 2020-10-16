//
//  sqlite_db.h
//  mediasdk
//
//  Created by cort xu on 2020/10/12.
//  Copyright © 2020 cortxu. All rights reserved.
//

#pragma once
#include <stdint.h>
#include <string>
#include <deque>
#include <vector>
#include "hi_sqlite3.h"

namespace hilive {
namespace media {

struct DbObject {
    enum DbType {
        kDbTypeUnknow,
        kDbTypeInt,
        kDbTypeFloat,
        kDbTypeString,
    };
    
    DbType          type = kDbTypeUnknow;
    std::string     name;
    
    int             int_val = 0;
    float           float_val = 0;
    std::string     str_val;
};

struct DbObjectResult {
    std::vector<DbObject>   values;
};

struct DbStringResult {
    std::vector<DbObject>   values;
};

class SqliteDB {
public:
    SqliteDB();
    ~SqliteDB();
    
public:
    bool Init(const char* db_name);
    bool Query(const char* sql);
    bool Query(const char* sql, std::deque<DbObjectResult>& results);
    bool Query(const char* sql, std::deque<DbStringResult>& results);
    void Uint();
    
private:
    bool        inited_;
    sqlite3*    db_;
};

}
}
