//
//  ServiceCall.m
//  MobileApprove
//
//  Created by 王彬 on 2017/1/17.
//  Copyright © 2017年 yonyou. All rights reserved.
//

#import "ServiceCall.h"
#import "MaServer.h"
#define APPID @"IApproval"
#define CONTROLLERID @"com.yyjr.jrpt.controller.JRPTController"

@implementation ServiceCall

+ (void)setUpMaServeripport:(NSString *)ipport
{
    [MaServer setUpMaServeripport:ipport];
}


+ (void)callActionParams:(NSDictionary *)parameters
           resultctxCall:(void (^)(NSDictionary *result))successBlock
{
    
    [MaServer callActionParams:parameters controllerid:CONTROLLERID appid:APPID successCall:successBlock error:nil];

}

+ (void)callActionParams:(NSDictionary *)parameters controllerid:(NSString*)controllerid
                   appid:(NSString *)appid resultctxCall:(void (^)(NSDictionary *result))successBlock errorCall:(void (^)(NSDictionary *error))errorBlock{
    
    [MaServer callActionParams:parameters controllerid:controllerid appid:appid successCall:successBlock error:errorBlock];
    
}
@end
