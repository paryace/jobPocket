//
//  CTLoginLoadingVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-11-12.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTLoginLoadingVCtler.h"
#import "AppDelegate.h"
#import "Utils.h"

@interface CTLoginLoadingVCtler ()

@end

@implementation CTLoginLoadingVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization 
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:INITIAL_AUTO_LOGIN];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loginEvtMeasure];
    //统计插码
//    [TrackingHelper trackPageLoadedState:NSStringFromClass([self class])];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [Utils getDocumentPath], @"loadingImage.png"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath])
    {
        // 显示网络下载的图片
        UIImageView *loadingImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        loadingImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        loadingImageView.image = [UIImage imageWithContentsOfFile:filePath];
        [self.view addSubview:loadingImageView];
    }
    else
    {
        // 显示默认图片
        if (iPhone5)
        {
            UIImageView *loadingImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
            loadingImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            loadingImage.image = [UIImage imageNamed:@"Default-568h"];
            [self.view addSubview:loadingImage];
        }
        else
        {
            UIImageView *loadingImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
            loadingImage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            loadingImage.image = [UIImage imageNamed:@"Default"];
            [self.view addSubview:loadingImage];
        }
    } 
    // 登录
    {
        NSString *DeviceToken = @"";
        NSUserDefaults *df  = [NSUserDefaults standardUserDefaults];
        if ([df objectForKey:@"devicetoken"])
        {
            DeviceToken = [df objectForKey:@"devicetoken"];
        }
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [Utils getPhone], @"PhoneNbr",
                                [Utils getPwd], @"PhonePsw",
                                @"01", @"PswType",
                                @"c2000004", @"AccountType",
                                DeviceToken, @"DeviceToken", nil];
        
        [MyAppDelegate.cserviceEngine postXMLWithCode:@"loginInfo"
                                               params:params
                                          onSucceeded:^(NSDictionary *dict) {
                                              
                                              DDLogInfo(@"自动登录成功！跳转到TabBar");
                                              [Global sharedInstance].loginInfoDict = @{@"UserLoginName": [Utils getPhone],
                                                                                        @"Token": dict[@"Data"][@"Token"]};
                                              [Global sharedInstance].isLogin = YES;
                                              [MyAppDelegate custIdInfo];
                                              [MyAppDelegate showTabBarCtler];
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"autoJumpPage" object:nil];
                                          } onError:^(NSError *engineError) {
                                              
                                              DDLogInfo(@"自动登录失败！依旧跳转到TabBar");
                                              [MyAppDelegate showTabBarCtler];
                                          }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginEvtMeasure
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // 跟踪登录相关事件
    NSMutableDictionary *evtDic = [[NSMutableDictionary alloc] init];
    [evtDic setObject:app_Version forKey:@"12"];
//    [TrackingHelper trackPage:NSStringFromClass([self class]) events:evtDic];
}

@end
