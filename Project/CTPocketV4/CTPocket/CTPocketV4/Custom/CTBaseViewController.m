//
//  CTBaseViewController.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTBaseViewController.h"
#import "TrackingHelper.h"
#import "AppDelegate.h"
#import "CTDetailVCtler.h"
#import "StatisticsObj.h"
#import "RightRootVCtler.h"
@interface CTBaseViewController ()

@end

@implementation CTBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.loadingView = nil;
        self.isDismissMVC = NO;
    }
    return self;
}

// added by zy, 2014-02-28
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController isKindOfClass:[CTNavigationController class]])
    {
        self.navigationController.animating = NO;
    }
    
//    NSString *objName = [NSString stringWithFormat:@"%@",[self class]];
//    BOOL isExt = NO;
//    for (NSString *str in [StatisticsObj shareInstance].adaptArray) {
//        if ([str isEqualToString:objName])
//        {
//            isExt = YES;
//            break;
//        }
//    }
//    if (!isExt) {
//        [TrackingHelper trackPageLoadedState:NSStringFromClass([self class])];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //add by liuruxian
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setShadowImage:)])
    {
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    }

#if 0   // modified by zy, 2014-02-28
    self.navigationController.delegate = self;
#endif
//    [[StatisticsObj shareInstance].adaptArray
//        enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSString *str = (NSString *)obj;
//        if (![str isEqualToString:objName])
//        {
//            
//        }
//        
//    }];
  
    if (self.navigationController != nil)
    {
        if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        {
            UIImage *titleBg = [UIImage imageNamed:@"navigationBar_background"];
            UIImage *resizableTitleBg = [titleBg resizableImageWithCapInsets:UIEdgeInsetsMake(titleBg.size.height/2.0f, titleBg.size.width/2.0f, titleBg.size.height/2.0f, titleBg.size.width/2.0f)];
            [self.navigationController.navigationBar setBackgroundImage:resizableTitleBg
                                                          forBarMetrics:UIBarMetricsDefault];
        }
        //modified by gongxt
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor blackColor], UITextAttributeTextColor,
                              [UIFont systemFontOfSize:20], UITextAttributeFont,
                              [UIColor clearColor], UITextAttributeTextShadowColor,
                             [NSValue valueWithUIOffset:UIOffsetZero], UITextAttributeTextShadowOffset,
//                              [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3], UITextAttributeTextShadowColor,
//                              [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                              nil];
        self.navigationController.navigationBar.titleTextAttributes = dict;
        
        //add by liuruxian 2014-03-04
        UIView *divide = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-1, self.view.frame.size.width, 1)];
        divide.backgroundColor = [UIColor colorWithRed:0xc3/255. green:0xc3/255. blue:0xc3/255. alpha:1];
        [self.navigationController.navigationBar addSubview:divide ];
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

#if 0   // modified by zy, 2014-04-01
    if (self.navigationController != nil)
    {
        /** modified by gongxt 禁用手势
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        {
            // modified by zy, 2014-04-01
            __weak typeof(self) wself = self;
            self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)wself;
        }*/
    }
#endif
#endif
    
    // 设置默认背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pop2RootVC)
                                                 name:@"pop2RootVC"
                                               object:nil];
}

#if 0   // modified by zy, 2014-02-28
//navigationdelegate
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    
//    MyAppDelegate.tabBarController.view.userInteractionEnabled = NO ;
//}
//
//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    MyAppDelegate.tabBarController.view.userInteractionEnabled = YES ;
////    self.navigationController.delegate = nil ;
//}

//- (void) viewWillAppear:(BOOL)animated{
//    MyAppDelegate.tabBarController.view.userInteractionEnabled = NO ;
//}
//
//- (void) viewDidDisappear:(BOOL)animated
//{
//    MyAppDelegate.tabBarController.view.userInteractionEnabled = YES ;
//}
#endif

- (void)dealloc
{
    NSLog(@"%s",__func__) ;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // added by zy, 2014-04-01
    if ([self.navigationController isKindOfClass:[CTNavigationController class]])
    {
        self.navigationController.animating = NO;
    }
}

#pragma mark - Self Func

- (void)showLoadingAnimated:(BOOL)animated
{
    self.loadingView = [[SSLoadingView alloc] initWithFrame:self.view.bounds];
    self.loadingView.alpha = 0.0f;
    [self.view addSubview:self.loadingView];
    [self.view bringSubviewToFront:self.loadingView];
    double duration = animated ? 0.4f : 0.0f;
    [UIView animateWithDuration:duration animations:^{
        self.loadingView.alpha = 1.0f;
    }];
}

- (void)hideLoadingViewAnimated:(BOOL)animated
{
    if (self.loadingView != nil) {
        double duration = animated ? 0.4f : 0.0f;
        [UIView animateWithDuration:duration animations:^{
            self.loadingView.alpha = 0.0f;
        } completion:^(BOOL finished){
            [self.loadingView removeFromSuperview];
            self.loadingView = nil;
        }];
    }
}

- (void)showErrorViewAnimated:(BOOL)animated
{
    ;
}

- (void)hideErrorViewAnimated:(BOOL)animated
{
    ;
}

#pragma mark titlebar button
/*
 *设置返回按钮，左侧显示
 */
- (void)setBackButton
{
    UIImage *img = [UIImage imageNamed:@"btn_back"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onLeftBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *baritem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = baritem;
}
/*
 *设置左侧按钮
 */
- (void)setLeftButton:(UIImage *)image
{
    if (!image)
    {
        return;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, image.size.width/*image.size.width + x*/, image.size.height);  // modified by zy, 2014-02-25
    [btn setImage:image forState:UIControlStateNormal];
#if 0   // modified by zy, 2014-02-25
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, x, 0, 0)];
#endif
    [btn addTarget:self action:@selector(onLeftBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *baritem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = baritem;
}
/*
 *设置右侧按钮
 */
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
    
    UIBarButtonItem *baritem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = baritem;
}

/*
 点击按钮响应，左按钮默认返回
 */
- (void)onLeftBtnAction:(id)sender
{
    if (self.isDismissMVC && [self respondsToSelector:@selector(dismissModalViewControllerAnimated:)])
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

    if (_leftDelegate)
    {
        [self.leftDelegate onLeft:self];
    }
}

- (void)onRightBtnAction:(id)sender
{
    ;
}

#pragma mark - notification

- (void)pop2RootVC
{
    if (self.navigationController != nil)
    {
        if ([self.navigationController respondsToSelector:@selector(popToRootViewControllerAnimated:)])
        {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
    
    // added by zy, 2014-02-28
    if ([self.navigationController isKindOfClass:[CTNavigationController class]])
    {
        self.navigationController.animating = NO;
    }
}

@end
