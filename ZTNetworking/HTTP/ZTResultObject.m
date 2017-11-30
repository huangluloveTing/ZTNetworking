//
//  ZTHttpResultObject.m
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import "ZTResultObject.h"
#import "ZTHttpConst.h"



@implementation ZTResultObject

@end

@implementation ZTHttpResultHeaderObject

- (NSError *) chechResult {
    if (self.status.integerValue == ZT_Http_Success_Code.integerValue) {
        return nil;
    }
    
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:self.status.integerValue
                                     userInfo:@{
                                                NSLocalizedDescriptionKey : [self valueForKey:@"result"] ?: @""
                                                }];
    
    return error;
}

@end

DCM_Generic_Custom_Json_Result_Implement(Dictionary, NSDictionary)
DCM_Generic_Custom_Json_Result_Implement(Array, NSArray)
DCM_Generic_Custom_Json_Result_Implement(String, NSString)
DCM_Generic_Custom_Json_Result_Implement(Number, NSNumber)
