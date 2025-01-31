//
//  AppDelegate.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "CTLoginLoadingVCtler.h"
#import "CTLoginVCtler.h"
#import "CTHomeVCtler.h"
#import "CTQueryVCtler.h"
#import "CTRechargeVCtler.h"
#import "CTPreferentialVCtler.h"
#import "CTMoreVCtler.h"
#import "Utils.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"
#import "CTPMsgCenterDetailVCtler.h"
#import "CTQryCollected.h"
#import "ABAddressBookCache.h"
#import "ABAddressBookRoller.h"
#import "CTDetailVCtler.h"
#import "CTSelectPhoneVCtler.h"
#import "CTPhoneInfoVCtler.h"
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "YXApi.h"
#import "WXApi.h"
#import "WeiboApi.h"
#import <RennSDK/RennSDK.h>
#import "WeiboSDK.h"
#import "CTHelperMap.h"
#import "CustomizeSliderController.h"
#import <Crashlytics/Crashlytics.h>
#import "RightRootVCtler.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "CTJumpWithMsg.h"

//added by wensj 20140303 用来通知各界面刷新显示的消息
NSString * const ESRefreshItemsNotification = @"RefreshItems";

@interface AppDelegate() <jumpPageDelegate>

@property (nonatomic, assign) UIBackgroundTaskIdentifier  backgroundTask;   // added by zy, 2014-04-03
@property (nonatomic, strong) CserviceOperation * olServiceConfigOpt;
@property (nonatomic, strong) CTJumpWithMsg * pushObj;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Crashlytics startWithAPIKey:@"88109354e16911274ce88458bf23282b45fe3101"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autoJumpPage)
                                                 name:@"autoJumpPage"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification) name:DEAL_WITH_NOTIFICATION object:nil];
    // RemoteNotification
    {
        // 注册通知
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        
        // 处理点击通知启动事件
        if (launchOptions!=nil && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]!=nil)
        {
            //通知的消息
            self.notificationInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        }
       
    }

    [self initializePlat]; // 初始化分享key
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // 从旧版本覆盖安装，第一次启动清掉旧的NSUserDefaults内容并写入标志位
    {
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        if ([standardDefaults objectForKey:@"Not1stTimeLaunch"] == nil)
        {
            // 不存在标志位，清掉旧数据，写入标志位
            [standardDefaults removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
            [standardDefaults setObject:@"YES" forKey:@"Not1stTimeLaunch"];
            
            //add by liuruxian 2014-03-02
            //清空靓号 收藏号码数据
            [[CTQryCollected shareQryCollected] clearFileData];
            [standardDefaults setObject:@"NO" forKey:@"DIRECTED"];
            
            [standardDefaults synchronize];
        }
    }
    
    // setup lumberjack logging framework
    {
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:fileLogger];
    }
    
    // Setup RESTfulEngine
    {
        // 大部分接口
#if isDeBug
        self.cserviceEngine = [[CserviceEngine alloc] initWithHostName:SERVICE_XML_Service_Debug];
        self.cserviceEngine2 = [[CserviceEngine2 alloc] initWithHostName:SERVICE_XML_Service2_Debug];
#else
        self.cserviceEngine = [[CserviceEngine alloc] initWithHostName:SERVICE_XML_Service_Releace];
        self.cserviceEngine2 = [[CserviceEngine2 alloc] initWithHostName:SERVICE_XML_Service2_Releace];
#endif
        
        // 号百接口, modiefied by zy, 2013-11-15, 公司网络封了6060端口
        self.bestToneEngine = [[BestToneEngine alloc] initWithHostName:SERVICE_BestTone];
        
        // 反馈接口
        self.feedbackEngine = [[FeedbackEngine alloc] initWithHostName:SERVICE_Feedback];
        
        // App Store
        self.appStoreEngine = [[AppStoreEngine alloc] initWithHostName:SERVICE_AppStore];
    }
    
    {
        // 首页刷新机制
        [Global sharedInstance].reloadHomeTime = [NSDate date];
    }
    
    {
        [Global sharedInstance].isLogin = NO;
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        if ([settings objectForKey:@"AutoLogin"] && [[settings objectForKey:@"AutoLogin"] isEqualToString:@"YES"])
        {
            [self showLoadingVCtler];
        }
        else
        {
            [self showTabBarCtler];
        }
    }
    
    [self homePageUrl];
    
    
    /*
     版本更新 初始化为NO 同时查看appstore app版本
     */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"NO" forKey:@"updataVersion"]; 
    [defaults synchronize];
    
    
//     统计埋点初始化  added by liuruxian 2014-05-03
//     [TrackingHelper configureAppMeasurement];

    
    //added by wensj 20130303 1800.0f
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1800.0f target:self selector:@selector(periodicallyRefreshData:) userInfo:nil repeats:YES];
    
    //added by wensj 20130303
    [Global sharedInstance].latestLoadTime = [NSDate date];
    
    self.window.backgroundColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)periodicallyRefreshData:(NSTimer *)timer
{
    NSNotification *notificationFormCenter = [NSNotification notificationWithName:ESRefreshItemsNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notificationFormCenter];
    
    // add by liuruxian 2014-05-05 添加定时刷新业务办理
    [self olServiceConfig];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //发送通知更新优惠
    
    //added by wensj 20140303 刷新数据
    NSTimeInterval refreshInterval = -1*[[Global sharedInstance].latestLoadTime timeIntervalSinceNow];
    if (refreshInterval>1800) {
        [Global sharedInstance].latestLoadTime = [NSDate date];
        
        //从后台激活后，要时间间隔超过一定值才会刷新
        NSNotification *notificationFormCenter = [NSNotification notificationWithName:ESRefreshItemsNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notificationFormCenter];
    }
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];    // added by zy, 2014-04-02
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
 // add by liuruxian 2014-06-18
- (CTJumpWithMsg *)pushObj
{
    if (_pushObj==nil) {
        _pushObj = [[CTJumpWithMsg alloc] init:self.tabBarController type:push];
        _pushObj.delegate = self;
    }
    
    return _pushObj ;
}

// add by liuruxian 2014-06-18
#pragma mark - ctjumpWithMsg delegate
- (void)pushToViewCtler:(UIViewController *)vc
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [[self controller4Present] presentViewController:nav animated:YES completion:nil];
}

#pragma mark - self func
#pragma mark 这个方法是为了初始化tab bar后才处理来自推送的跳转
-(void)processNotification
{
    self.Controller4modal=nil;
    if (self.notificationInfo)
    {
         // add by liuruxian 2014-06-18
        [self.pushObj jumpPage:self.notificationInfo];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//        [self dealWithRemoteNotification:self.notificationInfo];
        self.notificationInfo=nil;
    }
}

- (void)showLoadingVCtler
{
    CTLoginLoadingVCtler *loginLoadingVCtler = [[CTLoginLoadingVCtler alloc] init];
    self.window.rootViewController = loginLoadingVCtler;
}

- (void)showTabBarCtler
{
    RightRootVCtler *rootVCtler=[[RightRootVCtler alloc] init]; 
    self.window.rootViewController = rootVCtler;
}

- (void)custIdInfo
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [Global sharedInstance].loginInfoDict[@"UserLoginName"], @"Account",
                            @"201", @"AccountType",
                            BUSSINESS_SHOPID, @"ShopId", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"custIdInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          [Global sharedInstance].custInfoDict = dict[@"Data"];
                                          [self olServiceConfig];
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

- (void)homePageUrl
{
    //需要判断四种尺寸的图片大小
    NSString *width = @"640";
    int imgh = 960;
    if (iPhone5)
    {
        imgh = 1136;
    }
    
    if(!isIOS7)
        imgh -= 40;
    
    NSString *height = [NSString stringWithFormat:@"%d",imgh];
    
    NSDictionary *params = @{@"ShopId": BUSSINESS_SHOPID,
                             @"Width": width,
                             @"Height": height};
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"homePageUrl"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          if (dict[@"Data"][@"ServiceVersion"] && dict[@"Data"][@"ImageVersion"] && dict[@"Data"][@"Url"])
                                          {
                                              NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
                                              NSString *serviceVersion = [settings objectForKey:@"ServiceVersion"];
                                              NSString *imageVersion = [settings objectForKey:@"ImageVersion"];
                                              if ((serviceVersion == nil) ||
                                                  (imageVersion == nil) ||
                                                  (serviceVersion!=nil && ![serviceVersion isEqualToString:dict[@"Data"][@"ServiceVersion"]]) ||
                                                  (imageVersion!=nil && ![imageVersion isEqualToString:dict[@"Data"][@"ImageVersion"]]))
                                              {
                                                  // 需要下载新图片
                                                  [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:dict[@"Data"][@"Url"]]
                                                                                                      options:0
                                                                                                     progress:^(NSUInteger receivedSize, long long expectedSize)
                                                   {
                                                       // progression tracking code
                                                   }
                                                                                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
                                                   {
                                                       if (image && finished)
                                                       {
                                                           // do something with image
                                                           NSString *filePath = [NSString stringWithFormat:@"%@/%@", [Utils getDocumentPath], @"loadingImage.png"];
                                                           // create image path
                                                           NSFileManager *fm = [NSFileManager defaultManager];
                                                           NSError *errorPtr;
                                                           if ([fm fileExistsAtPath:filePath])
                                                           {
                                                               [fm removeItemAtPath:filePath error:&errorPtr];
                                                           }
                                                           // save image
                                                           NSData *imageData = UIImagePNGRepresentation(image);
                                                           BOOL success = [imageData writeToFile:filePath atomically:YES];
                                                           if (success)
                                                           {
                                                               NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
                                                               [settings setObject:dict[@"Data"][@"ServiceVersion"] forKey:@"ServiceVersion"];
                                                               [settings setObject:dict[@"Data"][@"ImageVersion"] forKey:@"ImageVersion"];
                                                               [settings synchronize];
                                                           }
                                                       }
                                                   }];
                                              }
                                          }
                                          
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

- (void)showReloginVC
{
    [self.cserviceEngine cancelAllOperations];
    [SVProgressHUD dismiss];
    
    CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
    }];
}

#pragma mark - handle RemoteNotification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 保存获取到的Token
    DDLogInfo(@"deviceToken: %@", deviceToken);
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    DDLogInfo(@"token: %@", token);
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"devicetoken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 推送接收 应用打开得前提下
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([userInfo isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    DDLogInfo(@"%@", userInfo);
    if (UIApplicationStateActive==[application applicationState])
    {
        NSString *alert=@"收到新的推送消息，是否查看?";
        NSDictionary *aps=userInfo[@"aps"];
        if (aps) {
            NSString *temp=aps[@"alert"];
            alert=temp?temp:@"收到新的推送消息，是否查看?";
        }
        __weak typeof(self) wself = self;
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:alert];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeDefault
                              handler:nil];
        [alertView addButtonWithTitle:@"查看"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert)
         {
//             [wself dealWithRemoteNotification:userInfo];
                 [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
             // add by liuruxian 2014-06-18
             [self.pushObj jumpPage:userInfo];
         }
         ];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
    else
    {
//        [self dealWithRemoteNotification:userInfo];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        // add by liuruxian 2014-06-18
        [self.pushObj jumpPage:userInfo];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DDLogError(@"%s %@", __func__, error.description);
}

- (void) autoJumpPage
{
    if(self.jumpDict)
    {
        [self jumpPage:self.jumpDict];
        self.jumpDict = nil;
    }
}

-(void)autoJumpPage4Type5
{
    if(self.jumpDict4Type5)
    {
        [self jumpPage:self.jumpDict4Type5];
        self.jumpDict4Type5 = nil;
    }
}
#pragma mark self method for notifitication
#pragma mark 用最顶层的viewcontroller来present
/*
用最顶层的viewcontroller来present,当tabBarController已经用present方式弹出一个viewcontroller时，再用tabBarController弹出viewcontroller是无效的，所以需要记录已经弹出的viewcontroller，用这个viewcontroller来present出新的viewcontroller，这种情况发生在同时接受到多个推送
 */
-(UIViewController*)controller4Present
{
    if (self.Controller4modal)
    {
        return self.Controller4modal;
    }
    else
    {
        return self.tabBarController;
    }
}

- (void)dealWithRemoteNotification:(NSDictionary *)userInfo
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self jumpPage:userInfo];
    
}
-(void)showPushView:(UIViewController*)paran Push:(UIViewController*)v
{
    [paran presentViewController:v animated:YES completion:nil];
}

- (void) jumpPage : (NSDictionary *) dictionary
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults]; 
    BOOL  initialAutoLogin=[settings boolForKey:INITIAL_AUTO_LOGIN]; 
    //如果是自动登录，不允许弹出登录界面
    BOOL autologin=[settings objectForKey:@"AutoLogin"] && [[settings objectForKey:@"AutoLogin"] isEqualToString:@"YES"]&&initialAutoLogin;
    [settings setBool:NO forKey:INITIAL_AUTO_LOGIN];
    [settings synchronize];
  
    if (!dictionary && ![dictionary respondsToSelector:@selector(objectForKey:)]) {
        return;
    }
    id LT = [dictionary objectForKey:@"LT"];
    BOOL correct=LT && [LT respondsToSelector:@selector(intValue)];
    if (!correct) {//如果推送的消息时不正确的
        return;
    }
    
    int LinkType = [[dictionary objectForKey:@"LT"]intValue];
    
    switch (LinkType) {
        case 2:     //  网页
        {
            NSString *jumpUrl = [dictionary objectForKey:@"L"];
            CTDetailVCtler *vc = [CTDetailVCtler new];
            vc.isDismissMVC = YES;
            vc.jumpUrl = jumpUrl ;
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [[self controller4Present] presentViewController:nav animated:YES completion:nil];
            self.Controller4modal=nav;//最顶层的present controller
        }
            break;
            
        case 1:    // 本地
        {
            
            NSArray * uiDatas = [self loadUIConfigure];
            
            int Link = [[dictionary objectForKey:@"L"] intValue];
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
            NSLog(@"%@", clsname);
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
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [[self controller4Present] presentViewController:nav animated:YES completion:^(void){
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
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:anInstance];
                    [[self controller4Present] presentViewController:nav animated:YES completion:nil];
                    self.Controller4modal=nav;
                }
            }
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
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [[self controller4Present] presentViewController:nav animated:YES completion:^(void){
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
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [[self controller4Present] presentViewController:nav animated:YES completion:^(void){
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
                if (autologin)//如果是自动登录
                {
                    NSLog(@"ticket 跳转-自动登录");
                    return;
                }
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                vc.isPush = YES;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [[self controller4Present] presentViewController:nav animated:YES completion:^(void){
                }];
                self.Controller4modal=nav;
                return;
            }

            __weak typeof(self) wself = self;
            [self generationSingleWithSuccessBlock:^()
             {
                 
                 NSString *ticket=[Global sharedInstance].ticket;
                 NSString *PhoneNbr = [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] ? [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] : @"";
                 NSString *uid=[[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"];
                 
                 NSString *link = [dictionary objectForKey:@"L"];
                 NSString *jumpUrl=[link stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//把转义字符换为utf8编码
                 jumpUrl=[jumpUrl stringByReplacingOccurrencesOfString:@"$ticket$" withString:ticket];
                 jumpUrl=[jumpUrl stringByReplacingOccurrencesOfString:@"$phonenumber$" withString:PhoneNbr];
                 jumpUrl=[jumpUrl stringByReplacingOccurrencesOfString:@"$userid$" withString:uid];
                 
                 CTDetailVCtler *vc = [CTDetailVCtler new];
                 vc.isDismissMVC = YES;
                 vc.jumpUrl = jumpUrl ;
                 
                 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                 [[wself controller4Present] presentViewController:nav animated:YES completion:nil];
                 wself.Controller4modal=nav;
             }
                                               failureBlock:^(){
                                               }];
            /**
             http://202.102.111.141/ztWxCz/servlet/ComplaintServlet?type=groupBuinessType&ztInterSource=100005&ticket=$ticket$&pnm=$phonenumber$&uid=$userid$
             &ticket=$ticket$&pnm=$phonenumber$&uid=$userid$
             */
          
            
        }
            break;
        case 6: //  百搭销售品ID
        {
            //请求数据
            NSString *Id = [dictionary objectForKey:@"L"];
            CTSelectPhoneVCtler *selectPhoneVCtler = [[CTSelectPhoneVCtler alloc] init];
            selectPhoneVCtler.isDismissMVC = YES;
            selectPhoneVCtler.salesId = Id;
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:selectPhoneVCtler];
            [[self controller4Present] presentViewController:nav animated:YES completion:nil];
            self.Controller4modal=nav;
            
        }
            break;
    }
}

#pragma mark 推送打开查找合约机或裸机界面
- (void) qrySalesProductCompleteInfo : (NSDictionary *) dictionary pageType : (int) type
{
    dictionary=@{@"Link":dictionary[@"L"]};
    CTPhoneInfoVCtler *vc = [CTPhoneInfoVCtler new];
    vc.isDismissMVC = YES;
    [vc setPhoneInfo:dictionary :type];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [[self controller4Present] presentViewController:nav animated:YES completion:nil];
    self.Controller4modal=nav;
}

#pragma mark - 读取文件数据
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

#pragma mark - 单点事件
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
                                              /**
                                               @Author                gongxt
                                               @Description           ticket设置成功后发送消息，用于重新跳转
                                               */
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

- (void)olServiceConfig
{
    DDLogInfo(@"请求网上办理业务!");
    if (![Global sharedInstance].isLogin) {
        return;
    }
    if (self.olServiceConfigOpt) {
        [self.olServiceConfigOpt cancel];
    }
    
    
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *PhoneNumber = loginInfoDict[@"UserLoginName"];
    
    NSString * shopId = BUSSINESS_SHOPID ; //生产BUSSINESS_SHOPID,测试BUSSINESS_SHOPID_TEST
    NSDictionary *params = @{@"PhoneNumber": PhoneNumber,
                             @"ShopId":shopId };//BUSSINESS_SHOPID
    self.olServiceConfigOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"olServiceConfig"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict)
    {
        //格式化数据(将指定的数据格式化成数组)
        dict = [Utils objFormatArray:dict path:@"Data/Configs/Item"];
        
          if (dict[@"Data"][@"Configs"])
          {
              if (dict[@"Data"][@"Configs"] &&
                       [dict[@"Data"][@"Configs"][@"Item"] isKindOfClass:[NSArray class]])
              {
                  [Global sharedInstance].configArray = [NSArray arrayWithArray:dict[@"Data"][@"Configs"][@"Item"]];
                  [Global sharedInstance].isShowBusiProc = YES;
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"刷新Tableview" object:nil];
              }
              else
              {
                  [Global sharedInstance].isShowBusiProc = NO;
                  [Global sharedInstance].configArray = nil;
              }
          }
          else
          {
              [Global sharedInstance].isShowBusiProc = NO;
              [Global sharedInstance].configArray = nil;
          }
          
      } onError:^(NSError *engineError) {
          
          DDLogError(@"在线业务办理配置获取失败！");
          [Global sharedInstance].isShowBusiProc = NO;
          [Global sharedInstance].configArray = nil;
          
      }];
}


- (void)initializePlat
{
    /**
     注册SDK应用，此应用请到http://www.sharesdk.cn中进行注册申请。
     此方法必须在启动时调用，否则会限制SDK的使用。
     **/
    [ShareSDK registerApp:@"186c5b350dca"];
    
    /**
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectSinaWeiboWithAppKey:@"114865177"
                               appSecret:@"96382552321d7ce7af5de09683399ccf"
                             redirectUri:@"http://www.189.cn/"
                             weiboSDKCls:[WeiboSDK class]];
    
    /**
     连接腾讯微博开放平台应用以使用相关功能，此应用需要引用TencentWeiboConnection.framework
     http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
     **/
    [ShareSDK connectTencentWeiboWithAppKey:@"801496579"
                                  appSecret:@"7202c658eb5a46edfdebb7b241784cda"
                                redirectUri:@"http://www.189.cn/"
                                   wbApiCls:[WeiboApi class]];
    
    /**
     连接人人网应用以使用相关功能，此应用需要引用RenRenConnection.framework
     http://dev.renren.com上注册人人网开放平台应用，并将相关信息填写到以下字段
     **/
    
    [ShareSDK connectRenRenWithAppId:@"266717"
                              appKey:@"7ffdea6deed741e98a85b3eb5b8b5897"
                           appSecret:@"9a59142082314fd1bce45314db169f64"
                   renrenClientClass:[RennClient class]];
    
    
    //连接短信分享
    [ShareSDK connectSMS];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    //    if ([WXApi isWXAppInstalled]) {
    //
    //        [ShareSDK connectWeChatWithAppId:@"wx9255d11e86fa74b9" wechatCls:[WXApi class]];
    //    }
    if ([WXApi isWXAppSupportApi]) {
        [ShareSDK connectWeChatWithAppId:@"wx9255d11e86fa74b9" wechatCls:[WXApi class]];
    }
    //    NSURL *wxurl = [NSURL URLWithString:@"wx9255d11e86fa74b9://"];
    //    if ([[UIApplication sharedApplication] canOpenURL:wxurl])
    //    {
    //        [ShareSDK connectWeChatWithAppId:@"wx9255d11e86fa74b9" wechatCls:[WXApi class]];
    //    }
    
    
    /**
     连接易信应用以使用相关功能，此应用需要引用YiXinConnection.framework
     http://open.yixin.im/上注册易信开放平台应用，并将相关信息填写到以下字段
     **/
    if ([YXApi isYXAppInstalled]) {
        
        [ShareSDK connectYiXinWithAppId:@"yx9f450b1029e84bc7a3d452abc112cb5b"
                               yixinCls:[YXApi class]];
    }
    
    
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
     http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    //旧版中申请的AppId（如：QQxxxxxx类型），可以通过下面方法进行初始化
    //    [ShareSDK connectQQWithAppId:@"QQ075BCD15" qqApiCls:[QQApi class]];
    
    if ([QQApi isQQInstalled]) {
        
        [ShareSDK connectQQWithQZoneAppKey:@"101057685"
                         qqApiInterfaceCls:[QQApiInterface class]
                           tencentOAuthCls:[TencentOAuth class]];
        [ShareSDK connectQZoneWithAppKey:@"101057685"
                               appSecret:@"150af2b6c4ac5c6f4bf420e839003858"
                       qqApiInterfaceCls:[QQApiInterface class]
                         tencentOAuthCls:[TencentOAuth class]];
    }
    /**
     连接QQ空间应用以使用相关功能，此应用需要引用QZoneConnection.framework
     http://connect.qq.com/intro/login/上申请加入QQ登录，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入TencentOpenAPI.framework,并引入QQApiInterface.h和TencentOAuth.h，将QQApiInterface和TencentOAuth的类型传入接口
     **/
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{

    //支付宝回调
    if ([[url scheme] isEqualToString:kZFBQBURLScheme]) {
        [self parse:url application:application];
        return YES;
        
    }
    
    //sharesdk回调
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    //支付宝回调
    if ([[url scheme] isEqualToString:kZFBQBURLScheme]) {
        [self parse:url application:application];
        return YES;
        
    }
    
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}
//added by huangfq 2014-5-28
#pragma mark - 支付宝回调


- (void)parse:(NSURL *)url application:(UIApplication *)application {
    
    //结果处理
    AlixPayResult* result = [self handleOpenURL:url];
    
	if (result)
    {
		
		if (result.statusCode == 9000)
        {
            
            NSLog(@"支付成功AppDelegate");
            
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CTZFBOnPaySucessed];
            [[NSNotificationCenter defaultCenter] postNotificationName:CTZFBOnPaySucessed object:self userInfo:dict];
            
			/*
			 *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			 */
            
            //            交易成功
//            NSString* key = @"签约帐户后获取到的支付宝公钥";
//            id<DataVerifier> verifier;
//            verifier = CreateRSADataVerifier(key);
//
//            if ([verifier verifyString:result.resultString withSign:result.signString])
//            {
//                //验证签名成功，交易结果无篡改
//                
//                
//            }
            
        }
        else
        {
            //交易失败
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CTZFBOnPaySucessed];
            [[NSNotificationCenter defaultCenter] postNotificationName:CTZFBOnPaySucessed object:nil userInfo:dict];
        }
    }
    else
    {
        //失败
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CTZFBOnPaySucessed];
        [[NSNotificationCenter defaultCenter] postNotificationName:CTZFBOnPaySucessed object:nil userInfo:dict];
    }
    
}

- (AlixPayResult *)resultFromURL:(NSURL *)url {

	NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#if ! __has_feature(objc_arc)
    return [[[AlixPayResult alloc] initWithString:query] autorelease];
#else
	return [[AlixPayResult alloc] initWithString:query];
#endif
}

- (AlixPayResult *)handleOpenURL:(NSURL *)url {

	AlixPayResult * result = nil;
	
	if (url != nil && [[url host] compare:@"safepay"] == 0) {
		result = [self resultFromURL:url];
	}
    
	return result;
}

@end
