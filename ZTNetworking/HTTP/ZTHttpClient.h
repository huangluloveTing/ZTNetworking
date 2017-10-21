//
//  ZTHttpClient.h
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking.h>

typedef void(^NormalRequestCompletion)(_Nullable id retObject , NSError * _Nullable error);

typedef void(^UploadRequestCompletion)(_Nullable id retObject ,  NSError * _Nullable error);

typedef void(^UploadProgressBlock)(CGFloat totalUnitCount , CGFloat completedUnitCount);

@interface ZTHttpClient : NSObject

@property (nonatomic , copy  ,nullable) NormalRequestCompletion normalCompletion; //正常接口的回调

@property (nonatomic , copy , nullable) UploadRequestCompletion uploadCompletion; //上床接口的回调

@property (nonatomic , copy , nullable) UploadProgressBlock progressBlock; //上传进度block

/**
 初始化

 @param normalHost 正常请求接口的ip
 @param uploadHost 上传接口的请求ip
 @return return value description
 */
-(nonnull instancetype) initWithNormalHost:(nonnull NSString *)normalHost
                                UploadHost:(nonnull NSString *)uploadHost;


/**
 https 网络请求， 设置ssl 证书

 @param certificates 证书
 */
- (void) setPinnedCertificates:(nullable NSArray *)certificates;

/**
 设置超时时间

 @param timeOut 超时时间
 */
- (void) setRequestTimeOut:(CGFloat)timeOut;


/**
 普通接口

 @param uri 唯一自愿标识符
 @param parameters 参数
 @param headers header
 @param completion block
 @return task
 */
- (nullable NSURLSessionDataTask *) perfrom_normal_post_URI:(nonnull NSString *)uri
                                                 Parameters:(nullable NSDictionary *)parameters
                                                    Headers:(nullable NSDictionary *)headers
                                                 Completion:(nullable NormalRequestCompletion)completion;

/**
 上传接口

 @param uri 唯一资源标志符
 @param parameters 参数
 @param binary 文件数据
 @param name  名称
 @param fileName 文件名
 @param headers header
 @param completion block
 @return task
 */
- (nullable NSURLSessionDataTask *) perform_upload_URI:(nonnull NSString *)uri
                                            Parameters:(nullable NSDictionary *)parameters
                                                Binary:(nullable NSData *)binary
                                                  Name:(nonnull NSString *)name
                                              FileName:(nonnull NSString *)fileName
                                               Headers:(nullable NSDictionary *)headers
                                              Progress:(nullable UploadProgressBlock)progress
                                            Completion:(nullable UploadRequestCompletion)completion;


@end
