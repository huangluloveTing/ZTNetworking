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

- (NSError *) checkResult {
    
    if (self.head.code.integerValue == ZT_Http_Success_Code.integerValue ||
        self.head.code.integerValue == ZT_Http_Update_Code.integerValue) {
        return nil;
    }
    
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:self.head.code.integerValue
                                     userInfo:@{
                                                NSLocalizedDescriptionKey : self.head.message ? :@""
                                                }];
    
    return error;
}

@end

@implementation ZTHttpResultHeaderObject

@end

DCM_Generic_Custom_Json_Result_Implement(Dictionary, NSDictionary)
DCM_Generic_Custom_Json_Result_Implement(Array, NSArray)
DCM_Generic_Custom_Json_Result_Implement(String, NSString)
DCM_Generic_Custom_Json_Result_Implement(Number, NSNumber)
