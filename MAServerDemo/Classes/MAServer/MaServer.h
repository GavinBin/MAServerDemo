//
//  MaServer.h
//  HRMeap
//
//  Created by kl on 2017/3/13.
//  Copyright © 2017年 王彬. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 请求成功的Block */
typedef void(^newWorkSuccess)(id responseObject);

/** 请求失败的Block */
typedef void(^newWorkFailed)(id error);


@interface MaServer : NSObject


/**
  设置ip端口
 @param ipport 设置ip端口 如123.103.1.1：8090
 */
+ (void)setUpMaServeripport:(NSString *)ipport;

+ (void)callActionParams:(NSDictionary *)params controllerid:(NSString *)controllerid appid:(NSString *)appid successCall:(newWorkSuccess)success error:(newWorkFailed)failure;
@end
