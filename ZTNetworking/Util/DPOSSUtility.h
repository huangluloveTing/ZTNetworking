//
//  DPOSSUtility.h
//  DPClientKit
//
//  Created by CoolCamel on 16/7/27.
//  Copyright © 2016年 www.1919.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPOSSUtility : NSObject

+ (nonnull NSString *)makePolicyWithKey:(nonnull NSString *)key;

+ (nonnull NSString *)makeUploadTokenWithContent:(nonnull NSString *)content
                                       AccessKey:(nonnull NSString *)ak
                                       SecretKey:(nonnull NSString *)sk;


+ (nonnull NSString *)makeDownloadTokenWithURI:(nonnull NSString *)uri
                                       Expires:(NSTimeInterval)expires
                                     AccessKey:(nonnull NSString *)ak
                                     SecretKey:(nonnull NSString *)sk;

+ (nonnull NSString *)encodeURL:(nonnull NSString *)url;
@end
