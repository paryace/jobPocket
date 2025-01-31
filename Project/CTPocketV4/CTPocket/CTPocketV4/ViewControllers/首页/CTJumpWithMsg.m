//
//  CTJumpWithMsg.m
//  CTPocketV4
//
//  Created by liuruxian on 14-6-16.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTJumpWithMsg.h"
#import "CustomTabBarVCtler.h"
#import "CTDetailVCtler.h"
#import "CTLoginVCtler.h"
#import "CTPhoneInfoVCtler.h"
#import "CTSelectPhoneVCtler.h"
#import "SIAlertView.h"
#import "CTRechargeVCtler.h"
#import "CTPrettyNumberVCtler.h"

NSString * const CTJumpPageWithMsgNotification = @"JumpPageWithMsgNotification";

@interface CTJumpWithMsg()<loginSucDelegate>

@property (nonatomic,strong) CustomTabBarVCtler * custabBarController ;
@property (nonatomic, strong) NSDictionary * jumpDict;
@property (nonatomic, assign) int type;
@property (weak, nonatomic) UIViewController *Controller4modal;
@property (nonatomic, assign)JUMPTYPE pushType;

@end

@implementation CTJumpWithMsg

- (instancetype)init:(UIViewController *)tabbar type:(JUMPTYPE)pushType
{
    self = [super init];
    if (self) {
        _custabBarController = (CustomTabBarVCtler *)tabbar;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jumpPage:)
                                                     name:CTJumpPageWithMsgNotification object:nil];
        _pushType = pushType;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 登录成功消息 delegate

- (void)autoPushVCtler
{
    if (self.jumpDict) {
        [self jumpPage:_jumpDict];
        _jumpDict = nil;
    }
    else {
        
    }
}

#pragma mark - 跳转的delegate
- (void)jumpPage:(NSDictionary *)dictionary
{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL  initialAutoLogin=[settings boolForKey:INITIAL_AUTO_LOGIN];
    BOOL autologin=[settings objectForKey:@"AutoLogin"] && [[settings objectForKey:@"AutoLogin"] isEqualToString:@"YES"]&&initialAutoLogin;
    [settings setBool:NO forKey:INITIAL_AUTO_LOGIN];
    [settings synchronize];
  
    // 跳转
    if (!dictionary && ![dictionary respondsToSelector:@selector(objectForKey:)]) {
        return;
    }
    
    NSString * LinkTypeStr = _pushType == push?@"LT":@"LinkType" ;
    NSString * LinkStr = _pushType == push?@"L":@"Link" ;
    id LT = [dictionary objectForKey:LinkTypeStr];
    BOOL correct = LT && [LT respondsToSelector:@selector(intValue)];
    if (!correct) { //如果推送的消息时不正确的
        return;
    }
    
    int LinkType = [[dictionary objectForKey:LinkTypeStr]intValue];
    switch (LinkType) {
        case 2:     //  网页
        {
            NSString *jumpUrl = [dictionary objectForKey:LinkStr];
            CTDetailVCtler *vc = [CTDetailVCtler new];
            vc.isDismissMVC =  _pushType == push?YES:NO;
            vc.jumpUrl = jumpUrl ;
            if ([self.delegate respondsToSelector:@selector(pushToViewCtler:)]) {
                [self.delegate pushToViewCtler:vc];
            }
            
        }
            break;
        case 1:    // 本地
        {
            NSArray * uiDatas = [self loadUIConfigure];
            
            int Link = [[dictionary objectForKey:LinkStr] intValue];
            static NSDictionary * uiDict = nil;
            [uiDatas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSDictionary class]] &&
                    [obj objectForKey:@"id"] &&
                    [[obj objectForKey:@"id"] respondsToSelector:@selector(intValue)] &&
                    [[obj objectForKey:@"id"] intValue] == Link)
                {
                    uiDict = obj;
                    *stop = YES;
                }
            }];
            
            if (![uiDict objectForKey:@"class"])
            {
                return;
            }
            
            NSString * clsname = [uiDict objectForKey:@"class"];
            NSLog(@"clsname:%@", clsname);
            
            BOOL needlogin = [[uiDict objectForKey:@"needlogin"] boolValue];
            
            NSArray * viewControllers = @[@"CTHomeVCtler",@"CTQueryVCtler",@"CTPreferentialVCtler",@"CTMoreVCtler",@"CTRechargeVCtler"];
            for (int i=0; i<viewControllers.count; i++) {
                if ([clsname isEqualToString:viewControllers[i]])
                {
                    if ([clsname isEqualToString:@"CTRechargeVCtler"])
                    {
                        
                        if (_pushType == push) {
                            self.custabBarController.selectedIndex = i;
                            [self.custabBarController.viewControllers[i] popViewControllerAnimated:YES];
                            return;
                        }
                        
                        CTRechargeVCtler *vc = [[CTRechargeVCtler alloc] init];
                        vc.isPush = YES;
                        NSString *type = [uiDict objectForKey:@"type"];
                        if ([type intValue]==0) {
                            [vc pageIndex:0];
                        }else if([type intValue]==1)
                        {
                            [vc pageIndex:1];
                        }else if([type intValue]==2)
                        {
                            [vc pageIndex:2];
                        }
                        if ([self.delegate respondsToSelector:@selector(pushToViewCtler:)]) {
                            [self.delegate pushToViewCtler:vc];
                        }
                        
                        return ;
                    }
                    
                    self.custabBarController.selectedIndex = i;
                    [self.custabBarController.viewControllers[i] popViewControllerAnimated:YES];
                    return;
                }
            }
            
            if (needlogin) {
                self.jumpDict = dictionary ; //作为下次直接跳转使用
                if (autologin)
                {
                    return;
                }
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                vc.isPush=YES;
                vc.loginDelegate = self;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [self.custabBarController presentViewController:nav animated:YES completion:^(void){
                    //                        self.jumpInfo = dictionary;
                }];
                
                self.Controller4modal=nav;
                return;
            }
            
            if ([clsname length] <= 0)
            {
                return;
            }
            
            Class cls   = NSClassFromString(clsname);
            // 添加靓号判断
            CTBaseViewController *anInstance  = [[cls alloc] init];
            if (anInstance) //CTPrettyNumberVCtler
            {
                if ([anInstance isKindOfClass:[CTPrettyNumberVCtler class]])
                {
                    CTPrettyNumberVCtler *vc =  (CTPrettyNumberVCtler *)anInstance ;
                    NSString *id = [uiDict objectForKey:@"id"];
                    if ([id intValue] == 41) {
                        vc.selectedIndex = 1;
                    }else if([id intValue] == 42)
                    {
                        vc.selectedIndex = 2;
                    }else if([id intValue] == 43)
                    {
                        vc.selectedIndex = 2;
                    }else if([id intValue] == 44)
                    {
                        vc.selectedIndex = 3;
                    }
                }
                
                anInstance.isDismissMVC =  _pushType == push?YES:NO;
                if ([self.delegate respondsToSelector:@selector(pushToViewCtler:)]) {
                    [self.delegate pushToViewCtler:anInstance];
                }
            }
            
            /*
            Class cls   = NSClassFromString(clsname);
            CTBaseViewController *anInstance  = [[cls alloc] init];
            if (anInstance)
            {
                anInstance.isDismissMVC = YES;
                if ([self.delegate respondsToSelector:@selector(pushToViewCtler:)]) {
                    [self.delegate pushToViewCtler:anInstance];
                }
            }

            
            if ([clsname isEqualToString:[NSString stringWithFormat:@"%@", [self class]]])
            {
                return;
            }
            else if ([clsname isEqualToString:@"CTHomeVCtler"])
            {
                self.tabBarController.selectedIndex = 0;
                [self.tabBarController.viewControllers[0] popViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTQueryVCtler"])
            {
                
                // 查询首页
                self.tabBarController.selectedIndex = 1;
                [self.tabBarController.viewControllers[1] popViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTPreferentialVCtler"])
            {
                // 优惠首页
                self.tabBarController.selectedIndex = 3;
                [self.tabBarController.viewControllers[3] popViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTMoreVCtler"])
            {
                // 更多首页
                self.tabBarController.selectedIndex = 4;
                [self.tabBarController.viewControllers[4] popViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTRechargeVCtler"])
            {
                
                // 充话费
                self.tabBarController.selectedIndex = 2;
                [self.tabBarController.viewControllers[2] popViewControllerAnimated:YES];
            }
            else
            {
                if ([Global sharedInstance].isLogin == NO) {
                    self.jumpDict = dictionary ; //作为下次直接跳转使用
                    if (autologin)
                    {
                        return;
                    }
                    CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                    vc.isPush=YES;
                    vc.loginDelegate = self;
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [self.tabBarController presentViewController:nav animated:YES completion:^(void){
                        //                        self.jumpInfo = dictionary;
                    }];
                    
                    self.Controller4modal=nav;
                    return;
                }
                
                if ([clsname length] <= 0)
                {
                    return;
                }
                
                Class cls   = NSClassFromString(clsname);
                CTBaseViewController *anInstance  = [[cls alloc] init];
                if (anInstance)
                {
                    anInstance.isDismissMVC = YES;
                    if ([self.delegate respondsToSelector:@selector(pushToViewCtler:)]) {
                        [self.delegate pushToViewCtler:anInstance];
                    }
                }
            }*/
        }
            break;
            
        case 3://合约机销售品ID
        {
            //跳转到登录页面
            if ([Global sharedInstance].isLogin == NO) {
                self.jumpDict = dictionary ; //作为下次直接跳转使用
                if (autologin)
                {
                    return;
                }
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                vc.isPush = YES;
                vc.loginDelegate = self;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [self.custabBarController presentViewController:nav animated:YES completion:^(void){
                }];
                self.Controller4modal=nav;
                
                return;
            }
            
            [self qrySalesProductCompleteInfo:dictionary pageType:0];
        }
            break;
        case 4://裸机销售品ID
        {
            //跳转到登录页面
            if ([Global sharedInstance].isLogin == NO) {
                self.jumpDict = dictionary ; //作为下次直接跳转使用
                if (autologin)
                {
                    return;
                }
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                vc.isPush = YES;
                vc.loginDelegate = self;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [self.custabBarController presentViewController:nav animated:YES completion:^(void){
                }];
                self.Controller4modal=nav;
                
                return;
            }
            
            [self qrySalesProductCompleteInfo:dictionary pageType:1];
        }
            break;
        case 5://动态参数的URL跳转
        {
            if ([Global sharedInstance].isLogin == NO)
            {
                NSLog(@"ticket 跳转-没登录");
                self.jumpDict = dictionary ; //作为下次直接跳转使用
                if (autologin)               //如果是自动登录
                {
                    NSLog(@"ticket 跳转-自动登录");
                    return;
                }
                
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                vc.isPush = YES;
                vc.loginDelegate = self;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [self.custabBarController presentViewController:nav animated:YES completion:^(void){
                }];
                
                self.Controller4modal=nav;
                return;
            }
            
            __weak typeof(self) wself = self;
            [self custIdInfo:^()
             {
                 NSString *ticket=[Global sharedInstance].ticket;
                 NSString *PhoneNbr = [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] ? [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] : @"";
                 NSString *uid=[[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"];
                 
                 NSString *link = [dictionary objectForKey:LinkStr];
                 NSString *jumpUrl=[link stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//把转义字符换为utf8编码
                 jumpUrl=[jumpUrl stringByReplacingOccurrencesOfString:@"$ticket$" withString:ticket];
                 jumpUrl=[jumpUrl stringByReplacingOccurrencesOfString:@"$phonenumber$" withString:PhoneNbr];
                 jumpUrl=[jumpUrl stringByReplacingOccurrencesOfString:@"$userid$" withString:uid];
                 
                 CTDetailVCtler *vc = [CTDetailVCtler new];
                 vc.isDismissMVC =  _pushType == push?YES:NO;
                 vc.jumpUrl = jumpUrl ;
                 
                 if ([wself.delegate respondsToSelector:@selector(pushToViewCtler:)]) {
                     [wself.delegate pushToViewCtler:vc];
                 }
             }
            failureBlock:^(){
                
              }];
        }
            break;
        case 6: //  百搭销售品ID
        {
            //请求数据
            NSString *Id = [dictionary objectForKey:LinkStr];
            CTSelectPhoneVCtler *vc = [[CTSelectPhoneVCtler alloc] init];
            vc.isDismissMVC =  _pushType == push?YES:NO;
            vc.salesId = Id;
            if ([self.delegate respondsToSelector:@selector(pushToViewCtler:)]) {
                [self.delegate pushToViewCtler:vc];
            }
        }
            break;
    }
}


#pragma mark - custIdInfo

- (void)custIdInfo:(SuccessGenerationSingle)sucess failureBlock:(FailureGenerationSingle)failure
{
    if ([Global sharedInstance].custInfoDict) {
        [self generationSingleWithSuccessBlock:sucess failureBlock:failure];
    } else{
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [Global sharedInstance].loginInfoDict[@"UserLoginName"], @"Account",
                                @"201", @"AccountType",
                                BUSSINESS_SHOPID, @"ShopId", nil];
        __weak typeof(self) wself = self;
        [MyAppDelegate.cserviceEngine postXMLWithCode:@"custIdInfo"
                                               params:params
                                          onSucceeded:^(NSDictionary *dict) {
                                              [Global sharedInstance].custInfoDict = dict[@"Data"];
                                              [wself generationSingleWithSuccessBlock:sucess failureBlock:failure];
                                          } onError:^(NSError *engineError) {
                                              if (engineError.userInfo[@"ResultCode"])
                                              {
                                                  if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"X104"])
                                                  {
                                                      // 取消掉全部请求和回调，避免出现多个弹框
                                                      [MyAppDelegate.cserviceEngine cancelAllOperations];
                                                      // 提示重新登录
                                                      SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                                       andMessage:@"长时间未登录，请重新登录。"];
                                                      [alertView addButtonWithTitle:@"确定"
                                                                               type:SIAlertViewButtonTypeDefault
                                                                            handler:^(SIAlertView *alertView) {
                                                                                [MyAppDelegate showReloginVC];
                                                                            }];
                                                      alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                      [alertView show];
                                                  }
                                              }
                                          }];
    }
}

- (void)generationSingleWithSuccessBlock:(SuccessGenerationSingle)sucess failureBlock:(FailureGenerationSingle)failure
{
    NSString *userId=[[[Global sharedInstance] custInfoDict]objectForKey:@"UserId"];
    if (userId==nil) {
        return;
    }
    
    NSDictionary *params = @{@"UserId": userId,
                             @"TargetUrl": @"0"};
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"generationSingle"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          if (dict[@"Data"][@"Ticket"])
                                          {
                                              NSLog(@"%s",__func__);
                                              [Global sharedInstance].ticket = dict[@"Data"][@"Ticket"];
                                              //                                              [self olServiceConfig];
                                              /**
                                               @Author                gongxt
                                               @Description           ticket设置成功后发送消息，用于重新跳转
                                               */
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kDynamicRedirect object:nil];
                                              //                                              [self autoJumpPage4Type5];
                                              if (sucess) {
                                                  sucess();
                                              }
                                              
                                          }
                                          
                                      } onError:^(NSError *engineError) {
                                          
                                          DDLogError(@"生成单点Ticket失败！");
                                          if (failure) {
                                              failure();
                                          }
                                          
                                      }];
}

- (void) qrySalesProductCompleteInfo : (NSDictionary *) dictionary pageType : (int) type
{
    dictionary=@{@"Link":dictionary[@"L"]};
    CTPhoneInfoVCtler *vc = [CTPhoneInfoVCtler new];
    vc.isDismissMVC =  _pushType == push?YES:NO;
    [vc setPhoneInfo:dictionary :type];
    
    if ([self.delegate respondsToSelector:@selector(pushToViewCtler:)]) {
        [self.delegate pushToViewCtler:vc];
    }
}

- (NSArray *)loadUIConfigure
{
    static NSArray *__uiConfiguredata = nil; // only load the data array once
    if (__uiConfiguredata == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"UIConfigure" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:path];
		NSPropertyListFormat format;
		NSError * error;
		__uiConfiguredata = [NSPropertyListSerialization propertyListWithData:plistData
                                                                      options:NSPropertyListImmutable
                                                                       format:&format
                                                                        error:&error];
        if (!__uiConfiguredata)
        {
            NSLog(@"Failed to read uiconfige data. ");
        }
    }
    return __uiConfiguredata;
}

@end
