//
//  MaServer.m
//  HRMeap
//
//  Created by kl on 2017/3/13.
//  Copyright © 2017年 王彬. All rights reserved.
//

#import "MaServer.h"
#import "NetworkHelper.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonCryptor.h>
#include "OpenUDID.h"
#import "AFNetworking.h"
#import "MBProgressHUD+WB.h"
@interface MaServer()

@end

NSString *uuid ,*macAddress,*wfaddress,*user,*ip_port;

@implementation MaServer

+ (void)initialize
{
    // 初始化赋值
    uuid = [OpenUDID value];
    macAddress = [OpenUDID getMacAddress];
    wfaddress = [OpenUDID getIpAddressWIFI];

}

+ (void)setUpMaServeripport:(NSString *)ipport
{
    ip_port = ipport;
}



+ (void)callActionParams:(NSDictionary *)params controllerid:(NSString *)controllerid appid:(NSString *)appid successCall:(newWorkSuccess)success error:(newWorkFailed)failure
{
    if(!ip_port.length){
        NSLog(@"请先使用[MaServer setUpMaServeripport]方法设置IP——port");
        return;
    }
    NSDictionary *appJson=@{
                               @"appid":appid,
                               @"controllerid":controllerid,
                               @"devid":uuid,
                               @"forcelogin":@"",
                               @"funcid":@"",
                               @"funcode":controllerid,
                               @"massotoken":@"",
                               @"sessionid":@"",
                               @"tabid":@"",
                               @"token":@"",
                               @"user":@"",
                               @"pass":@"",
                               @"userid":@"",
                               @"groupid":@""
                               };
    NSDictionary *deviceinfoJson = @{@"style":@"ios",
                                 @"uuid":uuid,
                                 @"mac":macAddress,
                                 @"wfaddress":wfaddress,
                                 @"bluetooth":@"",
                                 @"firmware":@"",
                                 @"ram":@"",
                                 @"rom":@"",
                                 @"imei":@"",
                                 @"imsi":@"",
                                 @"resolution":@"",
                                 @"pushtoken":@"",
                                 @"mode":[[UIDevice currentDevice] model],
                                 @"osversion":[[UIDevice currentDevice] systemVersion],
                                 @"appversion":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                 @"lang":@"",
                                 @"model":[[UIDevice currentDevice] model],
                                 @"categroy":[[UIDevice currentDevice] model],
                                 @"name":[[UIDevice currentDevice] name],
                                 @"screensize":@{@"width":[NSString stringWithFormat:@"%f",CGRectGetWidth([UIScreen mainScreen].bounds)],@"heigth":[NSString stringWithFormat:@"%f",CGRectGetHeight([UIScreen mainScreen].bounds)]},
                                 @"wifi":wfaddress,
                                 @"devid":uuid};
    
    NSMutableDictionary *postJson=[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                  @"actionid":@"",
                                                                                  @"actionname":@"handler",
                                                                                  @"callback":@"",
                                                                                  @"contextmapping":@"none",
                                                                                  @"controllerid":controllerid,
                                                                                  @"viewid":controllerid,
                                                                                  @"windowid":@""
                                                                                  }];
    [postJson setValue:params forKey:@"params"];
    NSDictionary *rootjson=@{@"serviceid":@"umCommonService",
                             @"appcontext":appJson,
                             @"deviceinfo":deviceinfoJson,
                             @"servicecontext":postJson
                             };
    
    NSError *jsonError;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:rootjson options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (!jsonData) {
        NSLog(@"---------->json转字符串错误%@",jsonError);
    }
    NSString *rootJsonStr=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    rootJsonStr         = [self removeMessRootJsonStr:rootJsonStr];
    if (rootJsonStr!=nil) {
        
        NSString *tp=@"des";
        NSString *result    = [self encoding:rootJsonStr type:tp];
        NSDictionary *dataParams=@{@"tp":tp,
                                   @"data":result};
        NSString *url       = @"";
        
        url=[NSString stringWithFormat:@"http://%@/umserver/core/",ip_port];
        [self netWorkUrl:url paramet:dataParams successCall:success error:failure];
    }
}





+ (void)netWorkUrl:(NSString *)url paramet:(NSDictionary *)dataParams successCall:(newWorkSuccess)success error:(newWorkFailed)failure
{
    [NetworkHelper POST:url parameters:dataParams success:^(NSDictionary *dict) {
        [self hideHUD];
        NSString *result                    = [self decoding:dict[@"data"] type:dict[@"tp"]];
        @try{
            //先把result转成nsdata
            NSData *resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
            //再把nsdata转成nsmutabledictionary
            NSError *jsonError;
            NSMutableDictionary *resultCode =[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&jsonError];
            if (!resultCode) {
                NSLog(@"解析异常%@",jsonError);
            }
            if ([resultCode[@"code"] isEqualToString:@"0"]) {
                //后台抛了异常，将处理权移交给调用者，提供一个默认的实现为弹框
                if (failure){
                    NSDictionary *errordic=@{@"errorcode":@"0",
                                             @"errormsg":resultCode[@"msg"],
                                             @"json":resultCode
                                             };
                    failure(errordic);
                    
                }else{
                    [self alertViewMsg:resultCode[@"msg"]];
                }
                return;
            }else if([resultCode[@"resultctx"][@"result"][@"retflag"] isEqualToString:@"1"]){ //
                if (failure){
                    
                    NSDictionary *errordic=@{@"errorcode":@"0",
                                             @"errormsg":resultCode[@"resultctx"][@"result"][@"msg"] ,
                                             @"json":resultCode
                                             };
                    failure(errordic);
                    
                }else{
                    [self alertViewMsg:resultCode[@"resultctx"][@"result"][@"msg"]];

                }
                return;
            }
            NSDictionary *resultctx             = resultCode[@"resultctx"];
            success(resultctx);
            
        }@catch (NSException *exception) {
            NSLog(@"---------->json转字符串错误");
        }
        
    } failure:^(NSError *error) {
        [self hideHUD];
        [MBProgressHUD showError:@"网络连接异常"];
        [MBProgressHUD showError:@"网络连接异常"];
    }];
    
}

+ (void)alertViewMsg:(NSString *)msg
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction             = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:okAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)hideHUD
{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow];
    [MBProgressHUD hideHUD];
}


/**
 主要目的是去掉json字符串中额外的字符
 
 :returns: 返回一个干净的json字符串
 */
+(NSString*)removeMessRootJsonStr:(NSString *)rootJsonStr{
    NSString *result=[rootJsonStr stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\"" options:NSLiteralSearch range:NSMakeRange(0, rootJsonStr.length)];
    result = [result stringByReplacingOccurrencesOfString:@"\\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    return result;
}

+(NSString*)encoding:(NSString*)string type:(NSString*)type{
    if ([type isEqualToString:@"des"]) {
        return  [self encrypt:string encryptOrDecrypt:kCCEncrypt key:@"12345678"];
    }
//    else if ([type isEqualToString:@"des_gzip"]){
//        NSData *zipData  = [self gzippedData:[string dataUsingEncoding:NSUTF8StringEncoding]];
//        NSString *base=[zipData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//        return base;
//    }else{
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:string options:NSJSONWritingPrettyPrinted error:nil];
//        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
}

/**
 对返回的字符串进行解压缩解密
 
 :param: string 未处理的字符串
 :param: type   解密方式，分为des和des_zip
 
 :returns: 返回String字符串
 */

+(NSString*)decoding:(NSString*)string type:(NSString*)type{
    if ([type isEqualToString:@"des"]) {
        return [self encrypt:string encryptOrDecrypt:kCCDecrypt key:@"12345678"];
    }else if ([type isEqualToString:@"des_gzip"]){
         NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
//            data = [self gunzippedData:data];
        return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }else if ([type isEqualToString:@"none"]){
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:string options:NSJSONWritingPrettyPrinted error:nil];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (NSString *)encrypt:(NSString *)sText encryptOrDecrypt:(CCOperation)encryptOperation key:(NSString *)key

{
    
    const void *vplainText;
    
    size_t plainTextBufferSize;
    
    
    
    if (encryptOperation == kCCDecrypt)
        
    {
        NSData *decryptData  = [[NSData alloc] initWithBase64EncodedString:sText options:NSDataBase64DecodingIgnoreUnknownCharacters];;
        
        
        //        NSData *decryptData = [GTMBase64 decodeString:sText];
        
        plainTextBufferSize  = [decryptData length];
        
        vplainText           = [decryptData bytes];
        
    }
    
    else
        
    {
        
        NSData* encryptData  = [sText dataUsingEncoding:NSUTF8StringEncoding];
        
        plainTextBufferSize  = [encryptData length];
        
        vplainText           = (const void *)[encryptData bytes];
        
    }
    
    
    
    CCCryptorStatus ccStatus;
    
    uint8_t *bufferPtr   = NULL;
    
    size_t bufferPtrSize = 0;
    
    size_t movedBytes    = 0;
    
    
    
    bufferPtrSize        = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    
    bufferPtr            = malloc( bufferPtrSize * sizeof(uint8_t));
    
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    
    const void *vkey     = (const void *) [key UTF8String];
    Byte  iv[]           = {0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF};
    
    ccStatus             = CCCrypt(encryptOperation,
                                   
                                   kCCAlgorithmDES,
                                   
                                   kCCOptionPKCS7Padding,
                                   
                                   vkey,
                                   
                                   kCCKeySizeDES,
                                   
                                   iv,
                                   
                                   vplainText,
                                   
                                   plainTextBufferSize,
                                   
                                   (void *)bufferPtr,
                                   
                                   bufferPtrSize,
                                   
                                   &movedBytes);
    
    
    
    NSString *result     = nil;
    
    
    
    if (encryptOperation == kCCDecrypt)
        
    {
        
        result               = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
        
    }
    
    else
        
    {
        
        NSData *data         = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        result               = [data base64EncodedStringWithOptions:0];
    }
    
    
    
    return result;
    
}

///**
//    nsdat压缩加密
// */
//+(NSData*)gzippedData:(NSData *)datas{
//    if (datas.length>0) {
//        z_stream stream = [self createZStream:datas];
//        if (deflateInit2_(&stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY, ZLIB_VERSION, (UInt32)sizeof(z_stream))!=Z_OK) {
//            return nil;
//        }
//        NSMutableData *data=[NSMutableData dataWithLength:(uint)2 ^ 14];
//        while (stream.avail_out==0) {
//            if ((uint)stream.total_out>=data.length) {
//                data.length+=(uint)2 ^ 14;
//            }
//            
//            stream.next_out=(Bytef*)[data mutableBytes]+stream.total_out
//            ;
//            stream.avail_out=(unsigned int)([data length] - stream.total_out);
//            
//            deflate(&stream, Z_FINISH);
//        }
//        deflateEnd(&stream);
//        data.length = stream.total_out;
//        return data;
//    }
//    
//    return nil;
//}
//
//+(NSData*)gunzippedData:(NSData *)datas{
//    if (datas.length>0) {
//        z_stream stream=[self createZStream:datas];
//        if (inflateInit2_(&stream, 47, ZLIB_VERSION, sizeof(z_stream)) != Z_OK) {
//            return nil;
//        }
//        
//        NSMutableData *data=[NSMutableData dataWithLength:datas.length*2];
//        UInt32 status;
//        do {
//            if (stream.total_out >= data.length) {
//                data.length += data.length / 2;
//            }
//            stream.next_out = (Bytef*)data.mutableBytes+stream.total_out;
//            stream.avail_out = (uint)data.length - (uint)stream.total_out;
//            
//            status = inflate(&stream, Z_SYNC_FLUSH);
//        } while (status==Z_OK || (status == Z_BUF_ERROR));
//        
//        if (inflateEnd(&stream) == Z_OK) {
//            if (status == Z_STREAM_END) {
//                data.length = stream.total_out;
//                return data;
//            }
//        }
//        
//    }
//    return nil;
//}
//
//
//+(z_stream)createZStream:(NSData *)data{
//    z_stream stream;
//    stream.next_in=(Bytef*)data.bytes;
//    stream.avail_in=(uint)data.length;
//    stream.total_in=0;
//    stream.next_out=nil;
//    stream.avail_out=0;
//    stream.total_out=0;
//    stream.msg=nil;
//    stream.state=nil;
//    stream.zalloc=nil;
//    stream.zfree=nil;
//    stream.opaque=nil;
//    stream.data_type=0;
//    stream.adler=0;
//    stream.reserved=0;
//    return stream;
//}



@end
