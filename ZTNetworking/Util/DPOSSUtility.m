//
//  DPOSSUtility.m
//  DPClientKit
//
//  Copyright © 2016年 www.1919.cn. All rights reserved.
//

#import "DPOSSUtility.h"
#import "ZTCryptoUtility.h"

@implementation DPOSSUtility

static uint8_t const kBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

+ (NSString *)makePolicyWithKey:(NSString *)key {
    
    NSString * policy = @"";
    struct tm *timeinfo;
    char buffer[80];
    time_t rawtime = (time_t)([[NSDate date] timeIntervalSince1970] + 60000);
    timeinfo = gmtime(&rawtime);
    strftime(buffer, 80, "%Y-%m-%dT%H:%M:%SZ", timeinfo);

    NSString * expiration = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    NSArray * conditions = @[@[@"eq", @"$key", key]];
    
    NSDictionary * jsonObject = @{@"expiration" : expiration,
                                  @"conditions" : conditions};
    
    NSError * error = nil;
    NSData * policyData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                              options:NSJSONWritingPrettyPrinted
                                                                error:&error];
    
    NSLog(@"OSS Signature Error = %@", error);
    if(!error && policyData) {
        
        policy = [ZTCryptoUtility Base64EncodeWithData:policyData
                                           EncodeTable:kBase64EncodingTable];
    }
    
    return policy;
}

+ (NSString *)makeUploadTokenWithContent:(NSString *)content
                               AccessKey:(NSString *)ak
                               SecretKey:(NSString *)sk {
    
    NSData * sign = [ZTCryptoUtility HmacSha1EncryptWithData:content
                                                         Key:sk];
    
    NSString * encodedSign = [ZTCryptoUtility Base64EncodeWithData:sign
                                                       EncodeTable:kBase64EncodingTable];
    
    return encodedSign;
}

+ (NSString *)makeDownloadTokenWithURI:(NSString *)uri
                               Expires:(NSTimeInterval)expires
                             AccessKey:(NSString *)ak
                             SecretKey:(NSString *)sk {
    
    
    
    NSMutableString * mutableURLString =[NSMutableString string];
    [mutableURLString appendString:@"GET\n\n\n"];
    [mutableURLString appendString:@(expires).stringValue];
    [mutableURLString appendString:@"\n"];
    [mutableURLString appendString:uri];
    //添加Token参数
    NSData * sign = [ZTCryptoUtility HmacSha1EncryptWithData:mutableURLString
                                                         Key:sk];
    
    NSString * encodedSign = [ZTCryptoUtility Base64EncodeWithData:sign
                                                       EncodeTable:kBase64EncodingTable];
    
    return encodedSign;
}

+ (NSString *)encodeURL:(NSString *)url {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[url UTF8String];
    NSUInteger sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ') {
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
@end
