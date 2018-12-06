//
//  LDViewController.m
//  LDSDKManager
//
//  Created by 张海洋 on 08/19/2015.
//  Copyright (c) 2015 张海洋. All rights reserved.
//

#import "LLDViewController.h"

#import "LDSDKAuthService.h"
#import "LDSDKManager.h"

#import "LLDViewDataVM.h"
#import "LLDPlatformDto.h"
#import "LLDPlatformCell.h"

@interface LLDViewController () {
    UILabel *infoLabel;
}

@property(nonatomic, strong) LLDViewDataVM *dataVM;

@end

@implementation LLDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataVM prepareData];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.tableView registerClass:[LLDPlatformCell class] forCellReuseIdentifier:NSStringFromClass([LLDPlatformCell class])];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];
    [self.tableView reloadData];
}

#pragma mark - getter

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 1;
    return 44;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return nil;
    UITableViewHeaderFooterView *headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];
    LLDCategoriryDto *categoriryDto = [self.dataVM categroryAtIndex:section - 1];
    headerFooterView.textLabel.text = categoriryDto.name;
    return headerFooterView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LLDPlatformCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LLDPlatformCell class]) forIndexPath:indexPath];
        [cell loadData:self.dataVM.dataList];
        __weak typeof(self) weakSelf = self;
        cell.callBack = ^(NSUInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.dataVM.platformIndx = index;
            [strongSelf.tableView reloadData];
        };
        return cell;
    }
    LLDShareInfoDto *infoDto = [self.dataVM shareInfoDtoAtCateIndex:indexPath.section - 1 index:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = infoDto.name;
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LLDPlatformDto *platformDto = self.dataVM.curPlatformDto;
    return platformDto.cates.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    LLDPlatformDto *platformDto = self.dataVM.curPlatformDto;
    LLDCategoriryDto *categoriryDto = platformDto.cates[section - 1];
    return categoriryDto.shareInfos.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return;
    LLDCategoriryDto *categoriryDto = [self.dataVM categroryAtIndex:indexPath.section -1];
    LLDShareInfoDto *infoDto = [self.dataVM shareInfoDtoAtCateIndex:indexPath.section - 1 index:indexPath.row];
    [self share:infoDto cate:categoriryDto];
}

- (void)share:(LLDShareInfoDto *)shareInfoDto cate:(LLDCategoriryDto *)categoriryDto {
    __weak typeof(self) weakSelf = self;
    NSDictionary *shareDict = [self.dataVM shareContentWithShareType:shareInfoDto.type
                                                         shareMoudle:categoriryDto.type
                                                            callBack:^(LDSDKErrorCode errorCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (errorCode == LDSDKSuccess) {
            [infoLabel setText:@"分享成功"];
        } else {
            [infoLabel setText:error.localizedDescription];
        }
    }];
    [[[LDSDKManager share] shareService:self.dataVM.curPlatformDto.type] shareContent:shareDict];
}

- (void)loginByWX {
    [[[LDSDKManager share] authService:LDSDKPlatformWeChat]
            loginToPlatformWithCallback:^(NSDictionary *oauthInfo, NSDictionary *userInfo,
                    NSError *error) {
                if (error == nil) {
                    if (userInfo == nil && oauthInfo != nil) {
                        [infoLabel setText:@"授权成功"];
                    } else {
                        NSString *alet =
                                [NSString stringWithFormat:@"昵称：%@  头像url：%@",
                                                           [userInfo objectForKey:kWX_NICKNAME_KEY],
                                                           [userInfo objectForKey:kWX_AVATARURL_KEY]];
                        NSLog(@"message = %@", alet);
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆成功"
                                                                            message:alet
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:@"Cancel", nil];
                        [alertView show];
                    }
                } else {
                    [infoLabel setText:error.localizedDescription];
                }
            }];
}

- (void)loginByQQ {
    [[[LDSDKManager share] authService:LDSDKPlatformQQ]
            loginToPlatformWithCallback:^(NSDictionary *oauthInfo, NSDictionary *userInfo,
                    NSError *error) {
                if (error == nil) {
                    if (userInfo == nil && oauthInfo != nil) {
                        [infoLabel setText:@"授权成功"];
                    } else {
                        NSString *alet =
                                [NSString stringWithFormat:@"昵称：%@  头像url：%@",
                                                           [userInfo objectForKey:kQQ_NICKNAME_KEY],
                                                           [userInfo objectForKey:kQQ_AVATARURL_KEY]];
                        NSLog(@"message = %@", alet);
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆成功"
                                                                            message:alet
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:@"Cancel", nil];
                        [alertView show];
                    }
                } else {
                    [infoLabel setText:error.localizedDescription];
                }
            }];
}

- (void)shareByQQ {
    __weak typeof(self) weakSelf = self;
    NSDictionary *shareDict = [self.dataVM shareContentWithShareType:LDSDKShareTypeImage shareMoudle:LDSDKShareToContact callBack:^(LDSDKErrorCode errorCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (errorCode == LDSDKSuccess) {
            [infoLabel setText:@"分享成功"];
        } else {
            [infoLabel setText:error.localizedDescription];
        }
    }];
    [[[LDSDKManager share] shareService:LDSDKPlatformQQ] shareContent:shareDict];
}

- (void)shareByWX {
    __weak typeof(self) weakSelf = self;
    NSDictionary *shareDict = [self.dataVM shareContentWithShareType:LDSDKShareTypeImage shareMoudle:LDSDKShareToContact callBack:^(LDSDKErrorCode errorCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (errorCode == LDSDKSuccess) {
            [infoLabel setText:@"分享成功"];
        } else {
            [infoLabel setText:error.localizedDescription];
        }
    }];
    [[[LDSDKManager share] shareService:LDSDKPlatformWeChat] shareContent:shareDict];
}

- (void)shareByQzone {
    __weak typeof(self) weakSelf = self;
    NSDictionary *shareDict = [self.dataVM shareContentWithShareType:LDSDKShareTypeImage shareMoudle:LDSDKShareToTimeLine callBack:^(LDSDKErrorCode errorCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (errorCode == LDSDKSuccess) {
            [infoLabel setText:@"分享成功"];
        } else {
            [infoLabel setText:error.localizedDescription];
        }
    }];
    [[[LDSDKManager share] shareService:LDSDKPlatformQQ] shareContent:shareDict];
}

- (void)shareByWXTimeline {
    __weak typeof(self) weakSelf = self;
    NSDictionary *shareDict = [self.dataVM shareContentWithShareType:LDSDKShareTypeImage shareMoudle:LDSDKShareToTimeLine callBack:^(LDSDKErrorCode errorCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (errorCode == LDSDKSuccess) {
            [infoLabel setText:@"分享成功"];
        } else {
            [infoLabel setText:error.localizedDescription];
        }
    }];
    [[[LDSDKManager share] shareService:LDSDKPlatformWeChat] shareContent:shareDict];
}

- (void)shareByWeibo {
    __weak typeof(self) weakSelf = self;
    NSDictionary *shareDict = [self.dataVM shareContentWithShareType:LDSDKShareTypeImage shareMoudle:LDSDKShareToTimeLine callBack:^(LDSDKErrorCode errorCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (errorCode == LDSDKSuccess) {
            [infoLabel setText:@"分享成功"];
        } else {
            [infoLabel setText:error.localizedDescription];
        }
    }];
    [[[LDSDKManager share] shareService:LDSDKPlatformWeibo] shareContent:shareDict];
}

- (void)payByWX {
//    [[LDSDKManager getPayService:LDSDKPlatformWeChat]
//            payOrder:@""
//            callback:^(NSString *signString, NSError *error) {
//                if (error) {
//                    [infoLabel setText:error.localizedDescription];
//                } else if (signString) {
//                    [infoLabel setText:signString];
//                }
//            }];
}

- (void)payByAli {
//    [[LDSDKManager getPayService:LDSDKPlatformAliPay]
//            payOrder:@"_input_charset=\"utf-8\"&body=\"\u5341\u4e8c\u6708\u8d77\u4e49-"
//                    @"\u5317\u4eacUME\u56fd\u9645\u5f71\u57ce\u534e\u661f\u5e97\"&notify_url=\"http%"
//                    @"3A%2F%2F123.58.185.47%2Fservlet%2FAlipaySdk\"&out_trade_no=\"862909311\"&"
//                    @"partner=\"null\"&payment_type=\"1\"&seller_id=\"null\"&service=\"mobile."
//                    @"securitypay.pay\"&subject=\"\u5341\u4e8c\u6708\u8d77\u4e49-"
//                    @"\u5317\u4eacUME\u56fd\u9645\u5f71\u57ce\u534e\u661f\u5e97\"&total_fee=\"2.00\"&"
//                    @"sign_type=\"RSA\"&sign=\"PHR9yK0cxHqeNYZnXIFAjSYn5zNijIc0oegD%"
//                    @"2BTV77ZsF3U5LjD9jbxsmjlEv%2B7nWlCbn2%"
//                    @"2BfmoiE0eTFnxoOqREuP0rkBs5XqAYlszGnU8Lv92x35R0AWpiouwnK8uRg2a9B%"
//                    @"2Fu1YLgXMf26v8pjAVYBKn7nnJbd23OIPNGPiU12s%3D\""
//            callback:^(NSString *signString, NSError *error) {
//                if (error) {
//                    [infoLabel setText:error.localizedDescription];
//                } else if (signString) {
//                    [infoLabel setText:signString];
//                }
//            }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"click");
    alertView = nil;
}

#pragma mark - getter

- (LLDViewDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LLDViewDataVM new];
    }
    return _dataVM;
}

@end
