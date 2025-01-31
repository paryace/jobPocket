//
//  CTPointsVCtler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 14-3-13.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTPointsVCtler.h"
#import "SVProgressHUD.h"
#import "SIAlertView.h"
#import "AppDelegate.h"
#import "CTPointConfirmExchangeVCtler.h"
#import "CTPointCommodityDetailVCtler.h"
#import "CTLoadingCell.h"
#import "CTPointExchangeCell.h"
#import "SIAlertView.h"
#import "CTPointQueryVCtler.h"
#import "EGORefreshTableHeaderView2.h"

typedef enum {
    Ascending=0,
    Descending
} SORTTYPE;


typedef enum _RefleshType
{
    pullUp=0,
    pullDown,//下拉
    nonStatus
}RefleshType;



NSString *const PointsSortDataNotified = @"pointsSort";

@interface CTPointsVCtler ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *CommodityList;
@property (nonatomic, strong) NSMutableArray *ascendingArray;
@property (nonatomic, strong) NSMutableArray *descendingArray;
@property (nonatomic, assign) SORTTYPE sortType;

@property (nonatomic, assign) BOOL asIsloading;
@property (nonatomic, assign) BOOL asIsfinished;
@property (nonatomic, assign) int asPageIndex;
@property (nonatomic, assign) int asPageSize;

@property (nonatomic, assign) BOOL desIsloading;
@property (nonatomic, assign) BOOL desIsfinished;
@property (nonatomic, assign) int desPageIndex;
@property (nonatomic, assign) int desPageSize;

@property (nonatomic, strong) CserviceOperation *AspointOpt;
@property (nonatomic, strong) CserviceOperation *DespointOpt;

@property (nonatomic, strong) EGORefreshTableHeaderView2 *refreshHeaderView;
@property (nonatomic, assign) RefleshType asRefleshType;
@property (nonatomic, assign) RefleshType desRefleshType;
@property (nonatomic, strong) UIView *coverView;


@end

@implementation CTPointsVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.ascendingArray = [NSMutableArray array];
        self.descendingArray = [NSMutableArray array];
        self.asIsfinished = NO;
        self.asIsloading = NO;
        self.desIsfinished = NO;
        self.desIsloading = NO;
        self.asPageIndex = 1;
        self.asPageSize = 20;
        self.desPageIndex = 1;
        self.desPageSize = 20;
        self.sortType = Descending;
        self.asRefleshType = nonStatus;
        self.desRefleshType = nonStatus ;
        
        //监听消息(升降序)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sortNotification)
                                                     name:PointsSortDataNotified object:nil];
    }
    return self;
}

#pragma mark - control

- (UITableView *) tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.backgroundColor = [UIColor colorWithRed:239/255. green:239/255. blue:239/255. alpha:1];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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
    self.sortType = Ascending ;
    [self igProdListWithAs];
}
#pragma mark - function

- (void)checkError:(NSError *)error
{
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
    }
}

- (void)goExchangeVC:(UIButton *)button
{
    switch (self.sortType) {
        case Ascending:
        {
            NSDictionary *dictionary =  [self.ascendingArray objectAtIndex:button.tag];
            int IntegralPrice = [dictionary[@"IntegralPrice"] intValue];
            if ([self.Integral integerValue]<IntegralPrice) {
                NSString *less = [NSString stringWithFormat:@"亲，你还需要%d积分即可兑换此宝贝了喔！",IntegralPrice-[self.Integral integerValue]];
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
            } else{
                CTPointConfirmExchangeVCtler *vc = [[CTPointConfirmExchangeVCtler alloc] init];
                vc.Integral = [self.Integral integerValue];
                vc.commodityInfo = [self.ascendingArray objectAtIndex:button.tag];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
            
        case Descending:
        {
            NSDictionary *dictionary =  [self.descendingArray objectAtIndex:button.tag];
            int IntegralPrice = [dictionary[@"IntegralPrice"] intValue];
            if ([self.Integral integerValue]<IntegralPrice) {
                NSString *less = [NSString stringWithFormat:@"亲，你还需要%d积分即可兑换此宝贝了喔！",IntegralPrice-[self.Integral integerValue]];
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
            } else{
                CTPointConfirmExchangeVCtler *vc = [[CTPointConfirmExchangeVCtler alloc] init];
                vc.Integral = [self.Integral integerValue];
                vc.commodityInfo = [self.descendingArray objectAtIndex:button.tag];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
    }
}

- (void)goCommodityDetailVCWithIndexPath:(NSIndexPath *)indexPath
{
    switch (self.sortType) {
        case Ascending:
        {
            CTPointCommodityDetailVCtler *vc = [[CTPointCommodityDetailVCtler alloc] init];
            vc.commodityInfo = [self.ascendingArray objectAtIndex:indexPath.row];
            vc.Integral = [self.Integral integerValue];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case Descending:
        {
            CTPointCommodityDetailVCtler *vc = [[CTPointCommodityDetailVCtler alloc] init];
            vc.commodityInfo = [self.descendingArray objectAtIndex:indexPath.row];
            vc.Integral = [self.Integral integerValue];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
}

#pragma mark - NSNotification

- (void)sortNotification
{
    if (self.sortType == Ascending) { // 降序
        self.sortType = Descending;
        if (self.descendingArray && [self.descendingArray count]<=0) {
            self.desIsloading = YES;
            self.desRefleshType = nonStatus;
            [self.tableView reloadData];
            [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
            [self igProdListWithDes];
        }
        [self.tableView reloadData];
    } else {
        self.sortType = Ascending ;
        if (self.ascendingArray && [self.ascendingArray count]<=0) {
            self.asIsloading = YES;
            self.asRefleshType = nonStatus;
            [self.tableView reloadData];
            [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
            [self igProdListWithAs];
        }
        [self.tableView reloadData];
    }
}
#pragma mark - netWork

- (void)igProdListWithAs
{
    NSString *PageIndex = [NSString stringWithFormat:@"%d",self.sortType==Ascending?self.asPageIndex:self.desPageIndex];
    NSString *PageSize = @"20";
    NSString *Sort = self.sortType==Ascending?@"1":@"2";
    NSString *MinPrice = self.infoDict[@"MinPrice"];
    NSString *MaxPrice = [self.infoDict[@"MaxPrice"] isEqualToString:@""]?@"9999999":self.infoDict[@"MaxPrice"];
  
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               PageIndex,@"PageIndex",
                               PageSize,@"PageSize",
                               Sort,@"Sort",
                               MinPrice,@"MinPrice",
                               MaxPrice,@"MaxPrice",
                               nil];
    
    
    __weak typeof(self) weakSelf = self;
    [MyAppDelegate.cserviceEngine
                     postXMLWithCode:@"igProdList"
                     params:params
                     onSucceeded:^(NSDictionary *dict) {
                         //格式化数据(将指定的数据格式化成数组)
                         dict = [Utils objFormatArray:dict path:@"Data/CommodityList/ListItem"];
                         
                         DDLogInfo(@"%s--%@", __func__, dict.description);
                         
                         NSDictionary *data = dict[@"Data"];
                         NSArray *array ;
                         
                         switch (self.asRefleshType) {
                             case nonStatus:
                             {
                                 self.asRefleshType = pullUp;
                             }
                                 break;
                                 
                             case pullDown: //下拉
                             {
                                 [self.ascendingArray removeAllObjects];
                             }
                                 break;
                             case pullUp:
                             {
                                 
                             }
                                 break;
                         }
                         
                         id CommodityList = [data objectForKey:@"CommodityList"];
                         if ([CommodityList isKindOfClass:[NSArray class]] && [CommodityList count] > 0)
                         {
                             array = [NSArray arrayWithArray:CommodityList];
                             if ([CommodityList count]<20) {
                                 weakSelf.asIsfinished = YES;
                             }
                         } else if ([CommodityList isKindOfClass:[NSDictionary class]]){
                             NSArray *ListItem = [CommodityList objectForKey:@"ListItem"];
                             if ([ListItem count]   <20) {
                                 weakSelf.asIsfinished = YES;
                             }
                             if ([ListItem isKindOfClass:[NSArray class]] && ListItem.count > 0) {
                                 array = [NSArray  arrayWithArray:ListItem];
                             } else {
                                 //无数据的提示
                             }
                         } else {
                             //无数据的提示
                         }
                         
                         if (weakSelf.asRefleshType == pullDown) {
                             weakSelf.asRefleshType = pullUp;
                             [weakSelf.ascendingArray addObjectsFromArray:array];
                             [weakSelf doneLoadingTableViewData];
                         } else {
                             [weakSelf.ascendingArray addObjectsFromArray:array];
                         }
                         
                         weakSelf.asIsloading = NO;
                         weakSelf.asPageIndex ++;
                         
                         [weakSelf.tableView reloadData];
                         [SVProgressHUD dismiss];
                         
                     } onError:^(NSError *engineError) {
                         DDLogInfo(@"%s--%@", __func__, engineError);
                         [SVProgressHUD dismiss];
                         switch (self.asRefleshType) {
                             case nonStatus:
                             {
                                 self.asIsloading = NO;
                                 [self.tableView reloadData];
                             }
                                 break;
                                 
                             case pullDown: //下拉
                             {
                                 if (self.asPageIndex == 1) {
                                     self.coverView.hidden = NO;
                                 }
                                 
                                 self.asIsloading = NO;
                                 [self doneLoadingTableViewData];
                                 [self.tableView reloadData];
                             }
                                 break;
                             case pullUp:
                             {
                                 double delayInSeconds = 1.0;
                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                     self.asIsloading = NO;
                                     [self.tableView reloadData];
                                 });
                             }
                                 break;
                         }
                     }];
}

- (void)igProdListWithDes
{
    NSString *PageIndex = [NSString stringWithFormat:@"%d",self.sortType==Ascending?self.asPageIndex:self.desPageIndex];
    NSString *PageSize = @"20";
    NSString *Sort = self.sortType==Ascending?@"1":@"2";
    NSString *MinPrice = self.infoDict[@"MinPrice"];
    NSString *MaxPrice = [self.infoDict[@"MaxPrice"] isEqualToString:@""]?@"9999999":self.infoDict[@"MaxPrice"];

    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               PageIndex,@"PageIndex",
                               PageSize,@"PageSize",
                               Sort,@"Sort",
                               MinPrice,@"MinPrice",
                               MaxPrice,@"MaxPrice",
                               nil];
    
    
    __weak typeof(self) weakSelf = self;
    [MyAppDelegate.cserviceEngine
                     postXMLWithCode:@"igProdList"
                     params:params
                     onSucceeded:^(NSDictionary *dict) {
                         //格式化数据(将指定的数据格式化成数组)
                         dict = [Utils objFormatArray:dict path:@"Data/CommodityList/ListItem"];
                         
                         DDLogInfo(@"%s--%@", __func__, dict.description);
                         NSDictionary *data = dict[@"Data"];
                         NSArray *array ;
                         
                         switch (self.desRefleshType) {
                             case nonStatus:
                             {
                                 self.desRefleshType = pullUp;
                             }
                                 break;
                                 
                             case pullDown: //下拉
                             {
                                 [self.descendingArray removeAllObjects];
                             }
                                 break;
                             case pullUp:
                             {
                                 
                             }
                                 break;
                         }
                         
                         id CommodityList = [data objectForKey:@"CommodityList"];
                         if ([CommodityList isKindOfClass:[NSArray class]] && [CommodityList count] > 0) {
                             array = [NSArray arrayWithArray:CommodityList];
                             if ([CommodityList count]<20) {
                                 weakSelf.desIsfinished = YES;
                             }
                         } else if ([CommodityList isKindOfClass:[NSDictionary class]]){
                             NSArray *ListItem = [CommodityList objectForKey:@"ListItem"];
                             if ([ListItem count]<20) {
                                 weakSelf.desIsfinished = YES;
                             }
                             if ([ListItem isKindOfClass:[NSArray class]] && ListItem.count > 0) {
                                 array = [NSArray arrayWithArray:ListItem];
                             } else {
                                 //无数据的提示
                             }
                         } else {
                             //无数据的提示
                             
                         }
                         
                         if (weakSelf.desRefleshType == pullDown) {
                             weakSelf.desRefleshType = pullUp ;
                             [weakSelf.descendingArray addObjectsFromArray:array];
                             [weakSelf doneLoadingTableViewData];
                         } else {
                             [weakSelf.descendingArray addObjectsFromArray:array];
                         }
                         
                         weakSelf.desIsloading = NO;
                         weakSelf.desPageIndex ++;
                         
                         [weakSelf.tableView reloadData];
                         [SVProgressHUD dismiss];
                         
                     } onError:^(NSError *engineError) {
                         DDLogInfo(@"%s--%@", __func__, engineError);
                         [SVProgressHUD dismiss];
                         switch (self.desRefleshType) {
                             case nonStatus:
                             {
                                  self.desIsloading = NO;
                                 [self.tableView reloadData];
                             }
                                 break;
                                 
                             case pullDown: //下拉
                             {
                                 if (self.desPageIndex == 1) {
                                     self.coverView.hidden = NO;
                                 }
                                 self.asIsloading = NO;
                                 [self doneLoadingTableViewData];
                                 [self.tableView reloadData];
                             }
                                 break;
                             case pullUp:
                             {
                                 double delayInSeconds = 1.0;
                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                     self.desIsloading = NO;
                                     [self.tableView reloadData];
                                 });
                             }
                                 break;
                         }

                     }];
}

#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        if (self.sortType == Ascending) {
//            switch (self.asRefleshType) {
//                case nonStatus:
//                {
//                    if (self.sortType == Ascending) {
//                        if (!self.asIsloading) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                        return 0;
//                    } else {
//                        if (!self.desIsloading) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                        return 0;
//                    }
//                    
//                }
//                    break;
//                case pullDown:
//                {
//                    if (self.sortType == Ascending) {
//                        if (!self.asIsloading && self.asPageIndex==1) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                    } else {
//                        if (!self.desIsloading &&  self.desPageIndex==1) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                    }
//                }
//                    break;
//                case pullUp:
//                {
//                    if (self.sortType == Ascending) {
//                        if (self.asPageIndex==1 && !self.asIsloading) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                    } else {
//                        if (self.desPageIndex==1 && !self.desIsloading) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                    }
//                }
//                    break;
//            }
//        } else {
//            switch (self.desRefleshType) {
//                case nonStatus:
//                {
//                    if (self.sortType == Ascending) {
//                        if (!self.asIsloading) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                        return 0;
//                    } else {
//                        if (!self.desIsloading) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                        return 0;
//                    }
//                    
//                }
//                    break;
//                case pullDown:
//                {
//                    if (self.sortType == Ascending) {
//                        if (!self.asIsloading && self.asPageIndex==1) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                    } else {
//                        if (!self.desIsloading &&  self.desPageIndex==1) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                    }
//                }
//                    break;
//                case pullUp:
//                {
//                    if (self.sortType == Ascending) {
//                        if (self.asPageIndex==1 && !self.asIsloading) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                    } else {
//                        if (self.desPageIndex==1 && !self.desIsloading) {
//                            return CGRectGetHeight(tableView.frame);
//                        }
//                    }
//                }
//                    break;
//            }
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

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.sortType)
    {
        case Ascending:
        {
            if (self.asRefleshType == pullDown) {
                return 0;
            }
            
            
            if (self.asIsfinished) {
                return 1;
            }
            
            return 2;
        }
            break;
            
        case Descending:
        {
            if (self.desRefleshType == pullDown) {
                return 0 ;
            }
            
            if (self.desIsfinished) {
                return 1;
            }
            
            return 2;
        }
            break;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        return 1;
    }
    if (self.sortType == Ascending) {
        return self.ascendingArray.count ;
    }
    return self.descendingArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        static NSString *loadcell = @"loadcell";
        CTLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:loadcell];
        if (cell==nil) {
            cell = [[CTLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadcell];
        }
        
        if (self.sortType == Ascending) {
            if (self.asIsloading) {
                [cell setView:YES];
            } else {
                [cell setView:NO];
            }
        } else {
            if (self.desIsloading) {
                [cell setView:YES];
            } else {
                [cell setView:NO];
            }
        }
        
        return  cell;
    }
    
    static NSString *cellIdentifier = @"Cell";
    CTPointExchangeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CTPointExchangeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *dictionary = self.sortType==Ascending?[self.ascendingArray objectAtIndex:indexPath.row]:
    [self.descendingArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = [dictionary objectForKey:@"CommodityName"];
    [cell.subTitleLabel.centerButton setTitle:[dictionary objectForKey:@"IntegralPrice"] forState:UIControlStateNormal];
    [cell.subTitleLabel.centerButton setEnabled:YES];//modified by shallow 2014-04-14
    cell.exchangeButton.tag = indexPath.row;
    [cell.exchangeButton addTarget:self action:@selector(goExchangeVC:) forControlEvents:UIControlEventTouchUpInside];
    NSString *PicUrl = [dictionary objectForKey:@"PicUrl"];
    if (PicUrl.length > 0) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:PicUrl] placeholderImage:[UIImage imageNamed:@"CommodityListDefault"]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - UITabelViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        return;
    }
    [self goCommodityDetailVCWithIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    //判断是否到达底部
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if (offset.y<=0) {
        if (!self.asIsloading) {
            [_refreshHeaderView egoRefreshScrollViewDidScroll:aScrollView];
        } else if (!self.desIsloading) {
            [_refreshHeaderView egoRefreshScrollViewDidScroll:aScrollView];
        }
    } else {
        float reload_distance = 5;
        if(y > h + reload_distance) {
            switch (self.sortType) {
                case Ascending:
                {
                    if (self.asIsfinished) {
                        return;
                    }
                    
                    self.asRefleshType = pullUp ;
                    if (!self.asIsloading) {
                        self.asIsloading = YES;
                        [self.tableView reloadData];
                        [self igProdListWithAs];
                    }
                }
                    break;
                    
                case Descending:
                {
                    if (self.desIsfinished) {
                        return;
                    }
                    self.desRefleshType = pullUp ;
                    if (!self.desIsloading) {
                        self.desIsloading = YES;
                        [self.tableView reloadData];
                        [self igProdListWithDes];
                    }
                }
                    break;
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
    if (self.sortType == Ascending) {
        self.asRefleshType = pullDown;
    } else{
        self.desRefleshType = pullDown;
    }
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    if (self.sortType == Ascending) {
        self.asIsfinished = NO;
        self.asIsloading = NO;
        self.asPageIndex = 1;
        self.asPageSize = 20;
        self.coverView.hidden = YES;
        [self igProdListWithAs];
    } else {
        self.desIsfinished = NO;
        self.desIsloading = NO;
        self.desPageIndex = 1;
        self.desPageSize = 20;
        self.coverView.hidden = YES;
        [self igProdListWithDes];
    }
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
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
    if (self.sortType == Ascending) {
        return  self.asIsloading;
    } else {
        return self.desIsloading ;
    }
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
