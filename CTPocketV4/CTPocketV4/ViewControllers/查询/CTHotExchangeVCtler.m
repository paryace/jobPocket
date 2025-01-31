//
//  CTHotExchangeVCtler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 14-3-12.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTHotExchangeVCtler.h"
#import "CserviceOperation.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "SIAlertView.h"
#import "CTPointExchangeCell.h"
#import "CTPointCommodityDetailVCtler.h"
#import "CTPointCommodityListVCtler.h"
#import "IgUserInfo.h"
#import "IgInfo.h"
#import "IgProdList.h"
#import "CTLoadingCell.h"
#import "CTPointConfirmExchangeVCtler.h"
#import "EGORefreshTableHeaderView2.h"
#import "CTPointQueryVCtler.h"

@interface CTHotExchangeVCtler ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *CommodityList;
@property (nonatomic, strong) CserviceOperation *igProdListOpt;
@property (nonatomic, assign) int pageSize;
@property (nonatomic, assign) int pageIndex;
@property (nonatomic, strong) NSString *maxPrice;
@property (nonatomic, assign) int Integral;

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isfinished;
@property (nonatomic, assign) BOOL isPullreflesh;

@property (nonatomic, strong) IgProdList *igProdListNetworking;

@property (nonatomic, strong) EGORefreshTableHeaderView2 *refreshHeaderView;
@property (nonatomic, strong) UIView *coverView;
// 网络
@property (nonatomic, strong) CserviceOperation *custIdOpt;
@property (nonatomic, strong) CserviceOperation *igInfoOpt;

@property (nonatomic, strong) NSString * CustId;

@end

@implementation CTHotExchangeVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.pageIndex = 1;
        self.pageSize = 20;
        self.isLoading = NO;
        self.isfinished = NO;
        self.isPullreflesh = NO;
        self.refleshType = nonStatus;
    }
    return self;
}

#pragma mark - init Data

- (NSMutableArray *)CommodityList{
    if (!_CommodityList) {
        _CommodityList = [NSMutableArray array];
    }
    return _CommodityList ;
}


#pragma mark - control

- (UITableView *) tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.backgroundColor = [UIColor colorWithRed:239/255. green:239/255. blue:239/255. alpha:1];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
        _tableView.dataSource = (id<UITableViewDataSource>)self;
        _tableView.delegate = (id<UITableViewDelegate>)self;
        [self.view addSubview:_tableView];
        
        if (!_refreshHeaderView) {
            _refreshHeaderView = [[EGORefreshTableHeaderView2 alloc] initWithFrame:CGRectMake(0.0f, 0.0f-_tableView.frame.size.height, self.view.frame.size.width, _tableView.frame.size.height)];
            _refreshHeaderView.backgroundColor = [UIColor clearColor];
            _refreshHeaderView.delegate = (id<EGORefreshTableHeaderDelegate2>)self;
            [self.tableView addSubview:_refreshHeaderView];
        }
    }
    
    return _tableView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.view.bounds];
        _coverView.backgroundColor = [UIColor colorWithRed:239/255. green:239/255. blue:239/255. alpha:1];
        _coverView.hidden = NO ;
        _coverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ;
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _coverView.frame.size.width, _coverView.frame.size.height)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:16];
            label.textAlignment = UITextAlignmentCenter ;
            label.text = @"加载失败...";
            [_coverView addSubview:label];
        }
        _coverView.userInteractionEnabled = NO;
        [self.tableView addSubview:_coverView];
    }
    
    return _coverView ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    [self tableView];
    [self initData];
}

#pragma mark - function

- (void)initData
{
    __weak typeof (self)wself = self;
    self.isLoading = YES ;
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *DeviceNo = loginInfoDict[@"UserLoginName"];
    [[IgUserInfo shareIgUserInfo] igUserInfoWithDeviceNo:DeviceNo finishBlock:^(NSDictionary *resultParams, NSError *error) {
        if (!error)
        {
            NSDictionary *data = resultParams[@"Data"];
            NSString *CustId = [data objectForKey:@"CustId"];
            if (CustId) {
                [[IgInfo shareIgInfo] igInfoWithDeviceNo:DeviceNo CustId:CustId finishBlock:^(NSDictionary *resultParams, NSError *error) {
                    if (error) {
                        [wself checkError:error];
                        return;
                    }
                    NSDictionary *data = resultParams[@"Data"];
                    NSString *Integral = data[@"Integral"];
                    wself.Integral = (NSUInteger)[Integral integerValue];
                    [wself igProdListWithMaxPrice:[Integral integerValue]];
                    
                }];
            }
        }
        else {
            [SVProgressHUD dismiss];
            self.isLoading = NO ;
            switch (self.refleshType) {
                case nonStatus:
                    break;
                case pullDown:
                {
                    [self doneLoadingTableViewData];
                }
                    break;
                case pullUp:
                {
                    
                }
                    break;
            }
            [self.tableView reloadData];
        }
    }];
    
}


#pragma mark - netWork

- (void)checkError:(NSError *)error
{
    if (error.userInfo[@"ResultCode"])
    {
        if ([error.userInfo[@"ResultCode"] isEqualToString:@"X104"])
        {
            // 取消掉全部请求和回调，避免出现多个弹框
            [MyAppDelegate.cserviceEngine cancelAllOperations];
            // 提示重新登录
//            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
//                                                             andMessage:@"长时间未登录，请重新登录。"];
//            [alertView addButtonWithTitle:@"确定"
//                                     type:SIAlertViewButtonTypeDefault
//                                  handler:^(SIAlertView *alertView) {
//                                      [MyAppDelegate showReloginVC];
//                                      if (self.navigationController != nil)
//                                      {
//                                          [self.navigationController popViewControllerAnimated:NO];
//                                      }
//                                  }];
//            
//            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
//            [alertView show];
        }
    }
}

- (void)goExchangeVC:(UIButton *)button
{
    NSDictionary *dictionary =  [self.CommodityList objectAtIndex:button.tag];
    int IntegralPrice = [dictionary[@"IntegralPrice"] intValue];
    if (self.Integral<IntegralPrice) {
        NSString *less = [NSString stringWithFormat:@"亲，你还需要%d积分即可兑换此宝贝了喔！",IntegralPrice-self.Integral];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:less];
        [alertView addButtonWithTitle:@"确认"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {

                              }];
        [alertView addButtonWithTitle:@"查看我的积分"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  CTPointQueryVCtler *vc = [[CTPointQueryVCtler alloc] init];
                                  [self.navigationController pushViewController:vc animated:YES];
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }
    else {
        CTPointConfirmExchangeVCtler *vc = [[CTPointConfirmExchangeVCtler alloc] init];
        vc.Integral = self.Integral;
        vc.commodityInfo = [self.CommodityList objectAtIndex:button.tag];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)goCommodityDetailVCWithIndexPath:(NSIndexPath *)indexPath
{
    CTPointCommodityDetailVCtler *vc = [[CTPointCommodityDetailVCtler alloc] init];
    vc.commodityInfo = [self.CommodityList objectAtIndex:indexPath.row];
    vc.Integral = self.Integral ;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadmore
{
    if (self.isfinished) {
        return;
    }
    if (!self.isLoading) {
        self.isLoading = YES;
        [self initData];
    }
}

- (void) refleshHotPoint
{
    [self.CommodityList removeAllObjects];
    
}

#pragma mark - netWork

//查询可兑换的商品列表，需传入用户当前所拥有的积分最大值
- (void)igProdListWithMaxPrice:(NSUInteger)maxPrice
{
    NSString *PageIndex = [NSString stringWithFormat:@"%d",self.pageIndex];
    NSString *PageSize = @"20";
    NSString *Sort = @"4";
    NSString *MinPrice = @"0";
    NSString *MaxPrice = @"0";
    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               PageIndex,@"PageIndex",
                               PageSize,@"PageSize",
                               Sort,@"Sort",
                               MinPrice,@"MinPrice",
                               MaxPrice,@"MaxPrice",
                                nil];
    
    if (self.igProdListOpt) {
        [self.igProdListOpt cancel];
        self.igProdListOpt = nil;
    }
    
    __weak typeof(self) weakSelf = self;
    self.igProdListOpt = [MyAppDelegate.cserviceEngine
                          postXMLWithCode:@"igProdList"
                          params:params
                          onSucceeded:^(NSDictionary *dict) {
                              DDLogInfo(@"%s--%@", __func__, dict.description);
                              [weakSelf onSuceess:dict];
                          } onError:^(NSError *engineError) {
                              DDLogInfo(@"%s--%@", __func__, engineError);
                              [SVProgressHUD dismiss];
                              [weakSelf onFailed:engineError];
                              
                          }];
}

#pragma mark - sucess

- (void)onSuceess:(NSDictionary *)dict
{
    NSDictionary *data = dict[@"Data"];
    id CommodityList = [data objectForKey:@"CommodityList"];
    
    switch (self.refleshType) {
        case nonStatus:
        {
            self.refleshType = pullUp;
        }
            break;
            
        case pullDown: //下拉
        {
            [self.CommodityList removeAllObjects];
        }
            break;
        case pullUp:
        {
            
        }
            break;
    }
    
    if ([CommodityList isKindOfClass:[NSArray class]] && [CommodityList count] > 0) {
        [self.CommodityList addObjectsFromArray:CommodityList];
        if ([CommodityList count]<20) {
            self.isfinished = YES;
        }
    } else if ([CommodityList isKindOfClass:[NSDictionary class]]){
        NSArray *ListItem = [CommodityList objectForKey:@"ListItem"];
        if ([ListItem count]<20) {
            self.isfinished = YES;
        }
        if ([ListItem isKindOfClass:[NSArray class]] && ListItem.count > 0) {
            [self.CommodityList addObjectsFromArray:ListItem];
        } else {
            //无数据的提示
            
        }
    }
    
    if (self.refleshType == pullDown) {
        self.refleshType = pullUp ;
        self.pageIndex++;
        [self doneLoadingTableViewData];
    } else if(self.refleshType == pullUp){
        self.pageIndex++;
    }
    
    self.isLoading = NO;
    [SVProgressHUD dismiss];
    [self.tableView reloadData];
}

- (void)onFailed:(NSError *)engineError
{
    switch (self.refleshType) {
        case nonStatus:
        {
            self.isLoading = NO;
            [self.tableView reloadData];
        }
            break;
            
        case pullDown: //下拉
        {
            self.isLoading = NO;
            if (self.pageIndex == 1) {
                self.coverView.hidden = NO;
            }
            [self doneLoadingTableViewData];
            [self.tableView reloadData];
        }
            break;
        case pullUp:
        {
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.isLoading = NO;
                [self.tableView reloadData];
            });
        }
            break;
    }
}

#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        switch (self.refleshType) {
//            case nonStatus:
//            {
//                if (!self.isLoading) {
//                    return CGRectGetHeight(tableView.frame);
//                }
//                return 0;
//            }
//                break;
//            case pullDown:
//            {
//                if (!self.isLoading && self.pageIndex==1) {
//                    return CGRectGetHeight(tableView.frame);
//                }
//            }
//                break;
//            case pullUp:
//            {
//                if (self.pageIndex == 1) {
//                    return CGRectGetHeight(tableView.frame);
//                }
//            }
//                break;
//        }
//    }
//    
//    return 0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return self.coverView;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.refleshType == pullDown) {
        return 0 ;
    }
    
    if (self.isfinished) {
        return 1;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        if (self.isfinished || self.pageIndex == 1) {
            return 0;
        }
        
        return 1;
    }
    return self.CommodityList.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        static NSString *loadcell = @"loadcell";
        CTLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:loadcell];
        if (cell==nil) {
            cell = [[CTLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadcell];
        }
        if (self.isLoading) {
            [cell setView:YES];
        } else {
            [cell setView:NO];
        }
        
        return  cell;
    }
    
    cellIdentifier = @"Cell";
    
    CTPointExchangeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CTPointExchangeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.CommodityList.count > indexPath.row) {
        
        NSDictionary *dictionary = [self.CommodityList objectAtIndex:indexPath.row];
        
        cell.titleLabel.text = [dictionary objectForKey:@"CommodityName"];
        UIButton *centerBtn=cell.subTitleLabel.centerButton;
        [centerBtn setEnabled:YES];//modified by shallow 2014-04-14
        [centerBtn setTitle:[dictionary objectForKey:@"IntegralPrice"] forState:UIControlStateNormal];
        
        cell.exchangeButton.tag = indexPath.row;
        [cell.exchangeButton addTarget:self action:@selector(goExchangeVC:) forControlEvents:UIControlEventTouchUpInside];
        NSString *PicUrl = [dictionary objectForKey:@"PicUrl"];
        if (PicUrl.length > 0) {
            [cell.imageView setImageWithURL:[NSURL URLWithString:PicUrl] placeholderImage:[UIImage imageNamed:@"CommodityListDefault"]];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 45;
    }
    return 60;
}

#pragma mark - UITabelViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        return;
    }
    [self doneLoadingTableViewData];
    if (self.igProdListOpt) {
        [self.igProdListOpt cancel];
        self.igProdListOpt = nil;
        self.isLoading = NO;
    }
    [self goCommodityDetailVCWithIndexPath:indexPath];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGPoint offset = scrollView.contentOffset;
    if (offset.y<0) {
        if (!self.isLoading) {
            [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
        }
    }else
    {
        if (self.CommodityList && self.CommodityList.count>0 &&
            self.pageIndex > 1){
            //判断是否到达底部
            CGRect bounds = scrollView.bounds;
            CGSize size = scrollView.contentSize;
            UIEdgeInsets inset = scrollView.contentInset;
            float y = offset.y + bounds.size.height - inset.bottom;
            float h = size.height;
            
            float reload_distance = 5;
            if(y > h + reload_distance) {
                if (self.isfinished) {
                    return;
                }
                
                if (!self.isLoading) {
                    self.refleshType = pullUp;
                    self.isLoading = YES ;
                    [self.tableView reloadData];
                    [self initData];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    self.refleshType = pullDown;
    self.tableView.directionalLockEnabled = NO ;
	self.isLoading = YES;
    self.isfinished = NO;
    self.pageIndex = 1;
    self.coverView.hidden = YES;
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    [self initData];
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	self.isLoading = NO;
    self.tableView.directionalLockEnabled = YES ;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView2*)view{
	
    //触发加载事件
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView2*)view{
	return self.isLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView2*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
