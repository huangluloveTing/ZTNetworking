//
//  ZTNetCache.m
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import "ZTNetCache.h"


#define Cache_Path ([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Tables"])

@interface ZTNetCache ()

@property (nonatomic , strong) FMDatabaseQueue *databaseQueue;

@end

@implementation ZTNetCache

//保存离线数据的对象，遵守PZTObject 协议 ， 数据库名称根据对象的类名
- (void) saveData:(id<PZTObject>)data {
    [self createTableName:data];
}

- (void) deleteAllForClass:(Class)class {
    [self deleteTableWithName:NSStringFromClass(class)];
}

//根据id 查询对象
- (id)   queryForEntity:(id<PZTObject>)entity queryValue:(NSString *)queryValue fieldName:(NSString *)field{
    return [self getCacheObject:entity queryNmae:queryValue fieldName:field];
}

//查询所有的数据
- (NSArray *)queryAllDataWithEntity:(id<PZTObject>)entity {
    return [self getAllCachedEntity:entity];
}


- (void) createTableName:(id<PZTObject>)queryObject {
    NSString *tableName = NSStringFromClass([queryObject class]);
    NSArray *allColmns = [queryObject allPropertyNames];
    NSMutableString *columnSql = [NSMutableString string];
    for (int i = 0 ; i < allColmns.count; i ++) {
        if ([allColmns[i] isEqualToString:@"Id"] || [allColmns[i] isEqualToString:@"id"]) {
            continue;
        }
        NSString *column = [NSString stringWithFormat:@" , %@ text" , allColmns[i]];
        [columnSql appendString:column];
    }
    
    __block NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (Id integer PRIMARY KEY AUTOINCREMENT %@);" , tableName , columnSql];
    
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            BOOL result =  [db executeUpdate:sql];
            if (result) {
#if DEBUG
                NSLog(@"创建表 %@ 成功" , tableName);
#endif
            }
        }
        [db close];
    }];
    
    [self confirmTableColumnWith:queryObject];
    [self saveDataToTable:queryObject];
}

- (void) deleteTableWithName:(NSString *)tableName {
    
    __block NSString *sql = [NSString stringWithFormat:@"DROP TABLE  %@;" , tableName];
    
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            BOOL result =  [db executeUpdate:sql];
            if (result) {
#if DEBUG
                NSLog(@"删除表 %@ 成功" , tableName);
#endif
            }
        }
        [db close];
    }];
}
- (NSArray *)queryData:(id<PZTObject>)enity
           queryValues:(NSArray *)values
                fields:(NSArray*)fields {
    return [self getCacheObject:enity values:values fields:fields];
}


/**
 保存数据
 
 @param data return
 */
- (void) saveDataToTable:(id<PZTObject>)data {
    NSDictionary *dataDic = [data toJsonObject];
    NSArray *allColumns = [data allPropertyNames];
    NSMutableString *columnsSql = [[NSMutableString alloc] initWithString:@"("];
    NSMutableString *columnsValueSql = [[NSMutableString alloc] initWithString:@"("];
    NSMutableArray *columnsValue = [NSMutableArray array];
    for (NSString *column in allColumns) {
        id value = [dataDic valueForKey:column];
        if ([column isEqualToString:@"Id"] || [column isEqualToString:@"id"]) {
            continue;
        }
        [columnsSql appendString:[NSString stringWithFormat:@"%@," , column]];
        
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]] ||
            [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]]) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:value
                                                           options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                                             error:nil];
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [columnsValueSql appendString:[NSString stringWithFormat:@"?," ]];
            [columnsValue addObject:string];
        }
        
        else {
            [columnsValueSql appendString:[NSString stringWithFormat:@"?,"]];
            [columnsValue addObject:value ?: @""];
        }
    }
    NSString *columns = [[NSString alloc] initWithString:columnsSql];
    NSString *values = [[NSString alloc] initWithString:columnsValueSql];
    columns = [columns substringToIndex:columns.length - 1];
    values = [values substringToIndex:values.length - 1];
    columns = [NSString stringWithFormat:@"%@ )" , columns];
    values = [NSString stringWithFormat:@"%@ )" , values];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ %@ VALUES %@; " , NSStringFromClass([data class]) , columns , values];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            BOOL result = [db executeUpdate:sql values:columnsValue error:nil];
            if (result) {
#ifdef DEBUG
                NSLog(@"插入数据 %@ 成功" , columnsValue);
#endif
            }
        }
        [db close];
    }];
}

- (id) getCacheObject:(id<PZTObject>)queryObject
               values:(NSArray *)values
               fields:(NSArray *)fields {
    NSAssert(values.count == fields.count, @"查询的字段和查询值需一样");
    NSString *tableName = NSStringFromClass(queryObject.class);
    NSString *sql = [self getQurySQL:fields tableName:tableName];
    NSMutableArray *tempAr= [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            FMResultSet *set = [db executeQuery:sql values:values error:nil];
            while ([set next]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                NSArray *columns =[queryObject allPropertyNames];
                for (NSString *column in columns) {
                    NSString *value = [set stringForColumn:column];
                    [dic setValue:value forKey:column];
                }
                [tempAr addObject:dic];
            }
        }
        
        [db close];
    }];
    
    return tempAr;
}

- (id) getCacheObject:(id<PZTObject>)queryObject
            queryNmae:(NSString *)queryKey
            fieldName:(NSString *)fieldName{
    NSString *tableName = NSStringFromClass(queryObject.class);
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=?;" , tableName , fieldName];
    NSMutableArray *tempAr= [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            FMResultSet *set = [db executeQuery:sql , queryKey];
            while ([set next]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                NSArray *columns =[queryObject allPropertyNames];
                NSDictionary *maps = [queryObject mapProperties];
                for (NSString *column in columns) {
                    NSString *value = [set stringForColumn:column];
                    NSString *newColumn = [maps valueForKey:column];
                    [dic setValue:value forKey:column];
                    if (newColumn) {
                        [dic setValue:value forKey:newColumn];
                    }
                }
                [tempAr addObject:dic];
            }
        }
        
        [db close];
    }];
    
    return tempAr;
}

/**
 根据 实体 获取所有数据
 
 @param entity 实体
 @return return
 */
- (NSArray *) getAllCachedEntity:(id<PZTObject>)entity {
    NSString *sql = [NSString stringWithFormat:@"select * from %@;" , entity.class];
    NSMutableArray *tempAr= [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            FMResultSet *set = [db executeQuery:sql];
            while ([set next]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                NSArray *columns =[entity allPropertyNames];
                NSDictionary *maps = [entity mapProperties];
                for (NSString *column in columns) {
                    NSString *value = [set stringForColumn:column];
                    NSString *newColumn = [maps valueForKey:column];
                    [dic setValue:value forKey:column];
                    if (newColumn) {
                        [dic setValue:value forKey:newColumn];
                    }
                }
                ZTPObject *object = [[[entity class] alloc] initWithJsonObject:dic];
                [tempAr addObject:object];
            }
        }
        
        [db close];
    }];
    
    return tempAr;
}


/**
 根据字段名称删除 数据
 
 @param entity 对象
 @param fieldValue 值
 @param fieldName 字段名
 */
- (void) deleteForEntity:(id<PZTObject>)entity fieldValue:(NSString *)fieldValue fieldName:(NSString *)fieldName  {
    NSString *tableName = NSStringFromClass(entity.class);
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?" , tableName , fieldName];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            BOOL result = [db executeUpdate:sql , fieldValue];
            if (result) {
#ifdef DEBUG
                NSLog(@"删除数据 %@ 成功" , fieldValue);
#endif
            }
        }
        [db close];
    }];
}


- (FMDatabaseQueue *)databaseQueue {
    if (!_databaseQueue) {
        NSString *path = [Cache_Path stringByAppendingPathComponent:@"Net_Cache.sqlite"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:path]) {
            [fileManager createDirectoryAtPath:Cache_Path withIntermediateDirectories:NO attributes:nil error:nil];
        }
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    
    return _databaseQueue;
}


/**
 判断表里的字段是否和对象一样
 
 @param table 对象
 */
- (void) confirmTableColumnWith:(id<PZTObject>)table {
    NSArray *allKeys = [[table toJsonObject] allKeys];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            for (NSString *column in allKeys) {
                BOOL result = [db columnExists:column inTableWithName:NSStringFromClass([table class])];
                if (! result) {
                    NSString *alter = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ text;" , [table class] , column];
                    result = [db executeUpdate:alter];
                    if (result) {
                        NSLog(@"新增表成功");
                    }
                }
            }
        }
    }];
}

- (void) updateForEntity:(id<PZTObject>)entity
              fieldValue:(NSString *)fieldValue
               fieldName:(NSString *)fieldName
             uniqueField:(NSString *)unique
             uniqueValue:(NSString *)uniqueValue{
    NSString *tableName = NSStringFromClass(entity.class);
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?" , tableName , fieldName , unique];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            BOOL result = [db executeUpdate:sql , fieldValue , uniqueValue];
            if (result) {
#ifdef DEBUG
                NSLog(@"更新数据 %@ 成功" , fieldValue);
#endif
            }
        }
        [db close];
    }];
}


#pragma mark - 组装sql
// 组装查询条件
- (NSString *) getQurySQL:(NSArray *) queryFields tableName:(NSString *)table{
    __block NSMutableString *query = [[NSMutableString alloc] initWithString:@""];
    [queryFields enumerateObjectsUsingBlock:^(NSString * _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != queryFields.count - 1) {
            [query appendString:@" %@=? and "];
        } else {
            [query appendString:[NSString stringWithFormat:@" %@=?" , field]];
        }
    }];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@;", table , query];
    return sql;
}


@end
