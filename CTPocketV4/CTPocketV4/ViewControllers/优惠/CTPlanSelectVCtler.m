//
//  CTPlanSelectVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 14-1-9.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  套餐选择页面

#import "CTPlanSelectVCtler.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"
#import "CTComboItemBar.h"

#import "CTLeXiangVCtler.h"
#import "CTFeiYoungVCtler.h"
#import "CTCloudCardVCtler.h"

#import "CTValueAddedPackageVCtler.h"

@interface CTPlanSelectVCtler () <CTComboItemBarDelegate>
@property (nonatomic, strong) NSMutableArray *comboItems;  //  可选套餐总类，数据从qryComboType接口获得
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *vcs;
@property (nonatomic, strong) NSMutableArray *packages;

@property (nonatomic) BOOL iSDefaultPackage;    // 是否有默认套餐的标识，影响到返回按钮回退到什么界面
// 下面三个NSNotification用来保存之前已选中的套餐状态，如果三个都没有则是返回到默认乐享3G套餐
@property (nonatomic, strong) NSNotification *leXiangNotification;
@property (nonatomic, strong) NSNotification *feiYoungNotification;
@property (nonatomic, strong) NSNotification *cloudCardNotification;

@property (nonatomic, strong) CserviceOperation *qryComboTypeOpt;
@property (nonatomic, strong) CserviceOperation *qryPackageUniOpt;

@property (nonatomic, strong) CTComboItemBar *combar;

@end

@implementation CTPlanSelectVCtler

#pragma mark - Lazy Instantiation

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

#pragma mark - Init

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 标题
    self.title = @"选择套餐";
    
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    // 显示载入界面
    [self showLoadingAnimated:YES];
    
    self.iSDefaultPackage = NO;
    self.leXiangNotification = nil;
    self.feiYoungNotification = nil;
    self.cloudCardNotification = nil;
    
    // 查询该号码支持的套餐种类
    [self qryComboType];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification

- (void)selectLeXiang:(NSNotification *)notification
{
    self.leXiangNotification = notification;
    self.feiYoungNotification = nil;
    self.cloudCardNotification = nil;
    
    NSDictionary *dict = [notification object];
    
    CTValueAddedPackageVCtler *vc = [[CTValueAddedPackageVCtler alloc] init];
    vc.iSDefaultPackage = NO;
    vc.info = @{@"item": self.item,
                @"index": dict[@"index"],
                @"combo": dict[@"combo"],
                @"package": dict[@"package"]};
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)selectFeiYoung:(NSNotification *)notification
{
    self.leXiangNotification = nil;
    self.feiYoungNotification = notification;
    self.cloudCardNotification = nil;
    
    NSDictionary *dict = [notification object];
    
    CTValueAddedPackageVCtler *vc = [[CTValueAddedPackageVCtler alloc] init];
    vc.iSDefaultPackage = NO;
    if (dict[@"blockInfo"]) {
        vc.info = @{@"item": self.item,
                    @"index": dict[@"index"],
                    @"combo": dict[@"combo"],
                    @"package": dict[@"package"],
                    @"blockInfo": dict[@"blockInfo"]};
    }
    else {
        vc.info = @{@"item": self.item,
                    @"index": dict[@"index"],
                    @"combo": dict[@"combo"],
                    @"package": dict[@"package"]};
    }
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)selectCloudCard:(NSNotification *)notification
{
    self.leXiangNotification = nil;
    self.feiYoungNotification = nil;
    self.cloudCardNotification = notification;
    
    NSDictionary *dict = [notification object];
    
    CTValueAddedPackageVCtler *vc = [[CTValueAddedPackageVCtler alloc] init];
    vc.iSDefaultPackage = NO;
    vc.info = @{@"item": self.item,
                @"index": dict[@"index"],
                @"combo": dict[@"combo"],
                @"package": dict[@"package"]};
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - Nav

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
                            
                            CTValueAddedPackageVCtler *vc = [[CTValueAddedPackageVCtler alloc] init];
                            vc.iSDefaultPackage = YES;
                            NSDictionary *combo = nil;
                            for (NSDictionary *comboItem in self.comboItems) {
                                if ([comboItem[@"ComboType"] isEqualToString:@"884"]) {
                                    combo = comboItem;
                                    break;
                                }
                            }
                            vc.info = @{@"item": self.item,
                                        @"index": [NSString stringWithFormat:@"%d", j],
                                        @"combo": combo,
                                        @"package": dict};
                            [self.navigationController pushViewController:vc animated:NO];
                        }
                    }
                    break;
                }
            }
        }
    }
    else {
        // 没有默认套餐，返回靓号界面
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark - Custom Methods

//  靓号-套餐类型查询
- (void)qryComboType
{
    NSDictionary *params = @{@"SalesProdid": self.item[@"SalesProdId"],
                             @"Number": self.item[@"PhoneNumber"]};
    
   self.qryComboTypeOpt =  [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryComboType"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          if ([dict[@"Data"][@"ComboItem"] isKindOfClass:[NSDictionary class]])
                                          {
                                              if ([dict[@"Data"][@"ComboItem"][@"ComboType"] isEqualToString:@"881"] ||
                                                  [dict[@"Data"][@"ComboItem"][@"ComboType"] isEqualToString:@"883"] ||
                                                  [dict[@"Data"][@"ComboItem"][@"ComboType"] isEqualToString:@"884"]) {
                                                  [self.comboItems addObject:dict[@"Data"][@"ComboItem"]];
                                              }
                                          }
                                          else if ([dict[@"Data"][@"ComboItem"] isKindOfClass:[NSArray class]])
                                          {
                                              for (NSDictionary *item in dict[@"Data"][@"ComboItem"]) {
                                                  if ([item[@"ComboType"] isEqualToString:@"881"] ||
                                                      [item[@"ComboType"] isEqualToString:@"883"] ||
                                                      [item[@"ComboType"] isEqualToString:@"884"]) {
                                                      [self.comboItems addObject:item];
                                                  }
                                              }
                                          }
                                          
                                          if ([self.comboItems count] > 0) {
                                              [self qryPackageUni];
                                          }
                                      }
                                          onError:^(NSError *engineError) {
                                          [self hideLoadingViewAnimated:NO];
                                          [SVProgressHUD showErrorWithStatus:engineError.localizedDescription];
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

// 选择套餐（靓号通用）
- (void)qryPackageUni
{
    NSDictionary *params = @{@"ShopId": ESHORE_ShopId,
                             @"SalesproductId": self.item[@"SalesProdId"],
                             @"PhoneNumber": self.item[@"PhoneNumber"],
                             @"ComboType": @"881",
                             @"ConvertColumn": @"1"};
    
   self.qryPackageUniOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryPackageUni"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          NSMutableArray *netPackage = [[NSMutableArray alloc] init];
                                          
                                          if ([dict[@"Data"][@"Package"] isKindOfClass:[NSDictionary class]])
                                          {
                                              [netPackage addObject:dict[@"Data"][@"Package"]];
                                          }
                                          else if ([dict[@"Data"][@"Package"] isKindOfClass:[NSArray class]])
                                          {
                                              [netPackage addObjectsFromArray:dict[@"Data"][@"Package"]];
                                          }
                                          
                                          // 匹配数据
                                          if ([netPackage count] > 0) {
                                              for (NSDictionary *info1 in self.comboItems) {
                                                  BOOL isInit = NO;
                                                  for (NSDictionary *info2 in netPackage) {
                                                      if ([info1[@"ComboType"] isEqualToString:info2[@"Type"]]) {
                                                          isInit = YES;
                                                          [self.packages addObject:info2];
                                                          break;
                                                      }
                                                  }
                                                  if (isInit == NO) {
                                                      [self.packages addObject:[NSNull null]];
                                                  }
                                              }
                                          }
                                          
                                          [self setAllContents];
                                          [self hideLoadingViewAnimated:YES];
                                          
                                      } onError:^(NSError *engineError) {
                                          [self hideLoadingViewAnimated:YES];
                                          [SVProgressHUD showErrorWithStatus:engineError.localizedDescription];
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
        self.containerView = [[UIView alloc] initWithFrame:rect];
        self.containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleWidth |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleHeight |
                                              UIViewAutoresizingFlexibleBottomMargin;
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
        
        [self.containerView addSubview:[[self.vcs objectAtIndex:0] view]];
        // 有默认乐享3G上网版套餐，自动跳到默认套餐页面
        {
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
                            
                            CTValueAddedPackageVCtler *vc = [[CTValueAddedPackageVCtler alloc] init];
                            vc.iSDefaultPackage = YES;
                            NSDictionary *combo = nil;
                            for (NSDictionary *comboItem in self.comboItems) {
                                if ([comboItem[@"ComboType"] isEqualToString:@"884"]) {
                                    combo = comboItem;
                                    break;
                                }
                            }
                            vc.info = @{@"item": self.item,
                                        @"index": [NSString stringWithFormat:@"%d", j],
                                        @"combo": combo,
                                        @"package": dict};
                            
                            [self.navigationController pushViewController:vc animated:NO];
                        }
                    }
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

@end
