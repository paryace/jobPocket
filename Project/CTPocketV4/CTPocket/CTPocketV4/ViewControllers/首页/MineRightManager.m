//
//  MineRightCVtler.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-5-26.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "MineRightManager.h"
#import "CTBaseViewController.h"
#import "MineNonLoginVCtler.h"
#import "MineLoginedVCtler.h"
#import "CTLoginVCtler.h"
#import "AppDelegate.h"
#import "CTNavigationController.h"
#import "CustomizeSliderController.h"
#import "COQueryListVctler.h"
#import "SIAlertView.h"
#import "Utils.h"
#import "CTHomeVCtler.h"
#import "COQueryVctler.h"
#import "CTPointQueryVCtler.h"
#import "CTQryPackageVctler.h"
#import "CTMyOrderListVCtler.h"
#import "CustomShareVC.h"
#import "RightParentVCtler.h"
@interface MineRightManager ()
{
    CTBaseViewController *rootCVtler;
    BOOL recomendHiden;
    NSString *shareContent;
}

@end

@implementation MineRightManager
+(instancetype)instance
{
    MineRightManager *mine=[[MineRightManager alloc] init];
    [mine fetchRecommend];
    [[NSNotificationCenter defaultCenter] addObserver:mine
                                             selector:@selector(onLoginSuccessNotification)
                                                 name:kLoginSuccess
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:mine
                                             selector:@selector(onNameValueNotification:)
                                                 name:MineNameValue
                                               object:nil];
    return mine;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - viewcontroller
-(CTBaseViewController*)currentController
{
 
    if ([Global sharedInstance].isLogin)
    {
        MineLoginedVCtler *loginVCtler=[[MineLoginedVCtler alloc] initWithNibName:@"MineLoginedVCtler" bundle:nil];
        loginVCtler.shareContent=shareContent;
        loginVCtler.manager=self;
        loginVCtler.recommendHiden=recomendHiden;
        rootCVtler=loginVCtler;
    }
    else
    {
        MineNonLoginVCtler *nonLoginVCtler=[[MineNonLoginVCtler alloc] initWithNibName:@"MineNonLoginVCtler" bundle:nil];
        nonLoginVCtler.shareContent=shareContent;
        nonLoginVCtler.manager=self;
        nonLoginVCtler.recommendHiden=recomendHiden;
        rootCVtler=nonLoginVCtler;
    }
    return rootCVtler;
    
}

#pragma mark - method 

- (void)onNameValueNotification:(NSNotification*)notifition
{
    id obj = [notifition object];
    if ([rootCVtler isKindOfClass:[MineLoginedVCtler class]]) {
        MineLoginedVCtler *login=(MineLoginedVCtler*)rootCVtler;
        [login resetUserName:[NSString stringWithFormat:@"%@",obj]];
        [self fetchPointInfo];
    }
}
#pragma mark 积分值发生变化
- (void)onPointValueNotification:(NSString*)point
{
    if ([rootCVtler isKindOfClass:[MineLoginedVCtler class]]) {
        MineLoginedVCtler *login=(MineLoginedVCtler*)rootCVtler;
        [login resetPoint:[NSString stringWithFormat:@"%@",point]];
    } ;
}


// 我的积分
- (void)fetchPointInfo
{
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNbr = loginInfoDict[@"UserLoginName"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            phoneNbr, @"PhoneNbr",
                            @"11", @"CodeType", nil];
    __weak typeof(self) weakSelf=self;
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"pointInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                         NSDictionary *pointInfo = dict[@"Data"];
                                          NSString *pointValue= pointInfo[@"PointValue"];
                                          [weakSelf onPointValueNotification:pointValue];
                                      } onError:^(NSError *engineError) {
                                          
                                          
                                      }];
}


#pragma mark 接受登录成功的通知
- (void)onLoginSuccessNotification
{
   [self update];
    [self fetchRecommend];
}
#pragma mark 登录
-(void)login
{
    CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
    }];
}

-(void)loginOut
{
        __weak typeof(self) wself = self;
    // 提示是否退出
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                     andMessage:@"您确定要退出登录？"];
    [alertView addButtonWithTitle:@"取消"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"取消");
                          }];
    [alertView addButtonWithTitle:@"确定"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"确定");
                              // 取消掉全部请求和回调
                              [MyAppDelegate.cserviceEngine cancelAllOperations];
                              [MyAppDelegate.bestToneEngine cancelAllOperations];
                              [MyAppDelegate.feedbackEngine cancelAllOperations];
                              
                              // 注销
                              [Global sharedInstance].isLogin = NO;
                              [Global sharedInstance].loginInfoDict = nil;
                              [Global sharedInstance].custInfoDict = nil;
                              [Global sharedInstance].ticket = nil;
                              [Global sharedInstance].isShowBusiProc = NO;
                              [Global sharedInstance].configArray = nil;
                              {
                                  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
                                  if ([settings objectForKey:@"AutoLogin"] && [[settings objectForKey:@"AutoLogin"] isEqualToString:@"YES"])
                                  {
                                      // 保留帐号、密码
                                  }
                                  else
                                  {
                                      [Utils clearPhoneAndPwd];
                                      NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
                                      [settings setObject:@"NO" forKey:@"AutoLogin"];
                                      [settings synchronize];
                                  }
                              }
                              
                              // 刷新消息中心按钮
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissMsg" object:nil];
                              
                              // 所有页面返回到RootVC
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"pop2RootVC" object:nil];
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"刷新Tableview" object:nil];
                              [wself.homeVctler processExit];
                              [wself update];
                              
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

#pragma mark 获取推荐内容
-(void)fetchRecommend
{
    NSString * shopId = BUSSINESS_SHOPID ;
    NSDictionary *params = @{@"ShopId":shopId};
    if ([Global sharedInstance].isLogin)
    {
        NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
        NSString *phone= loginInfoDict[@"UserLoginName"] ? loginInfoDict[@"UserLoginName"] : @"";
        params = @{@"PhoneNbr":phone,@"ShopId":shopId};
    }
    [MyAppDelegate.cserviceEngine2 postXMLWithCode:@"getAwardConfig"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict)
    {
        NSDictionary *Data= dict[@"Data"];
        NSDictionary *AwardConfig=  Data[@"AwardConfig"];
        int cuomShowType=[AwardConfig[@"ComShowType"] intValue];
        if (cuomShowType==1)
        {
            RightParentVCtler *vctler=(RightParentVCtler*)rootCVtler;
            shareContent=AwardConfig[@"ComString"] ;;
            vctler.shareContent=shareContent;
            vctler.recommendHiden=NO;
            [vctler resetRecommend];
            recomendHiden=NO;
        }
        else
        {
            RightParentVCtler *vctler=(RightParentVCtler*)rootCVtler;
            vctler.recommendHiden=YES;
            [vctler resetRecommend];
            recomendHiden=YES;
        }
      
    } onError:^(NSError *engineError) {
      
      
    }];
}
#pragma mark 告诉抽屉管理类要改变界面
-(void)update
{
    [self.changeRightDelegate changeRight:[self currentController]];
}

#pragma mark - push new controller
#pragma mark 显示快速订单查询
-(void)showDingdang
{
    COQueryVctler *vc = [[COQueryVctler alloc] init];
    [self.changeRightDelegate pushRightViewController:vc];
}
#pragma mark 显示积分
-(void)showScore
{
    CTPointQueryVCtler *vc = [[CTPointQueryVCtler alloc] init];
    [self.changeRightDelegate pushRightViewController:vc];
}
#pragma mark 显示套餐余额
-(void)showTaoCanYuE
{
    CTQryPackageVctler* qvct = [[CTQryPackageVctler alloc] init];
    [self.changeRightDelegate pushRightViewController:qvct];
}
#pragma mark 显示我的订单
-(void)showOrder
{ CTMyOrderListVCtler *vc = [[CTMyOrderListVCtler alloc] init];
    vc.orderType = @"0";
    [self.changeRightDelegate pushRightViewController:vc];
}

@end
