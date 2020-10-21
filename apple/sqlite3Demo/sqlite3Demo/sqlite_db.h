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

class SqliteDB;

class DbObject {
    friend class SqliteDB;
    
public:
    enum DbType {
        kDbTypeUnknow,
        kDbTypeInt,
        kDbTypeFloat,
        kDbTypeString,
    };
    
    DbObject() {}
    ~DbObject() {}
    
public:
    const DbType get_type() { return type_; }
    const std::string& get_name() { return name_; }
    const int32_t get_i32() { return (int32_t)u64_val_; }
    const int64_t get_i64() { return (int64_t)u64_val_; }
    const uint32_t get_u32() { return (uint32_t)u64_val_; }
    const uint64_t get_u64() { return u64_val_; }
    const float get_flt() { return (float)dbl_val_; }
    const double get_dbl() { return (double)dbl_val_; }
    const std::string& get_str() { return str_val_;}
    
private:
    DbType          type_ = kDbTypeUnknow;
    std::string     name_;
    
    uint64_t        u64_val_ = 0;
    double          dbl_val_ = 0;
    std::string     str_val_;
};

struct DbObjectResult {
    std::vector<DbObject>   values;
};

struct DbStringResult {
    std::vector<DbObject>   values;
};

class SqliteDB {
public:
    static std::unique_ptr<SqliteDB> Create();
    ~SqliteDB();
    
private:
    SqliteDB();
    
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
