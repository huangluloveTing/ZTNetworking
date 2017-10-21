//
//  QCloudUtil.m
//  YangHe_SCI
//
//  Created by 黄露 on 2017/7/14.
//  Copyright © 2017年 biz_zlq. All rights reserved.

//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>

#import "QCloudUtil.h"

static uint8_t const QBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

@implementation QCloudUtil

+ (NSString *)makePolicyWithParameters:(NSDictionary *)para {
    
    NSError *error = nil;
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:para options:NSJSONWritingPrettyPrinted error:&error];
    
    return [QCloudUtil Base64EncodeWithData:jsonData EncodeTable:QBase64EncodingTable];;
}

+ (NSString *)makeSignatureWithSecretKey:(NSString *)secretKey
                                  Policy:(NSString *)policy {
    
    NSData *sign = [QCloudUtil HmacSha256EncryptWithData:policy
                                                      Key:secretKey];
    
    NSString * encodedSign = [QCloudUtil Base64EncodeWithData:sign
                                            EncodeTable:QBase64EncodingTable];
    
    return encodedSign;
}

+ (NSData *)HmacSha256EncryptWithData:(NSString *)data Key:(NSString *)key {
    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData * HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return HMAC;
}

+ (NSString *)Base64EncodeWithData:(NSData *)data EncodeTable:(const uint8_t*)encodeTable {
    
    if(!encodeTable)
        return @"";
    
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = encodeTable[(value >> 18) & 0x3F];
        output[idx + 1] = encodeTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? encodeTable[(value >> 6) & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? encodeTable[(value >> 0) & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

@end
