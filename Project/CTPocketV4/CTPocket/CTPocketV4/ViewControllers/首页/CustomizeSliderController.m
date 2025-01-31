//
//  CustomizeSliderController.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-5-26.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//抽屉交互的实现

#import "CustomizeSliderController.h"
#import "CTHomeVCtler.h"
#import "MineRightManager.h"
#import "CTNavigationController.h"
#import "RightRootVCtler.h"
#import "CTQueryVCtler.h"
#import "CTRechargeVCtler.h"
#import "CTPreferentialVCtler.h"
#import "CTMoreVCtler.h"
#import "AppDelegate.h"

#import "UIImageView+mask.h"
@interface CustomizeSliderController ()

@property (nonatomic,strong)UIImageView *directedImageView;
@end

@implementation CustomizeSliderController
+(instancetype)instance
{

    //左边
    CTHomeVCtler *vc1 = [[CTHomeVCtler alloc] init];
    CTNavigationController *nav1 = [[CTNavigationController alloc] initWithRootViewController:vc1];
    CTQueryVCtler *vc2 = [[CTQueryVCtler alloc] init];
    CTNavigationController *nav2 = [[CTNavigationController alloc] initWithRootViewController:vc2];
    CTRechargeVCtler *vc3 = [[CTRechargeVCtler alloc] init];
    CTNavigationController *nav3 = [[CTNavigationController alloc] initWithRootViewController:vc3];
    CTPreferentialVCtler *vc4 = [[CTPreferentialVCtler alloc] init];
    CTNavigationController *nav4 = [[CTNavigationController alloc] initWithRootViewController:vc4];
    CTMoreVCtler *vc5 = [[CTMoreVCtler alloc] init];
    CTNavigationController *nav5 = [[CTNavigationController alloc] initWithRootViewController:vc5];
    
    CustomTabBarVCtler *center = [[CustomTabBarVCtler alloc] init];
    MyAppDelegate.tabBarController=center;
    MyAppDelegate.tabBarController.viewControllers = @[nav1, nav2, nav3, nav4, nav5];
    
    
        //右边
    MineRightManager * rightManager = [MineRightManager instance];
    UIViewController *right=[rightManager currentController];
    //初始化抽屉交互的viewcontroller
    CustomizeSliderController * drawerController = [[CustomizeSliderController alloc]
                                             initWithCenterViewController:center
                                             leftDrawerViewController:nil
                                                    rightDrawerViewController:right];
    //是否点击左侧关闭
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeTapCenterView|MMCloseDrawerGestureModePanningCenterView;
    [drawerController setGestureCompletionBlock:^(MMDrawerController *controller, UIGestureRecognizer *gesture){
        if(MyAppDelegate.tabBarController.selectedIndex==0){
            [Utils showRecommend];////第二次回到首页弹出提示框
        }
    }];
//

    //设置宽度
    [drawerController     setMaximumRightDrawerWidth:206  animated:YES   completion:nil];
    //设置动画
    [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         UIViewController * sideDrawerViewController;
         CATransform3D transform;
         CGFloat maxDrawerWidth;
         
         if(drawerSide == MMDrawerSideLeft){
             sideDrawerViewController = drawerController.leftDrawerViewController;
             maxDrawerWidth = drawerController.maximumLeftDrawerWidth;
         }
         else if(drawerSide == MMDrawerSideRight){
             sideDrawerViewController = drawerController.rightDrawerViewController;
             maxDrawerWidth = drawerController.maximumRightDrawerWidth;
         }
         
         if(percentVisible > 1.0){
             transform = CATransform3DMakeScale(percentVisible, 1.f, 1.f);
             
             if(drawerSide == MMDrawerSideLeft){
                 transform = CATransform3DTranslate(transform, maxDrawerWidth*(percentVisible-1.f)/2, 0.f, 0.f);
             }else if(drawerSide == MMDrawerSideRight){
                 transform = CATransform3DTranslate(transform, -maxDrawerWidth*(percentVisible-1.f)/2, 0.f, 0.f);
             }
         }
         else {
             transform = CATransform3DIdentity;
         }
         [sideDrawerViewController.view.layer setTransform:transform];
         
     }];
    
     
    rightManager.homeVctler=vc1;
    //设置委托
    rightManager.changeRightDelegate=drawerController;
    //首页设置委托
    vc1.sliederDelegate=drawerController;
    //查询界面设置委托
    vc2.sliederDelegate=drawerController;
    //充值界面设置委托
    vc3.sliederDelegate=drawerController;
    //更多界面设置委托
    vc5.sliederDelegate=drawerController;
    return drawerController;
}

#pragma mark - method
-(UINavigationController*)navigationController
{
    return (UINavigationController*)self.centerViewController;
}
#pragma mark - SliderDelegate
-(void)expandRight
{
    __weak typeof(self) weakSelf=self;
    [self toggleDrawerSide:MMDrawerSideRight animated:YES completion:^(BOOL finished){
        if(weakSelf.openSide == MMDrawerSideNone&&MyAppDelegate.tabBarController.selectedIndex==0){
            [Utils showRecommend];////第二次回到首页弹出提示框
        }
        [self maskTip];
    }];
    
    
}
-(void)shrinkRight
{
    [self toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}
#pragma mark - ChangeRightDelegate
-(void)changeRight:(CTBaseViewController*)rightVCtler
{
    [self setRightDrawerViewController:rightVCtler];
}
-(void)pushRightViewController:(CTBaseViewController*)viewController
{
    RightRootVCtler *root= (RightRootVCtler*) self.parentViewController;
    [root pushRightViewController:viewController];
}

#pragma mark - 遮盖层
-(void)maskTip
{
    
    NSString *key = [NSString stringWithFormat:@"%@%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],@"Recommend"];
    //  引导层 遮罩层
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *isShow = [defaults objectForKey:key];
    NSLog(@"key:%@",key);
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
       
            directedImageView.image = [UIImage imageNamed:@"Recommend4"];
          
        } else
        {
            directedImageView = [[UIImageView alloc] initWithFrame:
                                 CGRectMake(0, 0,
                                            CGRectGetWidth(window.frame),
                                            568)];
            
            directedImageView.backgroundColor = [UIColor clearColor];
            directedImageView.userInteractionEnabled = YES ;
            directedImageView.autoresizingMask = UIViewContentModeScaleAspectFill;
     
            directedImageView.image = [UIImage imageNamed:@"Recommend5"];
        }
        
        //modified by huangfq 2014-6-6
        directedImageView = [directedImageView accordingImageForImageView:directedImageView.image];
        if (directedImageView) {
            
            self.directedImageView = directedImageView;
            [window addSubview:directedImageView];
            {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.backgroundColor = [UIColor clearColor];
                button.frame = directedImageView.bounds;
                [button addTarget:self action:@selector(removeDirected) forControlEvents:UIControlEventTouchUpInside];
                [directedImageView addSubview:button];
            }
            [defaults setObject:@"YES" forKey:key];
            [defaults synchronize];
        }
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


@end
