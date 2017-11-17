//
//  DPQiniuUtility.m
//  Pods
//

//
//

#import "DPQiniuUtility.h"
#import "ZTCryptoUtility.h"

@implementation DPQiniuUtility

static uint8_t const kBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

+ (NSString *)makeUploadTokenWithKey:(NSString *)key
                               Space:(NSString *)space
                           AccessKey:(NSString *)ak
                           SecretKey:(NSString *)sk {
    
    NSError * error = nil;
    NSString * persistentOps = @"";
    NSString * scope = [NSString stringWithFormat:@"%@:%@", space, key];
    NSString * saveName = [NSString stringWithFormat:@"%@:%@", space, key];
    
    NSString * encodeSaveName = [ZTCryptoUtility Base64EncodeWithString:saveName
                                                            EncodeTable:kBase64EncodingTable];
    
    persistentOps = [NSString stringWithFormat:@"imageView2/0/h/%d|saveas/%@", 640, encodeSaveName];
    
    NSTimeInterval deadLine = [[NSDate date] timeIntervalSince1970] + 1200;
    NSDictionary * policy = @{@"scope" : scope,
                              @"deadline" : @((long)deadLine),
                              @"persistentOps" : persistentOps};
    
    NSData * policyData = [NSJSONSerialization dataWithJSONObject:policy
                                                          options:kNilOptions
                                                            error:&error];
    if(!error) {
        
        NSString * policyString = [[NSString alloc] initWithData:policyData
                                                        encoding:NSUTF8StringEncoding];
        
        NSString * encodPolicy = [ZTCryptoUtility Base64EncodeWithString:policyString
                                                             EncodeTable:kBase64EncodingTable];
        
        NSData * sign = [ZTCryptoUtility HmacSha1EncryptWithData:encodPolicy
                                                             Key:sk];
        
        NSString * encodedSign = [ZTCryptoUtility Base64EncodeWithData:sign
                                                           EncodeTable:kBase64EncodingTable];
        
        return [NSString stringWithFormat:@"%@:%@:%@", ak, encodedSign, encodPolicy];
    }
    
    return @"";
}

+ (NSString *)makeDownloadTokenWithURL:(NSString *)url
                             AccessKey:(NSString *)ak
                             SecretKey:(NSString *)sk {
    
    NSMutableString * mutableURLString =[NSMutableString stringWithString:url];
    
    //添加Token参数
    NSData * encryptSK = [ZTCryptoUtility HmacSha1EncryptWithData:mutableURLString
                                                              Key:sk];
    
    NSString * token = [NSString stringWithFormat:@"%@:%@", ak, [ZTCryptoUtility Base64EncodeWithData:encryptSK
                                                                                          EncodeTable:kBase64EncodingTable]];
    return token;
}
@end
