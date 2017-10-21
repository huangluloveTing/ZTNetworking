//
//  ZTHttpRequest.h
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZTPObject.h"

static NSString * _Nullable const  RequestType_UploadFile = @"UPLOAD_FILE";

static NSString * _Nullable const  RequestType_Normal = @"UPLOAD_NORMAL";

@interface ZTHttpRequest : ZTPObject <PZTObject>

@property (nonatomic , strong , nullable , readwrite) NSDictionary *parameters; //

@property (nonatomic , strong , nullable , readwrite) NSString *uri; //

@property (nonatomic , strong , nullable , readwrite) NSString *identifier; //

@property (nonatomic , strong , nullable , readwrite) NSString *fileName; //

@property (nonatomic , strong , nullable , readwrite) NSString *name; //

@property (nonatomic , strong , nullable , readwrite) NSString *aynac; //是否串行

@property (nonatomic , strong , nullable , readwrite) NSString *taskName; //是否串行

@property (nonatomic , strong , nullable , readwrite) NSString *requestType; //
//扩张的字段
@property (nonatomic , strong , nullable , readwrite) NSString *extra; //

@end
