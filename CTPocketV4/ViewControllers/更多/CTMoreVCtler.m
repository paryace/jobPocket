//
//  CTMoreVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTMoreVCtler.h"
#import "CTPCheckUpdateVCtler.h"
#import "CTPHelpVCtler.h"
#import "CTPOnlineServiceVCtler.h"
#import "CTPQryAttributionVCtler.h"
#import "CTFreeMsgVctler.h"
#import "CTUserFeedbackVCtler.h"
#import "CTThemeChangeVctller.h"
#import "CTLoginVCtler.h"
#import "AppDelegate.h"
#import "CTChangePasswordVCtler.h"
#import "CTAddrBookSyncVCtler.h"
#import "ABAddressBookCache.h"

#define kTagGridTagStart 88990
#define kTagVersionTip  9000

NSString * const ESVersionLastNotification;
NSString * const ESUpadataAppTipNotification;

NSString* const CTRefreshNewFlag = @"CTRefreshNewFlag"; // added by zy, 2014-04-02

@interface CTMoreVCtler ()
-(void)onGridBtnAction:(id)sender;
@end

@implementation CTMoreVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"更多";
        
        // added by zy, 2014-03-31
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onResumeLastSyncOperation)
                                                     name:kCTAddrBookResumeLastSyncOperation
                                                   object:nil];
        // added by zy, 2014-04-08
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshUI)
                                                     name:CTRefreshNewFlag
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    // added by zy, 2014-03-31
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:PAGEVIEW_BG_COLOR];
    
#if 0   // modified by zy, 2014-04-02
    CGFloat xval,yval,width,height;
    xval = 34;
    yval = 10;
    width  = 94/3*2;
    height = 94/3*2;
    
    // modified by zy, 2014-03
    NSArray* titleAry = [NSArray arrayWithObjects:@"版本更新",@"用户吐槽",@"号码归属地",@"在线客服",@"使用指南",@"修改密码",@"通讯录备份",nil];
    for (int i = 0; i < /*6*/titleAry.count; i++) {
        
        NSString* iconname = [NSString stringWithFormat:@"more_1%d.png",i];
        
        // added by zy, 2014-03-31
        if (i == titleAry.count - 1 &&
            ![[NSUserDefaults standardUserDefaults] objectForKey:kCTAddrBookSyncStatusKey]) {
            iconname = [NSString stringWithFormat:@"more_1%d_new.png",i];
        }
        // added by zy, 2014-03-31
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = kTagGridTagStart + i;
        btn.frame = CGRectMake(xval,yval,width,height);
        [btn setImage:nil forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onGridBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:iconname] forState:UIControlStateNormal];
        
        UILabel* labTitle = [[UILabel alloc] init];
        labTitle.backgroundColor = [UIColor clearColor];
        labTitle.frame    = CGRectMake(xval-10,yval+height,width+20,20);
        labTitle.font     = [UIFont systemFontOfSize:14];
        labTitle.textColor= [UIColor blackColor];
        labTitle.text     = (NSString*)[titleAry objectAtIndex:i];
        labTitle.textAlignment = UITextAlignmentCenter;
        
        [self.view addSubview:btn];
        [self.view addSubview:labTitle];
        
        // add by liuruxian 2014-03-31
        if (i==0) {
            UIImage *image = [UIImage imageNamed:@"more_updata_new.png"];
            UIImageView *versionImageView = [[UIImageView alloc]initWithFrame:
                                             CGRectMake(width+15,
                                                        btn.frame.origin.y,
                                                        image.size.width,
                                                        image.size.height)];
            versionImageView.image = image;
            versionImageView.tag = kTagVersionTip;
            versionImageView.hidden = YES;
            [self.view addSubview:versionImageView];
        }
        
        xval += width + 34;
        if ((i+1)%3==0) {
            yval += height + 20 + 15;
            xval  = 34;
        }
    }
#else
    [self refreshUI];
#endif
    
    // add by liuruxian 2014-03-31
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updataAppNotification)
                                                 name:ESUpadataAppTipNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(versionLast)
                                                 name:ESVersionLastNotification object:nil];
}

// added by zy, 2014-04-02
- (void)refreshUI
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat xval,yval,width,height;
    xval = 34;
    yval = 10;
    width  = 94/3*2;
    height = 94/3*2;
    
    // modified by zy, 2014-03
    NSArray* titleAry = [NSArray arrayWithObjects:@"版本更新",@"用户吐槽",@"号码归属地",@"在线客服",@"使用指南",@"修改密码",@"通讯录助手",nil];
    for (int i = 0; i < /*6*/titleAry.count; i++) {
        
        NSString* iconname = [NSString stringWithFormat:@"more_1%d.png",i];
        
        // added by zy, 2014-03-31
        if (i == titleAry.count - 1 &&
            ![[NSUserDefaults standardUserDefaults] objectForKey:kCTAddrBookSyncStatusKey]) {
            iconname = [NSString stringWithFormat:@"more_1%d_new.png",i];
        }
        // added by zy, 2014-03-31
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = kTagGridTagStart + i;
        btn.frame = CGRectMake(xval,yval,width,height);
        [btn setImage:nil forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onGridBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:iconname] forState:UIControlStateNormal];
        
        UILabel* labTitle = [[UILabel alloc] init];
        labTitle.backgroundColor = [UIColor clearColor];
        labTitle.frame    = CGRectMake(xval-10,yval+height,width+20,20);
        labTitle.font     = [UIFont systemFontOfSize:14];
        labTitle.textColor= [UIColor blackColor];
        labTitle.text     = (NSString*)[titleAry objectAtIndex:i];
        labTitle.textAlignment = UITextAlignmentCenter;
        
        [self.view addSubview:btn];
        [self.view addSubview:labTitle];
        
        // add by liuruxian 2014-03-31
        if (i==0) {
            UIImage *image = [UIImage imageNamed:@"more_updata_new.png"];
            UIImageView *versionImageView = [[UIImageView alloc]initWithFrame:
                                             CGRectMake(width+15,
                                                        btn.frame.origin.y,
                                                        image.size.width,
                                                        image.size.height)];
            versionImageView.image = image;
            versionImageView.tag = kTagVersionTip;
            versionImageView.hidden = YES;
            [self.view addSubview:versionImageView];
        }
        
        xval += width + 34;
        if ((i+1)%3==0) {
            yval += height + 20 + 15;
            xval  = 34;
        }
    }
}

// add by liuruxian 2014-03-31
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"updataVersion"] isEqualToString:@"YES"]) {
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:kTagVersionTip];
        imageView.hidden = NO;
    }
    else {
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:kTagVersionTip];
        imageView.hidden = YES;
    }
}

#pragma mark - NSNotification
#pragma 版本更新后提示  add by liuruxian 2014-03-31

- (void)updataAppNotification
{
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:kTagVersionTip];
    imageView.hidden = NO;
}

- (void)versionLast
{
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:kTagVersionTip];
    imageView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma btnActions
-(void)onGridBtnAction:(id)sender{
    UIButton* btn = (UIButton*)sender;
    int index = btn.tag - kTagGridTagStart;
    switch (index)
    {
        case 0:
            // 版本更新：TODO:
        {
            CTPCheckUpdateVCtler* updateVc = [[CTPCheckUpdateVCtler alloc] init];
            [self.navigationController pushViewController:updateVc animated:YES];
        }break;
        case 1:
            // 用户吐槽
        {
            if ([Global sharedInstance].isLogin)
            {
                CTUserFeedbackVCtler *vctler = [[CTUserFeedbackVCtler alloc] init];
                [self.navigationController pushViewController:vctler animated:YES];
            }
            else
            {
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
                }];
            }
        }break;
        case 2:
            // 号码归属地
        {
            CTPQryAttributionVCtler* queryVc = [[CTPQryAttributionVCtler alloc] init];
            [self.navigationController pushViewController:queryVc animated:YES];
            
        }break;
        case 3:
            // 在线客服
        {
            if ([Global sharedInstance].isLogin)
            {
                CTPOnlineServiceVCtler* lineVc = [[CTPOnlineServiceVCtler alloc] init];
                [self.navigationController pushViewController:lineVc animated:YES];
            }
            else
            {
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
                }];
            }
        }
            break;
        case 4:
            // 用户指南
        {
            CTPHelpVCtler* helpVc = [[CTPHelpVCtler alloc] init];
            [self.navigationController pushViewController:helpVc animated:YES];
        }break;
        case 5:
            // 修改密码
        {
            CTChangePasswordVCtler* vc = [[CTChangePasswordVCtler alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case 6:     // added by zy, 2014-03
            // 通讯录备份
        {
            if ([Global sharedInstance].isLogin)
            {
                [self gotoAddrBookSyncVCtler];
            }
            else
            {
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                vc.isPush = YES;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
                }];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoJumpPage" object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSuccess) name:@"autoJumpPage" object:nil];
            }
        }break;
        default:
            break;
    }
}

// added by zy, 2014-03
- (void)onLoginSuccess
{
    [self gotoAddrBookSyncVCtler];
}

// added by zy, 2014-04-02
- (void)gotoAddrBookSyncVCtler
{
    CTAddrBookSyncVCtler* vc = [[CTAddrBookSyncVCtler alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark notificaiton   // added by zy, 2014-03-31
- (void)onResumeLastSyncOperation
{
    if ([Global sharedInstance].isLogin)
    {
        [self gotoAddrBookSyncVCtler];
    }
    else
    {
        CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
        vc.isPush = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
        }];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoJumpPage" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSuccess) name:@"autoJumpPage" object:nil];
    }
    
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    [def setObject:[NSNumber numberWithInt:CTAddrBookSyncStatusNone] forKey:kCTAddrBookSyncStatusKey];
    [def synchronize];
}

@end
