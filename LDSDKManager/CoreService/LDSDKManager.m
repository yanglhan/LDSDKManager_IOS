//
//  LDSDKManager.m
//  LDSDKManager
//
//  Created by ss on 15/8/25.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

#import "LDSDKManager.h"
#import "LDSDKRegisterService.h"
#import "LDSDKPayService.h"
#import "LDSDKAuthService.h"
#import "LDSDKShareService.h"

NSString *const LDSDKConfigAppIdKey = @"kAppID";
NSString *const LDSDKConfigAppSecretKey = @"kAppSecret";
NSString *const LDSDKConfigAppSchemeKey = @"kAppScheme";
NSString *const LDSDKConfigAppPlatformTypeKey = @"kAppPlatformType";
NSString *const LDSDKConfigAppDescriptionKey = @"kAppDescription";

NSString *const LDSDKShareContentTitleKey = @"title";
NSString *const LDSDKShareContentDescriptionKey = @"description";
NSString *const LDSDKShareContentImageKey = @"image";
NSString *const LDSDKShareContentWapUrlKey = @"webpageurl";
NSString *const LDSDKShareContentTextKey = @"text";

static NSArray *sdkServiceConfigList = nil;

@implementation LDSDKManager

/**
 *  根据配置列表依次注册第三方SDK
 *
 *  @return YES则配置成功
 */
+ (void)registerWithPlatformConfigList:(NSArray *)configList;
{
  if (configList == nil || configList.count == 0)
    return;

  for (NSDictionary *onePlatformConfig in configList) {
    LDSDKPlatformType platformType =
        [onePlatformConfig[LDSDKConfigAppPlatformTypeKey] intValue];
    Class registerServiceImplCls =
        [[self class] getServiceProviderWithPlatformType:platformType];
    if (registerServiceImplCls != nil) {
      [[registerServiceImplCls sharedService]
          registerWithPlatformConfig:onePlatformConfig];
    }
  }
}

/**
 *  处理应用回调URL
 *
 *  @return YES
 */
+ (BOOL)handleOpenURL:(NSURL *)url {
  if ([[[self class] getPayService:LDSDKPlatformWeChat]
          payProcessOrderWithPaymentResult:url
                           standbyCallback:NULL]) {
    return YES;
  }

  if ([[[self class] getRegisterService:LDSDKPlatformQQ] handleResultUrl:url] ||
      [[[self class] getRegisterService:LDSDKPlatformWeChat]
          handleResultUrl:url] ||
      [[[self class] getRegisterService:LDSDKPlatformYiXin]
          handleResultUrl:url]) {
    return YES;
  }
  if ([[[self class] getPayService:LDSDKPlatformAliPay]
          payProcessOrderWithPaymentResult:url
                           standbyCallback:NULL]) {
    return YES;
  }

  return YES;
}

/*!
 *  @brief  获取配置服务
 *
 *  @return 服务实例
 */
+ (id)getRegisterService:(LDSDKPlatformType)type {
  Class shareServiceImplCls =
      [[self class] getServiceProviderWithPlatformType:type];
  if (shareServiceImplCls) {
    if ([[shareServiceImplCls sharedService]
            conformsToProtocol:@protocol(LDSDKRegisterService)]) {
      return [shareServiceImplCls sharedService];
    }
  }
  return nil;
}

/*!
 *  @brief  获取登陆服务
 *
 *  @return 服务实例
 */
+ (id)getAuthService:(LDSDKPlatformType)type {
  Class shareServiceImplCls =
      [[self class] getServiceProviderWithPlatformType:type];
  if (shareServiceImplCls) {
    if ([[shareServiceImplCls sharedService]
            conformsToProtocol:@protocol(LDSDKAuthService)]) {
      return [shareServiceImplCls sharedService];
    }
  }
  return nil;
}

/*!
 *  @brief  获取分享服务
 *
 *  @return 服务实例
 */
+ (id)getShareService:(LDSDKPlatformType)type {
  Class shareServiceImplCls =
      [[self class] getServiceProviderWithPlatformType:type];
  if (shareServiceImplCls) {
    if ([[shareServiceImplCls sharedService]
            conformsToProtocol:@protocol(LDSDKShareService)]) {
      return [shareServiceImplCls sharedService];
    }
  }
  return nil;
}

/*!
 *  @brief  获取支付服务
 *
 *  @return 服务实例
 */
+ (id)getPayService:(LDSDKPlatformType)type {
  Class shareServiceImplCls =
      [[self class] getServiceProviderWithPlatformType:type];
  if (shareServiceImplCls) {
    if ([[shareServiceImplCls sharedService]
            conformsToProtocol:@protocol(LDSDKPayService)]) {
      return [shareServiceImplCls sharedService];
    }
  }
  return nil;
}

/**
 * 根据平台类型和服务类型获取服务提供者
 */
+ (Class)getServiceProviderWithPlatformType:(LDSDKPlatformType)platformType {
  if (sdkServiceConfigList == nil) {
    NSString *plistPath =
        [[NSBundle mainBundle] pathForResource:@"SDKServiceConfig"
                                        ofType:@"plist"];
    sdkServiceConfigList = [[NSArray alloc] initWithContentsOfFile:plistPath];
  }

  Class serviceProvider = nil;
  for (NSDictionary *oneSDKServiceConfig in sdkServiceConfigList) {
    // find the specified platform
    if ([oneSDKServiceConfig[@"platformType"] intValue] == platformType) {
      serviceProvider =
          NSClassFromString(oneSDKServiceConfig[@"serviceProvider"]);
      break;
    } // if
  }   // for

  return serviceProvider;
}

@end
