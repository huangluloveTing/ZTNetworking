//
//  DPMObject.h
//  DepotNearby
//

//  Copyright © 2016年 www.depotnearby.com. All rights reserved.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#define RW_Property_Preffix \
@property(nonatomic , nullable , strong , readwrite)

#define R_Property_Preffix \
@property(nonatomic , nullable , strong , readonly)

@protocol PZTObject <NSObject>

+ (nullable instancetype)serializeWithJsonObject:(nullable NSDictionary *)jsonObj;
- (nullable instancetype)initWithJsonObject:(nullable NSDictionary *)jsonObj;
- (nonnull NSDictionary *)toJsonObject;
- (nullable NSArray *) allPropertyNames;
@end

@interface ZTPObject : NSObject<PZTObject, NSCopying, NSCoding>

+ (nullable instancetype)serializeWithJsonObject:(nullable NSDictionary *)jsonObj;

- (nullable instancetype)init;
- (nullable instancetype)initWithJsonObject:(nullable NSDictionary *)jsonObj;
- (nonnull NSDictionary *)toJsonObject;
//获取对象的所有属性名称 ， 只针对第一级属性
- (nullable NSArray *) allPropertyNames;
@end

#define DP_Generic_Custom_Array_Class_Define(__className) \
\
@protocol __className<NSObject>\
\
@end \

#define DP_Generic_Custom_Array_Class_Implement(__className) //Do nothing

#define DPMObjectArray(__className)         NSArray<__className *><__className>
#define DPMObjectMutableArray(__className)  NSMutableArray<__className *><__className>

