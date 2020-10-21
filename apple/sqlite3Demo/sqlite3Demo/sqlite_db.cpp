//
//  sqlite_db.cpp
//  mediasdk
//
//  Created by cort xu on 2020/10/12.
//  Copyright © 2020 cortxu. All rights reserved.
//

#include "sqlite_db.h"

namespace hilive {
namespace media {

std::unique_ptr<SqliteDB> SqliteDB::Create() {
    return std::unique_ptr<SqliteDB>(new SqliteDB());
}

SqliteDB::SqliteDB() : inited_(false), db_(nullptr) {
}

SqliteDB::~SqliteDB() {
    Uint();
}

bool SqliteDB::Init(const char* db_name) {
    do {
        if (inited_) {
            break;
        }
        
        // 打开数据库文件(如果数据库文件不存在,那么该函数会自动创建数据库文件)
        int ret = sqlite3_open(db_name, &db_);
        if (ret != SQLITE_OK) {
            break;
        }
        
        inited_ = true;
    } while (false);
    
    return inited_;
}

int ExcuteCallback(void* data, int rows, char** col_values, char** col_names) {
    return 0;
}

bool SqliteDB::Query(const char* sql) {
    do {
        if (!inited_) {
            break;
        }
        
        // 创建表
        char* err_msg = nullptr;
        int ret = sqlite3_exec(db_, sql, ExcuteCallback, this, &err_msg);
        if (ret != SQLITE_OK) {
            break;
        }
        
        return true;
    } while (false);
    return false;
}

bool SqliteDB::Query(const char* sql, std::deque<DbObjectResult>& results) {
    int ret = SQLITE_ERROR;
    sqlite3_stmt* stmt = nullptr;
    
    do {
        if (!inited_) {
            break;
        }
        
        const char* err_msg = nullptr;
        if ((ret = sqlite3_prepare_v2(db_, sql, -1, &stmt, &err_msg)) != SQLITE_OK) {
            break;
        }
        
        while (true) {
            int r = sqlite3_step(stmt);
            if (r != SQLITE_ROW) {
                break;
            }
            
            int columns = sqlite3_column_count(stmt);
            
            DbObjectResult result;
            result.values.resize(columns);
            
            for (int i = 0; i < columns; ++ i) {
                const char* name = sqlite3_column_name(stmt, i);
                const int type = sqlite3_column_type(stmt, i);
                
                DbObject& object = result.values[i];
                object.name_.assign(name ? name : "");
                
                switch (type) {
                    case SQLITE_INTEGER: {
                        object.type_ = DbObject::kDbTypeInt;
                        object.u64_val_ = sqlite3_column_int64(stmt, i);
                    } break;
                    case SQLITE_FLOAT: {
                        object.type_ = DbObject::kDbTypeFloat;
                        object.dbl_val_ = sqlite3_column_double(stmt, i);
                    } break;
                    case SQLITE_TEXT: {
                        const char* val = (const char*)sqlite3_column_text(stmt, i);
                        object.type_ = DbObject::kDbTypeString;
                        object.str_val_.assign(val ? val : "");
                    } break;
                    default:break;
                }
            }
            
            results.push_back(result);
        }
        
        ret = SQLITE_OK;
    } while (false);
    
    sqlite3_finalize(stmt);
    
    return ret == SQLITE_OK;
}

bool SqliteDB::Query(const char* sql, std::deque<DbStringResult>& results) {
    int ret = SQLITE_ERROR;
    sqlite3_stmt* stmt = nullptr;
    char** table_result = nullptr;
    
    do {
        if (!inited_) {
            break;
        }
        
        const char* prepare_err_msg = nullptr;
        if ((ret = sqlite3_prepare_v2(db_, sql, -1, &stmt, &prepare_err_msg)) != SQLITE_OK) {
            break;
        }
        
        char* get_err_msg = nullptr;
        int rows = 0;
        int columns = 0;
        if ((ret = sqlite3_get_table(db_, sql, &table_result, &rows, &columns, &get_err_msg)) != SQLITE_OK) {
            break;
        }
        
        if (rows && columns) {
            for (int i = 0; i < rows; ++ i) {
                DbStringResult result;
                result.values.resize(columns);
                
                for (int j = 0; j < columns; ++ j) {
                    DbObject& object = result.values[j];
                    
                    const char* name = table_result[j];
                    const char* value = table_result[(i + 1) * columns + j];
                    object.type_ = DbObject::kDbTypeString;
                    object.name_.assign(name ? name : "");
                    object.str_val_.assign(value ? value : "");
                }
                
                results.push_back(result);
            }
        }
        
        ret = SQLITE_OK;
    } while (false);
    
    sqlite3_free_table(table_result);
    sqlite3_finalize(stmt);
    
    return ret == SQLITE_OK;
}

void SqliteDB::Uint() {
    sqlite3_close(db_);
    
    inited_ = false;
    db_ = nullptr;
}

}
}
