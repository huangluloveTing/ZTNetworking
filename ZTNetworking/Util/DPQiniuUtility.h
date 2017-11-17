//
//  DPQiniuUtility.h
//  Pods
//

//
//

#import <Foundation/Foundation.h>

@interface DPQiniuUtility : NSObject
/*!
 *  @author Jingwei Zhang, 16-04-25 09:04:33
 *
 *  @brief 创建七牛上传Token
 *
 *  @param key        上传对象名
 *  @param space      上传空间名
 *  @param ak         七牛Access Key
 *  @param sk         七牛Secret Key
 *
 *  @return 上传Token
 *
 *  @since 1.0.6
 */
+ (nonnull NSString *)makeUploadTokenWithKey:(nonnull NSString *)key
                                       Space:(nonnull NSString *)space
                                   AccessKey:(nonnull NSString *)ak
                                   SecretKey:(nonnull NSString *)sk;

/*!
 *  @author Jingwei Zhang, 16-04-25 10:04:31
 *
 *  @brief 创建七牛下载Token
 *
 *  @param url        下载链接
 *  @param ak         七牛Access Key
 *  @param sk         七牛Secret Key
 *
 *  @return 下载Token
 *
 *  @since 1.0.6
 */
+ (nonnull NSString *)makeDownloadTokenWithURL:(nonnull NSString *)url
                                     AccessKey:(nonnull NSString *)ak
                                     SecretKey:(nonnull NSString *)sk;

@end
