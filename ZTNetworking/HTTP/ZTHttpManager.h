//
//  ZTHttpRequestManager.h
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTNetCache.h"
#import "ZTHttpConst.h"

static NSString * _Nullable const ZT_REST_TASK_IP = @"http://192.168.31.101:8080/eisp/";

static NSString * _Nullable const ZT_UPLoad_TASK_IP = @"http://192.168.31.101:8080/eisp/uploadServletForIos";

#define REQUEST_SEP_TIME (3)



typedef void(^ZTNormalRequestCompletion)(_Nullable id retObject ,  NSError * _Nullable error);

typedef void(^ZTUploadRequestCompletion)(_Nullable id retObject ,NSError * _Nullable error);

typedef void(^ZTUploadProgressBlock)(CGFloat totalUnitCount , CGFloat completedProgress);

typedef BOOL(^ZTGloableRequestHandler)(_Nullable id retObject , NSError * _Nullable error , id _Nullable requestObject);

@interface ZTHttpManager : NSObject


@property (nonatomic , copy , nullable) ZTNormalRequestCompletion restCompletion;

@property (nonatomic , copy , nullable) ZTGloableRequestHandler gloableHandler;

@property (nonatomic , copy , nullable) ZTUploadRequestCompletion uploadCompletion;

@property (nonatomic , copy , nullable) ZTUploadProgressBlock progressBlock;


+ (nonnull instancetype) sharedManager;


/**
 设置超时时间

 @param timeOut timeOut
 */
- (void)setRequestTimeout:(CGFloat)timeOut;


/**
 当前所有普通队列

 @return 普通对列
 */
- (nullable NSArray *) getCurrentRestQueue;

/**
 当前文件离线队列

 @return 离线队列
 */
- (nullable NSArray *) getCurrentUploadQueue;


/**
 上传文件时 ， 离线文件保存的文件夹

 @return return
 */
- (nonnull NSString *) getCacheTempFileDir;

/**
 启动未完成的离线队列
 */
- (void) restartAllOfflineQueue;

/**
 普通网络请求接口

 @param uri uri
 @param parameters 参数
 @param headers 头信息
 @param completion block
 @return return
 */
- (nullable NSURLSessionDataTask *) perform_PostRequest_URI:(nonnull NSString *)uri
                                                 Parameters:(nullable NSDictionary *)parameters
                                                    Headers:(nullable NSDictionary *)headers
                                                 Completion:(nullable ZTNormalRequestCompletion)completion;

/**
 普通上传图片 和 文件接口

 @param uri uri
 @param parameters 参数
 @param headers headers
 @param name name
 @param fileName fileName
 @param binary 文件二进制数据
 @param completion block
 @return return
 */
- (nullable NSURLSessionDataTask *) perform_UploadRequest_URI:(nonnull NSString *)uri
                                                   Parameters:(nullable NSDictionary *)parameters
                                                      Headers:(nullable NSDictionary *)headers
                                                         Name:(nonnull NSString *) name
                                                     FileName:(nonnull NSString *)fileName
                                                       Binary:(nonnull NSData *)binary
                                                     Progress:(nullable ZTUploadProgressBlock)progress
                                                   Completion:(nullable ZTUploadRequestCompletion)completion;

/**
 支持后台数据 post 的接口
 使用该方法， 参数实体必须遵守 PZTObject 协议
 
 @param uri uri
 @param parameters 参数实体
 @param headers headers
 @param  asynac Asynac:(BOOL)asynac
 @param completion completion
 @return return
 */
- (nullable NSURLSessionDataTask *) perform_BackNormalRequest_URI:(nonnull NSString *)uri
                                                         TaskName:(nullable NSString *)taskName
                                                       Parameters:(nullable NSDictionary *)parameters
                                                          Headers:(nullable NSDictionary *)headers
                                                           Asynac:(BOOL)asynac
                                                       Completion:(nullable ZTNormalRequestCompletion)completion;


/**
 支持后台文件上传接口
 用该方法， 文件参数 必须是 遵守 PZTObject 协议的对象实体

 @param uri uri
 @param parameters 参数
 @param headers headers
 @param name name
 @param fileName fileName
 @param binary 二进制书记
 @param asynac 是否串行
 @param progress progress
 @param completion completion
 @return return
 */
- (nullable NSURLSessionDataTask *) perform_BackUploadRequest_URI:(nonnull NSString *) uri
                                                         TaskName:(nullable NSString *)taskName
                                                       Parameters:(nullable NSDictionary *)parameters
                                                          Headers:(nullable NSDictionary *)headers
                                                             Name:(nonnull NSString *) name
                                                         FileName:(nonnull NSString *)fileName
                                                           Binary:(nonnull NSData *)binary
                                                           Asynac:(BOOL)asynac
                                                         Progress:(nullable ZTUploadProgressBlock)progress
                                                       Completion:(nullable ZTUploadRequestCompletion)completion;

#pragma mark - 需重写的方法
/**
 针对文件上传离线 时 ， 判断返回数据 是否 是成功的判断

 @param retObject 服务端返回的数据
 @return return
 */
- (BOOL) uploadRequestSuccessForRetObject:(nullable id)retObject;

/**
 针对普通数据 离线 时 ， 判断返回数据 是否 是成功的判断
 @param retObject 服务端返回数据
 @return return value descriptio
 */
- (BOOL) restRequestSuccessForRetObject:(nullable id)retObject;


@end
