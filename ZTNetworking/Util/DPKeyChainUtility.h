//
//  DPKeyChainUtility.h
//  DepotNearby
//

//  Copyright © 2016年 www.depotnearby.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPKeyChainUtility : NSObject

+ (BOOL)saveValueByKey:(NSString *)key data:(id)data;

+ (id)readValueByKey:(NSString *)key;

+ (BOOL)deleteValueByKey:(NSString *)key;
@end
