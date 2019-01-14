//
//  ViewController.m
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import "ViewController.h"
#import "ZTNetWorking.h"
#import "Student.h"
#import "ZTPObject.h"
#import "ZTNetCache.h"

#ifdef DEBUG
static NSString *const QCloundIP = @"http://jsonplaceholder.typicode.com/posts";
static NSString *const QCloud_Access_key_Id = @"c7JN1kstps9ZQ61NnqgBA2tK5orSA9SlIWr5q7rt";
static NSString *const QCloud_Secret_Access_key = @"WlKpyUStQkqRHcxScciHHqwYkQGrV38UcV8UjjzT";
static NSString *const QCloud_Bucket_Name = @"demo";

#else

static NSString *const QCloundIP = @"http://yanghe1.stor.chinayanghe.com/";
static NSString *const QCloud_Access_key_Id = @"XIIYXDLTWWYWNDGGGQSY";
static NSString *const QCloud_Secret_Access_key = @"KiR0383h1SZuwtpFUh1iEd96JRgsNlaPpZHOraVK";
static NSString *const QCloud_Bucket_Name = @"yanghesfa";

#endif

@interface ViewController ()

@property (nonatomic , strong) NSURLSessionDataTask *dataTask;

@property (nonatomic , strong) NSURLSessionDataTask *dataTask2;

@end

NSString *josn = @"{\"results\":[{\"userId\": 1,\"id\": 1,\"title\": \"sunt aut fact\",\"body\": \"quicto\",\"sub\":{\"userId\": 1,\"id\": 1,\"title\": \"sunt aut fact\",\"body\": \"quicto\"}},{\"userId\": 1,\"id\": 2,\"title\": \"qui est esse\",\"body\": \"est rella\"}]}";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDatas];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnAction:(id)sender {
//    NSArray *arr = [[ZTHttpManager sharedManager] getCurrentRestQueue];
//    NSArray *arr2 = [[ZTHttpManager sharedManager] getCurrentUploadQueue];
//    
//    NSLog(@"");
}



- (void) initDatas {
    ZTNetCache *cache = [[ZTNetCache alloc] init];
//    for (int i = 0; i < 100; i ++) {
//        Student *st = [[Student alloc] init];
//        st.name = @"111";
//        st.s_id = [NSString stringWithFormat:@"%d" , 100 + i];
//        st.email = @"888";
//        st.hobby = i / 20 == 0 ? @"hobby" : @"12333";
//        [cache saveData:st];
//    }
    id resut =  [cache queryData:[[Student alloc] init] queryValues:@[@"hobby"] fields:@[@"hobby"]];
    NSLog(@"%@" , resut);
}


@end
