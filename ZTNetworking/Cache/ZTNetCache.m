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
//根据id 查询对象
- (id)   queryForEntity:(id<PZTObject>)entity queryValue:(NSString *)queryValue column:(NSString *)columnName {
    return [self getCacheObject:entity queryNmae:queryValue ColumnName:columnName];
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
    [self saveDataToTable:queryObject];
}

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

- (id) getCacheObject:(id<PZTObject>)queryObject queryNmae:(NSString *)queryKey ColumnName:(NSString *)columnName{
    NSString *tableName = NSStringFromClass(queryObject.class);
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=?;" , tableName , columnName];
    NSMutableArray *tempAr= [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            FMResultSet *set = [db executeQuery:sql , queryKey];
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

- (NSArray *) getAllCachedEntity:(id<PZTObject>)entity {
    NSString *sql = [NSString stringWithFormat:@"select * from %@;" , entity.class];
    NSMutableArray *tempAr= [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            FMResultSet *set = [db executeQuery:sql];
            while ([set next]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                NSArray *columns =[entity allPropertyNames];
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

- (void) deleteForEntity:(id<PZTObject>)entity columnValue:(NSString *)queryValue column:(NSString *)columnName  {
    NSString *tableName = NSStringFromClass(entity.class);
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?" , tableName , columnName];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            BOOL result = [db executeUpdate:sql , queryValue];
            if (result) {
#ifdef DEBUG
                NSLog(@"删除数据 %@ 成功" , queryValue);
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


@end
