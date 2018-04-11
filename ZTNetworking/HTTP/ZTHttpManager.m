//
//  ZTHttpRequestManager.m
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import "ZTHttpManager.h"
#import "ZTHttpClient.h"
#import "QCloudUtil.h"

#define Save_File_Dir ([NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject])

@interface ZTHttpManager ()

@property (nonatomic , strong) ZTHttpClient *httpClient;

@property (nonatomic , strong) ZTNetCache *netCache;

@property (nonatomic , strong) NSMutableDictionary *backUploadQueue;
@property (nonatomic , strong) NSMutableArray *backRestRequestQueue; //离线队列

@property (nonatomic , strong) NSMutableDictionary *backRestQueue;  //离线队列
@property (nonatomic , strong) NSMutableArray *backUploadRequestQueue;

//离线队列串行
@property (nonatomic , strong) NSMutableArray *restSyncQueues;
@property (nonatomic , strong) NSMutableArray *uploadSyncQueues;

@property (nonatomic , strong) dispatch_semaphore_t rest_sema_t; // rest 请求的信号量

@property (nonatomic , strong) dispatch_semaphore_t upload_sema_t; // rest 请求的信号量

@property (nonatomic , copy) NSString *qinyun_access_key_id;
@property (nonatomic , copy) NSString *qinyun_secret_key;


//普通Post 接口 的 ip 地址
@property (nonatomic , copy) NSString *normalHost;

//上传接口的 ip
@property (nonatomic , copy) NSString *uploadHost;

@property (nonatomic , copy) NSString *icloudHost;  //三方云服务的ip地址

@end

@implementation ZTHttpManager {
    dispatch_queue_t _rest_queue; //rest 队列
    dispatch_queue_t _upload_queue; //rest 队列
}

static ZTHttpManager *manager = nil;

+ (instancetype) sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (! manager) {
            
            manager = [[ZTHttpManager alloc] init];
            manager.httpClient = [[ZTHttpClient alloc] init];
            [manager.httpClient setRequestTimeOut:40];
            manager.netCache = [[ZTNetCache alloc] init];
            manager.netCache = [[ZTNetCache alloc] init];
            manager.backUploadQueue = [NSMutableDictionary dictionary];
            manager.backRestQueue = [NSMutableDictionary dictionary];
            manager.backRestRequestQueue = [NSMutableArray array];
            manager.backUploadRequestQueue = [NSMutableArray array];
            manager.restSyncQueues = [NSMutableArray array];
            manager.uploadSyncQueues = [NSMutableArray array];
            manager.rest_sema_t = dispatch_semaphore_create(1);
            manager.upload_sema_t = dispatch_semaphore_create(1);
            [manager initQueue];
        }
    });
    
    return manager;
}


+ (instancetype) sharedManagerWithBaseUrl:(NSString *)url {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (! manager) {
            
            manager = [[ZTHttpManager alloc] init];
            manager.httpClient = [[ZTHttpClient alloc] initWithBaseUrl:url];
            [manager.httpClient setRequestTimeOut:40];
            manager.netCache = [[ZTNetCache alloc] init];
            manager.netCache = [[ZTNetCache alloc] init];
            manager.backUploadQueue = [NSMutableDictionary dictionary];
            manager.backRestQueue = [NSMutableDictionary dictionary];
            manager.backRestRequestQueue = [NSMutableArray array];
            manager.backUploadRequestQueue = [NSMutableArray array];
            manager.restSyncQueues = [NSMutableArray array];
            manager.uploadSyncQueues = [NSMutableArray array];
            manager.rest_sema_t = dispatch_semaphore_create(1);
            manager.upload_sema_t = dispatch_semaphore_create(1);
            [manager initQueue];
        }
    });
    
    return manager;
}
- (void) setNormalHost:(NSString *)normalHost
            UploadHost:(NSString *)uploadHost
       ICloudBuketHost:(nullable NSString *)icloudHost{
    
    self.normalHost = normalHost;
    self.uploadHost = uploadHost;
    self.icloudHost = icloudHost;
}

- (void) setRequestTimeout:(CGFloat)timeOut {
    [_httpClient setRequestTimeOut:timeOut];
}

- (void) setRequestSearializer:(id<AFURLRequestSerialization>)requestSearializer {
    [_httpClient setRequestSearializer:requestSearializer];
}

- (void) setPinnedCertificates:(NSArray *)certificates {
    [_httpClient setPinnedCertificates:certificates];
}

- (NSString *) getCacheTempFileDir {
    return Save_File_Dir;
}


- (BOOL) uploadRequestSuccessForRetObject:(id)retObject Request:(ZTHttpRequest *) request {
    
    return NO;
}

- (BOOL) restRequestSuccessForRetObject:(id)retObject Request:(ZTHttpRequest *)request {
    return NO;
}

- (void) setQinyun_Access_key_id:(NSString *)qinAccessKeyId SecretKey:(nonnull NSString *)secretKey {
    self.qinyun_access_key_id = qinAccessKeyId;
    self.qinyun_secret_key = secretKey;
}

- (NSArray *) getCurrentRestQueue {
    NSMutableArray *currentRestQueue = [NSMutableArray array];
    [currentRestQueue addObjectsFromArray:_backRestRequestQueue];
    [currentRestQueue addObjectsFromArray:_restSyncQueues];
    
    return currentRestQueue;
}

- (NSArray *) getCurrentUploadQueue {
    NSMutableArray *currentUploadQueue = [NSMutableArray array];
    [currentUploadQueue addObjectsFromArray:_backUploadRequestQueue];
    [currentUploadQueue addObjectsFromArray:_uploadSyncQueues];
    return currentUploadQueue;
}

- (void) initQueue {
    _rest_queue = dispatch_queue_create("com.jlb.rest.queue.thread", DISPATCH_QUEUE_SERIAL);
    _upload_queue = dispatch_queue_create("com.jlb.upload.queue.thread", DISPATCH_QUEUE_SERIAL);
}

- (NSURLSessionDataTask *) perform_GetRequest_URI:(NSString *)uri
                                       Parameters:(id)parameters
                                          Headers:(NSDictionary *)headers
                                       Completion:(ZTNormalRequestCompletion)completion {
    
//    NSString *url = [NSString stringWithFormat:@"%@%@" , self.normalHost , uri]; `
    NSString *url = @"";
    if (self.interceptor) {
        url = [self.interceptor normalIPForAppManager:self];
    }
    url = [NSString stringWithFormat:@"%@%@" , url , uri];
    
    return [_httpClient perfrom_normal_get_URL:url
                                    Parameters:parameters
                                       Headers:headers
                                    Completion:completion];
}

- (NSURLSessionDataTask *) perform_PostRequest_URI:(NSString *)uri
                                        Parameters:(id)parameters
                                           Headers:(nullable NSDictionary *)headers
                                        Completion:(ZTNormalRequestCompletion)completion {
    
    NSString *url = @"";
    if (self.interceptor) {
        url = [self.interceptor normalIPForAppManager:self];
    }
    url = [NSString stringWithFormat:@"%@%@" , url , uri];
    
    return [self perform_postRequest_URL:url Parameters:parameters Headers:headers Completion:completion];
}

- (NSURLSessionDataTask *) perform_postRequest_URL:(NSString *)url
                                        Parameters:(id)parameters
                                           Headers:(nullable NSDictionary *)headers
                                        Completion:(ZTNormalRequestCompletion)completion {
    return [_httpClient perfrom_normal_post_URL:url
                                     Parameters:parameters
                                        Headers:headers
                                     Completion:^(id  _Nullable retObject, NSError * _Nullable error) {
         if (self.gloableHandler) {
             BOOL handled = self.gloableHandler(retObject , error , parameters);
             if (handled) {
                 return ;
             }
         }
         if (completion) {
             completion(retObject , error);
         }
     }];
}

- (NSURLSessionDataTask *) perform_UploadRequest_URI:(NSString *)uri
                                          Parameters:(id)parameters
                                             Headers:(NSDictionary *)headers
                                                Name:(nonnull NSString *) name
                                            FileName:(nonnull NSString *)fileName
                                              Binary:(nonnull NSData *)binary
                                            Progress:(nullable ZTUploadProgressBlock)progress
                                          Completion:(ZTUploadRequestCompletion)completion {
    NSString *url = @"";
    if (self.interceptor) {
        url = [self.interceptor uploadIPForAppManager:self];
    }
    url = [NSString stringWithFormat:@"%@%@" , url , uri];
    return [self perform_uploadRequest_URL:url
                                Parameters:parameters
                                   Headers:headers
                                      Name:name
                                  FileName:fileName
                                    Binary:binary
                                  Progress:progress
                                Completion:completion];
}

- (NSURLSessionDataTask *) perform_uploadRequest_URL:(NSString *)url
                                          Parameters:(id)parameters
                                             Headers:(NSDictionary *)headers
                                                Name:(nonnull NSString *) name
                                            FileName:(nonnull NSString *)fileName
                                              Binary:(nonnull NSData *)binary
                                            Progress:(nullable ZTUploadProgressBlock)progress
                                          Completion:(ZTUploadRequestCompletion)completion {
    return [_httpClient perform_upload_URL:url
                                Parameters:parameters
                                    Binary:binary
                                      Name:name
                                  FileName:fileName
                                   Headers:headers
                                  Progress:progress
                                Completion:^(id  _Nullable retObject, NSError * _Nullable error) {
            if (self.gloableHandler) {
                BOOL handled = self.gloableHandler(retObject , error , nil);
                if (handled) {
                    return ;
                }
            }
            if (completion) {
                completion(retObject , error);
            }
        }];
}

- (NSURLSessionDataTask *) perform_BackUploadRequest_URI:(NSString *)uri
                                                TaskName:(NSString *)taskName
                                              Parameters:(id)parameters
                                                 Headers:(NSDictionary *)headers
                                                    Name:(NSString *)name
                                                FileName:(NSString *)fileName
                                                  Binary:(NSData *)binary
                                                  Asynac:(BOOL)asynac
                                                Progress:(nullable ZTUploadProgressBlock)progress
                                              Completion:(ZTUploadRequestCompletion)completion {
    
    NSString *url = @"";
    if (self.interceptor) {
        url = [self.interceptor uploadIPForAppManager:self];
    }
    url = [NSString stringWithFormat:@"%@%@" , url , uri];
    ZTHttpRequest *ztRequest = [[ZTHttpRequest alloc] init];
    ztRequest.parameters = parameters;
    ztRequest.identifier = [NSString stringWithFormat:@"%.f",[NSDate date].timeIntervalSince1970 * 1000];
    ztRequest.fileName = fileName;
    ztRequest.name = name;
    ztRequest.url = url;
    ztRequest.requestType = RequestType_UploadFile;
    ztRequest.taskName = taskName;
    ztRequest.aynac = [NSString stringWithFormat:@"%d" , asynac];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.tmp" , Save_File_Dir , ztRequest.identifier];
    
    [binary writeToFile:filePath atomically:YES];
    
    if (asynac) {
        
        return [self enqueSynacUploadRequest:ztRequest];
    }
    
    [self.netCache saveData:ztRequest];
    
    NSURLSessionDataTask *task = [self perform_backUploadRequest:ztRequest Back:YES Completion:completion];

   [self enquenUploadQueun:task Request:ztRequest];
    return task;
}


- (NSURLSessionDataTask *) perform_BackNormalRequest_URI:(NSString *)uri
                                                TaskName:(nullable NSString *)taskName 
                                              Parameters:(id)parameters
                                                 Headers:(NSDictionary *)headers
                                                  Asynac:(BOOL)asynac
                                              Completion:(ZTNormalRequestCompletion)completion {
    
    NSString *url = @"";
    if (self.interceptor) {
        url = [self.interceptor normalIPForAppManager:self];
    }
    url = [NSString stringWithFormat:@"%@%@" , url , uri];
    ZTHttpRequest *ztRequest = [[ZTHttpRequest alloc] init];
    ztRequest.parameters = parameters;
    ztRequest.identifier = [NSString stringWithFormat:@"%.f",[NSDate date].timeIntervalSince1970 * 1000];
    ztRequest.url = url;
    ztRequest.aynac = [NSString stringWithFormat:@"%d" , asynac];
    ztRequest.requestType = RequestType_Normal;
    ztRequest.taskName = taskName;
    
    if (asynac) {
        
        return [self enqueSynacRestRequest:ztRequest];
    }
    
    [self.netCache saveData:ztRequest];
    
    NSURLSessionDataTask *task = [self perform_back_post_request:ztRequest Back:YES Completion:completion];
    [self enquenRestTaskQueun:task Request:ztRequest];
    
    return task;
}

#pragma mark - 青云
- (NSURLSessionDataTask *) perform_Upload_Qinyun_FilePath:(NSString *)qFilePath
                                                 TaskName:(nullable NSString *)taskName
                                                   Binary:(NSData *)fileData
                                                   IsBack:(BOOL)isBack
                                                 Progress:(ZTUploadProgressBlock)progress
                                               Completion:(ZTUploadRequestCompletion)completion {
    
    
    NSString *url = [NSString stringWithFormat:@"%@" , self.icloudHost];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:self.qinyun_access_key_id   forKey:@"access_key_id"];
    [parameters setValue:qFilePath     forKey:@"key"];
    
    NSString *policy = [QCloudUtil makePolicyWithParameters:parameters];
    
    [parameters setValue:policy forKey:@"policy"];
    NSString *signature = [QCloudUtil makeSignatureWithSecretKey:self.qinyun_secret_key Policy:policy];
    [parameters setValue:signature forKey:@"signature"];
    
    ZTHttpRequest *ztRequest = [[ZTHttpRequest alloc] init];
    ztRequest.parameters = parameters;
    ztRequest.identifier = [NSString stringWithFormat:@"%.f",[NSDate date].timeIntervalSince1970 * 1000];
    ztRequest.fileName = qFilePath;
    ztRequest.name = qFilePath;
    ztRequest.url = url;
    ztRequest.requestType = RequestType_UploadFile;
    ztRequest.taskName = taskName;
    
    if (isBack) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.tmp" , Save_File_Dir , ztRequest.identifier];
        [fileData writeToFile:filePath atomically:YES];
        [self.netCache saveData:ztRequest];
        NSURLSessionDataTask *task = [self perform_backUploadRequest:ztRequest Back:YES Completion:completion];
        [self enquenUploadQueun:task Request:ztRequest];
        
        return task;
    }
    
    return [self perform_uploadRequest_URL:url
                                Parameters:parameters
                                   Headers:nil
                                      Name:qFilePath
                                  FileName:qFilePath
                                    Binary:fileData
                                  Progress:progress
                                Completion:completion];
}

#pragma mark --------

- (void) dequeUploadQueun:(ZTHttpRequest *) ztRequest {
    @synchronized(_backUploadQueue) {
        [_backUploadQueue removeObjectForKey:ztRequest.identifier];
        [_backUploadRequestQueue removeObject:ztRequest];
        [self.netCache deleteForEntity:ztRequest fieldValue:ztRequest.identifier fieldName:@"identifier"];
    }
}

- (void) dequeRestQueun:(ZTHttpRequest *)ztRequest {
    @synchronized(_backRestQueue) {
        [_backRestQueue removeObjectForKey:ztRequest.identifier];
        [_backRestRequestQueue removeObject:ztRequest];
        [self.netCache deleteForEntity:ztRequest fieldValue:ztRequest.identifier fieldName:@"identifier"];
    }
}


#pragma mark - private
- (NSURLSessionDataTask *) perform_back_post_request:(ZTHttpRequest *) ztRequest
                                                Back:(BOOL)isBack
                                          Completion:(ZTNormalRequestCompletion)completion {
    NSDictionary *paramters = ztRequest.parameters;
    NSString *uri = [ztRequest.url substringFromIndex:self.normalHost.length];
    
    NSURLSessionDataTask *task = [self perform_PostRequest_URI:uri
                                                    Parameters:paramters
                                                       Headers:nil
                                                    Completion:^(id  _Nullable retObject, NSError * _Nullable error) {
        sleep(REQUEST_SEP_TIME);
        if (completion) {
            completion(retObject , error);
        }
        if (isBack && (![self uploadRequestSuccessForRetObject:retObject Request:ztRequest] || error)) {
            [self restartPostFailedQueuen:ztRequest];
            return ;
        }
        [self dequeRestQueun:ztRequest];
    }];
    
    return task;
}

- (NSURLSessionDataTask *) perform_backUploadRequest:(ZTHttpRequest*) ztRequest
                                                Back:(BOOL)isBack
                                          Completion:(ZTUploadRequestCompletion)completion {
    
    NSString *url = ztRequest.url;
    NSDictionary *parameters = ztRequest.parameters;
    NSString *name = ztRequest.name;
    NSString *fileName = ztRequest.fileName;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.tmp" , Save_File_Dir , ztRequest.identifier];
    NSData *binary = [NSData dataWithContentsOfFile:filePath];
    if (binary.length == 0) {
        return nil;
    }
    NSURLSessionDataTask *task = [self perform_uploadRequest_URL:url
                                                      Parameters:parameters
                                                         Headers:nil
                                                            Name:name
                                                        FileName:fileName
                                                          Binary:binary
                                                        Progress:nil
                                                      Completion:^(id  _Nullable retObject, NSError * _Nullable error) {
          sleep(REQUEST_SEP_TIME);
          if (completion) {
              completion(retObject , error);
          }
          if (isBack && (![self uploadRequestSuccessForRetObject:retObject Request:nil] || error)) {
              [self restartUploadFailedQueuen:ztRequest];
              return ;
          }
          [self dequeUploadQueun:ztRequest];
      }];
    return task;
}

//保存普通任务的task
- (void) enquenRestTaskQueun:(NSURLSessionTask *)dataTask Request:(ZTHttpRequest *)request {
    @synchronized(_backRestQueue) {
        [_backRestQueue setValue:dataTask forKey:request.identifier];
        [_backRestRequestQueue addObject:request];
    }
    
}

//保存上传任务的task
- (void) enquenUploadQueun:(NSURLSessionDataTask *)dataTask Request:(ZTHttpRequest *)request {
    @synchronized(_backUploadQueue) {
        [_backUploadQueue setValue:dataTask forKey:request.identifier];
        [_backUploadRequestQueue addObject:request];
    }
}

//重新开启任务
- (void) restartUploadFailedQueuen:(ZTHttpRequest *)request {
    @synchronized(_backUploadQueue) {
        [_backUploadQueue removeObjectForKey:request.identifier];
        ZTHttpRequest *ztRequest = [ZTHttpRequest serializeWithJsonObject:[self.netCache queryForEntity:request
                                                                                             queryValue:request.identifier
                                                                                                 fieldName:@"identifier"][0]];
        NSURLSessionDataTask *task = [self perform_backUploadRequest:ztRequest
                                                                Back:YES
                                                          Completion:^(id  _Nullable retObject, NSError * _Nullable error) {
                                                          }];
        [_backUploadQueue setValue:task forKey:request.identifier];
    }
}

//重新开启任务
- (void) restartPostFailedQueuen:(ZTHttpRequest *)request {
    @synchronized(_backRestQueue) {
        [_backRestQueue removeObjectForKey:request.identifier];
        ZTHttpRequest *ztRequest = [ZTHttpRequest serializeWithJsonObject:[self.netCache queryForEntity:request queryValue:request.identifier fieldName:@"identifier"][0]];
        NSURLSessionDataTask *task = [self perform_back_post_request:ztRequest Back:YES Completion:nil];
        [_backRestQueue setValue:task forKey:request.identifier];
    }
}

#pragma mark - rest
#pragma mark - ===========================
//串行队列
- (NSURLSessionDataTask *) enqueSynacRestRequest:(ZTHttpRequest *)request {
    @synchronized(_restSyncQueues) {
        [self.netCache saveData:request];
        [_restSyncQueues addObject:request];
    }
    
    return [self perform_sync_Rest_Request:[_restSyncQueues firstObject] Completion:nil];
}

- (NSURLSessionDataTask *) popSyncRestRequest:(ZTHttpRequest *)request {
    @synchronized(_restSyncQueues) {
        [_restSyncQueues removeObject:request];
        [self.netCache deleteForEntity:request fieldValue:request.identifier fieldName:@"identifier"];
    }
    return [self perform_sync_Rest_Request:[_restSyncQueues firstObject] Completion:nil];
}

- (NSURLSessionDataTask *) putQueunRestStackBottomRequest:(ZTHttpRequest *)request {
    @synchronized(_restSyncQueues) {
        [_restSyncQueues removeObject:request];
        [self.netCache deleteForEntity:request fieldValue:request.identifier fieldName:@"identifier"];
        [_restSyncQueues addObject:request];
        [self.netCache saveData:request];
    }
    return [self perform_sync_Rest_Request:[_restSyncQueues firstObject] Completion:nil];
}

//串行离线队列 -- 普通
- (NSURLSessionDataTask *) perform_sync_Rest_Request:(ZTHttpRequest *)request
                                          Completion:(ZTNormalRequestCompletion)completion {
    
    if (!request) {
        return nil;
    }
    ZTWeakify(self);
    __block NSURLSessionDataTask *task = nil;
    dispatch_async(_rest_queue, ^{
        dispatch_semaphore_wait(_rest_sema_t, DISPATCH_TIME_FOREVER);
        task = [self perform_postRequest_URL:request.url
                                  Parameters:request.parameters
                                     Headers:nil
                                  Completion:^(id  _Nullable retObject, NSError * _Nullable error) {
             ZTStrongify(self);
              sleep(REQUEST_SEP_TIME);
             if (self.gloableHandler) {
                 BOOL handled = self.gloableHandler(retObject , error , request);
                 if (handled) {
                     dispatch_semaphore_signal(_rest_sema_t);
                     task = [self popSyncRestRequest:request];
                     return;
                 }
             }
             
             if (error || ! [self restRequestSuccessForRetObject:retObject Request:request]) {
                 task = [self putQueunRestStackBottomRequest:request];
                 dispatch_semaphore_signal(_rest_sema_t);
             } else {
                 task = [self popSyncRestRequest:request];
                 dispatch_semaphore_signal(_rest_sema_t);
             }
         }];
    });
    return task;
}

#pragma mark - upload
#pragma mark - ===========================
- (NSURLSessionDataTask *) enqueSynacUploadRequest:(ZTHttpRequest *)request {
    @synchronized(_uploadSyncQueues) {
        [self.netCache saveData:request];
        [_uploadSyncQueues addObject:request];
    }
    
   return [self perform_sync_Upload_Request:[_uploadSyncQueues firstObject]  Completion:nil];
}

- (NSURLSessionDataTask *) popSyncUploadRequest:(ZTHttpRequest *)request {
    @synchronized(_uploadSyncQueues) {
        [_uploadSyncQueues removeObject:request];
        [self.netCache deleteForEntity:request fieldValue:request.identifier fieldName:@"identifier"];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.tmp" , Save_File_Dir , request.identifier];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:filePath]) {
            [manager isDeletableFileAtPath:filePath];
        }
    }
    return [self perform_sync_Upload_Request:[_uploadSyncQueues firstObject]  Completion:nil];
}

- (NSURLSessionDataTask *) putQueunUploadStackBottomRequest:(ZTHttpRequest *)request {
    @synchronized(_uploadSyncQueues) {
        [_uploadSyncQueues removeObject:request];
        [self.netCache deleteForEntity:request fieldValue:request.identifier fieldName:@"identifier"];
        [_uploadSyncQueues addObject:request];
        [self.netCache saveData:request];
    }
    return [self perform_sync_Upload_Request:[_uploadSyncQueues firstObject]  Completion:nil];
}
//串行离线队列 -- upload
- (NSURLSessionDataTask *) perform_sync_Upload_Request:(ZTHttpRequest *)request
                                            Completion:(ZTNormalRequestCompletion)completion {
    
    if (!request) {
        return nil;
    }
    ZTWeakify(self);
    __block NSURLSessionDataTask *task = nil;
    dispatch_async(_upload_queue, ^{
        dispatch_semaphore_wait(_upload_sema_t, DISPATCH_TIME_FOREVER);
       task = [self perform_backUploadRequest:request
                                         Back:YES
                                   Completion:^(id  _Nullable retObject, NSError * _Nullable error) {
             ZTStrongify(self);
             if (self.gloableHandler) {
                 BOOL handled = self.gloableHandler(retObject , error , request);
                 if (handled) {
                     dispatch_semaphore_signal(_upload_sema_t);
                     task = [self popSyncUploadRequest:request];
                 }
             }
           
             if (error || [self uploadRequestSuccessForRetObject:retObject Request:request]) {
                 dispatch_semaphore_signal(_upload_sema_t);
                 task = [self putQueunUploadStackBottomRequest:request];
                 
             } else {
                 dispatch_semaphore_signal(_upload_sema_t);
                 task = [self popSyncUploadRequest:request];
             }
         }];
    });
    return task;
}

- (void) restartAllOfflineQueue {
    ZTHttpRequest *request = [[ZTHttpRequest alloc] init];
    NSArray *allCacheData = [self.netCache queryAllDataWithEntity:request];
    for (NSDictionary *parameters in allCacheData) {
        ZTHttpRequest *re = [ZTHttpRequest serializeWithJsonObject:parameters];
        NSLog(@"");
        
        if ([re.requestType isEqualToString:RequestType_Normal]) {
            [self perform_BackNormalRequest_URI:re.url
                                       TaskName:re.taskName
                                     Parameters:re.parameters
                                        Headers:nil
                                         Asynac:re.aynac.boolValue
                                     Completion:nil];
        }
        if ([re.requestType isEqualToString:RequestType_UploadFile]) {
            if (re.aynac.boolValue) {
                [self enqueSynacUploadRequest:re];
            } else {
                [self perform_backUploadRequest:re Back:YES Completion:nil];
            }
        }
    }
}

- (NSURLSessionDataTask *)perform_Upload_Qiniu_Key:(NSString *)QKey
                                        BucketName:(nonnull NSString *)bucketName
                                          TaskName:(NSString *)taskName
                                            Binary:(NSData *)fileData
                                            IsBack:(BOOL)isBack
                                         SecretKey:(nonnull NSString *)secretKey
                                          Progress:(ZTUploadProgressBlock)progress
                                        Completion:(ZTUploadRequestCompletion)completion {
    
    
    NSString *url = [NSString stringWithFormat:@"%@" , self.icloudHost];
    
    //构造上传凭证
    NSString *scope = [NSString stringWithFormat:@"%@:%@" , bucketName , QKey];
    NSString *deadline = [NSString stringWithFormat:@"%.f" , [[NSDate date] timeIntervalSince1970] * 1000 + 3600];
    NSDictionary *uploadPolocy = @{
                                   @"scope":scope,
                                   @"deadline":deadline
                                   };
    NSString *policy = [QCloudUtil makePolicyWithParameters:uploadPolocy];
    NSString *sign = [QCloudUtil makeSignatureSha1WithSecretKey:secretKey Policy:policy];
    NSString *uploadToken = [NSString stringWithFormat:@"%@:%@:%@", secretKey , sign , policy];
    
    NSDictionary *paramters = @{
                                @"token":uploadToken,
                                @"key":QKey
                                };
    
    ZTHttpRequest *ztRequest = [[ZTHttpRequest alloc] init];
    ztRequest.parameters = paramters;
    ztRequest.identifier = [NSString stringWithFormat:@"%.f",[NSDate date].timeIntervalSince1970 * 1000];
    ztRequest.fileName = QKey;
    ztRequest.name = QKey;
    ztRequest.url = url;
    ztRequest.requestType = RequestType_UploadFile;
    ztRequest.taskName = taskName;
    if (isBack) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.tmp" , Save_File_Dir , ztRequest.identifier];
        [fileData writeToFile:filePath atomically:YES];
        [self.netCache saveData:ztRequest];
        NSURLSessionDataTask *task = [self perform_backUploadRequest:ztRequest Back:YES Completion:completion];
        [self enquenUploadQueun:task Request:ztRequest];
        
        return task;
    }
    
    return [self perform_uploadRequest_URL:url
                                Parameters:paramters
                                   Headers:nil
                                      Name:QKey
                                  FileName:QKey
                                    Binary:fileData
                                  Progress:progress
                                Completion:completion];
}

- (void) perform_Upload_Qiniu_Key:(NSString *)QKey
                           Binary:(NSData *)fileData
                            Token:(NSString *)token
                         Progress:(ZTUploadProgressBlock)progress
                       Completion:(ZTUploadRequestCompletion)completion {
    
    [_httpClient perform_QiniuUpload_Token:token
                                      Data:fileData
                                       Key:QKey
                                  Progress:progress
                                Completion:completion];
}

@end
