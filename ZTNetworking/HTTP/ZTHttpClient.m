//
//  ZTHttpClient.m
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import "ZTHttpClient.h"

@interface ZTHttpClient ()

@property (nonatomic , strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic , assign) CGFloat timeout; //超时时间

@end

@implementation ZTHttpClient

- (instancetype) init {
    if (self = [super init]) {
        self.sessionManager = [AFHTTPSessionManager manager];
        self.sessionManager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
        self.sessionManager.requestSerializer.timeoutInterval = 30.0f;
        AFHTTPResponseSerializer *serializer = [[AFHTTPResponseSerializer alloc] init];
        serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/xml",@"text/json", @"text/javascript", nil];
        self.sessionManager.responseSerializer = serializer;
    }
    
    return self;
}

- (void) setRequestTimeOut:(CGFloat)timeOut {
    if (timeOut <= 0) {
        timeOut = 30.0f;
    }
    self.timeout = timeOut;
    self.sessionManager.requestSerializer.timeoutInterval = timeOut;
}

- (void) setPinnedCertificates:(NSArray *)certificates {
    self.sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[[NSSet alloc] initWithObjects:certificates, nil]];
     // 客户端是否信任非法证书
    self.sessionManager.securityPolicy.allowInvalidCertificates = YES;
    // 是否在证书域字段中验证域名
    [self.sessionManager.securityPolicy setValidatesDomainName:NO];
}

- (NSURLSessionDataTask *) perfrom_normal_post_URL:(NSString *)url
                                        Parameters:(NSDictionary *)parameters
                                           Headers:(nullable NSDictionary *)headers
                                        Completion:(nullable NormalRequestCompletion) completion{

    return  [self.sessionManager POST:url
                           parameters:parameters
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  
                                  id object = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
#if DEBUG
                                  NSLog(@"retObject = %@" , object);
#endif
                                  completion(object , nil);
                              }
                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#if DEBUG
                                  NSLog(@"error = %@" , error.localizedDescription);
#endif
                                  completion(nil , error);
                              }];
}

- (NSURLSessionDataTask *) perform_upload_URL:(NSString *)url
                                   Parameters:(NSDictionary *)parameters
                                       Binary:(NSData *)binary
                                         Name:(nonnull NSString *)name
                                     FileName:(nonnull NSString *)fileName
                                      Headers:(NSDictionary *)headers
                                     Progress:(nullable UploadProgressBlock)progress
                                   Completion:(UploadRequestCompletion)completion {
    
    __block id retObject = nil;
    __block NSError *retError = nil;
    __block CGFloat completedCount = 0;
    __block CGFloat totalCount = 0;
    __block AFHTTPRequestSerializer *serializer = self.sessionManager.requestSerializer;
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [serializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    NSURLSessionDataTask *taske = [self.sessionManager POST:url
                                                 parameters:parameters
                                  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:binary name:name fileName:fileName mimeType:@"application/octet-stream"];
    
                                  }
                                                   progress:^(NSProgress * _Nonnull uploadProgress) {
                                                       completedCount = uploadProgress.completedUnitCount;
                                                       totalCount = uploadProgress.totalUnitCount;
#if DEBUG
                                                       NSLog(@"total = %.f , completed = %.f" , totalCount  , completedCount);
#endif
                                                       if (progress) {
                                                           progress(totalCount, completedCount);
                                                       }
    }
                                                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                        retObject = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                                        NSLog(@"retObject = %@" , retObject);
                                                        if (completion) {
                                                            completion(retObject, nil);
                                                        }
    }
                                                    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                        retError = error;
                                                        if (completion) {
                                                            completion(nil, retError);
                                                        }
    }];
    
    return taske;
}


//- (NSURLSessionDataTask *) perform_Icloud_URI:(NSString *)uri
//                                   Parameters:(NSDictionary *)parameters
//                                       Binary:(NSData *)binary
//                                         Name:(NSString *)name
//                                     FileName:(NSString *)fileName
//                                      Headers:(NSDictionary *)headers
//                                     Progress:(UploadProgressBlock)progress
//                                   Completion:(UploadRequestCompletion)completion {
//    
//    NSString *url = [NSString stringWithFormat:@"%@%@" , self.icloudHost , uri];
//    __block id retObject = nil;
//    __block NSError *retError = nil;
//    __block CGFloat completedCount = 0;
//    __block CGFloat totalCount = 0;
//    __block AFHTTPRequestSerializer *serializer = self.sessionManager.requestSerializer;
//    if (headers) {
//        [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//            [serializer setValue:obj forHTTPHeaderField:key];
//        }];
//    }
//    NSURLSessionDataTask *taske = [self.sessionManager POST:url
//                                                 parameters:parameters
//                                  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//                                      [formData appendPartWithFileData:binary name:name fileName:fileName mimeType:@"application/octet-stream"];
//                                      
//                                  }
//                                                   progress:^(NSProgress * _Nonnull uploadProgress) {
//                                                       completedCount = uploadProgress.completedUnitCount;
//                                                       totalCount = uploadProgress.totalUnitCount;
//#if DEBUG
//                                                       NSLog(@"total = %.f , completed = %.f" , totalCount  , completedCount);
//#endif
//                                                       if (progress) {
//                                                           progress(totalCount, completedCount);
//                                                       }
//                                                   }
//                                                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                                        retObject = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
//                                                        NSLog(@"retObject = %@" , retObject);
//                                                        if (completion) {
//                                                            completion(retObject, nil);
//                                                        }
//                                                    }
//                                                    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                                        retError = error;
//                                                        if (completion) {
//                                                            completion(nil, retError);
//                                                        }
//                                                    }];
//    
//    return taske;
//}

@end
