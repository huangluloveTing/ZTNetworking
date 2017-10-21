//
//  ZTHttpRequest.m
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import "ZTHttpRequest.h"

@implementation ZTHttpRequest

- (void) setParameters:(NSDictionary *)parameters {
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        _parameters = parameters;
    }
    if ([parameters isKindOfClass:[NSString class]]) {
        NSData *data = [(NSString *)parameters dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (dic) {
            _parameters = dic;
            
        }
    }
}

@end
