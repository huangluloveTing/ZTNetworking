//
//  ZTNetCache.h
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZTPObject.h"
#import <FMDB.h>

/**
 接口：保存离线数据的接口
 */
@protocol ZTCache<NSObject>

//保存离线数据的对象，遵守PZTObject 协议 ， 数据库名称根据对象的类名
- (void) saveData:(id<PZTObject>)data;

//根据 查询条件 查询对象
- (id)   queryForEntity:(id<PZTObject>)entity
             queryValue:(NSString *)queryValue
              fieldName:(NSString *)field;

- (NSArray *)queryData:(id<PZTObject>)enity
           queryValues:(NSArray *)values
                fields:(NSArray*)field;

- (void) deleteAllForClass:(Class)class;

//查询所有的数据
- (NSArray *)queryAllDataWithEntity:(id<PZTObject>)entity;

//更新数据
- (void) updateForEntity:(id<PZTObject>)entity
              fieldValue:(NSString *)fieldValue
               fieldName:(NSString *)fieldName
             uniqueField:(NSString *)unique
             uniqueValue:(NSString *)uniqueValue;

//根据数据删除
- (void) deleteForEntity:(id<PZTObject>)entity
              fieldValue:(NSString *)fieldValue
               fieldName:(NSString *)fieldName;

@end



@interface ZTNetCache : NSObject<ZTCache>

//保存离线数据的对象，遵守PZTObject 协议 ， 数据库名称根据对象的类名
- (void) saveData:(id<PZTObject>)data;

//根据id 查询对象
- (id)   queryForEntity:(id<PZTObject>)entity
             queryValue:(NSString *)queryValue
              fieldName:(NSString *)field;

- (void) deleteAllForClass:(Class)class;

//查询所有的数据
- (NSArray *)queryAllDataWithEntity:(id<PZTObject>)entity;

- (void) deleteForEntity:(id<PZTObject>)entity
              fieldValue:(NSString *)fieldValue
               fieldName:(NSString *)fieldName;

- (void) updateForEntity:(id<PZTObject>)entity
              fieldValue:(NSString *)fieldValue
               fieldName:(NSString *)fieldName
             uniqueField:(NSString *)unique
             uniqueValue:(NSString *)uniqueValue;

- (NSArray *)queryData:(id<PZTObject>)enity
           queryValues:(NSArray *)values
                fields:(NSArray*)field;

@end

