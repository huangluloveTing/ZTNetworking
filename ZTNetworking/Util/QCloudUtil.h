//
//  QCloudUtil.h
//  YangHe_SCI
//
//  Created by 黄露 on 2017/7/14.
//  Copyright © 2017年 biz_zlq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCloudUtil : NSObject

+ (NSString *)makePolicyWithParameters:(NSDictionary *)para;

+ (NSString *)makeSignatureWithSecretKey:(NSString *)secretKey
                                  Policy:(NSString *)policy;

@end
