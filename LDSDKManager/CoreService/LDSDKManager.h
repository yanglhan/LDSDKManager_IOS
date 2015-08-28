//
//  LDSDKManager.h
//  LDSDKManager
//
//  Created by ss on 15/8/25.
//  Copyright (c) 2015年 张海洋. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LDSDKPlatformType) {
  LDSDKPlatformQQ = 1, // QQ
  LDSDKPlatformWeChat, //微信
  LDSDKPlatformYiXin,  //易信
  LDSDKPlatformAliPay, //支付宝
};

@interface LDSDKManager : NSObject

/**
 *  根据配置列表依次注册第三方SDK
 *
 *  @return YES则配置成功
 */
+ (void)registerWithPlatformConfigList:(NSArray *)configList;

/**
 *  处理应用回调URL
 *
 *  @return YES
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/*!
 *  @brief  获取配置服务
 *
 *  @return 服务实例
 */
+ (id)getRegisterService:(LDSDKPlatformType)type;

/*!
 *  @brief  获取登陆服务
 *
 *  @return 服务实例
 */
+ (id)getAuthService:(LDSDKPlatformType)type;

/*!
 *  @brief  获取分享服务
 *
 *  @return 服务实例
 */
+ (id)getShareService:(LDSDKPlatformType)type;

/*!
 *  @brief  获取支付服务
 *
 *  @return 服务实例
 */
+ (id)getPayService:(LDSDKPlatformType)type;

@end
