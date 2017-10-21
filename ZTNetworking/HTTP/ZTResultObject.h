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

@property (nonatomic , copy) NSString *code;

@property (nonatomic , copy) NSString *message;

@property (nonatomic , copy) NSString *ts;

@end;

@interface ZTResultObject : ZTPObject

@property (nonatomic , strong) ZTHttpResultHeaderObject *head;


- (NSError *) checkResult;

@end

#define ZTHttpResultObject(__name) ZTHttp_##__name##_JsonResult

#define DCM_Generic_Custom_Json_Result_Define(__name, __className) \
\
@interface ZTHttp_##__name##_JsonResult : ZTResultObject \
@property (nonatomic, strong, readwrite) __className * businessObject; \
@end

#define DCM_Generic_Custom_Json_Result_Implement(__name, __className) \
\
@implementation ZTHttp_##__name##_JsonResult \
@end

DCM_Generic_Custom_Json_Result_Define(Dictionary, NSDictionary)
DCM_Generic_Custom_Json_Result_Define(Array, NSArray)
DCM_Generic_Custom_Json_Result_Define(String, NSString)
DCM_Generic_Custom_Json_Result_Define(Number, NSNumber)

