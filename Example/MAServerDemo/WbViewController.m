//
//  WbViewController.m
//  MAServerDemo
//
//  Created by klwanshua@163.com on 06/21/2017.
//  Copyright (c) 2017 klwanshua@163.com. All rights reserved.
//

#import "WbViewController.h"
#import "ServiceCall.h"
#import "MBProgressHUD+WB.h"
@interface WbViewController ()

@end

@implementation WbViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [ServiceCall setUpMaServeripport:@"123.103.9.184:80"];
    NSDictionary *dict = @{
                           @"transtype":@"user_auth",
                           @"usercode":@"shixg",
                           @"password":@"1234567a"
                           };
    [MBProgressHUD showMessage:@"正在加载..."];
    [ServiceCall callActionParams:dict controllerid:@"com.yyjr.ydsp.controller.YdspController" appid:@"IApproval" resultctxCall:^(NSDictionary *result) {
        [MBProgressHUD showSuccess:@"成功"];
    } errorCall:^(NSDictionary *error) {
        [MBProgressHUD hideHUD];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
