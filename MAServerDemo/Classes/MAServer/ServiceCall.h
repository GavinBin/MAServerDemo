//
//  ServiceCall.h
//  MobileApprove
//
//  Created by 王彬 on 2017/1/17.
//  Copyright © 2017年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^serviceCallSuccess)(NSDictionary *result);

typedef void(^serviceCallFailed)(NSDictionary *error);


@interface ServiceCall : NSObject

/**
 访问MA请求，返回成功回调
 @param parameters 参数对象，传入字典
 @param successBlock 成功回调
 */
+ (void)callActionParams:(NSDictionary *)parameters
           resultctxCall:(void (^)(NSDictionary *result))successBlock;



/**
 访问MA请求
 @param parameters 参数对象，传入字典
 @param controllerid 后台对应controllerid 必传
 @param appid 后台对应appid 必传
 @param successBlock 成功回调
 @param errorBlock 失败回调
 */
+ (void)callActionParams:(NSDictionary *)parameters controllerid:(NSString*)controllerid
                   appid:(NSString *)appid resultctxCall:(void (^)(NSDictionary *result))successBlock errorCall:(void (^)(NSDictionary *error))errorBlock;

/**
 设置ip端口
 @param ipport 设置ip端口 如123.103.1.1：8090
 */
+ (void)setUpMaServeripport:(NSString *)ipport;

@end
