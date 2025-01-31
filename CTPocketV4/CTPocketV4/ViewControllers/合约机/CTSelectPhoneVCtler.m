//
//  CTSelectPhoneVCtler.m
//  CTPocketV4
//
//  Created by Y W on 14-3-18.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTSelectPhoneVCtler.h"

#import "SIAlertView.h"
#import "CTPRcScrollview.h"
#import "ImagePageControl.h"
#import "CTScrollTextCell.h"
#import "BdSpecCell.h"
#import "CTBdSalesPackageCell.h"
#import "CTBdSalesPictureTextDetailCell.h"
#import "CTBdSalesPriceCell.h"
#import "CTSelectPhoneNumberCell.h"
#import "COrderWildProductFillVctrler.h"
#import "SVProgressHUD.h"


#import "QryBdSalesComInfo.h"
#import "QryBdSpec.h"

#import "UIImage+Category.h"
#import "UIColor+Category.h"
#import "UIView+RoundRect.h"

#import "Utils.h"
#import "CTNumberSelectedVCtler.h"
#import "CTContractProductDetailVCtler.h"

#import "CTScrollTopBtn.h"
#import "ToastAlertView.h"
#import "PrestoreCell.h"
#import <QuartzCore/QuartzCore.h>
@interface FileterTableView :UITableView
@property(nonatomic,assign)UIWebView *webView;
@property(nonatomic,assign)BOOL isFilter;
@end

@implementation FileterTableView

// 重写hitTest:withEvent:将整个UIView的移动量重定位给UIScrollView
/**
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.isFilter)
    {
        return [super hitTest:point withEvent:event];
    }else
    {
        return self.webView;
    }
    
}
*/

@end

@interface CTSelectPhoneVCtler () <UITableViewDataSource, UITableViewDelegate, CTPRcScrollViewDatasource>
{
    NSMutableArray  *Height_BdSalesPictureTextDetailCell;//图文详情的高度
    BOOL errorShow;
}

@property (nonatomic, strong) QryBdSalesComInfo *qryBdSalesComInfoNetworking;
@property (nonatomic, strong) QryBdSalesComInfoModel *qryBdSalesComInfoModel;
@property (nonatomic, assign) BOOL qryBdSalesComInfoLoading;

@property (nonatomic, strong) QryBdSpec *qryBdSpecNetworking;
@property (nonatomic, strong) QryBdSpecModel *qryBdSpecModel;
@property (nonatomic, assign) BOOL qryBdSpecLoading;

@property (nonatomic, strong) NSMutableDictionary *configDictionary;
@property (nonatomic, strong) NSArray *configKeyArray; //保存排序好的floor key

@property (nonatomic, strong) FileterTableView *tableView;
@property (nonatomic, strong) CTPRcScrollview *pagedFlowView;

@property (nonatomic, strong) NSIndexPath *indexPathForPictureTextDetailCell;

@property(nonatomic,strong)CTScrollTopBtn *btn_scroll2top;

@property (nonatomic, strong) UIImageView *directedImageView;
@property (nonatomic, strong) UIButton *buyButton;

@property (nonatomic, copy) NSString *selectedId;//选中的项的ID
@end

@implementation CTSelectPhoneVCtler

- (void)loadView
{
     Height_BdSalesPictureTextDetailCell=[NSMutableArray arrayWithObject:@(48)];
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.origin.y = 0;
    frame.size.height = [[UIScreen mainScreen] applicationFrame].size.height - 56 - 44 * 2;
    
    FileterTableView *tableView = [[FileterTableView alloc] initWithFrame:frame];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    

    self.tableView = tableView;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    self.title = @"商品详情";

    
    {
        float y = [[UIScreen mainScreen] applicationFrame].size.height - 44 * 2 - 56;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.tableView.frame), 56)];
        view.backgroundColor = [UIColor clearColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(ceilf((CGRectGetWidth(view.frame) - 260)/2.0), ceilf((CGRectGetHeight(view.frame) - 36)/2.0), 260, 36);
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:94 G:189 B:42 A:1] cornerRadius:4] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"buyPhoneBtn_disable"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(nowBuyPhone) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"立即购买" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [button setBackgroundImage:[UIImage imageNamed:@"buyPhoneBtn_disable"] forState:UIControlStateDisabled];
        [view addSubview:button];
        
        [self.view addSubview:view];
        self.buyButton = button;
        
        //滚到顶部按钮
        __weak typeof(self) weakSelf = self;
        self.btn_scroll2top=[[CTScrollTopBtn alloc] initWithFrame:CGRectZero selectBlock:
                             ^(id obj){
                                 UITableView *tableView=weakSelf.tableView;
                                 CGRect rect_table=CGRectMake(0, 0,CGRectGetWidth(tableView.frame),
                                                              CGRectGetHeight(tableView.frame));
                                 [tableView scrollRectToVisible:rect_table animated:YES];
                                 
                                 CTBdSalesPictureTextDetailCell *cell = (CTBdSalesPictureTextDetailCell *)[weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:9]];
                                 if (cell)
                                 {
                                      NSLog(@"调用了啊啊啊啊啊啊啊啊----------->>>%s",__func__);
                                     [cell removeFilter];
                                 }
                                 
                             } delegate:self];
        self.btn_scroll2top.exclusiveTouch=YES;
        [self.view addSubview:self.btn_scroll2top];
        CGFloat btn_width=43;//高度和宽度相同
        CGFloat btnX=CGRectGetWidth(self.tableView.frame)-btn_width-8;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]-6.0>=0)
        {//6.0以上通过AutoLayout设置坐标系
            
            self.btn_scroll2top.translatesAutoresizingMaskIntoConstraints=NO;
            
            NSDictionary *dic=@{@"btn":self.btn_scroll2top};
            
           
            //x坐标
            NSString *format_horizontal=[NSString stringWithFormat:@"H:|-%f-[btn]",btnX];
            NSArray *constraints_horizontal=[NSLayoutConstraint constraintsWithVisualFormat:format_horizontal
                                                                                    options:0 metrics:nil views:dic];
            [self.view addConstraints:constraints_horizontal];
            
            //y坐标
            NSLayoutConstraint *constraints_vertical=[NSLayoutConstraint constraintWithItem:self.btn_scroll2top
                                                                                 attribute :NSLayoutAttributeBottom
                                                                                 relatedBy :NSLayoutRelationEqual
                                                                                 toItem    :self.tableView
                                                                                 attribute :NSLayoutAttributeBottom
                                                                                 multiplier:1.0
                                                                                 constant  :-8];
            [self.view addConstraint:constraints_vertical];
            
            
            NSString *format_width=[NSString stringWithFormat:@"H:[btn(==%f)]",btn_width];
            //设置按钮的宽
            NSArray *constriants_width= [NSLayoutConstraint constraintsWithVisualFormat:format_width options:0 metrics:nil views:dic];
            [self.btn_scroll2top addConstraints:constriants_width];
            
            
            NSString *format_height=[NSString stringWithFormat:@"V:[btn(==%f)]",btn_width];
            //设置按钮的高
            NSArray *constriants_height= [NSLayoutConstraint constraintsWithVisualFormat:format_height options:0 metrics:nil views:dic];
            [self.btn_scroll2top addConstraints:constriants_height];
        }
        else
        {
            //6.0以下通过设置frame设置坐标系
            CGFloat btnY=CGRectGetMinY(view.frame)-btn_width-8;
            CGRect frame_btn=CGRectMake(btnX, btnY, btn_width, btn_width);
            self.btn_scroll2top.frame=frame_btn;
        }
        
        
    }
   
    [self loadData];
    
    
    //  引导层 遮罩层
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *isShow = [defaults objectForKey:@"SelectPhone"];
    
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
                directedImageView.image = [UIImage imageNamed:@"SelectPhone_iphone4"];
            } else {
                directedImageView.image = [UIImage imageNamed:@"SelectPhone_iphone4"];
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
                directedImageView.image = [UIImage imageNamed:@"SelectPhone_iphone5"];
            } else {
                directedImageView.image = [UIImage imageNamed:@"SelectPhone_iphone5"];
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
        
        [defaults setObject:@"YES" forKey:@"SelectPhone"];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.phoneData && self.phoneData.PhoneNumber) {
        CTSelectPhoneNumberCell *cell = (CTSelectPhoneNumberCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:7]];
        [cell.button setTitle:self.phoneData.PhoneNumber forState:UIControlStateNormal];
        cell.button.layer.borderColor=[[UIColor clearColor] CGColor];
        cell.button.layer.borderWidth=0.0f;
    }
}

- (void)dealloc
{
    [self.pagedFlowView stopTimer];
    self.pagedFlowView.delegate = nil;
    self.pagedFlowView.datasource = nil;
}

#pragma mark - funcs

- (void)goProductDetailVCtler
{ //套餐详情  add by gongxt 2014-04-04
    CTContractProductDetailVCtler *vc = [[CTContractProductDetailVCtler alloc] init];
    vc.jumpUrl = self.qryBdSalesComInfoModel.PackageUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)nowBuyPhone
{
    if (self.qryBdSalesComInfoModel.Stock <= 0) {
        NSString * tipmsg = @"亲，你挑到爆款被抢光啦，小二正在疯狂补货，先看看别的吧";
        /**
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:tipmsg];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  return ;
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];*/
        ToastAlertView* alert = [ToastAlertView new];
        [alert showAlertMsg:tipmsg];
        return;
    }
    BOOL hasPhoneNumber=NO;
    if (self.phoneData && self.phoneData.PhoneNumber) {
        hasPhoneNumber=YES;
    }
    

//
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    if (self.qryBdSalesComInfoModel.WithNumber)
    {
        [ud setBool:NO forKey:@"BareMetal"];
        if (hasPhoneNumber) {
            CTSelectPhoneNumberCell *cell = (CTSelectPhoneNumberCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:7]];
            cell.button.layer.borderColor=[[UIColor clearColor] CGColor];
            cell.button.layer.borderWidth=0.0f;
        }
        else
        {
            
            ToastAlertView* alert = [ToastAlertView new];
            [alert showAlertMsg:@"亲，请选择一个号码"];
            
            CTSelectPhoneNumberCell *cell = (CTSelectPhoneNumberCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:7]];
            cell.button.layer.borderColor=[[UIColor redColor] CGColor];
            cell.button.layer.borderWidth=1.0f;
            return;
        }
    }else
    {
        [ud setBool:YES forKey:@"BareMetal"];
    }
    [ud synchronize];
    
    //填写订单信息  add by liuruxian 2014-03-27
    COrderWildProductFillVctrler *vc = [COrderWildProductFillVctrler new];
    vc.dataModel = self.qryBdSalesComInfoModel;
    vc.phoneData = self.phoneData ;
    vc.SalesProdId = self.salesId ;
    /*
    vc.info = @{@"item": self.item,
                @"index": dict[@"index"],
                @"combo": dict[@"combo"],
                @"package": dict[@"package"]};
     */
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goSelectPhoneNumber
{
    CTNumberSelectedVCtler *vc = [CTNumberSelectedVCtler new];
    vc.SalesproductId=self.salesId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reloadDataWithResponseDictionary:(NSDictionary *)responseDictionary
{
    self.qryBdSalesComInfoModel = [QryBdSalesComInfoModel modelObjectWithDictionary:responseDictionary];
    [self.pagedFlowView reloadData];
    
    // add by liuruxian 2014-05-06
    if (self.qryBdSalesComInfoModel.Stock<=0) {
        [self.buyButton setTitle:@"缺 货" forState:UIControlStateNormal];
        [self.buyButton setBackgroundImage:[UIImage imageNamed:@"buyPhoneBtn_disable"] forState:UIControlStateNormal];
        [self.buyButton setBackgroundImage:[UIImage imageNamed:@"buyPhoneBtn_disable"] forState:UIControlStateHighlighted];
//        self.buyButton.enabled = NO;
    } else {
        [self.buyButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:94 G:189 B:42 A:1] cornerRadius:4] forState:UIControlStateNormal];
//        [self.buyButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:34 G:69 B:16 A:1] cornerRadius:4]  forState:UIControlStateHighlighted]; 	
        
        [self.buyButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        [self.buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
        self.buyButton.enabled = YES;
    }

    [self.tableView reloadData];
    
    //在第一次进入界面的时候回滚到底部
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *isShow = [defaults objectForKey:@"SelectPhone"];
    if ([isShow isEqualToString:@"YES"]) {
        
    }
    else
    {
        NSInteger sections=[self.tableView numberOfSections];
        int row= [self.tableView numberOfRowsInSection:9];
        if (sections>9&&row==0)
        {
            return;
        }
        
        //NSIndexPath *path=[NSIndexPath indexPathForRow:0 inSection:9];
        //[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        //[defaults setObject:@"YES" forKey:@"SelectPhone"];
        //[defaults synchronize];
    }
}

- (void)reloadConfigWithResponseDictionary:(NSDictionary *)responseDictionary
{
    
    self.qryBdSpecModel = [QryBdSpecModel modelObjectWithDictionary:responseDictionary];
    
    if (self.configDictionary == nil) {
        self.configDictionary = [NSMutableDictionary dictionary];
    } else {
        [self.configDictionary removeAllObjects];
    }
    
    for (ConfigModel *config in self.qryBdSpecModel.DataList) {
        id key = [NSNumber numberWithUnsignedInteger:config.Floor];
        NSMutableArray *array = [self.configDictionary objectForKey:key];
        if (array == nil) {
            array = [NSMutableArray array];
            [self.configDictionary setObject:array forKey:key];
        }
        [array addObject:config];
    }
    
    NSMutableArray *floorSortArray = [NSMutableArray arrayWithArray:[self.configDictionary allKeys]];
    self.configKeyArray = [floorSortArray sortedArrayUsingSelector:@selector(compare:)];
     [self.tableView reloadData];
}

#pragma mark - action

- (void)loadPictureDetail
{
    [self.pagedFlowView reloadData];
}

#pragma mark - networking

- (void)checkError:(NSError *)error
{
    if (errorShow) {
        return;
    }
    if (error.userInfo[@"ResultCode"])
    {
        if ([error.userInfo[@"ResultCode"] isEqualToString:@"X104"])
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
        else{
 
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                             andMessage:error.localizedDescription];
            [alertView addButtonWithTitle:@"确定"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                  }];
            
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            [alertView show];
        }
    } else{
//        [SVProgressHUD showErrorWithStatus:error.userInfo[@"NSLocalizedDescription"]];
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:error.userInfo[@"NSLocalizedDescription"]];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }
}

- (void)loadData
{
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    //    self.tableView.hidden = YES; 
     CTBdSalesPictureTextDetailCell *cell = (CTBdSalesPictureTextDetailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:9]];
    if (cell)
    {
        [cell removeWebView];
    }
    [self qryBdSalesComInfo];
    [self qryBdSpec];
}

- (void)endLoadData
{
    if ((!self.qryBdSalesComInfoLoading) && (!self.qryBdSpecLoading)) {
        
        self.tableView.hidden = NO;
        self.tableView.tableFooterView.hidden=NO;
        
        [SVProgressHUD dismiss];
    }
}

- (void)qryBdSalesComInfo
{
    self.qryBdSalesComInfoLoading = YES;
    errorShow=NO;
    if (self.qryBdSalesComInfoNetworking == nil) {
        self.qryBdSalesComInfoNetworking = [[QryBdSalesComInfo alloc] init];
    }
    __weak typeof(self) weakSelf = self;
    [self.qryBdSalesComInfoNetworking qryBdSalesComInfoWithSalesId:self.salesId finishBlock:^(NSDictionary *resultParams, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.qryBdSalesComInfoLoading = NO;
        [strongSelf endLoadData];
        
        if (error) {
            [strongSelf checkError:error];
            errorShow=YES;
            return;
        }
        
        [strongSelf reloadDataWithResponseDictionary:[resultParams objectForKey:@"Data"]];
    }];
}

- (void)qryBdSpec
{
    self.qryBdSpecLoading = YES;
     errorShow=NO;
    if (self.qryBdSpecNetworking == nil) {
        self.qryBdSpecNetworking = [[QryBdSpec alloc] init];
    }
    __weak typeof(self) weakSelf = self;
    [self.qryBdSpecNetworking qryBdSpecWithSalesId:self.salesId finishBlock:^(NSDictionary *resultParams, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.qryBdSpecLoading = NO;
        [strongSelf endLoadData];
        
        if (error) {
            [strongSelf checkError:error];
            errorShow=YES;
            return;
        }
        [strongSelf reloadConfigWithResponseDictionary:[resultParams objectForKey:@"Data"]];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:      //手机图片
        {
            if (self.qryBdSalesComInfoModel.PhotoAlbumList.count > 0) {
                rows = 1;
            }
        }
            break;
        case 1:     //销售品名称
        {
            if (self.qryBdSalesComInfoModel.SalesProdName.length > 0) {
                rows = 1;
            }
        }
            break;
        case 2:     //销售品促销优惠信息
        {
            if (self.qryBdSalesComInfoModel.SalesProdDisInfo.length > 0) {
                rows = 1;
            }
        }
            break;
        case 3:     //商品价格
        {
            rows = 1;
        }
            break;
        case 4:     //赠品信息
        {
            rows = self.qryBdSalesComInfoModel.Gifts.count;
        }
            break;
        case 5:     //规格配置  目前看有 颜色-内存-套餐
        {
            rows = [self.configKeyArray count];
        }
            break;
        case 6:     //套餐详情
        {
            if (self.qryBdSalesComInfoModel.Package) {
                rows = 1;
            }
        }
            break;
        case 7:     //去选号码
        {
            rows = 1;
        }
            break;
        case 8:     //预存款
        {
            rows = 1;
            break;
        }
        case 9:     //商品图文详情
        {
           
            if (self.qryBdSalesComInfoModel.SalesProdPicInfo) {
                rows = 1;
            }
        }
            break;
        default:
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier0 = @"Cell0"; //UITableviewCell 重用标记
    static NSString *cellIdentifier1 = @"Cell1"; //CTScrollTextCell 重用标记
    static NSString *cellIdentifier2 = @"Cell2"; //CTSelectPhoneNumberCell 重用标记
    static NSString *cellIdentifier3 = @"Cell3"; //BdSpecCell 重用标记
    static NSString *cellIdentifier4 = @"Cell4"; //CTBdSalesPackageCell 重用标记
    static NSString *cellIdentifier5 = @"Cell5"; //CTBdSalesPictureTextDetailCell 重用标记
    static NSString *cellIdentifier6 = @"Cell6"; //CTBdSalesPriceCell 重用标记
    static NSString *cellIdentifier7 = @"Cell7"; //PrestoreCell 重用标记

    
    
    //销售品名称 优惠信息 赠品
    if (indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 4) {
        CTScrollTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (cell == nil) {
            cell = [[CTScrollTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        if (indexPath.section == 1) {//销售品名称  OK
            cell.autoLabel.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
            cell.autoLabel.text = self.qryBdSalesComInfoModel.SalesProdName;
            cell.autoLabel.font = [UIFont boldSystemFontOfSize:16  ];
            cell.imageView.image = nil;
        } else if (indexPath.section == 2) {//优惠信息  OK
//            cell.autoLabel.textColor = [UIColor colorWithR:221 G:131 B:124 A:1];
            cell.autoLabel.textColor = [UIColor colorWithR:240 G:103 B:81 A:1];
            cell.autoLabel.text = self.qryBdSalesComInfoModel.SalesProdDisInfo;
            cell.autoLabel.font = [UIFont systemFontOfSize:13];//
            cell.imageView.image = nil;
        } else if (indexPath.section == 4) { //赠品 OK
            GiftModel *giftModel = [self.qryBdSalesComInfoModel.Gifts objectAtIndex:indexPath.row];
            cell.autoLabel.textColor = [UIColor colorWithR:162 G:162 B:162 A:1];
            cell.autoLabel.text = [NSString stringWithFormat:@"%@x%@", giftModel.Name, giftModel.Count];
            cell.autoLabel.font = [UIFont systemFontOfSize:13];
            
            if (giftModel.IconUrl.length > 0) {
                UIImage *defaultImage = [UIImage imageNamed:@""];
                cell.imageView.image = defaultImage;
                [cell.imageView setImageWithURL:[NSURL URLWithString:giftModel.IconUrl] placeholderImage:defaultImage];
            } else {
                cell.imageView.image = nil;
            }
        }
        return cell;
    }
    
    //价格
    if (indexPath.section == 3) { //OK
        CTBdSalesPriceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier6];
        if (cell == nil) {
            cell = [[CTBdSalesPriceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier6];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        [cell setMarketPrice:[NSString stringWithFormat:@"%@", [Utils smartNumberStringWithFloat:[self.qryBdSalesComInfoModel.MarketPrice floatValue]]]];
        [cell setDisPrice:[NSString stringWithFormat:@"%@", [Utils smartNumberStringWithFloat:self.qryBdSalesComInfoModel.SalesProdDisPrice]]];
        
        return cell;
    }
    
    //颜色 容量 套餐
    if (indexPath.section == 5) {
//        BdSpecCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
//        if (cell == nil) {
            BdSpecCell *cell  = [[BdSpecCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            cell.defaultId=self.salesId; 
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
//        }
        
        __weak typeof(self) weakSelf = self;
        cell.selectBlock = ^(id object){
            if ([object isKindOfClass:[ConfigModel class]]) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.salesId = [(ConfigModel *)object Pid];
                if (strongSelf.salesId==nil)
                { 
                    //判断是否为空，为空的话给予默认值
                    strongSelf.salesId=@"00000000F60C5378C77C7038E043433210AC8E1A";
                }
                [strongSelf loadData];
            }
        };
        NSString *key = [self.configKeyArray objectAtIndex:indexPath.row];
        NSArray *configList = [self.configDictionary objectForKey:key]; 
        [cell setConfigList:configList];
        
        return cell;
    }
    
    //套餐详情 OK
    if (indexPath.section == 6) {
        CTBdSalesPackageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier4];
        if (cell == nil) {
            cell = [[CTBdSalesPackageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier4];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        __weak typeof(self) weakSelf = self;
        cell.goDetailBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf goProductDetailVCtler];
        };
        
        cell.packageModel = self.qryBdSalesComInfoModel.Package;
        return cell;
    }
    
    //去选号码
    if (indexPath.section == 7) {
        CTSelectPhoneNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[CTSelectPhoneNumberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        if (!self.qryBdSalesComInfoModel.WithNumber)
        {
            cell.hidden=YES;
        }
        __weak typeof(self) weakSelf = self;
        cell.selectBlock = ^(id object) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf goSelectPhoneNumber];
        };
        return cell;
    }
    
    //预存款
    if(indexPath.section == 8)
    {
        PrestoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier7];
        if (cell == nil) {
            cell = [[PrestoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier7 ];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        NSArray *datas=self.qryBdSalesComInfoModel.Yck;
        cell.datas=datas;
        [cell config];
        return cell;
    }
    //图文详情
    if (indexPath.section == 9) {
        CTBdSalesPictureTextDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier5];
        if (cell == nil) {
            cell = [[CTBdSalesPictureTextDetailCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:cellIdentifier5
                                                               tableView:self.tableView
                                                              withHeight:Height_BdSalesPictureTextDetailCell];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        cell.Detail = self.qryBdSalesComInfoModel.SalesProdPicInfo;
        [cell addIndicator];
//        __weak typeof(self) weakSelf = self;
        cell.didFinishLoadBlock = ^{
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            [strongSelf.tableView reloadData];
//            [strongSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        };
        return cell;
    }
    
    
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier0];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        
        //手机图片
        if (indexPath.section == 0) {
            if (self.pagedFlowView == nil) {
                self.pagedFlowView = [[CTPRcScrollview alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,[self imageHeight])];
                self.pagedFlowView.datasource = self;
                [self.pagedFlowView reloadData];
            }
            [cell.contentView addSubview:self.pagedFlowView];
        } else {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        return cell;
    }
}
-(CGFloat)imageHeight
{
    CGFloat cellHeight= [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cellHeight-8;//215
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellHeight = 0;
    switch (indexPath.section) {
        case 0:
        {
            cellHeight = 223;
        }
            break;
        case 1:
            cellHeight = 26;
            break;
        case 2:
        case 4:
            cellHeight = 20;
            break;
        case 3:
            cellHeight = 30;
            break;
        case 5:
        {
            NSString *key = [self.configKeyArray objectAtIndex:indexPath.row];
            NSArray *configList = [self.configDictionary objectForKey:key];
            cellHeight = [BdSpecCell CellHeightWithConfigList:configList];
        }
            break;
        case 6:
        {
            cellHeight = [CTBdSalesPackageCell CellHeightWithPackageModel:self.qryBdSalesComInfoModel.Package];
        }
            break;
            
        case 7:
        {
            if (self.qryBdSalesComInfoModel.WithNumber)
            {
                cellHeight = 30;
            }
            else
            {
                cellHeight=0;
            }
        }
           
            break;
        case 8:
        {
            NSArray *datas=self.qryBdSalesComInfoModel.Yck;
             cellHeight = [PrestoreCell cellHeightWithDatas:datas];
        }
            break;
        case 9:
        {
//            cellHeight = [CTBdSalesPictureTextDetailCell cellHeight];
//            cellHeight=CGRectGetHeight(self.tableView.frame);
            cellHeight=[Height_BdSalesPictureTextDetailCell[0] floatValue];
        }
        default:
            break;
    }
    return cellHeight;
}


#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point_offset= scrollView.contentOffset;
    
    if (point_offset.y> 50)
    {
        [self.btn_scroll2top enable];
    }
    else
    {
        [self.btn_scroll2top disable];
    }
    CTBdSalesPictureTextDetailCell *cell = (CTBdSalesPictureTextDetailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:9]];
    if (cell)
    {
        CGRect tableViewRect = [self.tableView rectForSection:9];
        CGFloat offsetY = point_offset.y;
        if ((offsetY-tableViewRect.origin.y) >= 0)
        {
            [cell setActionView2WebView];
        } else {
            [cell removeFilter];
        }
    }
}


-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

#pragma mark - CTPRcScrollViewDatasource

- (NSInteger)numberOfPages
{
    return self.qryBdSalesComInfoModel.PhotoAlbumList.count;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    NSArray *array=self.qryBdSalesComInfoModel.PhotoAlbumList;
    NSURL *url=nil;
    if (index>=array.count)
    {
        url=[NSURL URLWithString:@""];
    }
    else
    {
        PhotoAlbumModel *photoAlbumModel = [array objectAtIndex:index];
        url= [NSURL URLWithString:photoAlbumModel.Url];//5800 1800
    }
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), [self imageHeight])];
    [imageView dwMakeRoundCornerWithRadius:0.0f];
    imageView.backgroundColor = [UIColor whiteColor];
    [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loadingImage2.png"]];
    
    return imageView;
}

@end
