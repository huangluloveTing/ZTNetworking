//
//  Student.h
//  ZTNetworking
//
//  Created by 黄露 on 2017/11/24.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZTPObject.h"
@interface Student : ZTPObject

@property (nonatomic , strong) NSString *name;

@property (nonatomic , strong) NSString *hobby;

@property (nonatomic , strong) NSString *email;

@end
