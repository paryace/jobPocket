//
//  CustomTabBarVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-12-5.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CustomTabBarVCtler.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "ABAddressBookCache.h"
#import "CTMoreVCtler.h"
#import "AddressBookHelper.h"
#import "CTQueryVCtler.h"
#import "RightRootVCtler.h"
// add by liuruxian 2014-03-31
typedef enum ClickQuery {NeverClick=1,OnceClick,MoreClick}ClickQuery;
extern NSString * const ESRefreshItemsNotification ;
NSString * const ESUpadataAppTipNotification = @"updataAppTip";
NSString * const ESVersionLastNotification = @"versionLast";
NSString * const CustomTabbarShowCoverPageNotification = @"ShowCoverPageNotification";
NSString * const CustomTabbarShowCoverPageNotification2 = @"ShowCoverPageNotification2";//在没有欢迎页的时候调用

int const customTabGuideViewPage = 4;

@interface CustomTabBarVCtler () <UIScrollViewDelegate>
{
    ClickQuery clickQuery;//判断是否点击过查询
}
@property (strong, nonatomic) UIView *contentView;

@property (strong, nonatomic) UIButton *tabBarBtn0;
@property (strong, nonatomic) UIButton *tabBarBtn1;
@property (strong, nonatomic) UIButton *tabBarBtn2;
@property (strong, nonatomic) UIButton *tabBarBtn3;
@property (strong, nonatomic) UIButton *tabBarBtn4;

@property (strong, nonatomic) UIView *guideView;

@property (assign, nonatomic) BOOL showVersionTip;
@property (strong, nonatomic) AppStoreOperation *checkVersionOpt;

@property (nonatomic, assign) CGPoint beginPos;
@property (nonatomic, assign) BOOL isOver;

@end

@implementation CustomTabBarVCtler

@synthesize selectedIndex = _selectedIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        clickQuery=NeverClick;
        _showVersionTip = NO;
        _isOver = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    {
        CGRect rect = [UIScreen mainScreen].bounds;
        if(!isIOS7)
            rect.size.height -=20;
        
        rect.size.height = rect.size.height - 49.0f;
        self.contentView = [[UIView alloc] initWithFrame:rect];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.contentView];
    }
    
    for (UINavigationController *nav in self.viewControllers)
    {
        CGRect rect = [UIScreen mainScreen].bounds;
        if(!isIOS7)
            rect.size.height -=20;
        rect.size.height = rect.size.height - 49.0f;
        nav.view.frame = rect;
        
        [self addChildViewController:nav];
    }
    
    {
        CGRect rect = [UIScreen mainScreen].bounds;
        if(!isIOS7)
            rect.size.height -=20;
        self.tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height - 49.0f, rect.size.width, 49.0f)];
        self.tabbarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        self.tabbarView.backgroundColor = [UIColor clearColor];
        {
            self.tabBarBtn0 = [UIButton buttonWithType:UIButtonTypeCustom];
            self.tabBarBtn0.frame = CGRectMake(0, 0, 64, 49);
            [self.tabBarBtn0 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon1"] forState:UIControlStateNormal];
            [self.tabBarBtn0 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon1_selected"] forState:UIControlStateSelected];
            [self.tabBarBtn0 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon1_hl"] forState:UIControlStateHighlighted];
            self.tabBarBtn0.titleLabel.font = [UIFont systemFontOfSize:11.0f];
            [self.tabBarBtn0 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.tabBarBtn0 setTitleEdgeInsets:UIEdgeInsetsMake(25, 2, 0, 0)];
            [self.tabBarBtn0 setTitle:@"首页" forState:UIControlStateNormal];
            self.tabBarBtn0.tag = 0;
            [self.tabBarBtn0 addTarget:self action:@selector(onSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.tabbarView addSubview:self.tabBarBtn0];
            
            self.tabBarBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
            self.tabBarBtn1.frame = CGRectMake(64, 0, 64, 49);
            [self.tabBarBtn1 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon2"] forState:UIControlStateNormal];
            [self.tabBarBtn1 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon2_selected"] forState:UIControlStateSelected];
            [self.tabBarBtn1 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon2_hl"] forState:UIControlStateHighlighted];
            self.tabBarBtn1.titleLabel.font = [UIFont systemFontOfSize:11.0f];
            [self.tabBarBtn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.tabBarBtn1 setTitleEdgeInsets:UIEdgeInsetsMake(25, 2, 0, 0)];
            [self.tabBarBtn1 setTitle:@"查询" forState:UIControlStateNormal];
            self.tabBarBtn1.tag = 1;
            [self.tabBarBtn1 addTarget:self action:@selector(onSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.tabbarView addSubview:self.tabBarBtn1];
            
            self.tabBarBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
            self.tabBarBtn2.frame = CGRectMake(128, 0, 64, 49);
            [self.tabBarBtn2 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon3"] forState:UIControlStateNormal];
            [self.tabBarBtn2 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon3_selected"] forState:UIControlStateSelected];
            [self.tabBarBtn2 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon3_hl"] forState:UIControlStateHighlighted];
            self.tabBarBtn2.titleLabel.font = [UIFont systemFontOfSize:11.0f];
            [self.tabBarBtn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.tabBarBtn2 setTitleEdgeInsets:UIEdgeInsetsMake(25, 2, 0, 0)];
            [self.tabBarBtn2 setTitle:@"充值" forState:UIControlStateNormal];
            self.tabBarBtn2.tag = 2;
            [self.tabBarBtn2 addTarget:self action:@selector(onSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.tabbarView addSubview:self.tabBarBtn2];
            
            self.tabBarBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
            self.tabBarBtn3.frame = CGRectMake(192, 0, 64, 49);
            [self.tabBarBtn3 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon4_hl_rob"] forState:UIControlStateNormal];
            [self.tabBarBtn3 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon4_selected_rob"] forState:UIControlStateSelected];
            [self.tabBarBtn3 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon4_rob"] forState:UIControlStateHighlighted];
            self.tabBarBtn3.titleLabel.font = [UIFont systemFontOfSize:11.0f];
            [self.tabBarBtn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.tabBarBtn3 setTitleEdgeInsets:UIEdgeInsetsMake(25, 2, 0, 0)];
            [self.tabBarBtn3 setTitle:@"优惠" forState:UIControlStateNormal];
            self.tabBarBtn3.tag = 3;
            [self.tabBarBtn3 addTarget:self action:@selector(onSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.tabbarView addSubview:self.tabBarBtn3];
            
            self.tabBarBtn4 = [UIButton buttonWithType:UIButtonTypeCustom];
            self.tabBarBtn4.frame = CGRectMake(256, 0, 64, 49);
            [self.tabBarBtn4 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon5"] forState:UIControlStateNormal];
            [self.tabBarBtn4 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon5_selected"] forState:UIControlStateSelected];
            [self.tabBarBtn4 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon5_hl"] forState:UIControlStateHighlighted];
            self.tabBarBtn4.titleLabel.font = [UIFont systemFontOfSize:11.0f];
            [self.tabBarBtn4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.tabBarBtn4 setTitleEdgeInsets:UIEdgeInsetsMake(25, 2, 0, 0)];
            [self.tabBarBtn4 setTitle:@"更多" forState:UIControlStateNormal];
            self.tabBarBtn4.tag = 4;
            [self.tabBarBtn4 addTarget:self action:@selector(onSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.tabbarView addSubview:self.tabBarBtn4];
        }
        [self.view addSubview:self.tabbarView];
    }
    
    {
        [self.contentView addSubview:[[self.viewControllers objectAtIndex:0] view]];
        [[self.viewControllers objectAtIndex:0] didMoveToParentViewController:self];
        _selectedIndex = 0;
        self.tabBarBtn0.selected = YES;
    }
    
    [self showGuideView];
    [self qryDiscount];  // 定时更新折扣信息icon
    
    // add by liuruxian 2014-03-31
    [self hiddenVersonIcon];
    // 监听版本更新消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updataAppNotification)
                                                 name:ESRefreshItemsNotification object:nil];
    // add by liuruxian  版本号做特殊处理
    //    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    //    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:app_Version,@"12", nil];
    //    [TrackingHelper trackPage:NSStringFromClass([self class]) events:dict];
    
    //postNotificationName:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAddrBookNotification)
                                                 name:CTRefreshNewFlag object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // added by zy, 2014-03-31
    [self checkLastABSyncStatus];
    int64_t delayseconds = 1;
    dispatch_time_t delaytimer = dispatch_time(DISPATCH_TIME_NOW,delayseconds*NSEC_PER_SEC);
    dispatch_after(delaytimer, dispatch_get_main_queue(), ^(){
        //通知处理来自推送的跳转
        [[NSNotificationCenter defaultCenter] postNotificationName:DEAL_WITH_NOTIFICATION object:nil];
    });
}

#pragma mark -

- (void)onSelectAction:(UIButton *)sender
{
    int tag=sender.tag;
    if (tag==1)
    {
        if(clickQuery==NeverClick)
        {
            clickQuery=OnceClick;
        }
    }
    [self setSelectedIndex:tag];
}

- (NSUInteger)selectedIndex
{
    return _selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)index
{
    
    if (index != _selectedIndex)
    {
        UINavigationController *oldNav = self.viewControllers[_selectedIndex];
        UINavigationController *newNav = self.viewControllers[index];
        //modified by gogngxt 2014-05-26
        if (index==0) {
            [newNav setNavigationBarHidden:NO animated:NO];
            [newNav popToRootViewControllerAnimated:NO];
        }
        [self transitionFromViewController:oldNav
                          toViewController:newNav
                                  duration:0.01
                                   options:UIViewAnimationOptionTransitionNone
                                animations:^{
                                    
                                }
                                completion:^(BOOL finished) {
                                    //                                    if (finished) {
                                    switch (_selectedIndex) {
                                        case 0:
                                            self.tabBarBtn0.selected = NO;
                                            break;
                                        case 1:
                                            self.tabBarBtn1.selected = NO;
                                            break;
                                        case 2:
                                            self.tabBarBtn2.selected = NO;
                                            break;
                                        case 3:
                                            self.tabBarBtn3.selected = NO;
                                            break;
                                        case 4:
                                            self.tabBarBtn4.selected = NO;
                                            break;
                                        default:
                                            break;
                                    }
                                    switch (index) {
                                        case 0:
                                            self.tabBarBtn0.selected = YES;
                                            break;
                                        case 1:
                                            self.tabBarBtn1.selected = YES;
                                            NSLog(@"-------------->>>>>>>>调用了");
                                            break;
                                        case 2:
                                            self.tabBarBtn2.selected = YES;
                                            break;
                                        case 3:
                                            self.tabBarBtn3.selected = YES;
                                            break;
                                        case 4:
                                            self.tabBarBtn4.selected = YES;
                                            break;
                                        default:
                                            break;
                                    }
                                    _selectedIndex = index;
                                    //create by gongxt 判断当前选择的是否是查询选项，而且之前是否点击过此项
                                    /**/
                                    if (clickQuery==OnceClick&&(_selectedIndex==1))
                                    {
                                        UINavigationController *nav =self.viewControllers[_selectedIndex];
                                        [nav popToRootViewControllerAnimated:YES];
                                        CTQueryVCtler * vc = nav.viewControllers[0];
                                        vc.selectedIndex = 0;
                                        
                                        if(clickQuery==OnceClick)
                                        {
                                            clickQuery=MoreClick;
                                        }
                                    }
                                    //                                    }
                                }];
    }
    else
    {
        //modified by gogngxt 2014-05-26
        UINavigationController *newNav = self.viewControllers[index];
        [newNav setNavigationBarHidden:NO animated:NO];

        [newNav popToRootViewControllerAnimated:NO];
    }
}

- (void)showGuideView
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    //直接获取当前应用的版本号
    NSString *oldV = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (([settings objectForKey:@"Version"] == nil) ||
        (![[settings objectForKey:@"Version"] isEqualToString:oldV]))
    {
        _showVersionTip = YES; // 避免在导航页面弹出版本更新提示 (用户停留在导航页面 此时定时启动请求版本更新)
        
        //假如当前的版本和
        [settings setObject:oldV forKey:@"Version"];
        [settings synchronize];
        //  显示引导页
        self.guideView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.guideView.backgroundColor = [UIColor clearColor];
        {
            self.guideScrollView= [[UIScrollView alloc] initWithFrame:self.guideView.bounds];
            self. guideScrollView.backgroundColor = [UIColor clearColor];
            self.guideScrollView.contentSize = CGSizeMake(self.guideView.bounds.size.width*(customTabGuideViewPage + 1), self.guideView.bounds.size.height);
            self.guideScrollView.pagingEnabled = YES;
            self.guideScrollView.delegate = self;
            self.guideScrollView.showsHorizontalScrollIndicator = NO;
            self.guideScrollView.bounces = NO;
            if (iPhone5)
            {
                CGFloat originY = -20.0f;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
                originY = 0.0f;
#endif
                
                //modified by huangfq 2014-6-6
#if 0
                UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, originY, 320, 568)];
                imageView1.image = [UIImage imageNamed:@"guideView1136_1.jpg"];
                [self.guideScrollView addSubview:imageView1];
                
                UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(320, originY, 320, 568)];
                imageView2.image = [UIImage imageNamed:@"guideView1136_2.jpg"];
                [self.guideScrollView addSubview:imageView2];
                
                UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(640, originY, 320, 568)];
                imageView3.image = [UIImage imageNamed:@"guideView1136_3.jpg"];
                [self.guideScrollView addSubview:imageView3];
                
                UIImageView *imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(960, originY, 320, 568)];
                imageView4.image = [UIImage imageNamed:@"guideView1136_4.jpg"];
                [self.guideScrollView addSubview:imageView4];
                
                UIImageView *imageView5 = [[UIImageView alloc] initWithFrame:CGRectMake(1280, originY, 320, 568)];
                imageView5.image = [UIImage imageNamed:@"guideView1136_5.jpg"];
                [self.guideScrollView addSubview:imageView5];
#else
                
                //modified by huangfq 2014-6-6
                for (int i = 0; i < customTabGuideViewPage; i++) {
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 320, originY, 320, self.guideView.frame.size.height)];
                    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guideView1136_%d.jpg",i + 1]];
                    [self.guideScrollView addSubview:imageView];
                    
                }
                
#endif
                //modified by huangfq 2014-6-6
                CGFloat xOffset = (customTabGuideViewPage - 1) * 320;
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(xOffset+100, 378+originY, 120, 60)];
                [btn addTarget:self action:@selector(removeGuideView) forControlEvents:UIControlEventTouchUpInside];
                [self.guideScrollView addSubview:btn];
            }
            else
            {
                CGFloat originY = -20.0f;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
                originY = 0.0f;
#endif
                
                //modified by huangfq 2014-6-6
#if 0
                UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, originY, 320, self.guideView.frame.size.height)];
                imageView1.autoresizingMask = UIViewContentModeScaleAspectFit ;
                imageView1.image = [UIImage imageNamed:@"guideView960_1.jpg"];
                [self.guideScrollView addSubview:imageView1];
                
                UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(320, originY, 320, self.guideView.frame.size.height)];
                imageView2.image = [UIImage imageNamed:@"guideView960_2.jpg"];
                [self.guideScrollView addSubview:imageView2];
                
                UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(640, originY, 320, self.guideView.frame.size.height)];
                imageView3.image = [UIImage imageNamed:@"guideView960_3.jpg"];
                [self.guideScrollView addSubview:imageView3];
                
                UIImageView *imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(960, originY, 320, self.guideView.frame.size.height)];
                imageView4.image = [UIImage imageNamed:@"guideView960_4.jpg"];
                [self.guideScrollView addSubview:imageView4];
                
                UIImageView *imageView5 = [[UIImageView alloc] initWithFrame:CGRectMake(1280, originY, 320, self.guideView.frame.size.height)];
                imageView5.image = [UIImage imageNamed:@"guideView960_5.jpg"];
                [self.guideScrollView addSubview:imageView5];
#else
                
                //modified by huangfq 2014-6-6
                for (int i = 0; i < customTabGuideViewPage; i++) {
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 320, originY, 320, self.guideView.frame.size.height)];
                    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guideView960_%d.jpg",i + 1]];
                    [self.guideScrollView addSubview:imageView];
                    
                }
#endif
                //modified by huangfq 2014-6-6
                CGFloat xOffset = (customTabGuideViewPage - 1) * 320;
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(xOffset+100, 320+originY, 120, 60)];
                [btn addTarget:self action:@selector(removeGuideView) forControlEvents:UIControlEventTouchUpInside];
                [self.guideScrollView addSubview:btn];
            }
            [self.guideView addSubview:self.guideScrollView];
        }
        [self.view addSubview:self.guideView];
        
    }
    else {
        
        [self checkVersion];
        [[NSNotificationCenter defaultCenter] postNotificationName:CustomTabbarShowCoverPageNotification2 object:nil];
    }
}

#pragma mark - scrollView delegate
//added by wensj 2014-5-20 修复欢迎页滑动进入应用时有时会无法remove（卡住无法点、无法出现遮罩层）的问题
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page < 0){
        return;
    }

    //modified by huangfq 2014-6-6
    if (page >= customTabGuideViewPage) //kGuideViewCount 引导页的张数
    {
        [self removeView];
        return;
    }
    
}


- (void)removeView
{
    if (self.guideView)
    {
        [self.guideView removeFromSuperview];
        self.guideView = nil;
    }
    
    // add by liuruxian 2014-03-31
    _showVersionTip = NO; // 由于存在导航页面 定时器不起作用  由导航事件请求版本信息
    [self checkVersion];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CustomTabbarShowCoverPageNotification object:nil];
}

- (void)removeGuideView
{
    [UIView animateWithDuration:0.3f animations:^{
        self.guideView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeView];
    }];
    
}


// 银行卡充话费是否有折扣
- (void)qryDiscount
{
    //隐藏折扣
    [self hiddenZheIcon:YES];
    
    NSString *Amount = @"";
    NSString *Type = @"101" ;
    NSDictionary *params = @{@"Type": Type, @"Amount": Amount, @"ShopId": BUSSINESS_SHOPID};
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryDiscount"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict)
     {
         //格式化数据(将指定的数据格式化成数组)
         dict = [Utils objFormatArray:dict path:@"Data/HfList/Discount"];
         dict = [Utils objFormatArray:dict path:@"Data/LlList/Discount"];
         
         //保存折扣信息
         [Global sharedInstance].discountDict = dict[@"Data"];
         
         NSDictionary *Data = [dict objectForKey:@"Data"];
         NSArray *arryData1 = Data[@"HfList"][@"Discount"];
         [self checkZhe:arryData1];
         
         NSArray *arryData2 = Data[@"LlList"][@"Discount"];
         [self checkZhe:arryData2];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:DISCOUNTDATE object:nil];
          
    } onError:^(NSError *engineError) {
         
    }];
}

-(void)checkZhe:(NSArray*)arryData
{
    if(!arryData) return;
    // 获取当前时间
    NSDate *curDate = [NSDate date];//获取当前日期
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//这里去掉 具体时间 保留日期
    
    for(NSDictionary *dic in arryData)
    {
        NSString *EndTime = [dic objectForKey:@"EndTime"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate *destDate= [dateFormatter dateFromString:EndTime];
        
        if ([[destDate earlierDate:curDate]isEqual:curDate])
        {
            //没有过期 显示折扣icon
            [self hiddenZheIcon:NO];
        }
    }
}

// 设置默认的Tabbar充值按钮
- (void)hiddenZheIcon:(BOOL)isHide
{
    if (isHide == YES)
    {
        [self.tabBarBtn2 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon3"] forState:UIControlStateNormal];
        [self.tabBarBtn2 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon3_selected"] forState:UIControlStateSelected];
        [self.tabBarBtn2 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon3_hl"] forState:UIControlStateHighlighted];
    }
    else
    {
        [self.tabBarBtn2 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon3_zhe"] forState:UIControlStateNormal];
        [self.tabBarBtn2 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon3_selected_zhe"] forState:UIControlStateSelected];
        [self.tabBarBtn2 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon3_hl_zhe"] forState:UIControlStateHighlighted];
    }
}

#pragma 号码簿显示
- (void)showAddrBookNotification
{
    [self hiddenVersonIcon];
}

// add by liuruxian 2014-03-31
- (void)hiddenVersonIcon
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL showNewflag = ([[defaults objectForKey:@"updataVersion"] isEqualToString:@"YES"] || (![defaults objectForKey:kCTAddrBookSyncStatusKey])|| (![defaults objectForKey:kMoreBBHiden])) ; 
    if (showNewflag)
    {
        [self.tabBarBtn4 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon5_new"] forState:UIControlStateNormal];
        [self.tabBarBtn4 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon5_selected_new"] forState:UIControlStateSelected];
        [self.tabBarBtn4 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon5_hl_new"] forState:UIControlStateHighlighted];
    }
    else
    {
        [self.tabBarBtn4 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon5"] forState:UIControlStateNormal];
        [self.tabBarBtn4 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon5_selected"] forState:UIControlStateSelected];
        [self.tabBarBtn4 setBackgroundImage:[UIImage imageNamed:@"tabbar_icon5_hl"] forState:UIControlStateHighlighted];
    }
}



#pragma 定时检测版本

// add by liuruxian 2014-03-31
- (void)updataAppNotification
{
    [self qryDiscount];  // 定时更新折扣信息icon
    [self checkVersion]; // 版本信息
}

#pragma 检测版本

// add by liuruxian 2014-03-31
- (void)checkVersion
{
    if (self.checkVersionOpt) {
        [self.checkVersionOpt cancel];
        self.checkVersionOpt = nil;
    }
    
    self.checkVersionOpt = [MyAppDelegate.appStoreEngine getJSONWithId:@"513836029"
                                                           onSucceeded:^(NSDictionary *dict)
    {
        if(dict == nil || dict[@"results"] == nil || ![dict[@"results"] isKindOfClass:[NSArray class]]) return;
        
        if ([dict[@"results"] count] <= 0) {
            
            return;
        }
        
       NSString *oldV = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
       NSString *newV = [[[dict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"version"];
       DDLogInfo(@"当前版本:%@\nAppStore版本:%@", oldV, newV);
       if ([oldV compare:newV options:NSNumericSearch] == NSOrderedAscending)
       {
//           NSString *infoStr = [NSString stringWithFormat:
//                                @"发现版本%@更新，立即升级吧，享受更便捷的营业厅服务~ ",newV];
           NSNotification *notificationFormCenter = [NSNotification notificationWithName:ESUpadataAppTipNotification object:nil];
           [[NSNotificationCenter defaultCenter] postNotification:notificationFormCenter];
           
           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
           [defaults setObject:@"YES" forKey:@"updataVersion"];
           [defaults synchronize];
           
           // 掌厅提示
           //                                            [self updataApp:infoStr];
           [self hiddenVersonIcon];
           
       } else {
           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
           [defaults setObject:@"NO" forKey:@"updataVersion"];
           [defaults synchronize];
           
           [self hiddenVersonIcon];
           NSNotification *notificationFormCenter = [NSNotification notificationWithName:ESVersionLastNotification object:nil];
           [[NSNotificationCenter defaultCenter] postNotification:notificationFormCenter];
       }
   } onError:^(NSError *engineError) {
       
   }];
}

// add by liuruxian 2014-03-31
- (void)updataApp:(NSString *)updataInfo
{
    if (_showVersionTip) {
        return;
    }
    _showVersionTip = YES;
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                     andMessage:updataInfo];
    [alertView addButtonWithTitle:@"取消"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView addButtonWithTitle:@"确定"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [self updataApp];
                          }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

// add by liuruxian 2014-03-31
- (void)updataApp
{
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:@"https://itunes.apple.com/us/app/zhong-guo-dian-xin-zhang-shang/id513836029?mt=8&uo=4"]];
}

#pragma mark addressbook sync   // added by zy, 2014-03-31
- (void)checkLastABSyncStatus
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    CTAddrBookSyncStatus syncStatus = [def integerForKey:kCTAddrBookSyncStatusKey];
    if (syncStatus == CTAddrBookSyncStatusNone) {
        return;
    }
    
    NSString* msg = [NSString stringWithFormat:@"亲，由于意外，上次通讯录%@失败，是否继续？",
                     (syncStatus == CTAddrBookSyncStatusUpload ? @"上传" :
                      (syncStatus == CTAddrBookSyncStatusDownload ? @"下载" :
                       (syncStatus == CTAddrBookSyncStatusRollback ? @"回滚" : @"")))];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                     andMessage:msg];
    [alertView addButtonWithTitle:@"继续" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        
        [MyAppDelegate.tabBarController setSelectedIndex:4];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCTAddrBookResumeLastSyncOperation object:nil];
        
    }];
    
    [alertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        
        // 保存操作记录
        ABLogType type = ABLogTypeUpload;
        if (syncStatus == CTAddrBookSyncStatusDownload) {
            type = ABLogTypeDownload;
        } else if (syncStatus == CTAddrBookSyncStatusRollback) {
            type = ABLogTypeRollback;
        }
        NSTimeInterval timestamp = [def doubleForKey:kCTAddrBookSyncStatusTimestamp];
        AddressBookHelper* abhelper = [AddressBookHelper new];
        [abhelper saveLog:[NSDate dateWithTimeIntervalSince1970:timestamp]
                     type:type
                 contacts:0
                  comment:[NSString stringWithFormat:@"%@失败", (syncStatus == CTAddrBookSyncStatusUpload ? @"上传" :
                                                               (syncStatus == CTAddrBookSyncStatusDownload ? @"下载" :
                                                                (syncStatus == CTAddrBookSyncStatusRollback ? @"回滚" : @"")))]
                  success:NO];
        
        // 清除标志位
        [def setObject:[NSNumber numberWithInt:CTAddrBookSyncStatusNone] forKey:kCTAddrBookSyncStatusKey];
        [def removeObjectForKey:kCTAddrBookSyncStatusTimestamp];
        [def synchronize];
        
    }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    [alertView show];
}

@end
