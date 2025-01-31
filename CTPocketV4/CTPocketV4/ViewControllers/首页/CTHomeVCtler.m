//
//  CTHomeVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//  首页

#import "CTHomeVCtler.h"

#import "Utils.h"

#import "AppDelegate.h"
#import "CserviceEngine.h"

#import "CTPRcScrollview.h"
#import "CTFlowView.h"
#import "CTAccountInfoView.h"
#import "CTSimpleInfoView.h"
#import "CTCustomIcon.h"
#import "SIAlertView.h"
#import "CTMessageCenterVCtler.h"
#import "CTCustomPagesVCtler.h"
#import "StyledPageControl.h"
#import "CTDetailVCtler.h"
#import "CTLoginVCtler.h"

#import "CTQryPackageVctler.h"
#import "CTRechargeVCtler.h"
#import "CTPayHistoryVCtler.h"
#import "CTPointQueryVCtler.h"
#import "CTQueryVCtler.h"
#import "CTMyOrderListVCtler.h"
#import "CTQryValueAddVCtler.h"
#import "CTOrderSuccessVCtler.h"
#import "CTPreferentialVCtler.h"
#import "CTUserFeedbackVCtler.h"
#import "CTQryBalanceVCtler.h"
#import "CTPPointExchangeVCtler.h"
#import "CTBarePhoneVCtler.h"
#import "CTContractPhoneVCtler.h"
#import "CTValueAddedVCtler.h"
#import "CTQrtStreamVCtler.h" 
#import "CTChangePasswordVCtler.h"
#import <QuartzCore/QuartzCore.h>
#import "CTMoreVCtler.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "CTPhoneListViewController.h"
#import "CTRedeemVCtler.h"
#import "CTPhoneInfoVCtler.h"
#import "CTSelectPhoneVCtler.h"
#define kMsgLab 10000

#import "CTPrettyNumberVCtler.h"    // added by zy, 2014-02-18
#import "CTAddrBookSyncVCtler.h"
#import "ABAddressBookCache.h"
#import "CTMoreVCtler.h"


@class CustomTabBarVCtler ;

NSString * const QryPointNotificaion; // added by liuruxna, 2014-04-4

//added by wensj 20140303
extern NSString * const ESRefreshItemsNotification;

NSString* const kHasLookupCustomViewKey = @"hasLookupCustomView";   // added by zy, 2014-04-02
NSString* const CTHomeVCtlerDidRefreshUserInfoNotification = @"CTHomeVCtlerDidRefreshUserInfoNotification";   // added by zy, 2014-04-18

#define TAG_IMG_LOGIN0 1000
#define TAG_IMG_LOGIN1 1001
#define TAG_IMG_NOLOGIN 1002


@interface CTHomeVCtler () <CTPRcScrollViewDelegate, CTPRcScrollViewDatasource, UIScrollViewDelegate, CTAccountInfoViewDelegate, CTSimpleInfoViewDelegate>
{
    CTAccountInfoView *_accountInfoView;
    CTSimpleInfoView *_simpleInfoView;
    UIView *_loginView;
    
    UIView* _topLineView;       // added by zy, 2014-02-19
    
    NSInteger pressNum;   //遮盖层
}

@property (strong, nonatomic) CTPRcScrollview *adView;              // 顶部广告
@property (strong, nonatomic) UIScrollView *vScrollView;            // 纵向ScrollView
@property (strong, nonatomic) CTFlowView *flowView;                 // 流量图
@property (strong, nonatomic) UIView *middlePersonView;             // 中间层
@property (strong, nonatomic) UIScrollView *hScrollView;            // 底部层
@property (strong, nonatomic) UIImageView *arrowDown;
@property (strong, nonatomic) UILabel *arrowDownLabel;
@property (strong, nonatomic) StyledPageControl *pageControl;       // pageControl
@property (strong, nonatomic) UIImageView *arrowLeft;
@property (strong, nonatomic) UIImageView *arrowRight;

@property (strong, nonatomic) NSMutableArray *adList;
@property (strong, nonatomic) NSArray *defaultIconList;

@property (assign, nonatomic) int msgCenterCount ; //weak
@property (strong, nonatomic) NSDictionary *jumpDict;

@property (strong, nonatomic) UIButton *iconSelectedBtn;     // add by liuruxian 2014-05-14
@property (strong , nonatomic) UIButton * rightBtn;

/**
 "Cert_Infos" = {
    "Cert_item" =   {
        "Cert_Address" = "\U5e7f\U5dde\U5e02\U5929\U6cb3\U533a\U9f99\U53e3\U4e1c\U8def147\U53f7504\U623f";
        "Cert_Number" = 445121198803303436;
        "Cert_Type" = "";
        CustCertiId = "";
    };
 };
 "Contact_Address" = "";
 CustAddress = "\U5e7f\U5dde\U5e02\U5929\U6cb3\U533a\U9f99\U53e3\U4e1c\U8def147\U53f7504\U623f";
 CustAreaGrade = 10;
 CustId = 2958919865;
 CustNumber = 2958919865;
 CustType = 1100;
 "Cust_Name" = "\U8bb8\U5fe0\U6d32";
 "Lan_Id" = 8440100;
 ServiceLevel = 1300;
 StatusCd = 11;
 StatusDate = null;
 */
@property (strong, nonatomic) NSDictionary *custInfo;

/**
 AccAmount = 2097152;
 UnitTypeId = 3;
 UsedAmount = 191074;
 */
@property (strong, nonatomic) NSDictionary *flowInfo;

/**
 AcctName = "\U8bb8\U5fe0\U6d32";
 Items = (
        {
            Charge = "-0.3";
            ChargeTypeName = "\U79fb\U52a8\U4e1a\U52a1\U79fb\U52a8\U56fd\U5185\U70b9\U5bf9\U70b9\U77ed\U4fe1\U901a\U4fe1\U8d39";
        },
        {
            Charge = "0.3";
            ChargeTypeName = "\U79fb\U52a8\U4e1a\U52a1\U79fb\U52a8\U56fd\U5185\U70b9\U5bf9\U70b9\U77ed\U4fe1\U901a\U4fe1\U8d39";
        },
        {
            Charge = "-54.95";
            ChargeTypeName = "\U79fb\U52a8\U4e1a\U52a1\U672c\U5730\U7701\U5185\U957f\U9014\U8d39";
        },
        {
            Charge = "54.95";
            ChargeTypeName = "\U79fb\U52a8\U4e1a\U52a1\U672c\U5730\U7701\U5185\U957f\U9014\U8d39";
        },
        {
            Charge = "-1.6";
            ChargeTypeName = "\U79fb\U52a8\U4e1a\U52a1\U672c\U5730\U79fb\U52a8\U8d39";
        },
        {
            Charge = "1.6";
            ChargeTypeName = "\U79fb\U52a8\U4e1a\U52a1\U672c\U5730\U79fb\U52a8\U8d39";
        },
        {
            Charge = "-9.97";
            ChargeTypeName = "\U79fb\U52a8\U4e1a\U52a1\U624b\U673a\U4e0a\U7f51\U8d39";
        },
        {
            Charge = "-51.22";
            ChargeTypeName = "\U79fb\U52a8\U4e1a\U52a1\U624b\U673a\U4e0a\U7f51\U8d39";
        },
        {
            Charge = "61.19";
            ChargeTypeName = "\U79fb\U52a8\U4e1a\U52a1\U624b\U673a\U4e0a\U7f51\U8d39";
        },
        {
            Charge = "69.3";
            ChargeTypeName = "\U5957\U9910\U4f7f\U7528\U8d39";
        },
        {
            Charge = "-18.33";
            ChargeTypeName = "\U79fb\U52a8\U7535\U8bdd\U57fa\U672c\U6708\U79df(\U975e\U5957\U9910\U4f7f\U7528)";
        },
        {
            Charge = "18.33";
            ChargeTypeName = "\U79fb\U52a8\U7535\U8bdd\U57fa\U672c\U6708\U79df(\U975e\U5957\U9910\U4f7f\U7528)";
        },
        {
            Charge = "-2.2";
            ChargeTypeName = "\U79fb\U52a8\U6765\U7535\U663e\U793a\U6708\U79df\U8d39";
        },
        {
            Charge = "2.2";
            ChargeTypeName = "\U79fb\U52a8\U6765\U7535\U663e\U793a\U6708\U79df\U8d39";
        }
    );
 SumCharge = "69.3";
 */
@property (strong, nonatomic) NSDictionary *billInfo;

/**
 TotalBalance = 124;
 */
@property (strong, nonatomic) NSDictionary *canuse;

/**
 {
    PointTime = "1970-01-01 16:20:00";
    PointValue = 1647;
    PointValueEndOfYear = "";
    PointValueSum = 1647;
 }
 */
@property (strong, nonatomic) NSDictionary *pointInfo;

@property (strong, nonatomic) NSDictionary *ppaccuInfo;

@property (atomic) CGPoint startPoint;

@property (assign, nonatomic) BOOL          isLoadingCanuse;    // added by zy, 2014-04-04

@property (nonatomic, strong) UIImageView *directedImageView;

@end

@implementation CTHomeVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // tabbar title
        self.title = @"首页";
        
        // 左按钮
        [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"]];
        
        // titleView
        {
            UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 216, 44)];
            mView.backgroundColor = [UIColor clearColor];
            
            UIImageView *ctLogo = [[UIImageView alloc] initWithFrame:CGRectMake(28, 11, 75, 21)];
            ctLogo.image = [UIImage imageNamed:@"navigationBar_CT_logo"];
            [mView addSubview:ctLogo];
            
            UIImageView *separatorV = [[UIImageView alloc] initWithFrame:CGRectMake(108, 11, 1, 21)];
            separatorV.image = [UIImage imageNamed:@"navigationBar_separatorV"];
            [mView addSubview:separatorV];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(114, 11, 102, 21)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont systemFontOfSize:14.0f];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.text = @"掌上营业厅";
            [mView addSubview:titleLabel];
            
            self.navigationItem.titleView = mView;
        }
        
        // 右按钮
        if ([Global sharedInstance].isLogin) {
            [self setRightButton:[UIImage imageNamed:@"navigationBar_logout_icon"]];
        }
        else
        {
            [self setRightButton:[UIImage imageNamed:@"navigationBar_user_icon"]];
        }
        
        // 初始化数据
        self.adList = [NSMutableArray array];
        self.defaultIconList = @[@{@"icon": @"default_custom_Icon1", @"title": @"充值缴费"},
//                                 @{@"icon": @"default_custom_Icon2", @"title": @"免费短信"},
//                                 @{@"icon":@"custom_Icon1", @"title":@"套餐查询"},
                                 @{@"icon":@"custom_Icon8"/*@"custom_Icon1"*/, @"title":@"业务办理"},  // modified by liuruxian 2014-04-28
                                 @{@"icon":@"default_custom_Icon3", @"title": @"合约机"},
                                 @{@"icon":@"custom_Icon16", @"title":@"话费查询"},
                                 @{@"icon":@"custom_Icon5"/*@"custom_Icon17"*/, @"title":/*@"积分查询"*/@"积分兑换"},  // modified by liuruxian 2014-04-28
                                 @{@"icon":@"default_custom_Icon4", @"title": @"自定义"}];
        
        // 通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadHScrollView)
                                                     name:@"ReloadCustomIconView"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadHomeView)
                                                     name:@"ReloadHomeView"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadMsg)
                                                     name:@"ReloadMsg"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dismissMsg)
                                                     name:@"dismissMsg"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(autoJumpPage)
                                                     name:@"autoJumpPage"
                                                   object:nil];
        
        // added by zy, 2014-02-17
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onLoginSuccessNotification)
                                                     name:kLoginSuccess
                                                   object:nil];
        
        // added by zy, 2014-04-02
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRefreshNewFlag)
                                                     name:CTRefreshNewFlag
                                                   object:nil];
        
        // added by liuruxian 2014-04-04
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(qryPoint)
                                                     name:QryPointNotificaion
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _accountInfoView = nil;
    _simpleInfoView = nil;
    _loginView = nil;
    
    self.msgCenterCount = 0;
    
    // 广告栏
    {
        CGFloat adViewHeight = 126.0f;
        if (iPhone5) {
            adViewHeight = 160.0f;
        }
        self.adView = [[CTPRcScrollview alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, adViewHeight)];
        self.adView.delegate = self;
        self.adView.datasource = self;
        [self.view addSubview:self.adView];
        [self.adView reloadData];
        
        [self fetchAdList];
    }
    
    // scrollView
    {
        CGFloat vScrollViewHeight = 241.0f;
        CGFloat vScrollViewContentHeight = 366.0f;
        if (iPhone5) {
            vScrollViewHeight = 295.0f;
            vScrollViewContentHeight = 445.0f;
        }
        self.vScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.adView.bounds.size.height, self.view.bounds.size.width, vScrollViewHeight)];
        self.vScrollView.bounces = NO;
        self.vScrollView.showsVerticalScrollIndicator = NO;
        self.vScrollView.contentSize = CGSizeMake(self.vScrollView.contentSize.width, vScrollViewContentHeight);
        self.vScrollView.tag = 1;
        self.vScrollView.decelerationRate = 0.994;//UIScrollViewDecelerationRateNormal==0.99,UIScrollViewDecelerationRateFast==0.998;
        self.vScrollView.delegate = self;
        [self.view addSubview:self.vScrollView];
        
        // scrollView的三层内容
        CGFloat h1 = 125.0f;
        CGFloat h2 = 45.0f;
        CGFloat h3 = 70.0f + 125.0f;
        if (iPhone5) {
            h1 = 150.0f;
            h2 = 50.0f;
            h3 = 94.0f + 150.0f;
        }
        
        // 顶部圆环
        {
            CGFloat originY = 0;
            if (iPhone5) {
                originY = 12.0f;
            }
            self.flowView = [[CTFlowView alloc] initWithFrame:CGRectMake(0, originY, 320, 125)];
            [self.vScrollView addSubview:self.flowView];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(97, originY, 125, 125);
            [btn addTarget:self action:@selector(onSelectFlowViewAction) forControlEvents:UIControlEventTouchUpInside];
            [self.vScrollView addSubview:btn];
            
            // 分割线1
            UIImageView *sepatator1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, h1, self.vScrollView.bounds.size.width, 1)];
            sepatator1.image = [UIImage imageNamed:@"custom_separator"];
            [self.vScrollView addSubview:sepatator1];
            _topLineView = sepatator1;      // added by zy, 2014-02-19
            
            // 加流量按钮
            {
                UIButton *addFlowButton = [UIButton buttonWithType:UIButtonTypeCustom];
                addFlowButton.frame = CGRectMake(320-57, originY+44, 57, 38);
                [addFlowButton setBackgroundImage:[UIImage imageNamed:@"addFlowButton"] forState:UIControlStateNormal];
                [addFlowButton setBackgroundImage:[UIImage imageNamed:@"addFlowButton_hl"] forState:UIControlStateHighlighted];
                [addFlowButton addTarget:self
                                  action:@selector(onAddFlowAction)
                        forControlEvents:UIControlEventTouchUpInside];
                
                UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(36, 4, 16, 10)];
                lab1.backgroundColor = [UIColor clearColor];
                lab1.font = [UIFont systemFontOfSize:10.0f];
                lab1.textColor = [UIColor blackColor];
                lab1.text = @"加";
                [addFlowButton addSubview:lab1];
                
                UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(36, 14, 16, 10)];
                lab2.backgroundColor = [UIColor clearColor];
                lab2.font = [UIFont systemFontOfSize:10.0f];
                lab2.textColor = [UIColor blackColor];
                lab2.text = @"流";
                [addFlowButton addSubview:lab2];
                
                UILabel *lab3 = [[UILabel alloc] initWithFrame:CGRectMake(36, 24, 16, 10)];
                lab3.backgroundColor = [UIColor clearColor];
                lab3.font = [UIFont systemFontOfSize:10.0f];
                lab3.textColor = [UIColor blackColor];
                lab3.text = @"量";
                [addFlowButton addSubview:lab3];
                
                [self.vScrollView addSubview:addFlowButton];
            }
        }
        
        // 上滑箭头
        {
            CGFloat originY = 0;
            if (iPhone5) {
                originY = 12.0f;
            }
            UIImageView *arrowUp = [[UIImageView alloc] initWithFrame:CGRectMake(18, originY+51, 8, 24)];
            arrowUp.image = [UIImage imageNamed:@"arrow_up"];
            [self.vScrollView addSubview:arrowUp];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3, originY+51+24, 40, 12)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:10.0f];
            label.textColor = [UIColor lightGrayColor];
            label.text = @"向上滑动";
            [self.vScrollView addSubview:label];
        }
        
        // 中间模块
        {
            self.middlePersonView = [[UIView alloc] initWithFrame:CGRectMake(0, h1, self.vScrollView.bounds.size.width, h2)];
            [self.vScrollView addSubview:self.middlePersonView];
            
            // CTAccountInfoView
            _accountInfoView = [[CTAccountInfoView alloc] initWithFrame:self.middlePersonView.bounds];
            _accountInfoView.delegate = self;
            [self.middlePersonView addSubview:_accountInfoView];
            
            // CTSimpleInfoView
            _simpleInfoView = [[CTSimpleInfoView alloc] initWithFrame:self.middlePersonView.bounds];
            _simpleInfoView.delegate = self;
            [self.middlePersonView addSubview:_simpleInfoView];
            
            // 分割线2
            UIImageView *sepatator2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, h1+h2, self.vScrollView.bounds.size.width, 1)];
            sepatator2.image = [UIImage imageNamed:@"custom_separator"];
            [self.vScrollView addSubview:sepatator2];
        }
        
        // 底部
        {
            self.hScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, h1+h2+1, self.vScrollView.bounds.size.width, h3)];
            self.hScrollView.bounces = NO;
            self.hScrollView.pagingEnabled = YES;
            self.hScrollView.showsHorizontalScrollIndicator = NO;
            self.hScrollView.tag = 2;
            self.hScrollView.delegate = self;
            [self.vScrollView addSubview:self.hScrollView];
            
            // 向下滑箭头
            self.arrowDown = [[UIImageView alloc] initWithFrame:CGRectMake(18, h1+h2+1+15, 7, 18)];
            self.arrowDown.image = [UIImage imageNamed:@"arrow_down"];
            [self.vScrollView addSubview:self.arrowDown];
            
            self.arrowDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, h1+h2+1+2, 40, 12)];
            self.arrowDownLabel.backgroundColor = [UIColor clearColor];
            self.arrowDownLabel.font = [UIFont systemFontOfSize:10.0f];
            self.arrowDownLabel.textColor = [UIColor lightGrayColor];
            self.arrowDownLabel.text = @"向下滑动";
            [self.vScrollView addSubview:self.arrowDownLabel];
            
            // 底下scrollView
            {
                NSMutableArray *iconList = [NSMutableArray array];
                [iconList addObjectsFromArray:self.defaultIconList];
//                [iconList addObjectsFromArray:[Utils getCustomIconList]];  // 读取选择的图标数据(4.1 初始化的数据不同)
                NSArray * array = [Utils getCustomIconList];
                [iconList addObjectsFromArray: [self compareData:array]];
                
                [Utils saveCustomIconList:[self compareData:array]];  // 保存一次数据
                
                // 避免4.1数据的重复
                
#if 0           // modified by zy, 2014-04-08
                // added by zy, 2014-02-19
                {
                    [iconList removeObjectAtIndex:5];
                    [iconList addObject:[self.defaultIconList lastObject]];
                }
                // added by zy, 2014-02-19
#endif
                
                // added by zy, 2014-04-02
                NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
                BOOL showNewFlag = (![def objectForKey:kHasLookupCustomViewKey] && ![def objectForKey:kCTAddrBookSyncStatusKey]);
                // added by zy, 2014-04-02
                
                // 页数、列、行
                int pages = 0;
                if (([iconList count] % 6) > 0) {
                    pages = [iconList count]/6 + 1;
                }
                else
                {
                    pages = [iconList count]/6;
                }
                
                int num = 0;
                for (int i = 0; i < pages; i++)
                {
                    for (int j = 0; j < 2; j++)
                    {
                        for (int k = 0; k < 3; k++)
                        {
                            if (num < [iconList count]) {
                                CGFloat pageOffset = 320 * i;
                                CGFloat colOffset = 1 + 90 * j;
                                CGFloat rowOffset = 20 + 95 * k;
                                if (iPhone5) {
                                    colOffset = 20 + 95 * j;
                                }
                                
                                CTCustomIcon *icon = [[CTCustomIcon alloc] initWithOrigin:CGPointMake(pageOffset + rowOffset, colOffset)
                                                                                    image:[UIImage imageNamed:iconList[num][@"icon"]]
                                                                                  hlImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hl", iconList[num][@"icon"]]]
                                                                                    title:iconList[num][@"title"]];
                                [icon.iconButton addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
                                icon.iconButton.tag = num;
                                [self.hScrollView addSubview:icon];
                                
                                // added by zy, 2014-04-02
                                if (showNewFlag && [iconList[num][@"title"] isEqualToString:@"自定义"]) {
                                    UIImageView* newImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_updata_new"]];
                                    newImg.center = CGPointMake(CGRectGetMaxX(icon.iconButton.frame)-5,
                                                                CGRectGetMinY(icon.iconButton.frame)+6);
                                    [icon addSubview:newImg];
                                }
                                // added by zy, 2014-04-02
                                
                                num++;
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                }
                
                self.hScrollView.contentSize = CGSizeMake(self.hScrollView.bounds.size.width * pages, self.hScrollView.contentSize.height);
                
                // pageControl
                {
                    CGFloat h = self.hScrollView.frame.origin.y+164;
                    if (iPhone5)
                    {
                        h = self.hScrollView.frame.origin.y+200;
                    }
                    self.pageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(0, h, self.hScrollView.bounds.size.width, 20)];
                    [self.pageControl setPageControlStyle:PageControlStyleStrokedCircle];
                    [self.pageControl setNumberOfPages:pages];
                    [self.pageControl setCurrentPage:0];
                    [self.pageControl setCoreSelectedColor:[UIColor colorWithRed:0.44f green:0.78f blue:0.21f alpha:1.00f]];
                    [self.pageControl setDiameter:8];
                    self.pageControl.strokeWidth = 1;
                    self.pageControl.userInteractionEnabled = NO;
                    [self.vScrollView addSubview:self.pageControl];
                }
                
                // 左右滑动箭头
                {
                    CGFloat h = self.hScrollView.frame.origin.y+164;
                    if (iPhone5)
                    {
                        h = self.hScrollView.frame.origin.y+200;
                    }
                    
                    self.arrowLeft = [[UIImageView alloc] initWithFrame:CGRectMake(102, h+5, 29, 9)];
                    self.arrowLeft.image = [UIImage imageNamed:@"arrow_left"];
                    [self.vScrollView addSubview:self.arrowLeft];
                    
                    self.arrowRight = [[UIImageView alloc] initWithFrame:CGRectMake(189, h+5, 29, 9)];
                    self.arrowRight.image = [UIImage imageNamed:@"arrow_right"];
                    [self.vScrollView addSubview:self.arrowRight];
                }
            }
        }
    }
    
    // 根据登录、显示模式，设置scrollView的内容
    [self setMiddlePersonView];
    [self getData];
    
    //统计插码
    
    //added by wensj 20140303
    //当提醒时刻到时对条目进行刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshItemsNotification:)
                                                 name:ESRefreshItemsNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(directedLayout)
                                                 name:CustomTabbarShowCoverPageNotification object:nil];
    
}

// 匹配数据
- (NSArray *)compareData:(NSArray *)selectedArray
{
    NSMutableArray * array = [NSMutableArray arrayWithArray:selectedArray];
    if ([array count] == 0) {
        return [NSArray array];
    }
    
    int i = 0;
    
    for (NSDictionary *dict in selectedArray) {
        NSString *title = dict[@"title"];
        if ([@"购买手机" isEqualToString:title]) {
            title = @"单买手机";
            NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
            [array removeObject:dict];
            [dictionary setObject:title forKey:@"title"];
            [array insertObject:dictionary atIndex:i];
        } else if([@"业务办理" isEqualToString:title])
        {
//            [array removeObject:dict];
            title = @"套餐查询";
            NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
            [dictionary setObject:title forKey:@"title"];
            [dictionary setObject:@"custom_Icon1" forKey:@"icon"];
            [array removeObject:dict];
            [array insertObject:dictionary atIndex:i];
        } else if([@"积分兑换" isEqualToString:title])
        {
//            [array removeObject:dict];
            title = @"积分查询";
            NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
            [dictionary setObject:title forKey:@"title"];
            [dictionary setObject:@"custom_Icon17" forKey:@"icon"];
            [array removeObject:dict];
            [array insertObject:dictionary atIndex:i];
        }
        i++;
    }
    
    return [NSArray arrayWithArray:array] ;
}

#define KCoverBtnTag  10110
#define kStatusViewTag 10115

- (void)directedLayout
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    if ([Global sharedInstance].isLogin)
    {
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        //  引导层 遮罩层
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //NSString *isShow = [defaults objectForKey:@"HomeVCLogin"];
        NSString *isShow = [defaults objectForKey:@"HomeVC"];
        if ([isShow isEqualToString:@"YES"]) {
            
        }else{
            NSArray *glodEggArray4 = @[@"prettyNum_directed_iphone4s1", @"HitEggLogin_iphone4"]; //4S
            NSArray *glodEggArray5 = @[@"HitEggLogin_iphone52",@"HitEggLogin_iphone5"];
            
            NSArray *iconArray4 = @[@"prettyNum_directed_iphone4s1",@"prettyNum_directed_iphone4s.png"]; //
            NSArray *iconArray5 = @[@"ContactsLogin_iphone52",@"ContactsLogin_iphone5"]; //icon 取消，使用一张图实现
            
            for (int i=0; i<1; i++)
            {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = MyAppDelegate.window.bounds;
                button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin ;
                [button addTarget:self action:@selector(removeCover:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = KCoverBtnTag + i +1;
                if (i==0) {
                    if (!iPhone5) {
                        [button setBackgroundImage:version>=7.0?[UIImage imageNamed:glodEggArray4[1]]:[UIImage imageNamed:glodEggArray4[1]]
                                          forState:UIControlStateNormal];
                    }
                    else {
                        
                        [button setBackgroundImage:version>=7.0?[UIImage imageNamed:glodEggArray5[1]]:[UIImage imageNamed:glodEggArray5[1]] // 使用一张图，不区分导航栏
                                          forState:UIControlStateNormal];
                       
                    }
                    
                } else {
                    if (!iPhone5) {
                        [button setBackgroundImage:version>=7.0?[UIImage imageNamed:iconArray4[0]]:[UIImage imageNamed:iconArray4[0]]
                                          forState:UIControlStateNormal];
                    }
                    else {
                        [button setBackgroundImage:version>=7.0?[UIImage imageNamed:iconArray5[1]]:[UIImage imageNamed:iconArray5[1]]
                                          forState:UIControlStateNormal];
                    }
                     button.alpha = 0 ;
                }
                
                [window addSubview:button];
            }

            [defaults setObject:@"YES" forKey:@"HomeVC"];
            [defaults synchronize];
        }
        
    } else
    {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        //  引导层 遮罩层
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //NSString *isShow = [defaults objectForKey:@"HomeVCLoginNo"];
        NSString *isShow = [defaults objectForKey:@"HomeVC"];
        if ([isShow isEqualToString:@"YES"]) {
            
        }else{
            NSArray *glodEggArray4 = @[@"prettyNum_directed_iphone4s1", @"HitEggNoLogin_iphone4"]; //
            NSArray *glodEggArray5 = @[@"HitEggNoLogin_iphone52",@"HitEggNoLogin_iphone5"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            button.frame = MyAppDelegate.window.bounds;
//            button.frame = CGRectMake(0, 0,
//                                      CGRectGetWidth(window.frame),
//                                      568);
            [button addTarget:self action:@selector(removeCover:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = KCoverBtnTag;
            
            button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin ;
            if (!iPhone5) {
                [button setBackgroundImage:version>=7.0?[UIImage imageNamed:glodEggArray4[1]]:[UIImage imageNamed:glodEggArray4[1]]
                                  forState:UIControlStateNormal];
            }
            else {
                
                [button setBackgroundImage:version>=7.0?[UIImage imageNamed:glodEggArray5[1]]:[UIImage imageNamed:glodEggArray5[1]]
                                forState:UIControlStateNormal];
            }
            [window addSubview:button];
        }
        
        [defaults setObject:@"YES" forKey:@"HomeVC"];
        [defaults synchronize];
    }
}

- (void)removeCover:(UIButton *)sender
{
    // 未登录
    UIButton *button = (UIButton *)sender ;
    int inx = button.tag - KCoverBtnTag ;
    switch (inx) {
        case 0:
        {
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 button.alpha = 0;
            } completion:^(BOOL finished) {
                [button removeFromSuperview];
            }];
        }
            break;
        case 1:
        {
            /*
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 button.alpha = 0;
                             } completion:^(BOOL finished) {
                                 [button removeFromSuperview];
                                 __block UIButton *btn = (UIButton *)[MyAppDelegate.window viewWithTag:KCoverBtnTag+2];
                                 [UIView animateWithDuration:0.25f animations:^{
                                     btn.alpha = 1;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
                             }];
             */
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 button.alpha = 0;
                             } completion:^(BOOL finished) {
                                 [button removeFromSuperview];
                             }];
            
        }
            break;
        case 2:
        {
            [UIView animateWithDuration:0.25f
                             animations:^{
                                 button.alpha = 0;
                             } completion:^(BOOL finished) {
                                 [button removeFromSuperview];
                             }];
        }
            break;
    }
}

- (UIView *)removeStatusView:(int)tag
{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version>=7.0) {
        UIView *view = (UIView *)[self.navigationController.navigationBar viewWithTag:tag];
        return view;
    }
    return nil;
}

- (void)removeDirected
{
    pressNum ++;
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    UIImageView *imageview = (UIImageView*)[window viewWithTag:TAG_IMG_LOGIN0];
    [imageview removeFromSuperview];
    
    UIWindow* window1 = [UIApplication sharedApplication].keyWindow;
    UIImageView *imageview1 = (UIImageView*)[window1 viewWithTag:TAG_IMG_LOGIN1];
    [imageview1 removeFromSuperview];
    
    UIWindow* windowNo = [UIApplication sharedApplication].keyWindow;
    UIImageView *imageviewNo = (UIImageView*)[windowNo viewWithTag:TAG_IMG_NOLOGIN];
    [imageviewNo removeFromSuperview];
}

//added by wensj 20140303
- (void)handleRefreshItemsNotification:(NSNotification *)aNotification
{
    [self refreshData];
}

//added by wensj 20140303
- (void)refreshData
{
    //如果当前页面不显示时，则不刷新数据
    if (nil == self.view.window) {
        return;
    }
    
    DDLogInfo(@"当前显示页面刷新");
    
    // 轮播广告
    [self fetchAdList];
    
    if ([Global sharedInstance].isLogin) {
        // 已登录
        
        // 客户信息查询
        [self fetchCustInfo];
        // 流量信息查询
        [self queryFlowInfo];
        
        
        // 实时话费查询[帐户级]
        if (self.billInfo) {
            [self queryBillInfo];
        }
        // 可用余额查询
        if (self.canuse) {
            [self queryCanuse];
        }
        
        // 剩余通话
        if (self.ppaccuInfo) {
            [self queryPpaccuInfo];
        }
        // 我的积分
        if (self.pointInfo) {
            [self fetchPointInfo];
        }
        //刷新消息中心
        [self reloadMsg];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 已登录 && 时间差大于2min && 有显示的数据 && 该接口没在请求中
    // 那么更新数据
    
    // 计算时间差
    DDLogInfo(@"上次刷新时间：%@", [Global sharedInstance].reloadHomeTime);
    NSTimeInterval secs = -1*[[Global sharedInstance].reloadHomeTime timeIntervalSinceNow];
    DDLogInfo(@"两次显示时间差：%f", secs);
    
    if (secs > 120) {
        // 时间差大于2min
        
        // 更新刷新数据时间
        [Global sharedInstance].reloadHomeTime = [NSDate date];
        
        // 有显示的数据，那么更新数据
        // 用户、流量、话费、剩余通话、积分
        
        // 轮播广告
        [self fetchAdList];
        
        if ([Global sharedInstance].isLogin) {
            // 已登录
            
            // 客户信息查询
            [self fetchCustInfo];
            // 流量信息查询
            [self queryFlowInfo];
            
            
            // 实时话费查询[帐户级]
            if (self.billInfo) {
                [self queryBillInfo];
            }
            // 可用余额查询
            if (self.canuse) {
                [self queryCanuse];
            }
            
            // 剩余通话
            if (self.ppaccuInfo) {
                [self queryPpaccuInfo];
            }
            // 我的积分
            if (self.pointInfo) {
                [self fetchPointInfo];
            }
            
            //刷新消息中心
            [self reloadMsg];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 消息中心通知消息

#pragma 更新个人积分  added by liuruxian 2014-04-04
- (void)qryPoint
{
    [self fetchPointInfo];
}

- (void) reloadMsg
{
    [self getData];
    [self directedLayout];
}

- (void) dismissMsg
{
    [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"]
                 isShow:NO msgCount:[NSString stringWithFormat:@"%d",0]];
}

// added by zy, 2014-02-17
- (void)onLoginSuccessNotification
{
    // 轮播广告
    [self fetchAdList];
    
    if ([Global sharedInstance].isLogin)
    {
        // 已登录
        
        // 客户信息查询
        [self fetchCustInfo];
        // 流量信息查询
        [self queryFlowInfo];
        
        
        // 实时话费查询[帐户级]
        if (self.billInfo) {
            [self queryBillInfo];
        }
        // 可用余额查询
        if (self.canuse) {
            [self queryCanuse];
        }
        
        // 剩余通话
        if (self.ppaccuInfo) {
            [self queryPpaccuInfo];
        }
        // 我的积分
        if (self.pointInfo) {
            [self fetchPointInfo];
        }
    }
}

// added by zy, 2014-04-02
- (void)didRefreshNewFlag
{
    [self reloadHScrollView];
}

#pragma mark - 获取消息中心未读数据

- (void) getData
{
    
    BOOL isloadMsgCenter = YES;
    if (![Global sharedInstance].isLogin)
    {
        isloadMsgCenter = NO;
    }
    
    __block int total = 0;
    // 获取消息中心的条数 和 公告的条数
    {
        NSString *PhoneNbr = [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] ? [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] : @"";
        NSString *Type = @"3";
        NSString *Index =  [NSString stringWithFormat:@"%d",1]; //页码
        NSString *PageSize = @"20"; //每页显示的数量
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                PageSize      , @"PageSize",
                                Type          , @"Type",
                                ESHORE_ShopId , @"ShopId",
                                PhoneNbr      , @"PhoneNbr",
                                Index         , @"Index",
                                nil];
        //公告数据请求
        [MyAppDelegate.cserviceEngine postXMLWithCode:@"queryadlist"
                                                params:params
                                                onSucceeded:^(NSDictionary *dict)
                                               {
                                                   DDLogInfo(@"获取第一步的订单id成功 %s--%@", __func__, dict.description);
                                                   NSDictionary *Data = [dict objectForKey:@"Data"];
                                                   if (Data && [Data respondsToSelector:@selector(objectForKey:)]){

                                                       NSString *TotalCount = [Data objectForKey:@"TotalCount"]; //返回数量个数
                                                       if (TotalCount && TotalCount.length > 0) {
                                                           NSArray *msgReqAry = nil;
                                                           if ([TotalCount intValue] > 1) {
                                                               msgReqAry = [NSArray arrayWithArray:[Data objectForKey:@"AdItem"]];
                                                           }else if([TotalCount intValue] == 1)
                                                           {
                                                               msgReqAry = [NSArray arrayWithObject:[Data objectForKey:@"AdItem"]];
                                                           }
                                                           //匹配公告数据
                                                           total += [self matchData:ANNOUNCEFILE dataAry:msgReqAry type:0];
                                                           
                                                           self.msgCenterCount = total;
                                                           
                                                           if (total==0) {
                                                               [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"] isShow:NO msgCount:[NSString stringWithFormat:@"%d",total]];
                                                           }else{
                                                               [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"] isShow:YES msgCount:[NSString stringWithFormat:@"%d",total]];
                                                           }
                                                       } else {
                                                           [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"]
                                                                        isShow:NO msgCount:[NSString stringWithFormat:@"%d",total]];
                                                       }
                                                       
                                                   }
                                               } onError:^(NSError *engineError) {
                                                   DDLogInfo(@"%s--%@", __func__, engineError);
                                                   
                                                   [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"]
                                                                isShow:NO msgCount:[NSString stringWithFormat:@"%d",total]];
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
    
    if (!isloadMsgCenter) {
        return ;
    }
    
    //获取公告数据
    {
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
        NSString* Timestamp = [formatter stringFromDate:date];
        Timestamp = [Timestamp stringByReplacingOccurrencesOfString:@"-" withString:@""];
        Timestamp = [Timestamp stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        NSString *PhoneNum = [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] ? [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] : @"";;
        
        NSString *InType = @"0";
        NSString *Index =  [NSString stringWithFormat:@"%d",1]; //页码
        NSString *PageSize = @"20"; //每页显示的数量
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                PageSize      , @"PageSize",
                                InType        , @"InType",
                                ESHORE_ShopId , @"ShopId",
                                PhoneNum      , @"PhoneNum",
                                Index         , @"Index",
                                Timestamp     , @"Timestamp",
                                nil];

        [MyAppDelegate.cserviceEngine postXMLWithCode:@"getMessageList"
                                               params:params
                                          onSucceeded:^(NSDictionary *dict){
                                             DDLogInfo(@"获取第一步的订单id成功 %s--%@", __func__, dict.description);
                                              
                                             NSDictionary *Data = [dict objectForKey:@"Data"];
                                             if (Data && [Data respondsToSelector:@selector(objectForKey:)])
                                             {
                                                 NSString *TotalCount = [Data objectForKey:@"Count"]; //返回数量个数
                                                 if (TotalCount && TotalCount.length > 0)
                                                 {
                                                     NSArray *annoAry = nil;
                                                     if ([TotalCount intValue] > 1)
                                                     {
                                                         annoAry = [NSArray arrayWithArray:[Data objectForKey:@"Item"]] ;
                                                         
                                                     } else if([TotalCount intValue] == 1)
                                                     {
                                                         annoAry = [NSArray arrayWithObject:[Data objectForKey:@"Item"]];
                                                     }
                                                     
                                                     total += [self matchData:MESSAGEFILE dataAry:annoAry type:1];
                                                     
                                                     self.msgCenterCount = total;
                                                     
                                                     if (total==0) {
                                                         [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"]
                                                                      isShow:NO msgCount:[NSString stringWithFormat:@"%d",total]];
                                                     }else{
                                                         [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"]
                                                                      isShow:YES msgCount:[NSString stringWithFormat:@"%d",total]];
                                                     }
                                                     
                                                 } else {
                                                     [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"]
                                                                  isShow:NO msgCount:[NSString stringWithFormat:@"%d",total]];
                                                 }
                                             }
                                              
                                         } onError:^(NSError *engineError) {
                                             DDLogInfo(@"%s--%@", __func__, engineError);
                                             [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"]
                                                          isShow:NO msgCount:[NSString stringWithFormat:@"%d",total]];
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

- (void)setLeftButton:(UIImage *)image isShow : (BOOL) isShow msgCount : (NSString *)count
{
    if (!image)
    {
        return;
    }
    
//    int x = (image.size.width > 40 ? 0 : 10);
#if 0   // modified by zy, 2014-02-25
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width + x, image.size.height)];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
#endif
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 0, /*image.size.width + x*/image.size.width, image.size.height); // modified by zy, 2014-02-25
    [btn setImage:image forState:UIControlStateNormal];
#if 0   // modified by zy, 2014-02-25
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, x)];
#endif
    [btn addTarget:self action:@selector(onLeftBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    [imageView addSubview:btn];   // modified by zy, 2014-02-25
    if (isShow)
    {
        UIImage *bgimage = [UIImage imageNamed:@"prettyNum_squre_icon.png"];
#if 0   // modified by zy, 2014-02-25
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame)-28, btn.frame.origin.y-3, 10, 10)];
#else
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame)-22, btn.frame.origin.y-6, bgimage.size.width, bgimage.size.height)];
#endif
        
        imageView.backgroundColor = [UIColor clearColor];
//        imageView.layer.cornerRadius = 6;
        imageView.image = bgimage;
        imageView.userInteractionEnabled = YES ;
        [btn addSubview:imageView];
        
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, imageView.frame.size.width+1, imageView.frame.size.height-2)];
        lab.backgroundColor = [UIColor clearColor];
        lab.textAlignment = UITextAlignmentCenter ;
        lab.textColor = [UIColor whiteColor];
        lab.text = count;
        lab.font = [UIFont systemFontOfSize:9];
        [imageView addSubview:lab];
    }
    
    UIBarButtonItem *baritem = [[UIBarButtonItem alloc] initWithCustomView:/*imageView*/btn];   // modified by zy, 2014-02-25
    self.navigationItem.leftBarButtonItem = baritem;
}

- (void)setRightButton:(UIImage *)image
{
    if (!image)
    {
        return;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, image.size.width/*image.size.width + x*/, image.size.height);  // modified by zy, 2014-02-25
    [btn setImage:image forState:UIControlStateNormal];
#if 0   // modified by zy, 2014-02-25
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, x)];
#endif
    [btn addTarget:self action:@selector(onRightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = btn;
    self.rightBtn.exclusiveTouch = YES;
    UIBarButtonItem *baritem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = baritem;
}


//匹配数据
- (int) matchData : (NSString *)filePath dataAry : (NSArray *) dataAry type : (int) type
{
    NSString *configname = [NSString stringWithFormat:@"%@/%@", [Utils getDocumentPath],filePath];
    int count = dataAry.count;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:configname])  //判断当前文件是否存在
    {
        NSArray *array = [NSMutableArray arrayWithContentsOfFile:configname]; // 读数据
        NSMutableArray *configArray = [[NSMutableArray alloc] initWithArray: [NSMutableArray arrayWithContentsOfFile:configname]];
        if (configArray.count>0) {
            for (int i=0; i<[array count]; i++) {
                NSDictionary *dictionary = array[i];
                for (int j =0; j<configArray.count; j++) {
                    if (type==0) {
                        NSString *title  = [dictionary objectForKey:@"Title"];
                        NSString *title1 = [configArray[j] objectForKey:@"Title"];
                        if ([title isEqualToString:title1]) {
                            count --;
                            break;
                        }
                    }else{
                        NSString *Id  = [dictionary objectForKey:@"Id"];
                        NSString *Id1 = [configArray[j] objectForKey:@"Id"];
                        if ([Id isEqualToString:Id1]) {
                            count --;
                            break;
                        }
                    }
            
                }
            }
            if (count<0) {
                count = 0;
            }
            return count;
        } else {
            return count;
        }
    }
    return count;
}

#pragma mark - 获取数据

- (void)fetchAdList
{
    // 获取广告数据
    
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNbr = loginInfoDict[@"UserLoginName"] ? loginInfoDict[@"UserLoginName"] : @"";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            ESHORE_ShopId, @"ShopId",
                            phoneNbr, @"PhoneNbr",
                            @"2", @"Type",    // 1：消息中心 2：首页轮换位 3：促销优惠列表 4：公告 5：天翼应用轮换位
                            @"1", @"Index",
                            @"10", @"PageSize", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"queryadlist"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) { 
                                          [self.adList removeAllObjects];
                                          [self.adList addObjectsFromArray:dict[@"Data"][@"AdItem"]];
                                          [self.adView reloadData];
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

// 客户信息查询
- (void)fetchCustInfo
{
    // added by zy, 2014-04-18
    [Global sharedInstance].userInfoDict = nil;
    
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNbr = loginInfoDict[@"UserLoginName"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            phoneNbr, @"PhoneNbr", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"custInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          self.custInfo = dict[@"Data"];
                                          
                                          if (self.flowInfo) {
                                              CGFloat UsedAmount = [self.flowInfo[@"UsedAmount"] intValue]/1024;
                                              CGFloat AccAmount = [self.flowInfo[@"AccAmount"] intValue]/1024;
                                              [self.flowView setUserName:self.custInfo[@"Cust_Name"] usedFlow:UsedAmount allFlow:AccAmount];
                                          }
                                          else
                                          {
                                              [self.flowView setUserName:self.custInfo[@"Cust_Name"] usedFlow:0.0f allFlow:0.0f];
                                          }
                                          
                                          [_simpleInfoView setUserName:self.custInfo[@"Cust_Name"]];
                                          
                                          // added by zy, 2014-04-18
                                          [Global sharedInstance].userInfoDict = self.custInfo;
                                          [[NSNotificationCenter defaultCenter] postNotificationName:CTHomeVCtlerDidRefreshUserInfoNotification object:nil];
                                          // added by zy, 2014-04-18
                                          
                                      } onError:^(NSError *engineError) {
                                          if (self.flowInfo) {
                                              CGFloat UsedAmount = [self.flowInfo[@"UsedAmount"] intValue]/1024;
                                              CGFloat AccAmount = [self.flowInfo[@"AccAmount"] intValue]/1024;
                                              [self.flowView setUserName:@"－－" usedFlow:UsedAmount allFlow:AccAmount];
                                          }
                                          else
                                          {
                                              [self.flowView setUserName:@"－－" usedFlow:0.0f allFlow:0.0f];
                                          }
                                          
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
                                          
                                          [_simpleInfoView setUserName:@"－－"];
                                          
                                      }];
}

// 流量信息查询
- (void)queryFlowInfo
{
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNum = loginInfoDict[@"UserLoginName"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            phoneNum, @"PhoneNum", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"queryFlowInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          self.flowInfo = dict[@"Data"];
                                          
                                          if (self.custInfo) {
                                              CGFloat UsedAmount = [self.flowInfo[@"UsedAmount"] intValue]/1024;
                                              CGFloat AccAmount = [self.flowInfo[@"AccAmount"] intValue]/1024;
                                              [self.flowView setUserName:self.custInfo[@"Cust_Name"] usedFlow:UsedAmount allFlow:AccAmount];
                                          }
                                          else
                                          {
                                              CGFloat UsedAmount = [self.flowInfo[@"UsedAmount"] intValue]/1024;
                                              CGFloat AccAmount = [self.flowInfo[@"AccAmount"] intValue]/1024;
                                              [self.flowView setUserName:@"－－" usedFlow:UsedAmount allFlow:AccAmount];
                                          }
                                          
                                          {
                                              CGFloat UsedAmount = [self.flowInfo[@"UsedAmount"] intValue]/1024;
                                              CGFloat AccAmount = [self.flowInfo[@"AccAmount"] intValue]/1024;
                                              [_simpleInfoView setUsedFlow:UsedAmount allFlow:AccAmount];
                                          }
                                          
                                      } onError:^(NSError *engineError) {
                                          
                                          if (self.custInfo) {
                                              [self.flowView setUserName:self.custInfo[@"Cust_Name"] usedFlow:0.0f allFlow:0.0f];
                                          }
                                          else
                                          {
                                              [self.flowView setUserName:@"－－" usedFlow:0.0f allFlow:0.0f];
                                          }
                                          
                                          {
                                              [_simpleInfoView setUsedFlow:0.0f allFlow:0.0f];
                                          }
                                          
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

// 实时话费查询[帐户级]
- (void)queryBillInfo
{
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNum = loginInfoDict[@"UserLoginName"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMM"];
    NSString *month =  [df stringFromDate:[NSDate date]];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            phoneNum, @"PhoneNum",
                            month, @"Month", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"queryBillInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          self.billInfo = dict[@"Data"];
                                          
                                          [_accountInfoView setAccountInfo:self.billInfo[@"SumCharge"] atIndex:1];
                                          [_simpleInfoView setBenYueHuaFei:self.billInfo[@"SumCharge"]];
                                          
                                      } onError:^(NSError *engineError) {
                                          
                                          [_accountInfoView setAccountInfo:nil atIndex:1];
                                          [_simpleInfoView setBenYueHuaFei:@"－－"];
                                          
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

// 可用余额查询
- (void)queryCanuse
{
    // added by zy, 2014-04-04
    if (self.isLoadingCanuse) {
        return;
    }
    // added by zy, 2014-04-04
    
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNum = loginInfoDict[@"UserLoginName"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            phoneNum, @"PhoneNum", nil];
    
    self.isLoadingCanuse = YES;     // added by zy, 2014-04-04
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"queryCanuse"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          self.isLoadingCanuse = NO;    // added by zy, 2014-04-04
                                          self.canuse = dict[@"Data"];
                                          
                                          [_accountInfoView setAccountInfo:self.canuse[@"TotalBalance"] atIndex:2];
                                          [_simpleInfoView setDangQianYuE:self.canuse[@"TotalBalance"]];
                                          
                                      } onError:^(NSError *engineError) {

                                          self.isLoadingCanuse = NO;    // added by zy, 2014-04-04
                                          [_accountInfoView setAccountInfo:nil atIndex:2];
                                          [_simpleInfoView setDangQianYuE:@"－－"];
                                          
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

// 剩余通话 其实是查询“套餐使用情况查询 queryPpaccuInfo”然后自己计算出来
- (void)queryPpaccuInfo
{
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNum = loginInfoDict[@"UserLoginName"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            phoneNum, @"PhoneNum", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"queryPpaccuInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          self.ppaccuInfo = dict[@"Data"];
                                          
                                          // 你妹的自己加工数据
                                          int duration = 0;
                                          if ([dict[@"Data"][@"AccList"] isKindOfClass:[NSArray class]])
                                          {
                                              NSArray *AccList = [NSArray arrayWithArray:dict[@"Data"][@"AccList"]];
                                              for (NSDictionary *AccListDict in AccList) {
                                                  if ([AccListDict[@"Item"] isKindOfClass:[NSDictionary class]])
                                                  {
                                                      // 单独一个信息
                                                      NSString *AccuRscName = AccListDict[@"Item"][@"AccuRscName"];
                                                      int BalanceAmount = [AccListDict[@"Item"][@"BalanceAmount"] intValue];
                                                      int UnitTypeId = [AccListDict[@"Item"][@"UnitTypeId"] intValue];
                                                      
                                                      if (UnitTypeId == 1 &&
                                                          [AccuRscName rangeOfString:@"wifi" options:NSCaseInsensitiveSearch].location == NSIntegerMax &&
                                                          [AccuRscName rangeOfString:@"wlan" options:NSCaseInsensitiveSearch].location == NSIntegerMax)
                                                      {
                                                          duration += BalanceAmount;
                                                      }
                                                  }
                                                  else if ([AccListDict[@"Item"] isKindOfClass:[NSArray class]])
                                                  {
                                                      //多个信息
                                                      for (NSDictionary *ItemDict in AccListDict[@"Item"]) {
                                                          NSString *AccuRscName = ItemDict[@"AccuRscName"];
                                                          int BalanceAmount = [ItemDict[@"BalanceAmount"] intValue];
                                                          int UnitTypeId = [ItemDict[@"UnitTypeId"] intValue];
                                                          
                                                          if (UnitTypeId == 1 &&
                                                              [AccuRscName rangeOfString:@"wifi" options:NSCaseInsensitiveSearch].location == NSIntegerMax &&
                                                              [AccuRscName rangeOfString:@"wlan" options:NSCaseInsensitiveSearch].location == NSIntegerMax)
                                                          {
                                                              duration += BalanceAmount;
                                                          }
                                                      }
                                                  }
                                              }
                                          }
                                          else if ([dict[@"Data"][@"AccList"] isKindOfClass:[NSDictionary class]])
                                          {
                                              NSArray *AccList = [NSArray arrayWithObject:dict[@"Data"][@"AccList"]];
                                              for (NSDictionary *AccListDict in AccList) {
                                                  if ([AccListDict[@"Item"] isKindOfClass:[NSDictionary class]])
                                                  {
                                                      // 单独一个信息
                                                      NSString *AccuRscName = AccListDict[@"Item"][@"AccuRscName"];
                                                      int BalanceAmount = [AccListDict[@"Item"][@"BalanceAmount"] intValue];
                                                      int UnitTypeId = [AccListDict[@"Item"][@"UnitTypeId"] intValue];
                                                      
                                                      if (UnitTypeId == 1 &&
                                                          [AccuRscName rangeOfString:@"wifi" options:NSCaseInsensitiveSearch].location == NSIntegerMax &&
                                                          [AccuRscName rangeOfString:@"wlan" options:NSCaseInsensitiveSearch].location == NSIntegerMax)
                                                      {
                                                          duration += BalanceAmount;
                                                      }
                                                  }
                                                  else if ([AccListDict[@"Item"] isKindOfClass:[NSArray class]])
                                                  {
                                                      //多个信息
                                                      for (NSDictionary *ItemDict in AccListDict[@"Item"]) {
                                                          NSString *AccuRscName = ItemDict[@"AccuRscName"];
                                                          int BalanceAmount = [ItemDict[@"BalanceAmount"] intValue];
                                                          int UnitTypeId = [ItemDict[@"UnitTypeId"] intValue];
                                                          
                                                          if (UnitTypeId == 1 &&
                                                              [AccuRscName rangeOfString:@"wifi" options:NSCaseInsensitiveSearch].location == NSIntegerMax &&
                                                              [AccuRscName rangeOfString:@"wlan" options:NSCaseInsensitiveSearch].location == NSIntegerMax)
                                                          {
                                                              duration += BalanceAmount;
                                                          }
                                                      }
                                                  }
                                              }
                                          }
                                          
                                          [_accountInfoView setAccountInfo:[NSString stringWithFormat:@"%d", duration] atIndex:3];
                                          
                                      } onError:^(NSError *engineError) {
                                          
                                          [_accountInfoView setAccountInfo:nil atIndex:3];
                                          
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

// 我的积分
- (void)fetchPointInfo
{
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNbr = loginInfoDict[@"UserLoginName"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            phoneNbr, @"PhoneNbr",
                            @"11", @"CodeType", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"pointInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          self.pointInfo = dict[@"Data"];
                                          
                                          [_accountInfoView setAccountInfo:self.pointInfo[@"PointValue"] atIndex:4];
                                          
                                      } onError:^(NSError *engineError) {
                                          
                                          [_accountInfoView setAccountInfo:nil atIndex:4];
                                          
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

#pragma mark - self func

- (void)setMiddlePersonView
{
    if ([Global sharedInstance].isLogin)
    {
        // 已登录
        
        CGFloat vOffset = 125.0f;
        if (iPhone5) {
            vOffset = 150.0f;
        }
        
        if ([[Utils getDisplayMode] isEqualToString:@"0"]) {
            // 圆环模式
            
            _accountInfoView.alpha = 1.0f;
            _accountInfoView.hidden = NO;
            _simpleInfoView.alpha = 0.0f;
            _simpleInfoView.hidden = YES;
            self.arrowDown.hidden = YES;
            self.arrowDownLabel.hidden = YES;
            {
                NSMutableArray *iconList = [NSMutableArray array];
                [iconList addObjectsFromArray:self.defaultIconList];
                [iconList addObjectsFromArray:[Utils getCustomIconList]];
                
#if 0           // modified by zy, 2014-04-08
                // added by zy, 2014-02-19
                {
                    [iconList removeObjectAtIndex:5];
                    [iconList addObject:[self.defaultIconList lastObject]];
                }
                // added by zy, 2014-02-19
#endif
                
                if ([iconList count] > 6)
                {
                    self.arrowLeft.hidden = NO;
                    self.arrowRight.hidden = NO;
                    self.pageControl.hidden = NO;
                }
                else
                {
                    self.arrowLeft.hidden = YES;
                    self.arrowRight.hidden = YES;
                    self.pageControl.hidden = YES;
                }
            }
            
            self.vScrollView.contentOffset = CGPointMake(0, 0);
            self.vScrollView.scrollEnabled = YES;
            self.hScrollView.contentOffset = CGPointMake(0, 0);
            self.hScrollView.scrollEnabled = NO;
            
            // 客户信息查询
            [self fetchCustInfo];
            // 流量信息查询
            [self queryFlowInfo];
            
            _topLineView.hidden = NO;   // added by zy, 2014-02-19
        }
        else
        {
            // 简介模式
            
            _accountInfoView.alpha = 0.0f;
            _accountInfoView.hidden = YES;
            _simpleInfoView.alpha = 1.0f;
            _simpleInfoView.hidden = NO;
            self.arrowDown.hidden = NO;
            self.arrowDownLabel.hidden = NO;
            {
                NSMutableArray *iconList = [NSMutableArray array];
                [iconList addObjectsFromArray:self.defaultIconList];
                [iconList addObjectsFromArray:[Utils getCustomIconList]];
                
#if 0           // modified by zy, 2014-04-08
                // added by zy, 2014-02-19
                {
                    [iconList removeObjectAtIndex:5];
                    [iconList addObject:[self.defaultIconList lastObject]];
                }
                // added by zy, 2014-02-19
#endif
                
                if ([iconList count] > 6)
                {
                    self.arrowLeft.hidden = NO;
                    self.arrowRight.hidden = NO;
                    self.pageControl.hidden = NO;
                }
                else
                {
                    self.arrowLeft.hidden = YES;
                    self.arrowRight.hidden = YES;
                    self.pageControl.hidden = YES;
                }
            }
            
            self.vScrollView.contentOffset = CGPointMake(0, vOffset);
            self.vScrollView.scrollEnabled = YES;
            self.hScrollView.contentOffset = CGPointMake(0, 0);
            self.hScrollView.scrollEnabled = YES;
            
            // 客户信息查询
            [self fetchCustInfo];
            // 流量信息查询
            [self queryFlowInfo];
            // 实时话费查询[帐户级]
            [self queryBillInfo];
            // 可用余额查询
            [self queryCanuse];
            
            _topLineView.hidden = YES;   // added by zy, 2014-02-19
        }
    }
    else
    {
        // 未登录
        
        {
            _accountInfoView.alpha = 0.0f;
            _accountInfoView.hidden = YES;
            _simpleInfoView.alpha = 0.0f;
            _simpleInfoView.hidden = YES;
            self.arrowDown.hidden = YES;
            self.arrowDownLabel.hidden = YES;
            self.arrowLeft.hidden = YES;
            self.arrowRight.hidden = YES;
            self.pageControl.hidden = YES;
        }
        
        CGFloat h2 = 45.0f;
        CGFloat vOffset = 125.0f;
        if (iPhone5) {
            h2 = 50.0f;
            vOffset = 150.0f;
        }
        
        _loginView = [[UIView alloc] initWithFrame:self.middlePersonView.bounds];
        [self.middlePersonView addSubview:_loginView];
        
        UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(250, (h2-29)/2.0f, 29, 29)];
        rightArrow.image = [UIImage imageNamed:@"home_right_arrow"];
        [_loginView addSubview:rightArrow];
        
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        loginBtn.frame = self.middlePersonView.bounds;
        loginBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [loginBtn setTitle:@"想看更多亮点，请点我登录" forState:UIControlStateNormal];
        [loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginView addSubview:loginBtn];
        
        self.vScrollView.contentOffset = CGPointMake(0, vOffset);
        self.vScrollView.scrollEnabled = NO;
        self.hScrollView.contentOffset = CGPointMake(0, 0);
        self.hScrollView.scrollEnabled = NO;
        
        _topLineView.hidden = YES;   // added by zy, 2014-02-20
    }
}

- (void)reloadHScrollView
{
    // 移除所有子视图
    [self.hScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *iconList = [NSMutableArray array];
    [iconList addObjectsFromArray:self.defaultIconList];
    [iconList addObjectsFromArray:[Utils getCustomIconList]];
    
#if 0           // modified by zy, 2014-04-08
    // added by zy, 2014-02-19
    {
        [iconList removeObjectAtIndex:5];
        [iconList addObject:[self.defaultIconList lastObject]];
    }
    // added by zy, 2014-02-19
#endif
    
    if ([iconList count] > 6)
    {
        self.arrowLeft.hidden = NO;
        self.arrowRight.hidden = NO;
        self.pageControl.hidden = NO;
    }
    else
    {
        self.arrowLeft.hidden = YES;
        self.arrowRight.hidden = YES;
        self.pageControl.hidden = YES;
    }
    
    // 页数、列、行
    int pages = 0;
    if (([iconList count] % 6) > 0) {
        pages = [iconList count]/6 + 1;
    }
    else
    {
        pages = [iconList count]/6;
    }
    
    // added by zy, 2014-04-02
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    BOOL showNewFlag = (![def objectForKey:kHasLookupCustomViewKey] && ![def objectForKey:kCTAddrBookSyncStatusKey]);
    // added by zy, 2014-04-02
    
    int num = 0;
    for (int i = 0; i < pages; i++)
    {
        for (int j = 0; j < 2; j++)
        {
            for (int k = 0; k < 3; k++)
            {
                if (num < [iconList count]) {
                    CGFloat pageOffset = 320 * i;
                    CGFloat colOffset = 1 + 90 * j;
                    CGFloat rowOffset = 20 + 95 * k;
                    if (iPhone5) {
                        colOffset = 20 + 95 * j;
                    }
                    
                    CTCustomIcon *icon = [[CTCustomIcon alloc] initWithOrigin:CGPointMake(pageOffset + rowOffset, colOffset)
                                                                        image:[UIImage imageNamed:iconList[num][@"icon"]]
                                                                        hlImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_hl", iconList[num][@"icon"]]]
                                                                        title:iconList[num][@"title"]];
                    [icon.iconButton addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
                    icon.iconButton.tag = num;
                    [self.hScrollView addSubview:icon];
                    
                    // added by zy, 2014-04-02
                    if (showNewFlag && [iconList[num][@"title"] isEqualToString:@"自定义"]) {
                        UIImageView* newImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_updata_new"]];
                        newImg.center = CGPointMake(CGRectGetMaxX(icon.frame), CGRectGetMinY(icon.frame));
                        [icon addSubview:newImg];
                    }
                    // added by zy, 2014-04-02
                    
                    num++;
                }
                else
                {
                    break;
                }
            }
        }
    }
    
    self.hScrollView.contentSize = CGSizeMake(self.hScrollView.bounds.size.width * pages, self.hScrollView.contentSize.height);
    
    {
        [self.pageControl setNumberOfPages:pages];
#if 0   // modified by zy, 2014-04-10
        [self.pageControl setCurrentPage:0];
#else
        [self.pageControl setCurrentPage:pages-1];
        [self.hScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.hScrollView.frame)*(pages-1), 0) animated:YES];
#endif
    }
}

- (void)loginAction
{
    // 登录
    CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
    }];
}

- (void)iconAction:(UIButton *)sender
{
    NSMutableArray *iconList = [NSMutableArray array];
    [iconList addObjectsFromArray:self.defaultIconList];
    [iconList addObjectsFromArray:[Utils getCustomIconList]];
    
#if 0           // modified by zy, 2014-04-08
    // added by zy, 2014-02-19
    {
        [iconList removeObjectAtIndex:5];
        [iconList addObject:[self.defaultIconList lastObject]];
    }
    // added by zy, 2014-02-19
#endif
    
    NSString *title = iconList[sender.tag][@"title"];
    
    // modified by liuruxian
    self.iconSelectedBtn = sender ;
    
    if ([title isEqualToString:@"充值缴费"])
    {
        DDLogInfo(@"充值缴费");
        CTRechargeVCtler *vc =  [[CTRechargeVCtler alloc] init];
        vc.isPush = YES;
        [vc pageIndex:0];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([title isEqualToString:@"免费短信"])
    {
        DDLogInfo(@"免费短信");
        // 暂无
    }
    else if ([title isEqualToString:@"合约机"])
    {
        DDLogInfo(@"合约机");
        
        //change by yanw
        if (1) {
            CTPhoneListViewController *phoneListViewController = [[CTPhoneListViewController alloc] init];
            phoneListViewController.phoneType = PhoneTypeContract;
            [self.navigationController pushViewController:phoneListViewController animated:YES];
        } else {
            if ([Global sharedInstance].isLogin)
            {
                CTContractPhoneVCtler *vc = [[CTContractPhoneVCtler alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                CTPreferentialVCtler *vc = [[CTPreferentialVCtler alloc] init];
                [vc setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    else if ([title isEqualToString:@"套餐查询"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"套餐查询");
            CTQryPackageVctler *vc = [CTQryPackageVctler new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"历史账单"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"历史账单");
            CTPayHistoryVCtler *vc = [CTPayHistoryVCtler new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"剩余流量"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"剩余流量");
            CTQrtStreamVCtler *vc = [CTQrtStreamVCtler new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"充流量"])
    {
        DDLogInfo(@"充流量");
        CTRechargeVCtler *vc =  [[CTRechargeVCtler alloc] init];
        vc.isPush = YES;
        [vc pageIndex:1];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([title isEqualToString:@"积分查询"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"积分查询");
            CTPointQueryVCtler *vc = [CTPointQueryVCtler new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"订单查询"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"订单查询");
            CTMyOrderListVCtler *vc = [[CTMyOrderListVCtler alloc] init];
            vc.orderType = @"0";
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"增值业务查询"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"增值业务查询");
            CTQryValueAddVCtler *vc = [CTQryValueAddVCtler new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"业务办理"])
    {
        // modified by liuruxian 2014-05-11
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"业务办理");
            MyAppDelegate.tabBarController.selectedIndex = 1;
            UINavigationController *nav = MyAppDelegate.tabBarController.viewControllers[1];
            CTQueryVCtler * vc = nav.viewControllers[0];
            vc.selectedIndex = 1;
            [MyAppDelegate.tabBarController.viewControllers[1] popToViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"单买手机"])
    {
        DDLogInfo(@"单买手机");
        if (1) {
            CTPhoneListViewController *phoneListViewController = [[CTPhoneListViewController alloc] init];
            phoneListViewController.phoneType = PhoneTypeNude;
            [self.navigationController pushViewController:phoneListViewController animated:YES];
        } else {
            CTBarePhoneVCtler *vc = [[CTBarePhoneVCtler alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if ([title isEqualToString:@"摇摇靓号"])
    {
        DDLogInfo(@"摇摇靓号");
        // 暂无
    }
    else if ([title isEqualToString:@"精选配件"])
    {
        DDLogInfo(@"精选配件");
        // 暂无
    }
    else if ([title isEqualToString:@"换肤"])
    {
        DDLogInfo(@"换肤");
        // 暂无
    }
    else if ([title isEqualToString:@"用户吐槽"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"用户吐槽");
            CTUserFeedbackVCtler *vc = [CTUserFeedbackVCtler new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"设备信息"])
    {
        DDLogInfo(@"设备信息");
        // 暂无
    }
    else if ([title isEqualToString:@"优惠活动"])
    {
        DDLogInfo(@"优惠活动");
        // 暂无
    }
    else if ([title isEqualToString:@"话费查询"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"实时话费");
            CTQryBalanceVCtler *vc = [CTQryBalanceVCtler new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"积分兑换"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"积分兑换");
            CTRedeemVCtler *vc = [CTRedeemVCtler new];
//            CTPPointExchangeVCtler *vc = [CTPPointExchangeVCtler new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"自定义"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"自定义");
            CTCustomPagesVCtler *vc = [[CTCustomPagesVCtler alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
            // added by zy, 2014-04-02
            NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
            if (![def objectForKey:kHasLookupCustomViewKey]) {
                [def setBool:YES forKey:kHasLookupCustomViewKey];
                [def synchronize];
                [self reloadHScrollView];
            }
            // added by zy, 2014-04-02
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"修改密码"])
    {
        if ([Global sharedInstance].isLogin)
        {
            DDLogInfo(@"修改密码");
            CTChangePasswordVCtler *vc = [[CTChangePasswordVCtler alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
        }
    }
    else if ([title isEqualToString:@"精选靓号"])
    {
        // added by zy, 2014-02-18
        CTPrettyNumberVCtler* vctler = [CTPrettyNumberVCtler new];
        [self.navigationController pushViewController:vctler animated:YES];
    }
    else if ([title isEqualToString:@"通讯录助手"])
    {
        // added by zy, 2014-04-02
        if ([Global sharedInstance].isLogin)
        {
            CTAddrBookSyncVCtler* vctler = [CTAddrBookSyncVCtler new];
            [self.navigationController pushViewController:vctler animated:YES];
        }
        else
        {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            vc.isPush = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:nil];
        }
    }
}

- (void)reloadHomeView
{
    // 刷新首页UI
    if (_loginView) {
        [_loginView removeFromSuperview];
        _loginView = nil;
    }

    // 设置右上角按钮
    [self setRightButton:[UIImage imageNamed:@"navigationBar_logout_icon"]];
    
    [self setMiddlePersonView];
}

- (void)onAddFlowAction
{
    DDLogInfo(@"加流量啊！加流量啊！");
    CTRechargeVCtler *vc = [CTRechargeVCtler new] ;
    vc.isPush = YES ;
    [self.navigationController pushViewController:vc animated:YES];
    [vc pageIndex:1];
}

- (void)onSelectFlowViewAction
{
    if (self.flowInfo == nil)
    {
        // 跳转至“流量查询”
        [self queryFlowInfo];
    }
    else {
        // 再次获取流量数据
        CTQrtStreamVCtler *vc = [CTQrtStreamVCtler new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Nav

//消息中心
- (void) onLeftBtnAction:(id)sender
{
    CTMessageCenterVCtler *vc = [CTMessageCenterVCtler new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onRightBtnAction:(id)sender
{
    if ([Global sharedInstance].isLogin)
    {
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
                                  
                                  [self setRightButton:[UIImage imageNamed:@"navigationBar_user_icon"]];
                                  [self.flowView setUserName:@"" usedFlow:0 allFlow:0];
                                  
                                  // 刷新首页
                                  [self setMiddlePersonView];
                                  // 刷新消息中心按钮
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissMsg" object:nil];
                                  
                                  // 所有页面返回到RootVC
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"pop2RootVC" object:nil];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"刷新Tableview" object:nil];
                                  
                                  // added by zy, 2014-02-17，注销登录时，要清除相关ＵＩ的显示
                                  [_accountInfoView reset];
                                  [_simpleInfoView setBenYueHuaFei:@"－－"];
                                  [_simpleInfoView setDangQianYuE:@"－－"];
                                  [_simpleInfoView setUserName:@"－－"];
                                  [_simpleInfoView setUsedFlow:0. allFlow:0.];
                                  // added by zy, 2014-02-17，注销登录时，要清除相关ＵＩ的显示
                                  
                                  _simpleInfoView.hidden = YES;
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }
    else
    {
        CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
        }];
    }
}

#pragma mark - CTPRcScrollviewdelegate

- (void)didClickPage:(CTPRcScrollview *)csView atIndex:(NSInteger)index
{
    DDLogInfo(@"%s atIndex:%d", __func__, index);
    
//    if ([Global sharedInstance].isLogin == NO) {
//        CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//        [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
//        }];
//        return;
//    }
    //网页跳转  与  本地跳转
    if (self.adList && [self.adList count]>0) {
        NSDictionary *dictionary = [self.adList objectAtIndex:index];
        [self jumpPage:dictionary];
    }
}

- (void) autoJumpPage
{
    if(self.jumpDict)
    {
        [self jumpPage:self.jumpDict];
        self.jumpDict = nil;
        return;
    }
    // add by liuruxian 2014-05-14
    if (_iconSelectedBtn) {
        [self iconAction:_iconSelectedBtn];
        _iconSelectedBtn = nil;
    }
}

- (void) jumpPage : (NSDictionary *) dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return ;
    }
    if (!dictionary && ![dictionary respondsToSelector:@selector(objectForKey:)]) {
        return;
    }

     
    NSString * title = dictionary[@"Title"];
    [[NSUserDefaults standardUserDefaults] setObject:title?title:@"" forKey:@"ShareDetail"];
    [[NSUserDefaults standardUserDefaults] synchronize];// 分享title传值
    
    // add by liuruxian 2014-05-14
    NSString * linkTypeStr = [dictionary objectForKey:@"LinkType"];
    NSAssert(linkTypeStr != nil, @"名字不能为空！");

    if (!linkTypeStr && [linkTypeStr length]>0) {
        return ;
    }
    
    int LinkType = [[dictionary objectForKey:@"LinkType"]intValue];
    switch (LinkType) {
        case 2:     //  网页
        {
            NSString *jumpUrl = [dictionary objectForKey:@"Link"];
            // add by liuruxian 2014-05-14
            if (jumpUrl == nil && ![dictionary isKindOfClass:[NSDictionary class]]) {
                return ;
            }
        
            CTDetailVCtler *vc = [CTDetailVCtler new];
            vc.jumpUrl = jumpUrl ;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 1:    // 本地
        {
            NSArray * uiDatas = [self loadUIConfigure];
            // add by liuruxian 2014-05-14
            if (![dictionary objectForKey:@"Link"]) {
                return ;
            }
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
            
            NSString * clsname = [uiDict objectForKey:@"class"];
            NSLog(@"%@", clsname);
            
            BOOL needlogin = [[uiDict objectForKey:@"needlogin"] boolValue];
            
            if ([clsname isEqualToString:[NSString stringWithFormat:@"%@", [self class]]])
            {
                return;
            }
            else if ([clsname isEqualToString:@"CTHomeVCtler"])
            {
//                [self dismissModalViewControllerAnimated:YES];
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
                CTMoreVCtler *vc = [CTMoreVCtler new];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if ([clsname isEqualToString:@"CTRechargeVCtler"])
            {
                // 充话费
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
            if ([Global sharedInstance].isLogin == NO) {
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
            }**/
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

#pragma mark 查找合约机或裸机
- (void) qrySalesProductCompleteInfo : (NSDictionary *) dictionary pageType : (int) type
{
    CTPhoneInfoVCtler *vc = [CTPhoneInfoVCtler new];
    [vc setPhoneInfo:dictionary :type];
    [self.navigationController pushViewController:vc animated:YES];
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
#pragma mark - CTPRcScrollViewDatasource

- (NSInteger)numberOfPages
{
    return [self.adList count] ? [self.adList count] : 1;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    //UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.adView.bounds.size.height)];
    //imageView.backgroundColor = [UIColor clearColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //button.frame = imageView.bounds ;
    button.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.adView.bounds.size.height);
    //[imageView addSubview:button];
    
    NSURL *imageUrl = nil;
    if (index >= 0 && index < [self.adList count]) {
        imageUrl = [NSURL URLWithString:self.adList[index][@"IconUrl"]];
    }
    [button setBackgroundImageWithURL:imageUrl forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ad_default"]];
//    [imageView setImageWithURL:imageUrl
//              placeholderImage:[UIImage imageNamed:@"ad_default"]];
    
    return button;
}

#pragma mark - CTAccountInfoViewDelegate

- (void)didSelectIconAtIndex:(NSInteger)index
{
    switch (index) {
        case 1:
        {
            [self queryBillInfo];
        }
            break;
        case 2:
        {
            [self queryCanuse];
        }
            break;
        case 3:
        {
            [self queryPpaccuInfo];
        }
            break;
        case 4:
        {
            [self fetchPointInfo];
        }
            break;
        default:
            break;
    }
}

#pragma mark - CTSimpleInfoViewDelegate

- (void)didSelectFlowButton
{
    DDLogInfo(@"加流量啊！加流量啊！");
    CTRechargeVCtler *vc = [CTRechargeVCtler new] ;
    [self.navigationController pushViewController:vc animated:YES];
    [vc setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
    [vc pageIndex:1];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1) {
        self.startPoint = scrollView.contentOffset;
        self.rightBtn.userInteractionEnabled = NO;
//        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView.tag == 1) {
        
        CGFloat vOffset = 125.0f;
        if (iPhone5) {
            vOffset = 150.0f;
        }
        
        CGFloat offset = scrollView.contentOffset.y - self.startPoint.y;
        if (offset < 0)
        {
            targetContentOffset->y = 0;
            self.hScrollView.scrollEnabled = NO;
            
            _accountInfoView.hidden = NO;
            _simpleInfoView.hidden = NO;
            self.arrowDown.hidden = YES;
            self.arrowDownLabel.hidden = YES;
            [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 _accountInfoView.alpha = 1.0f;
                                 _simpleInfoView.alpha = 0.0f;
                             }
                             completion:^(BOOL finished){
                                 _accountInfoView.hidden = NO;
                                 _simpleInfoView.hidden = YES;
                                 // add by liuruxian 2014-04-27
                                 self.navigationItem.rightBarButtonItem.enabled = YES;
                                 self.rightBtn.userInteractionEnabled = YES;
                             }
             ];
            
            [Utils saveDisplayMode:@"0"];
            
            _topLineView.hidden = NO;   // added by zy, 2014-02-19
        }
        else if (offset > 0)
        {
            targetContentOffset->y = vOffset;
            self.hScrollView.scrollEnabled = YES;
            
            _accountInfoView.hidden = NO;
            _simpleInfoView.hidden = NO;
            self.arrowDown.hidden = NO;
            self.arrowDownLabel.hidden = NO;
            [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 _accountInfoView.alpha = 0.0f;
                                 _simpleInfoView.alpha = 1.0f;
                             }
                             completion:^(BOOL finished){
                                 _accountInfoView.hidden = YES;
                                 _simpleInfoView.hidden = NO;
                                 // add by liuruxian 2014-04-27
//                                 self.navigationItem.rightBarButtonItem.enabled = YES;
                                  self.rightBtn.userInteractionEnabled = YES;
                             }
             ];
            
            if (self.billInfo == nil) {
                [self queryBillInfo];
            }
            if (self.canuse == nil) {
                [self queryCanuse];
            }
            
            [Utils saveDisplayMode:@"1"];
            
            _topLineView.hidden = YES;  // added by zy, 2014-02-19
        }
        else
        {
            DDLogInfo(@"特殊情况");
            if (scrollView.contentOffset.y >= vOffset/2.0f) {
                targetContentOffset->y = vOffset;
                self.hScrollView.scrollEnabled = YES;
                
                _accountInfoView.hidden = NO;
                _simpleInfoView.hidden = NO;
                self.arrowDown.hidden = NO;
                self.arrowDownLabel.hidden = NO;
                [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     _accountInfoView.alpha = 0.0f;
                                     _simpleInfoView.alpha = 1.0f;
                                 }
                                 completion:^(BOOL finished){
                                     _accountInfoView.hidden = YES;
                                     _simpleInfoView.hidden = NO;
                                     // add by liuruxian 2014-04-27
//                                     self.navigationItem.rightBarButtonItem.enabled = YES;
                                      self.rightBtn.userInteractionEnabled = YES;
                                 }
                 ];
                
                if (self.billInfo == nil) {
                    [self queryBillInfo];
                }
                if (self.canuse == nil) {
                    [self queryCanuse];
                }
                
                [Utils saveDisplayMode:@"1"];
                
                _topLineView.hidden = YES;  // added by zy, 2014-02-19
            }
            else
            {
                targetContentOffset->y = 0;
                self.hScrollView.scrollEnabled = NO;
                
                _accountInfoView.hidden = NO;
                _simpleInfoView.hidden = NO;
                self.arrowDown.hidden = YES;
                self.arrowDownLabel.hidden = YES;
                [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     _accountInfoView.alpha = 1.0f;
                                     _simpleInfoView.alpha = 0.0f;
                                 }
                                 completion:^(BOOL finished){
                                     _accountInfoView.hidden = NO;
                                     _simpleInfoView.hidden = YES;
                                     // add by liuruxian 2014-04-27
//                                     self.navigationItem.rightBarButtonItem.enabled = YES;
                                      self.rightBtn.userInteractionEnabled = YES;
                                 }
                 ];
                
                [Utils saveDisplayMode:@"0"];
                
                _topLineView.hidden = NO;   // added by zy, 2014-02-19
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // hScrollView tag==2
    
    if (scrollView.tag == 2) {
        [self.pageControl setCurrentPage:(int)scrollView.contentOffset.x/320];
    }
    else
    {
        _topLineView.hidden = NO;   // added by zy, 2014-02-19
    }
}

@end
