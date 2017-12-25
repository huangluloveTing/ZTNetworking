//
//  ZTHttpConst.h
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#ifndef ZTHttpConst_h
#define ZTHttpConst_h

static NSString * const ZT_Http_Success_Code = @"200";  //成功的code

static NSString * const ZT_Http_Update_Code = @"101";   //监测版本的code

static NSString * const ZT_Http_Failed_Description = @"请求数据失败";

// 避免宏循环引用
#ifndef LLWeakObj
#if DEBUG
#if __has_feature(objc_arc)
#define LLWeakObj(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define LLWeakObj(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define LLWeakObj(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define LLWeakObj(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef LLStrongObj
#if DEBUG
#if __has_feature(objc_arc)
#define LLStrongObj(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define LLStrongObj(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define LLStrongObj(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define LLStrongObj(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#define ZTWeakify(A) @LLWeakObj(A)

#define ZTStrongify(A) @LLStrongObj(A)

#endif /* ZTHttpConst_h */

