//
//  CTPreferentialVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTPreferentialVCtler.h"
#import "CTPRcScrollview.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "CTDetailVCtler.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "CTContractPhoneVCtler.h"
#import "CTLoginVCtler.h"
#import "CTBarePhoneVCtler.h"
#import "CTPhoneInfoVCtler.h"
#import "CTMessageCenterVCtler.h"
#import "CTRechargeVCtler.h"
#import "ToastAlertView.h"
#import "SVProgressHUD.h"
#import "CTPrettyNumberVCtler.h"
#import "CTShakeNumberVCtler.h"
#import "CTHelperMap.h"
#import "CTQryCity.h"
#import "CTPhoneListViewController.h"
#import "COrderWildProductFillVctrler.h"

#import "CTNumberSelectedVCtler.h"
#import "CTSelectPhoneVCtler.h"
extern NSString * const ESRefreshItemsNotification;

#define kBtnTag 1000

@interface CTPreferentialVCtler ()<CTPRcScrollViewDatasource,CTPRcScrollViewDelegate>

@property (nonatomic, strong) CTPRcScrollview *adView;
@property (nonatomic, strong) NSMutableArray *adList;
@property (nonatomic, strong) NSMutableArray *phoneInfoList;

@property (nonatomic, strong) UIButton *phoneFirBtn;
@property (nonatomic, strong) UIButton *phoneSecBtn;
@property (nonatomic, strong) UIButton *phoneThrBtn;
@property (nonatomic, strong) UIButton *phoneForBtn;

@property (nonatomic, strong) UIButton *phoneFitBtn;
@property (nonatomic, strong) UIButton *phoneSixBtn;
@property (nonatomic, strong) UIButton *phoneSevBtn;
@property (nonatomic, strong) UIButton *phoneEigBtn;

@property (nonatomic, strong) NSDictionary *jumpDict;
@property (nonatomic, strong) NSDictionary *areaInfoDict;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *directedImageView;

@end

@implementation CTPreferentialVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"优惠";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(autoJumpPage)
                                                     name:@"autoJumpPage"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    DDLogInfo(@"%s", __func__);
//    if (self.adView) {
//        [self.adView stopTimer];
//    }
//    self.adView.datasource = nil;
//    self.adView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // added by zy, 2014-04-23
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  
    
    [self.view setBackgroundColor:PAGEVIEW_BG_COLOR];
    
    self.adList = [NSMutableArray new];
    self.phoneInfoList = [NSMutableArray new];
    
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scroll.backgroundColor = [UIColor clearColor];
    scroll.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    [self.view addSubview:scroll];
    self.scrollView = scroll ;
    float yPos = 0;
    // 广告栏
    {
        CGFloat adViewHeight = 160.0f;
        if (iPhone5) {
            adViewHeight = 160.0f;
        }
        self.adView = [[CTPRcScrollview alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, adViewHeight)];
        self.adView.delegate = self;
        self.adView.datasource = self;
        [scroll addSubview:self.adView];

        yPos = CGRectGetMaxY(self.adView.frame) + 1;
    }
    //点击查看更多 跳转到消息中心的公告
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, yPos, self.view.frame.size.width, 40)];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.userInteractionEnabled = YES;
        [scroll addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(77, 0,145, imageView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"点击查看更多优惠活动";
        label.textColor = [UIColor colorWithRed:50/255. green:205/255. blue:47/255. alpha:1];
        label.textAlignment = UITextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        [imageView addSubview:label] ;
        
        UIImage *image = [UIImage imageNamed:@"preference_green_arrow.png"];
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label.frame)+6, (imageView.frame.size.height - image.size.height)/2, image.size.width, image.size.height)];
        arrow.backgroundColor = [UIColor clearColor];
        arrow.image = image;
        [imageView addSubview:arrow] ;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, yPos, self.view.frame.size.width, 40);
        [btn addTarget:self action:@selector(morPrefernceAction) forControlEvents:UIControlEventTouchUpInside];
        [scroll addSubview:btn];
        
        yPos = CGRectGetMaxY(imageView.frame) + 5;
    }
    //图片区 444
    {
        UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectMake(0, yPos, scroll.frame.size.width, 444)];
        picView.backgroundColor = [UIColor whiteColor];
        picView.userInteractionEnabled = YES ;
        [scroll addSubview:picView];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 100, 33)];
        label1.backgroundColor = [UIColor clearColor];
        label1.text = @"精品手机";
        label1.textAlignment = UITextAlignmentLeft ;
        label1.textColor = [UIColor blackColor];
        label1.font = [UIFont systemFontOfSize:14];
        [picView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(240, 0, 60 ,33)];
        label2.backgroundColor = [UIColor clearColor];
        label2.text = @"查看更多";
        label2.textAlignment = UITextAlignmentLeft ;
        label2.textColor = [UIColor colorWithRed:175/255. green:175/255. blue:174/255. alpha:1];
        label2.font = [UIFont systemFontOfSize:14];
        [picView addSubview:label2];
        
        UIImage *image = [UIImage imageNamed:@"preference_gray_arrow.png"];
        UIImageView *check = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label2.frame)+5, (33-image.size.height)/2, image.size.width, image.size.height)];
        check.backgroundColor = [UIColor clearColor];
        check.image = image ;
        [picView addSubview:check];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(240, 0,120, 33);
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(checkMoreInfoAction) forControlEvents:UIControlEventTouchUpInside];
        [picView addSubview:button];
        
        //大图
        {
            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
            button1.frame = CGRectMake(3, 33, picView.frame.size.width - 6, 190);
            button1.tag = kBtnTag;
            button1.backgroundColor = [UIColor clearColor];
            [button1 addTarget:self action:@selector(buyPhoneAction:) forControlEvents:UIControlEventTouchUpInside];
            self.phoneFirBtn = button1;
            [picView addSubview:button1];
            
            UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
            button2.frame = CGRectMake(3, CGRectGetMaxY(button1.frame)+2, 195, 190);
            button2.tag = kBtnTag + 1;
            button2.backgroundColor = [UIColor clearColor];
            [button2 addTarget:self action:@selector(buyPhoneAction:) forControlEvents:UIControlEventTouchUpInside];
            self.phoneSecBtn = button2 ;
            [picView addSubview:button2];
            
            UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
            button3.frame = CGRectMake(CGRectGetMaxX(button2.frame)+2, CGRectGetMaxY(button1.frame)+2, picView.frame.size.width - 195-6-2, 192/2-2);
            button3.tag = kBtnTag + 2;
            button3.backgroundColor = [UIColor clearColor];
            [button3 addTarget:self action:@selector(buyPhoneAction:) forControlEvents:UIControlEventTouchUpInside];
            self.phoneThrBtn = button3 ;
            [picView addSubview:button3];
            
            UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
            button4.frame = CGRectMake(CGRectGetMaxX(button2.frame)+2, CGRectGetMaxY(button3.frame)+2, picView.frame.size.width - 195-6-2, 192/2-2);
            button4.tag = kBtnTag + 3;
            button4.backgroundColor = [UIColor clearColor];
            [button4 addTarget:self action:@selector(buyPhoneAction:) forControlEvents:UIControlEventTouchUpInside];
            self.phoneForBtn = button4 ;
            [picView addSubview:button4];
        }
        
        yPos = CGRectGetMaxY(picView.frame);

    }
    
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, yPos,scroll.frame.size.width,5)];
        imageView.backgroundColor = [UIColor colorWithRed:239/255. green:239/255. blue:239/255. alpha:1];
        [scroll addSubview:imageView];
        yPos = CGRectGetMaxY(imageView.frame);
    }
    
    //靓号推荐
    {
        UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectMake(0, yPos, scroll.frame.size.width, 240)];
        picView.backgroundColor = [UIColor whiteColor];
        picView.userInteractionEnabled = YES ;
        [scroll addSubview:picView];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 100, 33)];
        label1.backgroundColor = [UIColor clearColor];
        label1.text = @"靓号推荐";
        label1.textAlignment = UITextAlignmentLeft ;
        label1.textColor = [UIColor blackColor];
        label1.font = [UIFont systemFontOfSize:14];
        [picView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(240, 0, 60 ,33)];
        label2.backgroundColor = [UIColor clearColor];
        label2.text = @"显示全部";
        label2.textAlignment = UITextAlignmentLeft ;
        label2.textColor = [UIColor colorWithRed:175/255. green:175/255. blue:174/255. alpha:1];
        label2.font = [UIFont systemFontOfSize:14];
        [picView addSubview:label2];
        
        UIImage *image = [UIImage imageNamed:@"preference_gray_arrow.png"];
        UIImageView *check = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label2.frame)+5, (33-image.size.height)/2, image.size.width, image.size.height)];
        check.backgroundColor = [UIColor clearColor];
        check.image = image ;
        [picView addSubview:check];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(240, 0,120, 33);
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(shouPrettyNumAction) forControlEvents:UIControlEventTouchUpInside];
        [picView addSubview:button];
        
        //大图
        {
            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
            button1.frame = CGRectMake(3, 33,(CGRectGetWidth(picView.frame)-6)/2-1, 100-1);
            button1.tag = kBtnTag + 4;
            self.phoneFitBtn = button1;
            [button1 setBackgroundImage:[UIImage imageNamed:@"pretty_top_icon.png"] forState:UIControlStateNormal];
            [button1 addTarget:self action:@selector(buyPhoneAction:) forControlEvents:UIControlEventTouchUpInside];
            [picView addSubview:button1];
            
            UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
            button2.frame = CGRectMake(CGRectGetMaxX(button1.frame)+2, 33, (CGRectGetWidth(picView.frame)-6)/2-1, 100-1);
            button2.tag = kBtnTag + 5;
            self.phoneSixBtn = button2 ;
            [button2 setBackgroundImage:[UIImage imageNamed:@"pretty_bussiness_icon.png"] forState:UIControlStateNormal];
            [button2 addTarget:self action:@selector(buyPhoneAction:) forControlEvents:UIControlEventTouchUpInside];
            [picView addSubview:button2];
            
            UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
            button3.frame = CGRectMake(3, CGRectGetMaxY(button1.frame)+2, (CGRectGetWidth(picView.frame)-6)/2-1, 100-1);
            button3.tag = kBtnTag + 6;
            self.phoneSevBtn = button3 ;
            [button3 setBackgroundImage:[UIImage imageNamed:@"pretty_free_icon.png"] forState:UIControlStateNormal];
            [button3 addTarget:self action:@selector(buyPhoneAction:) forControlEvents:UIControlEventTouchUpInside];
            [picView addSubview:button3];
            
            UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
            button4.frame = CGRectMake(CGRectGetMaxX(button3.frame)+2, CGRectGetMaxY(button2.frame)+2,(CGRectGetWidth(picView.frame)-6)/2-1,100-1);
            button4.tag = kBtnTag + 7;
            self.phoneEigBtn = button4 ;
            [button4 setBackgroundImage:[UIImage imageNamed:@"pretty_shake_icon.png"] forState:UIControlStateNormal];
            [button4 addTarget:self action:@selector(buyPhoneAction:) forControlEvents:UIControlEventTouchUpInside];
            [picView addSubview:button4];
        }
        yPos = CGRectGetMaxY(picView.frame);
    }

    scroll.contentSize  = CGSizeMake(self.view.frame.size.width, yPos);
    //当提醒时刻到时对条目进行刷新
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRefreshItemsNotification:)
                                                 name:ESRefreshItemsNotification object:nil];
    
    //  引导层 遮罩层
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *isShow = [defaults objectForKey:@"Preferential"];
    
    if ([isShow isEqualToString:@"YES"]) {
        
    }
    else
    {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        UIImageView *directedImageView ;
        
        if (!iPhone5)
        {
            directedImageView = [[UIImageView alloc] initWithFrame:
                                 CGRectMake(0, 0,
                                            CGRectGetWidth(window.frame),
                                            480)];
            
            directedImageView.backgroundColor = [UIColor clearColor];
            directedImageView.userInteractionEnabled = YES ;
            directedImageView.autoresizingMask = UIViewContentModeScaleAspectFill;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                directedImageView.image = [UIImage imageNamed:@"Preferential_iphone4"];
            } else {
                directedImageView.image = [UIImage imageNamed:@"Preferential_iphone4"];
            }
        } else
        {
//            directedImageView = [[UIImageView alloc] initWithFrame:
//                                 CGRectMake(0, 0,
//                                            CGRectGetWidth(window.frame),
//                                            568)];
            directedImageView = [[UIImageView alloc] initWithFrame:
                                 CGRectMake(0, 0,
                                            CGRectGetWidth(window.frame),
                                            568)];
            
            directedImageView.backgroundColor = [UIColor clearColor];
            directedImageView.userInteractionEnabled = YES ;
            directedImageView.autoresizingMask = UIViewContentModeScaleAspectFill;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                directedImageView.image = [UIImage imageNamed:@"Preferential_iphone5"];
            } else {
                directedImageView.image = [UIImage imageNamed:@"Preferential_iphone5"];
            }
            
        }
        
        self.directedImageView = directedImageView;
        [window addSubview:directedImageView];
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = directedImageView.bounds;
            [button addTarget:self action:@selector(removeDirected) forControlEvents:UIControlEventTouchUpInside];
            [directedImageView addSubview:button];
        }
        
        [defaults setObject:@"YES" forKey:@"Preferential"];
        [defaults synchronize];
    }
}

- (void) removeDirected
{
    __weak typeof(self)wSelf = self ;
    [UIView animateWithDuration:0.3 animations:^()
     {
         wSelf.directedImageView.alpha = 0;
     }completion:^(BOOL finished){
         
         [wSelf.directedImageView removeFromSuperview];
     }];
}

#pragma 定时刷新优惠广告位

- (void)handleRefreshItemsNotification:(NSNotification *)notification
{
    [self fetchAdList];
    [self phoneAdList];
}

-(void) viewDidAppear:(BOOL)animated
{
     [super viewDidAppear:animated];
    if (self.adList && [self.adList count]>0) {
        [self.adView reloadData];
    } else{
        [self fetchAdList];
    }
    
    if (self.phoneInfoList && [self.phoneInfoList count]>0) {

    } else{
        [self phoneAdList];
    }
    
    @try {
        //添加定位
        if (![CTHelperMap shareHelperMap].isSuccess) {
//            [[CTHelperMap shareHelperMap] getAreaInfo:^(CTCity *city,NSError *error)
//             {
//                 
//             }];
            [[CTHelperMap shareHelperMap] getAreaInfo:nil];

        }
    }
    @catch (NSException *exception) {
        DDLogCVerbose(@"%@",exception);
    }
    @finally {  }
    
}

-(void)viewWillDisappear:(BOOL)animated{
//    if (self.adView) {
//        [self.adView stopTimer];
//    }
    [super viewWillDisappear:animated];
}

#pragma mark - mknetwork

- (void)fetchAdList
{
    // 获取广告数据
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNbr = loginInfoDict[@"UserLoginName"] ? loginInfoDict[@"UserLoginName"] : @"";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            ESHORE_ShopId, @"ShopId",
                            phoneNbr, @"PhoneNbr",
                            @"8", @"Type",    // 优惠广告位 type ＝ 6
                            @"1", @"Index",
                            @"10", @"PageSize", nil];
    //__block CTPreferentialVCtler *weakself = self;
    
    __weak typeof(self)weakself = self;
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"queryadlist"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict)
                                      {
                                          
                                          [weakself.adList removeAllObjects];
                                          if ([dict[@"Data"][@"AdItem"] isKindOfClass:[NSArray class]])
                                          {
                                              [weakself.adList addObjectsFromArray:dict[@"Data"][@"AdItem"]];
                                          }
                                          else if ([dict[@"Data"][@"AdItem"] isKindOfClass:[NSDictionary class]])
                                          {
                                              [weakself.adList addObject:dict[@"Data"][@"AdItem"]];
                                          }
                                          [weakself.adView reloadData];
                                          
                                      } onError:^(NSError *engineError)
                                        {
                                          if ([engineError.userInfo objectForKey:@"ResultCode"])
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
                                                                            if (self.navigationController != nil)
                                                                            {
                                                                                [self.navigationController popViewControllerAnimated:NO];
                                                                            }
                                                                        }];
                                                  alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                  [alertView show];
                                              }
                                          }
                                          else
                                          {
                                              
                                          }
                                      }];
}

- (void) phoneAdList
{
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNbr = loginInfoDict[@"UserLoginName"] ? loginInfoDict[@"UserLoginName"] : @"";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            ESHORE_ShopId, @"ShopId",
                            phoneNbr, @"PhoneNbr",
                            @"9", @"Type",    // 优惠广告位 type ＝ 6
                            @"1", @"Index",
                            @"10", @"PageSize", nil];
    
    //__block CTPreferentialVCtler *weakself = self;
    
    __weak typeof(self)weakself = self;
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"queryadlist"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          [weakself.phoneInfoList removeAllObjects];
                                          if ([dict[@"Data"][@"AdItem"] isKindOfClass:[NSArray class]])
                                          {
                                              [weakself.phoneInfoList addObjectsFromArray:dict[@"Data"][@"AdItem"]];
                                          }
                                          else if ([dict[@"Data"][@"AdItem"] isKindOfClass:[NSDictionary class]])
                                          {
                                              [weakself.phoneInfoList addObject:dict[@"Data"][@"AdItem"]];
                                          }
                                          
                                          [weakself setPhoneinfo];
                                          
                                      } onError:^(NSError *engineError) {
                                          
                                          if ([engineError.userInfo objectForKey:@"ResultCode"])
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
                                                                            if (self.navigationController != nil)
                                                                            {
                                                                                [self.navigationController popViewControllerAnimated:NO];
                                                                            }
                                                                        }];
                                                  alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                  [alertView show];
                                              }
                                          }
                                          else
                                          {
                                              
                                          }
                                          
                                      }];
}

- (void)custIdInfo
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [Global sharedInstance].loginInfoDict[@"UserLoginName"], @"Account",
                            @"201", @"AccountType",
                            ESHORE_ShopId, @"ShopId", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"custIdInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          [Global sharedInstance].custInfoDict = dict[@"Data"];
                                      } onError:^(NSError *engineError) {
                                          if ([engineError.userInfo objectForKey:@"ResultCode"])
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
                                                                            if (self.navigationController != nil)
                                                                            {
                                                                                [self.navigationController popViewControllerAnimated:NO];
                                                                            }
                                                                        }];
                                                  alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                  [alertView show];
                                              }
                                          }
                                          else
                                          {
                                              
                                          }
                                      }];
}

- (void) qrySalesProductCompleteInfo : (NSDictionary *) dictionary pageType : (int) type
{
    CTPhoneInfoVCtler *vc = [CTPhoneInfoVCtler new];
    [vc setPhoneInfo:dictionary :type];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - fun

- (void) setPhoneinfo
{
    //设置4个按钮的图片
//    if (self.phoneInfoList.count > 0) {
//        
//        NSURL *url = [NSURL URLWithString:[[self.phoneInfoList objectAtIndex:0]objectForKey:@"IconUrl"]];
//        [self.phoneFirBtn setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loadingImage1.png"]];
//        
//        url = [NSURL URLWithString:[[self.phoneInfoList objectAtIndex:1]objectForKey:@"IconUrl"]];
//        [self.phoneSecBtn setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loadingImage1.png"]];
//        
//        url = [NSURL URLWithString:[[self.phoneInfoList objectAtIndex:2]objectForKey:@"IconUrl"]];
//        [self.phoneThrBtn setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loadingImage1.png"]];
//        
//        url = [NSURL URLWithString:[[self.phoneInfoList objectAtIndex:3]objectForKey:@"IconUrl"]];
//        [self.phoneForBtn setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loadingImage1.png"]];
//        
//        //靓号
//        url = [NSURL URLWithString:[[self.phoneInfoList objectAtIndex:4]objectForKey:@"IconUrl"]];
//        [self.phoneFitBtn setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loadingImage1.png"]];
//        
//        url = [NSURL URLWithString:[[self.phoneInfoList objectAtIndex:5]objectForKey:@"IconUrl"]];
//        [self.phoneSixBtn setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loadingImage1.png"]];
//        
//        url = [NSURL URLWithString:[[self.phoneInfoList objectAtIndex:6]objectForKey:@"IconUrl"]];
//        [self.phoneSevBtn setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loadingImage1.png"]];
//        
//        url = [NSURL URLWithString:[[self.phoneInfoList objectAtIndex:7]objectForKey:@"IconUrl"]];
//        [self.phoneEigBtn setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loadingImage1.png"]];
//    }
    
    for (int i=0; i<self.phoneInfoList.count; i++) {
        UIButton *btn = (UIButton *)[self.scrollView viewWithTag:kBtnTag+i];
        NSURL *url = [NSURL URLWithString:[[self.phoneInfoList objectAtIndex:i]objectForKey:@"IconUrl"]];
        [btn setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loadingImage1.png"]];
    }
}

//登录成功后得跳转
- (void) autoJumpPage
{
    if(self.jumpDict)
    {
        NSString *UserId = [Global sharedInstance].custInfoDict[@"UserId"];
        if(!UserId && UserId.length==0)
        {
            NSDictionary *loginDict = [Global sharedInstance].loginInfoDict;
            NSString *Account = [loginDict objectForKey:@"UserLoginName"] ? [loginDict objectForKey:@"UserLoginName"] : @"";
            
            NSDictionary *params1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     Account, @"Account",
                                     @"201", @"AccountType",
                                     ESHORE_ShopId, @"ShopId", nil];
            
            //__block CTPreferentialVCtler *weakSelf = self;
            __weak typeof(self) weakSelf = self;
            
            [MyAppDelegate.cserviceEngine postXMLWithCode:@"custIdInfo"
                                                   params:params1
                                              onSucceeded:^(NSDictionary *dict) {
                                                  
                                                  //获取用户id
                                                  id Data = [dict objectForKey:@"Data"];
                                                  if (Data && [Data respondsToSelector:@selector(objectForKey:)]) {
                                                      [Global sharedInstance].custInfoDict = dict[@"Data"];
                                                      [weakSelf jumpPage:self.jumpDict];
                                                      weakSelf.jumpDict = nil;
                                                  }
                                              } onError:^(NSError *engineError) {
                                                  [SVProgressHUD dismiss];
                                                  if ([engineError.userInfo objectForKey:@"ResultCode"])
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
                                                                                    if (self.navigationController != nil)
                                                                                    {
                                                                                        [self.navigationController popViewControllerAnimated:NO];
                                                                                    }
                                                                                }];
                                                          alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                          [alertView show];
                                                      }
                                                  }
                                                  else{
                                                      ToastAlertView *alert = [ToastAlertView new];
                                                      [alert showAlertMsg:@"系统繁忙,请重新提交"];
                                                  }
                                              }];
        }else{
            [self jumpPage:self.jumpDict];
            self.jumpDict = nil;
        }
    }

}

- (void) jumpPage : (NSDictionary *) dictionary
{
    if (!dictionary && ![dictionary respondsToSelector:@selector(objectForKey:)]) {
        return;
    }
    
    int LinkType = [[dictionary objectForKey:@"LinkType"]intValue];
    
    NSString *title=dictionary[@"Title"];
    [[NSUserDefaults standardUserDefaults]setObject:title?title:@"" forKey:@"ShareDetail"];
    
    switch (LinkType) {
        case 2:     //  网页
        {
            NSString *jumpUrl = [dictionary objectForKey:@"Link"];
            CTDetailVCtler *vc = [CTDetailVCtler new];
            vc.jumpUrl = jumpUrl ;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 1:    // 本地
        {
            NSArray * uiDatas = [self loadUIConfigure];
            int Link = [[dictionary objectForKey:@"Link"] intValue];
            
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
                break;
            }
            BOOL needlogin = [[uiDict objectForKey:@"needlogin"] boolValue];
            
            NSString * clsname = [uiDict objectForKey:@"class"];
            NSLog(@"%@", clsname);
            
            if ([clsname isEqualToString:[NSString stringWithFormat:@"%@", [self class]]])
            {
                return;
            }
            else if ([clsname isEqualToString:@"CTHomeVCtler"])
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTQueryVCtler"])
            {
                // 查询首页
                MyAppDelegate.tabBarController.selectedIndex = 1;
                [MyAppDelegate.tabBarController.viewControllers[1] popViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTPreferentialVCtler"])
            {
                // 优惠首页
                
                MyAppDelegate.tabBarController.selectedIndex = 3;
                [MyAppDelegate.tabBarController.viewControllers[3] popViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTMoreVCtler"])
            {
                // 更多首页
                MyAppDelegate.tabBarController.selectedIndex = 4;
                [MyAppDelegate.tabBarController.viewControllers[4] popViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTRechargeVCtler"])
            {
                MyAppDelegate.tabBarController.selectedIndex = 2;
                UINavigationController *nar =  MyAppDelegate.tabBarController.viewControllers[2] ;
                CTRechargeVCtler *vc =  (CTRechargeVCtler *)nar.topViewController ;
                // 充话费
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

                [self.navigationController pushViewController:vc animated:YES];
            }
            else if ([clsname isEqualToString:@"CTPrettyNumberVCtler"])
            {
                CTPrettyNumberVCtler *vc =  [CTPrettyNumberVCtler new] ;
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
                [self.navigationController pushViewController:vc animated:YES];
                
            }
            else        //本地跳转默认的页面  除各自的首页外
            {
                if ([clsname length] <= 0)
                {
                    break;
                }
                if(needlogin)  //判断是否要登录
                {
                    //跳转到登录页面
                    if ([Global sharedInstance].isLogin == NO) {
                        CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                        vc.isPush = YES ;
                        self.jumpDict = dictionary ; //作为下次直接跳转使用
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                        [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
                        }];
                        
                        return;
                    }
                }
                Class cls   = NSClassFromString(clsname);
                id anInstance  = [[cls alloc] init];
                if (anInstance)
                {
                    [self.navigationController pushViewController:anInstance animated:YES];
                }
            }
        }
            break;
            
        case 3://合约机销售品ID
        {
            //跳转到登录页面
            if ([Global sharedInstance].isLogin == NO) {
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                vc.isPush = YES;
                self.jumpDict = dictionary ; //作为下次直接跳转使用
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
                }];
                
                return;
            }
            
            [self qrySalesProductCompleteInfo:dictionary pageType:0];
        }
            break;
        case 4://裸机销售品ID
        {
            //跳转到登录页面
            if ([Global sharedInstance].isLogin == NO) {
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                vc.isPush = YES;
                self.jumpDict = dictionary ; //作为下次直接跳转使用
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
                }];
                
                return;
            }
            [self qrySalesProductCompleteInfo:dictionary pageType:1];
        }
            break;
        case 5:
        {
            
            
            //跳转到登录页面
            if ([Global sharedInstance].isLogin == NO ) {
                /**
                 @Author                gongxt
                 @Description           添加消息通知监听，监听ticket设置成功后重新跳转
                 
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(autoJumpPage)
                                                             name:kDynamicRedirect
                                                           object:nil];*/
                
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                vc.isPush = YES;
                self.jumpDict = dictionary ; //作为下次直接跳转使用
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
                }];
                
                return;
            }
             __weak typeof(self) wself = self;
            [MyAppDelegate generationSingleWithSuccessBlock:^()
             {
                 [wself JumpPage4Type5:dictionary];
             }
                                               failureBlock:^(){
                                               }];
            /**
             http://202.102.111.141/ztWxCz/servlet/ComplaintServlet?type=groupBuinessType&ztInterSource=100005&ticket=$ticket$&pnm=$phonenumber$&uid=$userid$
             &ticket=$ticket$&pnm=$phonenumber$&uid=$userid$
            
            @try
            {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:kDynamicRedirect object:nil];
            }
            @catch (NSException *exception) {  } */
            
           
            
        }
            
            break;
        case 6: //  百搭销售品ID
        {
            //  CTSelectPhoneVCtler
            /*
            //跳转到登录页面
            if ([Global sharedInstance].isLogin == NO) {
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                vc.isPush = YES;
                self.jumpDict = dictionary ; //作为下次直接跳转使用
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
                }];
                return;
            }*/
            //请求数据
            NSString *Id = [dictionary objectForKey:@"Link"];
            CTSelectPhoneVCtler *selectPhoneVCtler = [[CTSelectPhoneVCtler alloc] init];
            selectPhoneVCtler.salesId = Id;
            self.jumpDict = dictionary ; //作为下次直接跳转使用
            [self.navigationController pushViewController:selectPhoneVCtler animated:YES];
            
        }
            break;
    }
}
#pragma mark 动态链接跳转
-(void)JumpPage4Type5:(NSDictionary*)dictionary
{
     NSString *ticket=[Global sharedInstance].ticket;
    NSString *PhoneNbr = [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] ? [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] : @"";
    NSString *uid=[[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"];
    
    NSString *link = [dictionary objectForKey:@"Link"];
    NSString *jumpUrl=[link stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//把转义字符换为utf8编码
    jumpUrl=[jumpUrl stringByReplacingOccurrencesOfString:@"$ticket$" withString:ticket];
    jumpUrl=[jumpUrl stringByReplacingOccurrencesOfString:@"$phonenumber$" withString:PhoneNbr];
    jumpUrl=[jumpUrl stringByReplacingOccurrencesOfString:@"$userid$" withString:uid];
    
    CTDetailVCtler *vc = [CTDetailVCtler new];
    vc.jumpUrl = jumpUrl ;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - CTPRcScrollviewdelegate

- (void)didClickPage:(CTPRcScrollview *)csView atIndex:(NSInteger)index
{
    DDLogInfo(@"%s atIndex:%d", __func__, index);
    //网页跳转  与  本地跳转
    if (self.adList && [self.adList count]>0) {
        NSDictionary *dictionary = [self.adList objectAtIndex:index];
        [self jumpPage:dictionary];
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

#pragma mark - CTPRcScrollViewDatasource

- (NSInteger)numberOfPages
{
    return [self.adList count] ? [self.adList count] : 1;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 160)];
    
    NSURL *imageUrl = nil;
    if (index >= 0 && index < [self.adList count]) {
        imageUrl = [NSURL URLWithString:self.adList[index][@"IconUrl"]];
    }
    
    [imageView setImageWithURL:imageUrl
              placeholderImage:[UIImage imageNamed:@"ad_default"]];
    
    return imageView;
}

#pragma mark - Action
//精品手机购买
- (void) buyPhoneAction : (id) sender
{
    if([Global sharedInstance].isLogin)
    {
        NSString *UserId = [Global sharedInstance].custInfoDict[@"UserId"];
        if(!UserId && UserId.length==0)
        {
            [self custIdInfo]; //请求userid
            UIButton *btn = (UIButton *)sender;
            int index = btn.tag - kBtnTag ;
            if (self.phoneInfoList && [self.phoneInfoList count]>index) {
                NSDictionary *dictionary = [self.phoneInfoList objectAtIndex:index];
                [self jumpPage:dictionary];
            }
        }else{
            UIButton *btn = (UIButton *)sender;
            int index = btn.tag - kBtnTag ;
            if (self.phoneInfoList && [self.phoneInfoList count]>index) {
                NSDictionary *dictionary = [self.phoneInfoList objectAtIndex:index];
                [self jumpPage:dictionary];
            }
        }
    }
    else
    {
        UIButton *btn = (UIButton *)sender;
        int index = btn.tag - kBtnTag ;
        if (self.phoneInfoList && [self.phoneInfoList count]>index)
        {
            NSDictionary *dictionary = [self.phoneInfoList objectAtIndex:index];
            [self jumpPage:dictionary];
        } else {
            
        }
    }
}

//跳转到合约机列表页面
- (void) checkMoreInfoAction
{
    //changed by yanw
    if (0) {
        [self custIdInfo];
        CTContractPhoneVCtler *vc = [CTContractPhoneVCtler new];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        CTPhoneListViewController *phoneListViewController = [[CTPhoneListViewController alloc] init];
        phoneListViewController.phoneType = PhoneTypeAll;
        [self.navigationController pushViewController:phoneListViewController animated:YES];
    }
}

//查看更多优惠活动（消息中心）
- (void)morPrefernceAction
{
    CTMessageCenterVCtler *vc = [CTMessageCenterVCtler new];
    [vc rechargeType:0];
    [self.navigationController pushViewController:vc animated:YES];
    
//    CTNumberSelectedVCtler *vc = [CTNumberSelectedVCtler new];
//    [self.navigationController pushViewController:vc animated:YES];
    
//    COrderWildProductFillVctrler *vc = [COrderWildProductFillVctrler new];
//    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void) shouPrettyNumAction
{
    CTPrettyNumberVCtler *vc = [CTPrettyNumberVCtler new];
    vc.selectedIndex = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) prettyNumAction : (id) sender
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
