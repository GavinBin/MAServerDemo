#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MaServer.h"
#import "MBProgressHUD+WB.h"
#import "NetworkHelper.h"
#import "OpenUDID.h"
#import "ServiceCall.h"

FOUNDATION_EXPORT double MAServerDemoVersionNumber;
FOUNDATION_EXPORT const unsigned char MAServerDemoVersionString[];

