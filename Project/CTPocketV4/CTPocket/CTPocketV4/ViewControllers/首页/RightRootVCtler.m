//
//  RightRootVCtler.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-5-26.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//window的根界面

#import "RightRootVCtler.h"
#import "CustomizeSliderController.h"

@interface RightRootVCtler ()
{
    CustomizeSliderController *slider;
    UINavigationController *pushNavVCtler;
}
@end

@implementation RightRootVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCenter) name:MineShowHome object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //显示主界面
    slider=[CustomizeSliderController instance];
    [self addChildViewController:slider];                // 1
    slider.view.frame = self.view.bounds; // 2
    [self.view addSubview:slider.view];
    [slider didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UINavigationController*)navigationController
{
    return [slider navigationController];
}

#pragma mark - method
-(void)pushRightViewController:(CTBaseViewController*)viewController
{
    self.view.userInteractionEnabled=NO;
    viewController.leftDelegate=self;
    if (pushNavVCtler==nil) {
        pushNavVCtler=[[UINavigationController alloc] initWithRootViewController:viewController];
        pushNavVCtler.delegate=(id<UINavigationControllerDelegate>)self;
        [self addChildViewController:pushNavVCtler];
        pushNavVCtler.view.frame = self.view.bounds; // 2
        [self.view addSubview:pushNavVCtler.view];
        [pushNavVCtler didMoveToParentViewController:self];
    }
   
    CGRect bounds=self.view.bounds;
    CGFloat maxX=CGRectGetMaxX(bounds);
    
    __weak typeof(self) weakSelf=self;
   CGRect rect=pushNavVCtler.view.frame;
    rect.origin.x=maxX;
    pushNavVCtler.view.frame=rect;
    [UIView transitionWithView:pushNavVCtler.view duration:0.44 options:UIViewAnimationOptionCurveEaseOut animations:^(){
        CGRect descRect=rect;
        descRect.origin.x=CGRectGetMinX(bounds);
            pushNavVCtler.view.frame=descRect;
    } completion:^(BOOL finished){
        weakSelf.view.userInteractionEnabled=YES;
    }];
}
#pragma mark 清除界面
-(void)popView
{
    CGRect bounds=self.view.bounds;
    CGFloat maxX=CGRectGetMaxX(bounds);
    
    CGRect rect=pushNavVCtler.view.frame;
    rect.origin.x=maxX;
    __weak typeof(self) weakSelf=self;
    [UIView transitionWithView:pushNavVCtler.view duration:0.44 options:UIViewAnimationOptionCurveEaseOut animations:^(){
        CGRect descRect=rect;
        pushNavVCtler.view.frame=descRect;
    } completion:^(BOOL finished){
        [weakSelf removePush];
    }];
    
}
-(void)removePush
{
    if (pushNavVCtler) {
        [pushNavVCtler willMoveToParentViewController:nil];
        [pushNavVCtler.view removeFromSuperview];
        [pushNavVCtler removeFromParentViewController];
        pushNavVCtler=nil;
    }
}
#pragma mark 显示左侧
-(void)showCenter
{
    [self removePush];
    [slider toggleDrawerSide:MMDrawerSideRight animated:NO completion:nil];
}
#pragma mark - OnLeftActionDelegate
-(void)onLeft:(CTBaseViewController*)controller
{
    if (controller==([pushNavVCtler childViewControllers][0]))
    {
        [self popView];
    }
}
@end
