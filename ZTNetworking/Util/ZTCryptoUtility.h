//
//  DPCryptoUtility.h
//  DepotNearby
//
//
//  Copyright © 2015年 www.depotnearby.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:25
 *
 *  @brief  加密解密工具类
 */
@interface ZTCryptoUtility : NSObject

+ (nonnull NSString *)makeHTTPQueryWithParameters:(nonnull NSDictionary *)parameters
                                            Token:(nonnull NSString *)token
                                         PostData:(nullable NSString *)postDatas;

+ (nonnull NSString *)makeHTTPQueryWithDictionary:(nonnull NSDictionary *)dict IsSigned:(BOOL)isSigned;

+ (nonnull NSString *)makeEtagWithData:(nonnull NSData *)data;

/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:41
 *
 *  @brief  生成一个UUID字符串
 *  @return UUID字符串
 
 */
+ (nonnull NSString *)makeUUID;

#pragma mark - Diffie-Hellman算法
/*!
 *  @author Jingwei Zhang, 15-11-18 15:11:26
 *
 *  @brief  Diffie-Hellman算法：
            假如用户A和用户B希望交换一个密钥。
            取素数P和整数G，G是P的一个原根，公开G和P。
            A选择随机数XA<P，并计算YA=G^XA mod P。
            B选择随机数XB<P，并计算YB=G^XB mod P。
            每一方都将X保密而将Y公开让另一方得到。
            A计算密钥的方式是：K=(YB) ^XA mod P
            B计算密钥的方式是：K=(YA) ^XB mod P

            生成交换密钥
 *  @param XAString 随机数XA字符串
 *  @param GString  整数G字符串
 *  @param PString  素数P字符串
 *  @return 交换公钥数据
 */
+ (nonnull NSData *)makeDHPublicKeyWithXA:(nonnull NSString *)XAString
                                        G:(nonnull NSString *)GString
                                        P:(nonnull NSString *)PString;

/*!
 *  @author Jingwei Zhang, 15-11-18 15:11:26
 *
 *  @brief  Diffie-Hellman算法：
            假如用户A和用户B希望交换一个密钥。
            取素数P和整数G，G是P的一个原根，公开G和P。
            A选择随机数XA<P，并计算YA=G^XA mod P。
            B选择随机数XB<P，并计算YB=G^XB mod P。
            每一方都将X保密而将Y公开让另一方得到。
            A计算密钥的方式是：K=(YB) ^XA mod P
            B计算密钥的方式是：K=(YA) ^XB mod P

            生成加密密钥
 *  @param PKString 对方交换密钥
 *  @param XAString 随机数XA字符串
 *  @param PString  素数P字符串
 *  @return 加密密钥数据
 */
+ (nonnull NSData *)makeDHSecureKeyWithPK:(nonnull NSString *)PKString
                                       XA:(nonnull NSString *)XAString
                                        P:(nonnull NSString *)PString;

#pragma mark - MD5 crypto
/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:25
 *
 *  @brief MD5加密
 *  @param data 待加密数据
 *  @return 加密后数据
 */
+ (nonnull NSString *)MD5EncryptWithString:(nonnull NSString *)data;

#pragma mark - Base64 encoding
/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:40
 *
 *  @brief  Base 64 encode
 *  @param source origin string
 *  @return encodeTable string
 */
+ (nonnull NSString *)Base64EncodeWithString:(nonnull NSString *)source
                                 EncodeTable:(nonnull const uint8_t*)encodeTable;
/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:25
 *
 *  @brief Base 64 encode
 *  @param data  origin data
 *  @return encodeTable
 */
+ (nonnull NSString *)Base64EncodeWithData:(nonnull NSData *)data
                               EncodeTable:(nonnull const uint8_t*)encodeTable;

#pragma mark - DES Encrypt/Decrypt
/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:40
 *  @method
 *  @brief  数据进行DES加密
 *  @param data 待加密数据
 *  @param key  加密密钥
 */
+ (nonnull NSData *)DESEncryptWithData:(nonnull NSData *)data
                                   Key:(nonnull NSData *)key;

/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:07
 *  @method
 *  @brief  数据进行DES解密
 *  @param data 待解密密数据
 *  @param key  加密密钥
 *  @return 解密后数据
 */
+ (nonnull NSData *)DESDecryptWithData:(nonnull NSData *)data
                                   Key:(nonnull NSData *)key;

#pragma mark - AES Encrypt/Decrypt
/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:40
 *  @method
 *  @brief  数据进行128位AES加密(CBC模式)
 *  @param data 待加密数据
 *  @param key  加密密钥
 *  @return 加密后数据
 */
+ (nonnull NSData *)AES128CBCEncryptWithData:(nonnull NSData *)data
                                         Key:(nonnull NSData *)key
                                          IV:(nonnull NSData *)iv;

/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:07
 *  @method
 *  @brief  数据进行128位AES解密(CBC模式)
 *  @param data 待解密密数据
 *  @param key  加密密钥
 *  @return 解密后数据
 *  @discussion 此函数不可用于过长文本
 */
+ (nonnull NSData *)AES128CBCDecryptWithData:(nonnull NSData *)data
                                         Key:(nonnull NSData *)key
                                          IV:(nonnull NSData *)iv;

/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:40
 *  @method
 *  @brief  数据进行128位AES加密(ECB模式)
 *  @param data 待加密数据
 *  @param key  加密密钥
 *  @return 加密后数据
 *  @discussion 此函数不可用于过长文本
 */
+ (nonnull NSData *)AES128ECBEncryptWithData:(nonnull NSData *)data
                                         Key:(nonnull NSData *)key;

/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:07
 *  @method
 *  @brief  数据进行128位AES解密(ECB模式)
 *  @param data 待解密密数据
 *  @param key  加密密钥
 *  @return 解密后数据
 *  @discussion 此函数不可用于过长文本
 */
+ (nonnull NSData *)AES128ECBDecryptWithData:(nonnull NSData *)data
                                         Key:(nonnull NSData *)key;

/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:40
 *  @method
 *  @brief  数据进行256位AES加密
 *  @param data 待加密数据
 *  @param key  加密密钥
 *  @return 加密后数据
 *  @discussion 此函数不可用于过长文本
 */
+ (nonnull NSData *)AES256EncryptWithData:(nonnull NSData *)data
                                      Key:(nonnull NSData *)key;

/*!
 *  @author Jingwei Zhang, 15-11-18 14:11:07
 *  @method
 *  @brief  数据进行256位AES解密
 *  @param data 待解密密数据
 *  @param key  加密密钥
 *  @return 解密后数据
 *  @discussion 此函数不可用于过长文本
 */
+ (nonnull NSData *)AES256DecryptWithData:(nonnull NSData *)data
                                      Key:(nonnull NSData *)key;

#pragma mark - HMAC_SHA1 Encrypt
/*!
 *  @author Jingwei  Zhang, 15-11-18 14:11:06
 *  @method
 *  @brief  数据进行HMAC_SHA1加密
 *  @param data 待加密数据
 *  @param key  加密密钥
 *  @return 加密后数据
 */
+ (nonnull NSData *)HmacSha1EncryptWithData:(nonnull NSString *)data
                                        Key:(nonnull NSString *)key;


#pragma mark - SHA1 Encyrpt
/*!
 *  @author Jingwei Zhang, 15-11-18 17:11:57
 *
 *  @brief  数据进行SHA1加密
 *  @param data 待加密数据
 *  @return 加密后数据
 */
+ (nonnull NSData *)Sha1EncryptWithData:(nonnull NSData *)data;
@end
