//
//  ViewController.m
//  ZTNetworking
//
//  Created by 黄露 on 2017/10/19.
//  Copyright © 2017年 huanglu. All rights reserved.
//

#import "ViewController.h"
#import "ZTNetWorking.h"


@interface ViewController ()

@property (nonatomic , strong) NSURLSessionDataTask *dataTask;

@property (nonatomic , strong) NSURLSessionDataTask *dataTask2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    ZTNetCache *cache = [[ZTNetCache alloc] init];
//    Student *st = [[Student alloc] init];
//    st.name = @"hl";

//    [cache saveData:st];
//    [cache saveData:st2];
//
//   NSArray *rresults = [cache queryAllDataWithEntity:st];
//
//    for (NSDictionary *s  in rresults) {
//        NSLog(@" re = %@ " , s);
    //    }- ERROR | [iOS] unknown: Encountered an unknown error (Unable to find a specification for `XSLKeyChainCache (~> 0.1.0)` depended upon by `XSLOpenUDID`) during validation.
    
//
//    Student *su = [Student serializeWithJsonObject:rresults.firstObject];
//    NSLog(@"su Id = %@" , su.Id);;
//
//    NSArray *data = [cache queryForEntity:st queryValue:@"huanglu" column:@"name"];
//
//    for (NSDictionary *sss in data) {
//        Student *sudent = [Student serializeWithJsonObject:sss];
//        NSLog(@"Id = %@" , sudent.Id);
//    }
//
    NSDictionary * parameters = @{
                                  @"appType" : @"IOS",
                                  @"appVersion" : @"15",
                                  @"businessId" : @"J000183T16063412017-10-20",
                                  @"imei" : @"F850C2F8-BF1B-49E2-B4E3-0B5E232E9139",
                                  @"imgType" : @"30",
                                  @"imgedate" : @"2017-10-20",
                                  @"phoneSend" : @"1",
                                  @"photoName" : @"J000183_1508480076128.jpg",
                                  @"psTime" : @"2017-10-20 14:14:39",
                                  @"subFlag" : @"offline",
                                  @"uaccount" : @"5071772D86FF68ECE053870AA8C0B393"
                                  };
//    loginPIController.do?checkUser
//    self.dataTask2 = [[ZTHttpManager sharedManager] perform_BackNormalRequest_URI:@"loginPIController.do?changeTmPassword" Parameters:parameters Headers:nil Asynac:NO Completion:^(id  _Nullable retObject, NSError * _Nullable error) {
//
//    }];
//    self.dataTask = [[ZTHttpManager sharedManager] perform_BackNormalRequest_URI:@"loginPIController.do?checkUser" Parameters:parameters Headers:nil Asynac:NO Completion:^(id  _Nullable retObject, NSError * _Nullable error) {
//
//    }];
    
    
//    [[ZTHttpManager sharedManager] restartAllOfflineQueue];
    
   
    UIImage *image = [UIImage imageNamed:@"tp"];
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) {
        data = UIImageJPEGRepresentation(image, 1);
    }
    self.dataTask = [[ZTHttpManager sharedManager] perform_BackUploadRequest_URI:@""
                                                                        TaskName:@"upload"
                                                                      Parameters:parameters
                                                                         Headers:nil
                                                                            Name:@"name"
                                                                        FileName:@"fileName"
                                                                          Binary:data
                                                                          Asynac:YES
                                                                        Progress:nil
                                                                      Completion:^(id  _Nullable retObject, NSError * _Nullable error) {

    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnAction:(id)sender {
    NSArray *arr = [[ZTHttpManager sharedManager] getCurrentRestQueue];
    NSArray *arr2 = [[ZTHttpManager sharedManager] getCurrentUploadQueue];
    
    NSLog(@"");
}


@end
