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
#import "ZTHttpRequest.h"
#import "ZTResultObject.h"
#import <AFURLRequestSerialization.h>

#define REQUEST_SEP_TIME (3)

@class ZTHttpManager;

@protocol ZTHttpManagerInterceptor <NSObject>

- (NSString *_Nullable) normalIPForAppManager:(nullable ZTHttpManager *)coreManager;

- (NSString *_Nullable) uploadIPForAppManager:(nullable ZTHttpManager *)coreManager;

- (NSString *_Nullable) icloudIPForAppManager:(nullable ZTHttpManager *)coreManager;

@end

@protocol ZTHttpManagerResponseInterceptor <NSObject>

@optional
- (nullable id) requestManager:(nullable ZTHttpManager *)manager handlerResponse:(ZTResultObject *_Nullable)result;

@end

@protocol ZTHttpManagerRequestInterceptor <NSObject>

@optional
- (nullable NSURLRequest *) requestManager:(nullable ZTHttpManager *)manager request:(nullable NSURLRequest *)request;

- (nullable id) requestManager:(nullable ZTHttpManager *)manager paramter:(nullable id)parameter;

- (nullable NSDictionary *) requestManager:(nullable ZTHttpManager *)manager header:(nullable NSDictionary *)header;

@end


typedef void(^ZTNormalRequestCompletion)(_Nullable id retObject ,  NSError * _Nullable error);

typedef void(^ZTUploadRequestCompletion)(_Nullable id retObject ,NSError * _Nullable error);

typedef void(^ZTUploadProgressBlock)(CGFloat totalUnitCount , CGFloat completedProgress);

typedef BOOL(^ZTGloableRequestHandler)(_Nullable id retObject , NSError * _Nullable error , id _Nullable requestObject);

/**
 建议继承该类，然后写业务方面的接口 ， 对于 离线的 状态判断，需要自己重写 成功 判断
 */
@interface ZTHttpManager : NSObject


@property (nonatomic , copy , nullable) ZTNormalRequestCompletion restCompletion; 

@property (nonatomic , copy , nullable) ZTGloableRequestHandler gloableHandler;

@property (nonatomic , copy , nullable) ZTUploadRequestCompletion uploadCompletion;

@property (nonatomic , copy , nullable) ZTUploadProgressBlock progressBlock;

@property (nonatomic , weak , nullable) id <ZTHttpManagerInterceptor> interceptor;

@property (nonatomic , weak , nullable) id <ZTHttpManagerResponseInterceptor> responseHandler;

@property (nonatomic , weak , nullable) id <ZTHttpManagerRequestInterceptor> requestHandler;

+ (nonnull instancetype) sharedManager;

/**
 带URL初始化 (AFNetWorking3.2 使用)
 
 @param url baseUrl
 @return instancetype
 */
+ (nonnull instancetype) sharedManagerWithBaseUrl:(nonnull NSString *)url;

/**
 设置请求的Ip地址

 @param normalHost 普通接口的ip
 @param uploadHost 上传的ip
 @param icloudHost 云服务的ip地址
 */
//- (void) setNormalHost:(nonnull NSString *)normalHost
//            UploadHost:(nonnull NSString *)uploadHost
//       ICloudBuketHost:(nullable NSString *)icloudHost;


/**
 青云云存储的配置

 @param qinAccessKeyId access key id
 @param secretKey secret key
 */
- (void) setQinyun_Access_key_id:(nonnull NSString *)qinAccessKeyId
                       SecretKey:(nonnull NSString *)secretKey;

/**
 设置超时时间

 @param timeOut timeOut
 */
- (void)setRequestTimeout:(CGFloat)timeOut;

- (void) setRequestSearializer:(nullable id<AFURLRequestSerialization>)requestSearializer;

/**
 设置证书

 @param certificates certificates description
 */
- (void) setPinnedCertificates:(nullable NSArray *)certificates;


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
 普通GET 请求接口

 @param uri uri
 @param parameters 参数
 @param headers 请求头
 @param completion block
 @return return value description
 */
- (nullable NSURLSessionDataTask *) perform_GetRequest_URI:(nonnull NSString *)uri
                                                Parameters:(nullable id) parameters
                                                   Headers:(nullable NSDictionary *) headers
                                                Completion:(nullable ZTNormalRequestCompletion)completion;

/**
 普通网络请求接口

 @param uri uri
 @param parameters 参数
 @param headers 头信息
 @param completion block
 @return return
 */
- (nullable NSURLSessionDataTask *) perform_PostRequest_URI:(nonnull NSString *)uri
                                                 Parameters:(nullable id)parameters
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
                                                   Parameters:(nullable id)parameters
                                                      Headers:(nullable NSDictionary *)headers
                                                         Name:(nonnull NSString *) name
                                                     FileName:(nonnull NSString *)fileName
                                                       Binary:(nonnull NSData *)binary
                                                     Progress:(nullable ZTUploadProgressBlock)progress
                                                   Completion:(nullable ZTUploadRequestCompletion)completion;

/**
 支持后台数据 post 的接口
 
 @param uri uri
 @param parameters 参数实体
 @param headers headers
 @param  asynac Asynac:(BOOL)asynac
 @param completion completion
 @return return
 */
- (nullable NSURLSessionDataTask *) perform_BackNormalRequest_URI:(nonnull NSString *)uri
                                                         TaskName:(nullable NSString *)taskName
                                                       Parameters:(nullable id)parameters
                                                          Headers:(nullable NSDictionary *)headers
                                                           Asynac:(BOOL)asynac
                                                       Completion:(nullable ZTNormalRequestCompletion)completion;


/**
 支持后台文件上传接口

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
                                                       Parameters:(nullable id)parameters
                                                          Headers:(nullable NSDictionary *)headers
                                                             Name:(nonnull NSString *) name
                                                         FileName:(nonnull NSString *)fileName
                                                           Binary:(nonnull NSData *)binary
                                                           Asynac:(BOOL)asynac
                                                         Progress:(nullable ZTUploadProgressBlock)progress
                                                       Completion:(nullable ZTUploadRequestCompletion)completion;

#pragma mark -- 青云

/**
 青云云存储

 @param qFilePath 对应的 参数列表的key ------ 青云 文件的地址
 @param taskName 任务名称。----- 该属性 方便查看离线队列的 来源
 @param fileData 数据
 @param isBack 是否离线
 @param progress 进度
 @param completion block
 @return return
 */
- (nullable NSURLSessionDataTask *) perform_Upload_Qinyun_FilePath:(nonnull NSString *)qFilePath
                                                          TaskName:(nullable NSString *)taskName
                                                            Binary:(nonnull NSData *)fileData
                                                            IsBack:(BOOL)isBack
                                                          Progress:(nullable ZTUploadProgressBlock)progress
                                                        Completion:(nullable ZTUploadRequestCompletion)completion;


/**
 七牛上传

 @param QKey 七牛key
 @param taskName 任务名称
 @param fileData 文件二进制
 @param isBack 是否后台
 @param progress 进度
 @param completion 回调
 @return return
 */
- (nullable NSURLSessionDataTask *) perform_Upload_Qiniu_Key:(nonnull NSString *)QKey
                                                  BucketName:(nonnull NSString *)bucketName
                                                    TaskName:(nullable NSString *)taskName
                                                      Binary:(nonnull NSData *)fileData
                                                      IsBack:(BOOL)isBack
                                                   SecretKey:(nonnull NSString *)secretKey
                                                    Progress:(nullable ZTUploadProgressBlock)progress
                                                  Completion:(nullable ZTUploadRequestCompletion)completion;

/**
 七牛上传

 @param QKey QKey description
 @param fileData fileData description
 @param token token description
 @param progress progress description
 @param completion completion description
 */
- (void) perform_Upload_Qiniu_Key:(nonnull NSString *)QKey
                           Binary:(nonnull NSData *)fileData
                            Token:(nonnull NSString *)token
                         Progress:(nullable ZTUploadProgressBlock)progress
                       Completion:(nullable ZTUploadRequestCompletion)completion;


#pragma mark - 需重写的方法
/**
 针对文件上传离线 时 ， 判断返回数据 是否 是成功的判断
 
 @param retObject 服务端返回的数据
 @return return
 */
- (BOOL) uploadRequestSuccessForRetObject:(nullable id)retObject
                                  Request:(nullable ZTHttpRequest *) request;

/**
 针对普通数据 离线 时 ， 判断返回数据 是否 是成功的判断
 @param retObject 服务端返回数据
 @return return value descriptio
 */
- (BOOL) restRequestSuccessForRetObject:(nullable id)retObject
                                Request:(nullable ZTHttpRequest *)request;




@end
