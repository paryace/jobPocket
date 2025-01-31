//
//  CTPackageSelectVCtler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 14-4-18.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTPackageSelectVCtler.h"
#import "CTComboItemBar.h"
#import "CTCloudCardVCtler.h"
#import "CTLeXiangVCtler.h"
#import "CTFeiYoungVCtler.h"
#import "CTAddPackageVCtler.h"
#import "CTPrettyNumberVCtler.h"
#import "CTShakeNumberVCtler.h"

@interface CTPackageSelectVCtler ()<CTComboItemBarDelegate>


@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *vcs;

@property (nonatomic, strong) CTComboItemBar *combar;


// 下面三个NSNotification用来保存之前已选中的套餐状态，如果三个都没有则是返回到默认乐享3G套餐
@property (nonatomic, strong) NSNotification *leXiangNotification;
@property (nonatomic, strong) NSNotification *feiYoungNotification;
@property (nonatomic, strong) NSNotification *cloudCardNotification;

@end

@implementation CTPackageSelectVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectLeXiang:)
                                                     name:@"选择乐享3G"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectFeiYoung:)
                                                     name:@"选择飞Young"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectCloudCard:)
                                                     name:@"选择云卡"
                                                   object:nil];
    }
    return self;
}
/** modified by gongxt 禁用手势
- (void)viewDidAppear:(BOOL)animated{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
*/
- (void) dealloc
{/** modified by gongxt 禁用手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)comboItems
{
    if (!_comboItems) {
        _comboItems = [[NSMutableArray alloc] init];
    }
    return _comboItems;
}

- (NSMutableArray *)vcs
{
    if (!_vcs) {
        _vcs = [[NSMutableArray alloc] init];
    }
    return _vcs;
}

- (NSMutableArray *)packages
{
    if (!_packages) {
        _packages = [[NSMutableArray alloc] init];
    }
    return _packages;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // 标题
    self.title = @"选择套餐";
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    _packageIndex = 0;
    [self setAllContents];
}

#pragma mark - NSNotification

- (void)selectLeXiang:(NSNotification *)notification
{
    self.leXiangNotification = notification;
    self.feiYoungNotification = nil;
    self.cloudCardNotification = nil;
    
    NSDictionary *dict = [notification object];
    
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *vc in array) {
        if ([vc isKindOfClass:[CTAddPackageVCtler class]]) {
            CTAddPackageVCtler *packageVC = (CTAddPackageVCtler *)vc;
            packageVC.info = @{@"item": self.item,
                        @"index": dict[@"index"],
                        @"combo": dict[@"combo"],
                        @"package": dict[@"package"]};
            [packageVC initPackage];
            [self.navigationController  popToViewController:packageVC animated:YES];
        }
    }
}

- (void)selectFeiYoung:(NSNotification *)notification
{
    self.leXiangNotification = nil;
    self.feiYoungNotification = notification;
    self.cloudCardNotification = nil;
    
    NSDictionary *dict = [notification object];
    
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *vc in array) {
        if ([vc isKindOfClass:[CTAddPackageVCtler class]]) {
            CTAddPackageVCtler *packageVC = (CTAddPackageVCtler *)vc;
            if (dict[@"blockInfo"]) {
                packageVC.info = @{@"item": self.item,
                            @"index": dict[@"index"],
                            @"combo": dict[@"combo"],
                            @"package": dict[@"package"],
                            @"blockInfo": dict[@"blockInfo"]};
            }
            else {
                packageVC.info = @{@"item": self.item,
                            @"index": dict[@"index"],
                            @"combo": dict[@"combo"],
                            @"package": dict[@"package"]};
            }
            [packageVC initPackage];
            [self.navigationController popToViewController:packageVC animated:YES];
        }
    }
}

- (void)selectCloudCard:(NSNotification *)notification
{
    self.leXiangNotification = nil;
    self.feiYoungNotification = nil;
    self.cloudCardNotification = notification;
    
    NSDictionary *dict = [notification object];
    
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *vc in array) {
        if ([vc isKindOfClass:[CTAddPackageVCtler class]]) {
            CTAddPackageVCtler *packageVC = (CTAddPackageVCtler *)vc;
            packageVC.info = @{@"item": self.item,
                               @"index": dict[@"index"],
                               @"combo": dict[@"combo"],
                               @"package": dict[@"package"]};
            [packageVC initPackage];
            [self.navigationController  popToViewController:packageVC animated:YES];
        }
    }
}

// 根据返回内容动态显示可选套餐标签页面
- (void)setAllContents
{
    if ([self.comboItems count] > 0)
    {
        // 有套餐可选择
        // 选择tabbar
        CTComboItemBar *comboItemBar = [[CTComboItemBar alloc] initWithArray:self.comboItems];
        comboItemBar.delegate = self;
        // add by liuruxian
        _combar = comboItemBar;
        [self.view addSubview:comboItemBar];
        
        // ContainerView
        CGRect rect = self.view.bounds;
        rect.origin.y = 42.0f;
        rect.size.height = rect.size.height - 42.0f;
        self.containerView.backgroundColor = [UIColor redColor];
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_combar.frame), rect.size.width, rect.size.height)];
        self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
//        UIViewAutoresizingFlexibleWidth |
//        UIViewAutoresizingFlexibleRightMargin |
//        UIViewAutoresizingFlexibleTopMargin |
//        UIViewAutoresizingFlexibleHeight |
//        UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:self.containerView];
        
        // addChildViewController
        int i = 0;
        for (NSDictionary *dict in self.comboItems)
        {
            // 根据数据初始化vc并添加队列
            if ([dict[@"ComboType"] isEqualToString:@"881"]) {
                CTCloudCardVCtler *vc = [[CTCloudCardVCtler alloc] init];
                vc.salesProdid = self.item[@"SalesProdId"];
                vc.combo = dict;
                vc.package = self.packages[i];
                vc.item = self.item;        // added by zy, 2014-02-17
                vc.view.frame = self.containerView.bounds;
                [self addChildViewController:vc];
                [self.vcs addObject:vc];
            }
            else if ([dict[@"ComboType"] isEqualToString:@"883"]) {
                CTFeiYoungVCtler *vc = [[CTFeiYoungVCtler alloc] init];
                vc.salesProdid = self.item[@"SalesProdId"];
                vc.combo = dict;
                vc.package = self.packages[i];
                vc.item = self.item;        // added by zy, 2014-02-17
                vc.view.frame = self.containerView.bounds;
                [self addChildViewController:vc];
                [self.vcs addObject:vc];
            }
            else if ([dict[@"ComboType"] isEqualToString:@"884"]) {
                CTLeXiangVCtler *vc = [[CTLeXiangVCtler alloc] init];
                vc.item = self.item;
                vc.combo = dict;
                vc.package = self.packages[i];
                vc.view.frame = self.containerView.bounds;
                [self addChildViewController:vc];
                [self.vcs addObject:vc];
            }
            i++;
        }
        
        [self.containerView addSubview:[[self.vcs objectAtIndex:_packageIndex] view]];
    }
}

- (void)onLeftBtnAction:(id)sender
{
    if (self.iSDefaultPackage == YES) {
        // 有默认套餐，返回到之前选中的套餐
        if (self.leXiangNotification) {
            // 返回到之前选中的乐享3G套餐
            DDLogInfo(@"返回到之前选中的乐享3G套餐");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"选择乐享3G"
                                                                object:[self.leXiangNotification object]];
        }
        else if (self.feiYoungNotification) {
            // 返回到之前选中的飞Young套餐
            DDLogInfo(@"返回到之前选中的飞Young套餐");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"选择飞Young"
                                                                object:[self.feiYoungNotification object]];
        }
        else if (self.cloudCardNotification) {
            // 返回到之前选中的云卡套餐
            DDLogInfo(@"返回到之前选中的云卡套餐");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"选择云卡"
                                                                object:[self.cloudCardNotification object]];
        }
        else {
            // 返回默认的套餐
            DDLogInfo(@"返回默认的套餐");
            for (NSDictionary *dict in self.packages)
            {
                if ([dict[@"Type"] isEqualToString:@"884"]) {
                    
                    NSMutableArray *packageItems = [[NSMutableArray alloc] init];
                    if (dict[@"PackageItem"]) {
                        if ([dict[@"PackageItem"] isKindOfClass:[NSDictionary class]]) {
                            [packageItems addObject:dict[@"PackageItem"]];
                        }
                        else if ([dict[@"PackageItem"] isKindOfClass:[NSArray class]]) {
                            [packageItems addObjectsFromArray:dict[@"PackageItem"]];
                        }
                        
                        int j = 0;
                        BOOL isDefault = NO;
                        for (NSDictionary *packageItem in packageItems) {
                            if ([packageItem[@"Properties"][@"IS_DEFAULT"] isEqualToString:@"1"]) {
                                // 默认乐享3G上网版套餐
                                isDefault = YES;
                                break;
                            }
                            j++;
                        }
                        if (isDefault) {
                            self.iSDefaultPackage = YES;
                            NSArray *array = self.navigationController.viewControllers ;
                            for (UIViewController *vc in array) {
                                if ([vc isKindOfClass:[CTAddPackageVCtler class]]) {
                                    CTAddPackageVCtler *addPackageVC = (CTAddPackageVCtler *)vc;
                                    
                                    addPackageVC.iSDefaultPackage = YES;
                                    NSDictionary *combo = nil;
                                    for (NSDictionary *comboItem in self.comboItems) {
                                        if ([comboItem[@"ComboType"] isEqualToString:@"884"]) {
                                            combo = comboItem;
                                            break;
                                        }
                                    }
                                    addPackageVC.info = @{@"item": self.item,
                                                @"index": [NSString stringWithFormat:@"%d", j],
                                                @"combo": combo,
                                                @"package": dict};
                                            [addPackageVC initPackage];
                                    [self.navigationController popToViewController:addPackageVC animated:YES];
                                }
                            }
                        }
                    }
                    break;
                }
            }
        }
    }
    else {
        // 没有默认套餐，返回靓号界面
        NSArray *array = self.navigationController.viewControllers;
        BOOL isFound = NO;
        for (UIViewController *vc in array) {
            if ([vc isKindOfClass:[CTPrettyNumberVCtler class]]) {
                isFound = YES;
                CTPrettyNumberVCtler *packageVC = (CTPrettyNumberVCtler *)vc;
                [self.navigationController  popToViewController:packageVC animated:YES];
                break;
            }
        }
        
        if (!isFound) {
            for (UIViewController *vc in array) {
                if ([vc isKindOfClass:[CTShakeNumberVCtler class]]) {
                    isFound = YES;
                    CTShakeNumberVCtler *shakeVC = (CTShakeNumberVCtler *)vc;
                    [self.navigationController  popToViewController:shakeVC animated:YES];
                    break;
                }
            }
        }
        
    }
}

#pragma mark - CTComboItemBarDelegate
- (void)didSelectFromIndex1:(NSUInteger)index1 ToIndex2:(NSUInteger)index2
{
    // 切换Tab
    UIViewController *oldVc = self.vcs[index1 - 1];
    UIViewController *newVc = self.vcs[index2 - 1];
    
    
    //    int count = self.comboItems.count ;
    //    for(int i=0;i<count;i++)
    //    {
    //        UIButton *btn = (UIButton *)[self.combar viewWithTag:i+1];
    //        btn.backgroundColor = [UIColor redColor];
    //        [btn setBackgroundImage:nil forState:UIControlStateNormal];
    //        btn.userInteractionEnabled = NO;
    //    }
    
    [oldVc.view removeFromSuperview];
    [self.containerView addSubview:newVc.view];
    
    
    //    [self transitionFromViewController:oldVc
    //                      toViewController:newVc
    //                              duration:0l
    //                               options:UIViewAnimationOptionTransitionNone
    //                            animations:nil
    //                            completion:^(BOOL finised){
    //                                for(int i=0;i<count;i++)
    //                                {
    //                                    UIButton *btn = (UIButton *)[self.combar viewWithTag:i+1];
    //                                    btn.userInteractionEnabled = YES;
    //                                }
    //                            }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
