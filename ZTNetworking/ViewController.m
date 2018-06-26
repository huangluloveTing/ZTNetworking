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
@interface MyObject:ZTPObject

@property (nonatomic , strong) NSString *userId;
@property(nonatomic , strong) NSString *ID;
@property (nonatomic , strong) NSString *title;
@property (nonatomic ,strong) NSString *body;

@property (nonatomic , strong) MyObject *sub;

@end

@implementation MyObject

- (NSDictionary *) mapProperties {
    return @{
             @"ID" : @"id"
             };
}

@end
DP_Generic_Custom_Array_Class_Define(MyObject)


@interface MyObjects:ZTPObject

@property (nonatomic , strong) DPMObjectArray(MyObject) *results;

@end

@implementation MyObjects

@end

@interface ViewController ()

@property (nonatomic , strong) NSURLSessionDataTask *dataTask;

@property (nonatomic , strong) NSURLSessionDataTask *dataTask2;

@end

NSString *josn = @"{\"results\":[{\"userId\": 1,\"id\": 1,\"title\": \"sunt aut fact\",\"body\": \"quicto\",\"sub\":{\"userId\": 1,\"id\": 1,\"title\": \"sunt aut fact\",\"body\": \"quicto\"}},{\"userId\": 1,\"id\": 2,\"title\": \"qui est esse\",\"body\": \"est rella\"}]}";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[josn dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    MyObjects *m = [MyObjects serializeWithJsonObject:dic];
    NSLog(@"json = %@",[m toJsonObject]);
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
