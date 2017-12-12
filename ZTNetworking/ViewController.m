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


#ifdef DEBUG
static NSString *const QCloundIP = @"http://ozsymqi0d.bkt.clouddn.com/";
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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ZTNetCache *cache = [[ZTNetCache alloc] init];
    Student *st = [[Student alloc] init];
    st.name = @"hl";
    st.hobby = @"haha";
    st.email = @"1234";
    
    Student *st_1 = [[Student alloc] init];
    st_1.name = @"h---l";
    st_1.hobby = @"haha";
    st_1.email = @"1234";
    
    Student *st_2 = [[Student alloc] init];
    st_2.name = @"h-l";
    st_2.hobby = @"haha";
    st_2.email = @"1234";
    st_2.code = @"code";

    [cache saveData:st];
    [cache saveData:st_1];
    [cache saveData:st_2];
    [cache saveData:st_1];
    [cache saveData:st_2];
    [cache saveData:st_1];
    [cache saveData:st_2];
    
    [cache updateForEntity:st fieldValue:@"email_10" fieldName:@"email" uniqueField:@"code" uniqueValue:@"code"];
//
   NSArray *rresults = [cache queryAllDataWithEntity:st];
//
    for (NSDictionary *s  in rresults) {
        NSLog(@" re = %@ " , s);
    }
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


@end
