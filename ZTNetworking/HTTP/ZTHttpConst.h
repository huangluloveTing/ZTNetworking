//
//  ZTHttpConst.h
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#ifndef ZTHttpConst_h
#define ZTHttpConst_h

static NSString * const ZT_Http_Success_Code = @"100";  //成功的code

static NSString * const ZT_Http_Update_Code = @"101";   //监测版本的code

static NSString * const ZT_Http_Failed_Description = @"请求数据失败";

#define ZTWeakify(A) \
__weak typeof(A) weak##A = A;

#define ZTStrongify(A) \
__strong typeof(weak##A) A = weak##A;

#endif /* ZTHttpConst_h */
