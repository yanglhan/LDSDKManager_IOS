//
//  LDSDKAliPayServiceImpl.h
//  LDSDKManager
//
//  Created by ss on 15/8/21.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LDSDKRegisterService.h"
#import "LDSDKPayService.h"
#import "LDSDKAuthService.h"

@interface LDSDKAliPayServiceImpl : NSObject <LDSDKRegisterService, LDSDKAuthService, LDSDKPayService>

@end
