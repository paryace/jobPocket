//
//  CTQueryVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTQueryVCtler.h"
#import "CTQryBalanceVCtler.h"
#import "CTPayHistoryVCtler.h"
#import "CTQrtStreamVCtler.h"
#import "CTQryPackageVctler.h"
#import "CTQryValueAddVCtler.h"
#import "CTChargeHistoryVctler.h"
#import "CTLoginVCtler.h"
#import "AppDelegate.h"
#import "CTQryWifiVCtler.h"
#import "CTQryServiceHallVCtler.h"

#import "CTPointQueryVCtler.h"
#import "CTPointExchangeVCtler.h"
#import "CTPoints4RecordVCtler.h"
#import "CTValueAddedVCtler.h"
#import "CTMyOrderListVCtler.h"
#import "CTBusiProcVCtler.h"
#import "COQueryVctler.h"
#import "CTRedeemVCtler.h"
#import "CTPointExchangeRecordVCtler.h"
#import "CTExchangeSucessVCtler.h"

#import "LeftTableView_CTQueryVCtler.h"
#import "RightTableView_CTQueryVCtler.h"

#import "UIImageView+mask.h"//added by huangfq 2014-6-6
#import "CustomizeSliderController.h"
@interface CTQueryVCtler ()<LeftTableViewDelegate>


@property (nonatomic, strong) UIImageView *directedImageView;
@property (nonatomic, assign) BOOL isJump; 

@end

@implementation CTQueryVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"查询";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:PAGEVIEW_BG_COLOR];
    
    
    {
        _leftNavBg = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,85,self.view.bounds.size.height - 44)];
        _leftNavBg.image =  [UIImage imageNamed:@"qry_leftbg.png"];
        _leftNavBg.backgroundColor = [UIColor clearColor];
        _leftNavBg.userInteractionEnabled = NO;
        _leftNavBg.alpha = 1;
        [self.view addSubview:_leftNavBg];
        
        _leftNavArrow = [[UIImageView alloc] initWithFrame:CGRectMake(85,0,5,14)];
        _leftNavArrow.image =  [UIImage imageNamed:@"qry_leftarow.png"];
        _leftNavArrow.backgroundColor = [UIColor clearColor];
        _leftNavArrow.userInteractionEnabled = NO;
        _leftNavArrow.alpha = 1;
        [self.view addSubview:_leftNavArrow];
        
        // add by liuruxian 2014-05-11
        _leftNavArrow.frame = CGRectMake(_leftNavArrow.frame.origin.x,
                                         52*_selectedIndex + (52-14)/2,
                                         5,
                                         14);
    }
    
    
    {
        leftTableView=[LeftTableView_CTQueryVCtler initialWithDelegate:self];
        leftTableView.homeIndex=self.selectedIndex;
        [self.view addSubview:leftTableView];
        
        rightTableView=[leftTableView rightTableView];
        [self.view addSubview:rightTableView];
    }
    if (self.sliederDelegate) {
        //右侧按钮
        [self setRightButton:[UIImage imageNamed:@"navigationBar_user_icon"]];
    }
    //处理遮盖层
    [self maskTip];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadMsg)
                                                 name:@"ReloadMsg"
                                               object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:rightTableView name:@"autoJumpPage" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 右侧按钮及其事件
- (void)setRightButton:(UIImage *)image
{
    if (!image)
    {
        return;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, image.size.width/*image.size.width + x*/, image.size.height);  // modified by zy, 2014-02-25
    [btn setImage:image forState:UIControlStateNormal];
 
    [btn addTarget:self action:@selector(onRightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.exclusiveTouch = YES;
    UIBarButtonItem *baritem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = baritem;
}


- (void)onRightBtnAction:(id)sender
{
    [self.sliederDelegate expandRight];
}

#pragma mark - 登录成功消息

- (void)reloadMsg
{
    if (_isJump) {
        _isJump = NO ;
        [rightTableView reloadWithHomeIndex:1];
        [UIView animateWithDuration:0.5
                         animations:^{
                             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                             UITableViewCell* cell = [leftTableView cellForRowAtIndexPath:indexPath];
                             CGRect cellf = [cell frame];
                             _leftNavArrow.frame = CGRectMake(_leftNavArrow.frame.origin.x,
                                                              cellf.origin.y + (cellf.size.height-14)/2,
                                                              5,
                                                              14);
                         }];
    }
}

#pragma mark - LeftTableViewDelegate
- (void)didSelectLeftRowAtIndexPath:(NSIndexPath *)indexPath
                       subTalbeView:(RightTableView_CTQueryVCtler*)subTalbeView
{
    int row=indexPath.row;
    
    if (rightTableView==nil)
    {
        rightTableView=subTalbeView;
        [self.view addSubview:rightTableView];
    }
    
    if (row == 1 && [Global sharedInstance].isLogin == NO)
    {
        [self loginFirst];
        _isJump = YES;
        return;
    }
    
    [rightTableView reloadWithHomeIndex:row];
    [UIView animateWithDuration:0.5
                     animations:^{
                         UITableViewCell* cell = [leftTableView cellForRowAtIndexPath:indexPath];
                         CGRect cellf = [cell frame];
                         _leftNavArrow.frame = CGRectMake(_leftNavArrow.frame.origin.x,
                                                          cellf.origin.y + (cellf.size.height-14)/2,
                                                          5,
                                                          14);
                     }];

}

- (void)didSelectRightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGRect)leftFrame
{
    return CGRectMake(0, 0, 85, self.view.bounds.size.height);
}
-(CGRect)rightFrame
{
  return  CGRectMake(88,0,self.view.frame.size.width-88,
               self.view.bounds.size.height - 44);
}

-(CTNavigationController*)leftNavigation
{
    return (CTNavigationController*)self.navigationController;
}

-(void)tableViewDidRefresh:(UITableView*)tableView
{
}

#pragma mark -func
- (void)setSelectedIndex:(int)selectedIndex
{
    _selectedIndex = selectedIndex;
    if (leftTableView)
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_selectedIndex inSection:0];
        [leftTableView.delegate tableView:leftTableView didSelectRowAtIndexPath:indexPath];
    }
   
}

-(void)loginFirst
{
    if([Global sharedInstance].isLogin == NO)
    {
        CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
        }];
    }
}

#pragma mark - 遮盖层
-(void)maskTip
{
    
    NSString *key = [NSString stringWithFormat:@"%@%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],@"QueryVC"];
    //  引导层 遮罩层
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *isShow = [defaults objectForKey:key];
    
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
                directedImageView.image = [UIImage imageNamed:@"QueryVC_iphone4"];
            } else {
                directedImageView.image = [UIImage imageNamed:@"QueryVC_iphone4"];
            }
        } else
        {
            directedImageView = [[UIImageView alloc] initWithFrame:
                                 CGRectMake(0, 0,
                                            CGRectGetWidth(window.frame),
                                            568)];
            
            directedImageView.backgroundColor = [UIColor clearColor];
            directedImageView.userInteractionEnabled = YES ;
            directedImageView.autoresizingMask = UIViewContentModeScaleAspectFill;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                directedImageView.image = [UIImage imageNamed:@"QueryVC_iphone5"];
            } else {
                directedImageView.image = [UIImage imageNamed:@"QueryVC_iphone5"];
            }
            
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
