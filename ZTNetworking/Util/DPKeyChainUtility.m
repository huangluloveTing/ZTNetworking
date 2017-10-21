//
//  DPKeyChainUtility.m
//  DepotNearby
//
//  Created by Gong Shutao on 16/4/28.
//  Copyright © 2016年 www.depotnearby.com. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonCrypto.h>

#import "DPKeyChainUtility.h"

@implementation DPKeyChainUtility

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword,
            (__bridge id)kSecClass,service,
            (__bridge id)kSecAttrService,service,
            (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,
            (__bridge id)kSecAttrAccessible,
            nil];
}

+ (BOOL)saveValueByKey:(NSString *)key data:(id)data {
    
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [DPKeyChainUtility getKeychainQuery:key];
    //Delete old item before add new item
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    //Add item to keychain with the search dictionary
    OSStatus result = SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
    
    return (result == noErr);
}


+ (id)readValueByKey:(NSString *)key {
    
    id ret = nil;
    NSMutableDictionary *keychainQuery = [DPKeyChainUtility getKeychainQuery:key];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        
        @try {
            
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e) {
            
            ret = nil;
        }
    }
    
    if (keyData) {
        
        CFRelease(keyData);
    }
    
    return ret;
}


+ (BOOL)deleteValueByKey:(NSString *)key {
    
    NSMutableDictionary *keychainQuery = [DPKeyChainUtility getKeychainQuery:key];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    
    return (result == noErr);
}
@end
