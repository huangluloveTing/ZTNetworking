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
- (id)   queryForEntity:(id<PZTObject>)entity queryValue:(NSString *)queryValue column:(NSString *)columnName;
//查询所有的数据
- (NSArray *)queryAllDataWithEntity:(id<PZTObject>)entity;
//根据数据删除
- (void) deleteForEntity:(id<PZTObject>)entity columnValue:(NSString *)queryValue column:(NSString *)columnName;

@end



@interface ZTNetCache : NSObject<ZTCache>

//保存离线数据的对象，遵守PZTObject 协议 ， 数据库名称根据对象的类名
- (void) saveData:(id<PZTObject>)data;
//根据id 查询对象
- (id)   queryForEntity:(id<PZTObject>)entity queryValue:(NSString *)queryValue column:(NSString *)columnName;
//查询所有的数据
- (NSArray *)queryAllDataWithEntity:(id<PZTObject>)entity;

- (void) deleteForEntity:(id<PZTObject>)entity columnValue:(NSString *)queryValue column:(NSString *)columnName;

@end

