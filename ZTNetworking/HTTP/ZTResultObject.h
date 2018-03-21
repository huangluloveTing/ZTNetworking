//
//  ZTHttpResultObject.h
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZTPObject.h"

@protocol ZTResultObject <NSObject>
    
    @end

@interface ZTHttpResultHeaderObject : ZTPObject
    
    //业务code
    @property (nonatomic , strong , readwrite) NSString *code;
    
    //id
    @property (nonatomic , strong , readwrite) NSString *requestId;
    
    //
    @property (nonatomic , strong , readwrite) NSString *reqTime;
    
    //
    @property (nonatomic , strong , readwrite) NSString *resTime;
    
    //
    @property (nonatomic , strong , readwrite) NSString *remark;
    
    //
    @property (nonatomic , strong , readwrite) NSString *status;
    
- (NSError *) chechResult;
    
    @end;


@interface ZTIOSParamObject : ZTPObject
    
    @property (nonatomic , strong , readwrite) NSString *currentVersion;
    
    @property (nonatomic , strong , readwrite) NSString *updateUrl;
    
    @property (nonatomic , strong , readwrite) NSString *desc;
    
    @property (nonatomic , strong , readwrite) NSString *forceUpdate;
    
    @end

@interface ZTParamResult : ZTPObject
    
    @property (nonatomic , strong , readwrite) ZTIOSParamObject *ios;
    
    @end

@interface ZTResultObject : ZTPObject
    
    //业务code
    @property (nonatomic , strong , readwrite) NSString *code;
    
    //id
    @property (nonatomic , strong , readwrite) NSString *requestId;
    
    //
    @property (nonatomic , strong , readwrite) NSString *reqTime;
    
    //
    @property (nonatomic , strong , readwrite) NSString *resTime;
    
    //
    @property (nonatomic , strong , readwrite) NSString *remark;
    
    //
    @property (nonatomic , strong , readwrite) NSString *status;
    
    @property (nonatomic , strong , readwrite) ZTParamResult *params;
    
- (NSError *) chechResult;
    
    @end

#define ZTHttpResultObject(__name) ZTHttp_##__name##_JsonResult

#define DCM_Generic_Custom_Json_Result_Define(__name, __className) \
\
@interface ZTHttp_##__name##_JsonResult : ZTResultObject \
@property (nonatomic, strong, readwrite) __className * result; \
@end

#define DCM_Generic_Custom_Json_Result_Implement(__name, __className) \
\
@implementation ZTHttp_##__name##_JsonResult \
@end

DCM_Generic_Custom_Json_Result_Define(Dictionary, NSDictionary)
DCM_Generic_Custom_Json_Result_Define(Array, NSArray)
DCM_Generic_Custom_Json_Result_Define(String, NSString)
DCM_Generic_Custom_Json_Result_Define(Number, NSNumber)


