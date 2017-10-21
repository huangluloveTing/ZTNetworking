//
//  DPCryptoUtility.m
//  DepotNearby
//
//  Created by zhangjingwei on 15/11/18.
//  Copyright © 2015年 www.depotnearby.com. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>

#import "DPCryptoUtility.h"
#import "bignum.h"

static UInt32 kQRDBlockSize = 4 * 1024 * 1024;


@implementation DPCryptoUtility

static uint8_t const kBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

+ (NSString *)makeHTTPQueryWithParameters:(NSDictionary *)parameters
                                    Token:(NSString *)token
                                 PostData:(NSString *)postData {
    
    NSString * query = [DPCryptoUtility makeHTTPQueryWithDictionary:parameters IsSigned:NO];
    
    NSMutableString * signString = [NSMutableString string];
    if(query) [signString appendString:query];
    if(token) [signString appendString:token];
    if(postData) [signString appendString:postData];
    
    NSString * sign = [NSString stringWithFormat:@"%@&sign=%@", query, [DPCryptoUtility MD5EncryptWithString:signString]];
    return [NSString stringWithString:sign];
}

+ (NSString *)makeHTTPQueryWithDictionary:(NSDictionary *)dict IsSigned:(BOOL)isSigned {
    
    NSMutableString * query = [NSMutableString string];
    NSArray * sortedKeys = [[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        return [obj1 compare:obj2
                     options:NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch];
    }];
    
    [sortedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        id value = [dict objectForKey:obj];
        NSString * valueString = ([value isKindOfClass:[NSString class]]?
                                  value:
                                  [NSString stringWithFormat:@"%@", value]);
        
        //判断值是否为空，如果为空则不加入参数字符串
        if(valueString && 0 < valueString.length) {
        //if(valueString) {
            
            [query appendString:[obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
            [query appendString:@"="];
            [query  appendString:[valueString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
        
            if(obj != [sortedKeys lastObject]) {
              
                [query appendString:@"&"];
            }
        }
    }];
    
    if(isSigned) {
        
        NSString * sign = [DPCryptoUtility MD5EncryptWithString:query];
        [query appendString:@"sign"];
        [query appendString:@"="];
        [query appendString:sign];
    }
    
    return [NSString stringWithString:query];
}

+ (NSString *)makeEtagWithData:(NSData *)data {
    
    if (data == nil || [data length] == 0) {
        return @"Fto5o-5ea0sNMlW_75VgGJCv2AcJ";
    }
    int len = (int)[data length];
    int count = (len + kQRDBlockSize - 1) / kQRDBlockSize;
    
    NSMutableData *retData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH + 1];
    UInt8 *ret = [retData mutableBytes];
    
    NSMutableData *blocksSha1 = nil;
    UInt8 *pblocksSha1 = ret + 1;
    if (count > 1) {
        blocksSha1 = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH * count];
        pblocksSha1 = [blocksSha1 mutableBytes];
    }
    
    for (int i = 0; i < count; i++) {
        int offset = i * kQRDBlockSize;
        int size = (len - offset) > kQRDBlockSize ? kQRDBlockSize : (len - offset);
        NSData *d = [data subdataWithRange:NSMakeRange(offset, (unsigned int)size)];
        CC_SHA1([d bytes], (CC_LONG)size, pblocksSha1 + i * CC_SHA1_DIGEST_LENGTH);
    }
    if (count == 1) {
        ret[0] = 0x16;
    }
    else {
        ret[0] = 0x96;
        CC_SHA1(pblocksSha1, (CC_LONG)CC_SHA1_DIGEST_LENGTH * count, ret + 1);
    }
    
    return [DPCryptoUtility Base64EncodeWithData:retData
                                     EncodeTable:kBase64EncodingTable];
}

+ (NSString *)makeUUID {
    //DPLogTrace();
    
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);
    NSString	*uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}

+ (NSData *)makeDHPublicKeyWithXA:(NSString *)XAString
                                G:(NSString *)GString
                                P:(NSString *)PString {
    //DPLogTrace();
    
    NSString * keyString = nil;
    mpi PK, P, G, XA;
    
    mpi_init(&PK);
    mpi_init(&P);
    mpi_init(&G);
    mpi_init(&XA);
    
    mpi_read_string(&P, 10, [PString UTF8String]);
    mpi_read_string(&G, 10, [GString UTF8String]);
    mpi_read_string(&XA, 10, [XAString UTF8String]);
    
    if(0 == mpi_exp_mod(&PK, &G, &XA, &P, NULL)) {
        size_t length = 2 * POLARSSL_MPI_MAX_SIZE;
        char temp_string[length];
        
        if(0 == mpi_write_string(&PK, 10, temp_string, &length)) {
            keyString = [NSString stringWithUTF8String:temp_string];
        }
    }
    
    mpi_free(&PK);
    mpi_free(&P);
    mpi_free(&G);
    mpi_free(&XA);
    
    return [keyString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)makeDHSecureKeyWithPK:(NSString *)PKString
                               XA:(NSString *)XAString
                                P:(NSString *)PString {
    //DPLogTrace();
    
    NSData * key = nil;
    mpi PK, XA, P, SK;
    
    mpi_init(&PK);
    mpi_init(&XA);
    mpi_init(&P);
    mpi_init(&SK);
    
    mpi_read_string(&P, 10, [PString UTF8String]);
    mpi_read_string(&XA, 10, [XAString UTF8String]);
    mpi_read_string(&PK, 10, [PKString UTF8String]);
    
    if(0 == mpi_exp_mod(&SK, &PK, &XA, &P, NULL)) {
        
        size_t length = mpi_size(&SK);
        unsigned char buffer[length];
        
        if(0 == mpi_write_binary(&SK, buffer, length)) {
            
            unsigned char keyBytes[sizeof(uint64_t)];
            memset(keyBytes, 0, sizeof(uint64_t));
            
            memcpy(&keyBytes, buffer + length - sizeof(uint64_t), sizeof(uint64_t));
            key = [NSData dataWithBytes:keyBytes length:sizeof(uint64_t)];
        }
    }
    
    mpi_free(&PK);
    mpi_free(&XA);
    mpi_free(&P);
    mpi_free(&SK);
    
    return key;
}

+ (NSString *)MD5EncryptWithString:(NSString *)data {
    
    const char *cStr = [data UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)Base64EncodeWithString:(NSString *)source EncodeTable:(const uint8_t*)encodeTable {
    
    NSUInteger length = [source lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:[source UTF8String] length:length];
    return [DPCryptoUtility Base64EncodeWithData:data
                                     EncodeTable:encodeTable];
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

+ (NSData *)DESEncryptWithData:(NSData *)data Key:(NSData *)key {
    //DPLogTrace();
    
    char keyPtr[kCCKeySizeDES];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getBytes:keyPtr length:sizeof(keyPtr)];
    
    NSData * retValue = nil;
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = (dataLength + kCCKeySizeDES) & ~(kCCKeySizeDES -1);
    
    void * buffer = malloc(bufferSize);
    memset(buffer, 0, sizeof(buffer));
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        retValue = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return retValue;
}

+ (NSData *)DESDecryptWithData:(NSData *)data Key:(NSData *)key {
    //DPLogTrace();
    
    char keyPtr[kCCKeySizeDES];
    bzero(keyPtr, sizeof(keyPtr));
    [key getBytes:keyPtr length:sizeof(keyPtr)];
    
    NSData * retValue = nil;
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCKeySizeDES;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        retValue = [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return retValue;
}

+ (NSData *)AES128CBCEncryptWithData:(NSData *)data Key:(NSData *)key IV:(NSData *)iv {
    
    //DPLogTrace();
    
    if(!key || !iv || (kCCKeySizeAES128 != key.length) || (kCCKeySizeAES128 != iv.length)) {
        return data;
    }
    
    char keyPtr[kCCKeySizeAES128];
    bzero(keyPtr, sizeof(keyPtr));
    [key getBytes:keyPtr length:sizeof(keyPtr)];
    
    char ivPtr[kCCKeySizeAES128];
    bzero(ivPtr, sizeof(ivPtr));
    [iv getBytes:ivPtr length:sizeof(ivPtr)];
    
    //[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = (dataLength + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 -1);
    
    void * buffer = malloc(bufferSize);
    memset(buffer, 0, sizeof(buffer));
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          ivPtr,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

+ (NSData *)AES128CBCDecryptWithData:(NSData *)data Key:(NSData *)key IV:(NSData *)iv {
    
    //DPLogTrace();
    
    if(!key || !iv || (kCCKeySizeAES128 != key.length) || (kCCKeySizeAES128 != iv.length)) {
        return data;
    }
    
    char keyPtr[kCCKeySizeAES128];
    bzero(keyPtr, sizeof(keyPtr));
    [key getBytes:keyPtr length:sizeof(keyPtr)];
    
    char ivPtr[kCCKeySizeAES128];
    bzero(ivPtr, sizeof(ivPtr));
    [iv getBytes:ivPtr length:sizeof(ivPtr)];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = (dataLength + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 - 1);
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          ivPtr,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

+ (NSData *)AES128ECBEncryptWithData:(NSData *)data Key:(NSData *)key {
    //DPLogTrace();
    
    if(!key || (kCCKeySizeAES128 != key.length)) {
        return data;
    }
    
    char keyPtr[kCCKeySizeAES128];
    bzero(keyPtr, sizeof(keyPtr));
    [key getBytes:keyPtr length:sizeof(keyPtr)];
    
    NSData * retValue = nil;
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = (dataLength + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 -1);
    
    void * buffer = malloc(bufferSize);
    memset(buffer, 0, sizeof(buffer));
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        retValue = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return retValue;
}

+ (NSData *)AES128ECBDecryptWithData:(NSData *)data Key:(NSData *)key {
    //DPLogTrace();
    
    if(!key || (kCCKeySizeAES128 != key.length)) {
        return data;
    }
    
    char keyPtr[kCCKeySizeAES128];
    bzero(keyPtr, sizeof(keyPtr));
    [key getBytes:keyPtr length:sizeof(keyPtr)];
    
    NSData * retValue = nil;
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = (dataLength + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 -1);
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        retValue = [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return retValue;
}

+ (NSData *)AES256EncryptWithData:(NSData *)data Key:(NSData *)key {
    //DPLogTrace();
    
    char keyPtr[kCCKeySizeAES256];
    bzero(keyPtr, sizeof(keyPtr));
    [key getBytes:keyPtr length:sizeof(keyPtr)];
    
    NSData * retValue = nil;
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = (dataLength + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 -1);
    
    void * buffer = malloc(bufferSize);
    memset(buffer, 0, sizeof(buffer));
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        retValue = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return retValue;
}

+ (NSData *)AES256DecryptWithData:(NSData *)data Key:(NSData *)key {
    //DPLogTrace();
    
    char keyPtr[kCCKeySizeAES256];
    bzero(keyPtr, sizeof(keyPtr));
    [key getBytes:keyPtr length:sizeof(keyPtr)];
    
    NSData * retValue = nil;
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        retValue = [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return retValue;
}

+ (NSData *)HmacSha1EncryptWithData:(NSString *)data Key:(NSString *)key {
    //DPLogTrace();
    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData * HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return HMAC;
}


+ (NSData *)Sha1EncryptWithData:(NSData *)data {
    //DPLogTrace();
    
    if (data == nil || [data length] == 0) {
        return nil;
    }
    
    int len = (int)[data length];
    int count = (len + kQRDBlockSize - 1) / kQRDBlockSize;
    
    NSMutableData *retData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH + 1];
    UInt8 *ret = [retData mutableBytes];
    
    NSMutableData *blocksSha1 = nil;
    UInt8 *pblocksSha1 = ret + 1;
    if (count > 1) {
        blocksSha1 = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH * count];
        pblocksSha1 = [blocksSha1 mutableBytes];
    }
    
    for (int i = 0; i < count; i++) {
        int offset = i * kQRDBlockSize;
        int size = (len - offset) > kQRDBlockSize ? kQRDBlockSize : (len - offset);
        NSData *d = [data subdataWithRange:NSMakeRange(offset, (unsigned int)size)];
        CC_SHA1([d bytes], (CC_LONG)size, pblocksSha1 + i * CC_SHA1_DIGEST_LENGTH);
    }
    
    if (count == 1) {
        ret[0] = 0x16;
    }
    else {
        ret[0] = 0x96;
        CC_SHA1(pblocksSha1, (CC_LONG)CC_SHA1_DIGEST_LENGTH * count, ret + 1);
    }
    
    return [NSData dataWithData:retData];
}

@end
