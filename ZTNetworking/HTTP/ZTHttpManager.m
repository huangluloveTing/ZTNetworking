//
//  ZTHttpRequestManager.m
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import "ZTHttpManager.h"
#import "ZTHttpClient.h"
#import "ZTResultObject.h"
#import "ZTHttpRequest.h"


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
            manager.httpClient = [[ZTHttpClient alloc] initWithNormalHost:ZT_REST_TASK_IP
                                                               UploadHost:ZT_UPLoad_TASK_IP];
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


- (void) setRequestTimeout:(CGFloat)timeOut {
    [_httpClient setRequestTimeOut:timeOut];
}

- (NSString *) getCacheTempFileDir {
    return Save_File_Dir;
}


- (BOOL) uploadRequestSuccessForRetObject:(id)retObject {
    
    return NO;
}

- (BOOL) restRequestSuccessForRetObject:(id)retObject {
    return NO;
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

- (NSURLSessionDataTask *) perform_PostRequest_URI:(NSString *)uri
                                        Parameters:(NSDictionary *)parameters
                                           Headers:(nullable NSDictionary *)headers
                                        Completion:(ZTNormalRequestCompletion)completion {
    
    
    return [_httpClient perfrom_normal_post_URI:uri
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
                                          Parameters:(NSDictionary *)parameters
                                             Headers:(NSDictionary *)headers
                                                Name:(nonnull NSString *) name
                                            FileName:(nonnull NSString *)fileName
                                              Binary:(nonnull NSData *)binary
                                            Progress:(nullable ZTUploadProgressBlock)progress
                                          Completion:(ZTUploadRequestCompletion)completion {
    
    return [_httpClient perform_upload_URI:uri
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
                                                TaskName:(nullable NSString *)taskName
                                              Parameters:(nullable NSDictionary *)parameters
                                                 Headers:(NSDictionary *)headers
                                                    Name:(NSString *)name
                                                FileName:(NSString *)fileName
                                                  Binary:(NSData *)binary
                                                  Asynac:(BOOL)asynac
                                                Progress:(nullable ZTUploadProgressBlock)progress
                                              Completion:(ZTUploadRequestCompletion)completion {
    
    ZTHttpRequest *ztRequest = [[ZTHttpRequest alloc] init];
    ztRequest.parameters = parameters;
    ztRequest.identifier = [NSString stringWithFormat:@"%.f",[NSDate date].timeIntervalSince1970 * 1000];
    ztRequest.fileName = fileName;
    ztRequest.name = name;
    ztRequest.uri = uri;
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
                                              Parameters:(nullable NSDictionary *)parameters
                                                 Headers:(NSDictionary *)headers
                                                  Asynac:(BOOL)asynac
                                              Completion:(ZTNormalRequestCompletion)completion {
    
    ZTHttpRequest *ztRequest = [[ZTHttpRequest alloc] init];
    ztRequest.parameters = parameters;
    ztRequest.identifier = [NSString stringWithFormat:@"%.f",[NSDate date].timeIntervalSince1970 * 1000];
    ztRequest.uri = uri;
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

- (void) dequeUploadQueun:(ZTHttpRequest *) ztRequest {
    @synchronized(_backUploadQueue) {
        [_backUploadQueue removeObjectForKey:ztRequest.identifier];
        [_backUploadRequestQueue removeObject:ztRequest];
        [self.netCache deleteForEntity:ztRequest columnValue:ztRequest.identifier column:@"identifier"];
    }
}

- (void) dequeRestQueun:(ZTHttpRequest *)ztRequest {
    @synchronized(_backRestQueue) {
        [_backRestQueue removeObjectForKey:ztRequest.identifier];
        [_backRestRequestQueue removeObject:ztRequest];
        [self.netCache deleteForEntity:ztRequest columnValue:ztRequest.identifier column:@"identifier"];
    }
}


#pragma mark - private
- (NSURLSessionDataTask *) perform_back_post_request:(ZTHttpRequest *) ztRequest
                                                Back:(BOOL)isBack
                                          Completion:(ZTNormalRequestCompletion)completion {
    NSDictionary *paramters = ztRequest.parameters;
    NSString *uri = ztRequest.uri;
    
    NSURLSessionDataTask *task = [self perform_PostRequest_URI:uri
                                                    Parameters:paramters
                                                       Headers:nil
                                                    Completion:^(id  _Nullable retObject, NSError * _Nullable error) {
        sleep(REQUEST_SEP_TIME);
        if (completion) {
            completion(retObject , error);
        }
        if (isBack && (![self uploadRequestSuccessForRetObject:retObject] || error)) {
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
    
    NSString *uri = ztRequest.uri;
    NSDictionary *parameters = ztRequest.parameters;
    NSString *name = ztRequest.name;
    NSString *fileName = ztRequest.fileName;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.tmp" , Save_File_Dir , ztRequest.identifier];
    NSData *binary = [NSData dataWithContentsOfFile:filePath];
    if (binary.length == 0) {
        return nil;
    }
    NSURLSessionDataTask *task = [self perform_UploadRequest_URI:uri
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
          if (isBack && (![self uploadRequestSuccessForRetObject:retObject] || error)) {
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
                                                                                                 column:@"identifier"][0]];
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
        ZTHttpRequest *ztRequest = [ZTHttpRequest serializeWithJsonObject:[self.netCache queryForEntity:request
                                                                                             queryValue:request.identifier
                                                                                                 column:@"identifier"][0]];
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
        [self.netCache deleteForEntity:request columnValue:request.identifier column:@"identifier"];
    }
    return [self perform_sync_Rest_Request:[_restSyncQueues firstObject] Completion:nil];
}

- (NSURLSessionDataTask *) putQueunRestStackBottomRequest:(ZTHttpRequest *)request {
    @synchronized(_restSyncQueues) {
        [_restSyncQueues removeObject:request];
        [self.netCache deleteForEntity:request columnValue:request.identifier column:@"identifier"];
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
        task = [self perform_PostRequest_URI:request.uri
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
             
             if (error || ! [self restRequestSuccessForRetObject:retObject]) {
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
        [self.netCache deleteForEntity:request columnValue:request.identifier column:@"identifier"];
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
        [self.netCache deleteForEntity:request columnValue:request.identifier column:@"identifier"];
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
           
             if (error || [self uploadRequestSuccessForRetObject:retObject]) {
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
            [self perform_BackNormalRequest_URI:re.uri
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

@end
