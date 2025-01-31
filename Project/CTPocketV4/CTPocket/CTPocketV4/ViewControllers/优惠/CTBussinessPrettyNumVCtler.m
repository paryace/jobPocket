//
//  CTAllPrettyNumVCtler.m
//  CTPocketV4
//
//  Created by liuruxian on 14-1-7.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTBussinessPrettyNumVCtler.h"
#import "CTPrettyNumViewCell.h"
#import "CserviceOperation.h"
#import "CTQryCollected.h"
#import "CTPrettyNumberVCtler.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "SIAlertView.h"
#import "ToastAlertView.h"
#import "CTLoadMoreCell.h"
#import "CTTopPrettyNumVCtler.h"
#import "CTHelperMap.h"
#import "CTCity.h"
#import "CTLoadingCell.h"

@interface CTBussinessPrettyNumVCtler ()

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray * searchArray;
@property (nonatomic, strong) UITableView * tableView ;
@property (nonatomic, strong) CserviceOperation * qryNumByCnlOpt;


@property (nonatomic, assign) int pageSize ;
@property (nonatomic, assign) int pageIndex;

@property (nonatomic, assign) BOOL isFinish;
@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, assign) BOOL isSearchFinish;
@property (nonatomic, assign) BOOL isSearchLoading;
@property (nonatomic, assign) int searchPageSize;
@property (nonatomic, assign) int searchPageIndex;


@property (nonatomic, strong) NSString * provinceCode ;
@property (nonatomic, strong) NSString * cityCode;
@property (nonatomic, strong) NSDictionary * codeData;

@property (nonatomic, assign) qryTopNumType type;  //当前请求数据的模式
@property (nonatomic, strong) NSString *searchText;


@property (nonatomic, strong) UILabel *luckyNumLabel;
@property (nonatomic, strong) UILabel *numAttributionLabel;
@property (nonatomic, strong) UILabel *phoneNumLabel;
@property (nonatomic, strong) UILabel *phoneNumInfoLabel;
//@property (nonatomic, strong) CTCity *areaInfo;
@property (nonatomic, strong) UIView *tipView;

@end

@implementation CTBussinessPrettyNumVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.dataArray = [NSMutableArray new];
        self.searchArray  = [NSMutableArray new];
        self.isFinish = NO;
        self.isLoading = NO;
        self.pageIndex = 1;
        self.pageSize = 20;
        self.provinceCode = @"";
        self.cityCode = @"";
        self.type = normalModel ;
        self.searchText = @"";
        self.searchPageIndex = 0;
        self.searchPageSize = 0;
        self.isSearchFinish = NO;
        self.isSearchLoading = NO;
        
        [[CTHelperMap shareHelperMap].mapView setShowsUserLocation:NO]; //停止定位
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(2,
                                                                          0,
                                                                          CGRectGetWidth(self.view.frame)-4,
                                                                          iPhone5?258:170)];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = (id<UITableViewDelegate>)self;
    tableView.dataSource = (id<UITableViewDataSource>)self;
    [self.view addSubview:tableView];
    tableView.separatorStyle = NO;
    self.tableView = tableView ;
    
    
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.view.frame)-5, CGRectGetHeight(self.view.frame))];
    tipView.backgroundColor = [UIColor whiteColor];
    tipView.hidden = YES;
    [self.view addSubview:tipView];
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(1, 0, 300, 40)];
        label.textAlignment = UITextAlignmentCenter ;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"亲，没有更多可选号码啦~";
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14];
        [tipView addSubview:label];
        
        UIImageView *dividingImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame),CGRectGetWidth(label.frame),1)];
        dividingImg.backgroundColor = [UIColor colorWithRed:220/255. green:220/255. blue:220/255. alpha:1];
        [tipView addSubview:dividingImg];
    }
    self.tipView = tipView ;
    [self.view bringSubviewToFront:tipView];
    
    
    UIImage *image = [UIImage imageNamed:@"arrow_down"];
    UIImageView *upImageView = [[UIImageView alloc] initWithFrame:
                                CGRectMake(2,
                                           (iPhone5?250:170)/2 + 2,
                                           image.size.width,
                                           image.size.height)];
    upImageView.Image = image ;
    [self.view addSubview:upImageView];
    
//    image = [UIImage imageNamed:@"arrow_up"];
//    UIImageView *downImageView = [[UIImageView alloc] initWithFrame:
//                                  CGRectMake(2,
//                                             (iPhone5?250:170)/2-image.size.height - 2,
//                                             image.size.width,
//                                             image.size.height)];
//    downImageView.image = image ;
//    [self.view addSubview:downImageView];
    
    //监听搜索消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchNumNotification:)
                                                 name:SEARCHBUSSINESS_MSG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelSearchNumNotification)
                                                 name:CANCELSEARCH_MSG object:nil];
    //更新收藏状态
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updataCollectedStatus)
                                                 name:UPDATACOLLECTEDSTATUS object:nil];
    //城市切换消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedCityNotification:)
                                                 name:SELECTCITY_MSG object:nil];
    //收藏更新消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatadataCollected:)
                                                 name:@"UPDATADATACOLLECTED" object:nil];

}

#pragma mark - fun

- (void) viewDidAppear:(BOOL)animated{
    
    [self.tableView reloadData];
    
    [super viewDidAppear:YES];
}

#pragma mark - fun

- (void) dealloc {
    NSLog(@"******************%s",__func__);
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void) createView
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    if (self.type == normalModel) {
        if (self.isFinish) {
            return;
        }
        
        if (!self.isLoading) {
            NSLog(@"再次调用");
            self.isLoading = YES ;
            [self qryNumByCnl:@""];
        }
    }else{
        if (self.isSearchFinish) {
            return;
        }
        
        if (!self.isSearchLoading) {
            self.isSearchLoading = YES ;
            [self qryNumByCnl:self.searchText];
        }
    }
    
}

- (void) location
{
    self.isLoading = YES ;
    [self qryNumByCnl:@""];
}

- (void) locateByGD
{
    //高德定位
}

- (void) matchCollectionData : (NSArray *) array
{
    NSMutableArray *mutableArray = [CTQryCollected shareQryCollected].collectedMutableDict;
    for (int i=0; i<array.count; i++) {
        NSString *phoneNum = array[i][@"PhoneNumber"];
        BOOL isAdd = YES;
        for (int j=0; j<mutableArray.count; j++) {
            NSString *temp = mutableArray[j][@"PhoneNumber"];
            if ([phoneNum isEqualToString:temp]) {
                CTPrettyNumData *data = [CTPrettyNumData modelObjectWithDictionary:array[i]];
                data.isCollected = @"1";//收藏状态
                isAdd = NO;
                if (self.type == normalModel) {
                    [self.dataArray addObject:data];
                }else{
                    [self.searchArray addObject:data];
                }
                
                break ;
            }
        }
        if (isAdd) {
            CTPrettyNumData *data = [CTPrettyNumData modelObjectWithDictionary:array[i]];
            data.isCollected = @"0"; //不是收藏状态
            if (self.type == normalModel) {
                [self.dataArray addObject:data];
            }else{
                [self.searchArray addObject:data];
            }
        }
    }
}

- (void) createCellInView : (CTPrettyNumData *)data
                     cell : (CTPrettyNumView *)view
                viewIndex : (int) viewIndex
{
    if (data == nil) {
        [view setPrettynumInfo:nil viewIndex:viewIndex selectBlock:nil];
        return;
    }
    //保证block释放 当viewcontroller释放的时候
    __weak __typeof(&*self)weakSelf = self;
    [view setPrettynumInfo:data viewIndex:viewIndex  selectBlock:^(CTPrettyNumData *data){
        weakSelf.selectedData = data;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SELECTPRETTYNUM" object:data];
    }];
    
    [view setCollectedBlock: ^(int collectIndex,BOOL collectedStatus)
     {
         if (weakSelf.type == normalModel) {
             if (collectedStatus) {
                 CTPrettyNumData *prettyData = (CTPrettyNumData *)weakSelf.dataArray[collectIndex];
                 [prettyData setValue:@"1" forKey:@"isCollected"];
                 //取消收藏
                 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:prettyData.dictionaryRepresentation];
                 [[CTQryCollected shareQryCollected].collectedMutableDict addObject:dict];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATADATACOLLECTED" object:weakSelf];
             }else{
                 CTPrettyNumData *prettyData =  (CTPrettyNumData *)weakSelf.dataArray[collectIndex];
                 [prettyData setValue:@"0" forKey:@"isCollected"];
                 for (NSMutableDictionary *dict in [CTQryCollected shareQryCollected].collectedMutableDict) {
                     NSString *phoneNum = dict[@"PhoneNumber"];
                     
                     if ([phoneNum isEqualToString:prettyData.PhoneNumber]) {
                         [[CTQryCollected shareQryCollected].collectedMutableDict removeObject:dict];
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATADATACOLLECTED" object:weakSelf];
                         break;
                     }
                 }
             }
         } else {
             if (collectedStatus) {
                 CTPrettyNumData *prettyData = (CTPrettyNumData *)weakSelf.searchArray[collectIndex];
                 [prettyData setValue:@"1" forKey:@"isCollected"];
                 //取消收藏
                 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:prettyData.dictionaryRepresentation];
                 [[CTQryCollected shareQryCollected].collectedMutableDict addObject:dict];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATADATACOLLECTED" object:weakSelf];
             }else{
                 CTPrettyNumData *prettyData =  (CTPrettyNumData *)weakSelf.searchArray[collectIndex];
                 [prettyData setValue:@"0" forKey:@"isCollected"];
                 for (NSMutableDictionary *dict in [CTQryCollected shareQryCollected].collectedMutableDict) {
                     NSString *phoneNum = dict[@"PhoneNumber"];
                     
                     if ([phoneNum isEqualToString:prettyData.PhoneNumber]) {
                         
                         [[CTQryCollected shareQryCollected].collectedMutableDict removeObject:dict];
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATADATACOLLECTED" object:weakSelf];
                         break;
                     }
                 }
             }
         }
         [[CTQryCollected shareQryCollected] saveCacheArea] ;
         [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTPRETTYNUMBERCOUNT object:nil];
     }];
    
    if (data == self.selectedData) {
        [view setSelected:YES];
    }else{
        [view setSelected:NO];
    }
}


#pragma mark - NSNotification

- (void)updatadataCollected:(NSNotification *)notification
{
    if (self != [notification object]) {
        [self updataCollectedStatus];
    }
}

- (void) selectedCityNotification : (NSNotification *)notification
{
    if (self.qryNumByCnlOpt) {
        [self.qryNumByCnlOpt cancel];
        self.qryNumByCnlOpt = nil ;
    }
    
    self.tipView.hidden = YES;
    
    self.selectedData = nil;
    
    //城市选择消息
    CTCity *city = [notification object];
    self.areaInfo = city ;
    
    //清空数据
    [self.dataArray removeAllObjects];
    [self.searchArray removeAllObjects];
    [self.tableView reloadData];
    
    //测试城市选择
    self.pageIndex = 1;
    self.pageSize = 20;
    self.isFinish = NO;
    self.isLoading = NO;
    
    self.isSearchFinish = NO;
    self.isSearchLoading = NO;
    self.searchPageSize = 20;
    self.searchPageIndex = 1;
    
    //搜索状态
    if (self.type == normalModel) {
        if (!self.isLoading) {
            [self qryNumByCnl:@""];
        }
        self.isLoading = YES;
        [self.tableView reloadData];
    }else{
        if (!self.isSearchLoading) {
            [self qryNumByCnl:self.searchText];
        }
        self.isSearchLoading = YES;
        [self.tableView reloadData];
    }
}

- (void) updataCollectedStatus
{
    //更新收藏数据消息
    if (!self.dataArray && !self.searchArray) {
        return;
    }
    if (self.type == normalModel) {
        NSMutableArray *array = [CTQryCollected shareQryCollected].collectedMutableDict;
        for (CTPrettyNumData *tempData in self.dataArray)
        {
            BOOL isChange = NO;
            for (NSDictionary *data in array) {
                if ([data[@"PhoneNumber"] isEqualToString:tempData.PhoneNumber]) {
                    tempData.isCollected = @"1";
                    NSLog(@"%@",tempData.PhoneNumber);
                    isChange = YES;
                    break;
                }
            }
            if (!isChange) {
                tempData.isCollected = @"0";
            }
        }
    } else {
        NSMutableArray *array = [CTQryCollected shareQryCollected].collectedMutableDict;
        for (CTPrettyNumData *tempData in self.searchArray)
        {
            BOOL isChange = NO;
            for (NSDictionary *data in array) {
                if ([data[@"PhoneNumber"] isEqualToString:tempData.PhoneNumber]) {
                    tempData.isCollected = @"1";
                    NSLog(@"%@",tempData.PhoneNumber);
                    isChange = YES;
                    break;
                }
            }
            if (!isChange) {
                tempData.isCollected = @"0";
            }
        }
    }
    
    [self.tableView reloadData];
}

- (void) searchNumNotification : (NSNotification *)notification
{
    if (self.qryNumByCnlOpt) {
        [self.qryNumByCnlOpt  cancel];
        self.qryNumByCnlOpt = nil ;
    }
    
    self.tipView.hidden = YES;
    
    //搜索消息
    self.searchText = [notification object];
    if (!self.searchArray) {
        self.searchArray = [NSMutableArray array];
    }
    
    [self.searchArray removeAllObjects];
    
    self.type = SearchModel ;
    self.searchPageSize = 20;
    self.searchPageIndex = 1;
    
    self.isSearchLoading = YES ;
    [self.tableView reloadData];
    [self qryNumByCnl:self.searchText];
    
}

- (void) cancelSearchNumNotification{
    
    //取消搜索消息
    if (self.type == SearchModel)
    {
        self.type = normalModel;
        if (self.dataArray && self.dataArray.count == 0) {
            self.isLoading = NO;
            self.isFinish = NO;
            self.pageSize = 20;
            self.pageIndex = 1;
            [self qryNumByCnl:@""]; //调用一次数据接口,避免没有数据情况
        }
        [self.searchArray removeAllObjects];
        [self.tableView reloadData];
    }
    
    self.searchText = @"";
    self.isSearchLoading = NO;
    self.isSearchFinish = NO;
    [self.searchArray removeAllObjects];
    [self updataCollectedStatus];
    
    if ([self.dataArray respondsToSelector:@selector(count)]) {
        if (self.dataArray.count > 0) {
            self.tipView.hidden = YES;
        } else{
            self.tipView.hidden = NO ;
        }
    }else {
        self.tipView.hidden = YES;
    }
}

#pragma mark - netWork

- (void)qryNumByCnl : (NSString *) searchText
{
    //靓号-频道选择接口 (测试)
    NSString *ProvinceCode = self.areaInfo.provincecode;//self.codeData [@"ProvinceCode"];
    NSString *AreaCode = self.areaInfo.citycode;//self.codeData [@"CityCode"];
    NSString *ShopId = BUSSINESS_SHOPID;
    NSString *PageIndex = [NSString stringWithFormat:@"%d",self.pageIndex];//[NSString stringWithFormat:@"%d",self.pageIndex];
    NSString *PageSize = @"20";
    NSString *Type = @"1";
    NSString *InNumber = @"";
    NSString *InFlag = @"";
    NSString *HeadNumber = @"";
    NSString *ContNumber = searchText;
    NSString *Level = @"";
    NSString *MinPay = @"";
    NSString *MaxPay = @"";
    NSString *Sortby = @"1";
    NSString *PrettyPattern = @"";
    NSString *IsLast = @"0";
    
    if (self.type == SearchModel) {
        IsLast = @"1";
        PageIndex = [NSString stringWithFormat:@"%d",self.searchPageIndex];
        PageSize = [NSString stringWithFormat:@"%d",self.searchPageSize];
    }
    

    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               ProvinceCode,@"ProvinceCode",
                               AreaCode,@"AreaCode",
                               ShopId,@"ShopId",
                               PageIndex,@"PageIndex",
                               PageSize,@"PageSize",
                               Type,@"Type",
                               InNumber,@"InNumber",
                               InFlag,@"InFlag",
                               HeadNumber,@"HeadNumber",
                               ContNumber,@"ContNumber",
                               Level,@"Level",
                               MinPay,@"MinPay",
                               MaxPay,@"MaxPay",
                               Sortby,@"Sortby",
                               PrettyPattern,@"PrettyPattern",
                               IsLast,@"IsLast",
                               nil];
    
    __weak typeof(self) wself = self;
    self.qryNumByCnlOpt =[MyAppDelegate.cserviceEngine
                          postXMLWithCode:@"qryNumByCnl"
                          params:params
                          onSucceeded:^(NSDictionary *dict) {
                                  DDLogInfo(@"%s--%@", __func__, dict.description);
                              [wself onQryNumByCnlSuccess:dict];
                          } onError:^(NSError *engineError) {
                              DDLogInfo(@"%s--%@", __func__, engineError);
                              
                              [SVProgressHUD dismiss];
                              [wself onQryNumByCnlError:engineError];
                          }];
}

// modified by zy, 2014-02-21
- (void)onQryNumByCnlSuccess:(NSDictionary *)dict
{
    //格式化数据(将指定的数据格式化成数组)
    dict = [Utils objFormatArray:dict path:@"Data/Items"];
    
    id Data = [dict objectForKey:@"Data"];
    //获取信息失败
    id Items = [Data objectForKey:@"Items"]; NSArray *array;
    if (Items) {
        array = [NSArray arrayWithArray:Items];
    }else
    {
        array = [[NSArray alloc]init];
    }
    
    if (self.type == normalModel) {
        if (array.count<20) {
            self.isFinish = YES ;
        }else{
            self.pageIndex ++;
            self.isFinish = NO ;
        }
        
        [self matchCollectionData:array];
        self.isLoading = NO ;
        
        if (self.dataArray.count == 0) {
            self.tipView.hidden = NO;
        } else {
            self.tipView.hidden = YES ;
        }
    }
    else {
        if (array.count<20) {
            self.isSearchFinish = YES ;
        }else{
            self.searchPageIndex ++;
            self.isSearchFinish = NO ;
        }
        
        [self matchCollectionData:array];
        self.isSearchLoading = NO ;
        
        if (self.searchArray.count == 0) {
            self.tipView.hidden = NO ;
        } else {
            self.tipView.hidden = YES ;
        }
    }
    
    [self.tableView reloadData];
}

// modified by zy, 2014-02-21
- (void)onQryNumByCnlError:(NSError *)engineError
{
    [SVProgressHUD dismiss];
    __weak __typeof(&*self)weakSelf = self;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (weakSelf.type == normalModel) {
            weakSelf.isLoading = NO;
        } else{
            weakSelf.isSearchLoading = NO ;
        }
        [weakSelf.tableView reloadData];
        
    });
    if ([engineError.userInfo objectForKey:@"ResultCode"])
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
                                      if (self.navigationController != nil)
                                      {
                                          [self.navigationController popViewControllerAnimated:NO];
                                      }
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            [alertView show];
        }
    }
    else{
        ToastAlertView *alert = [ToastAlertView new];
        [alert showAlertMsg:@"系统繁忙,请重新提交"];
    }
}
#pragma mark - tableview delegate

//设置tablevie的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 45;
    }
    return 62;
}
//cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
}

#pragma mark - datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.type == normalModel) {
        if (section==1) {
            if (self.isFinish) {
                return 0;
            }else{
                return 1;
            }
        }
        
        return (int)ceilf(self.dataArray.count / 2.0) ;
    }else{
        if (section==1) {
            if (self.isSearchFinish) {
                return 0;
            }else{
                return 1;
            }
        }
        
        return (int)ceilf(self.searchArray.count / 2.0) ;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.type == normalModel) {
        if (self.isFinish) {
            return 1;
        }
        return 2;
    }else{
        if (self.isSearchFinish) {
            return 1;
        }
        return 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        static NSString *loadingCell = @"loadingCell";
        CTLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:loadingCell];
        if (cell == nil) {
            cell = [[CTLoadingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            [cell setCellHeight:45];
        }
        if(self.type == normalModel)
        {
            [cell setView:self.isLoading];
        } else {
            [cell setView:self.isSearchLoading];
        }
        return cell ;
        
    } else {
        
        if (self.type == normalModel) {
            static NSString *CellIdentifier = @"BussinessCell";
            CTPrettyNumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil)
            {
                cell = [[CTPrettyNumViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ViewListCellType:bussinessCellType];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            int index = indexPath.row*2  ;
            if (index < self.dataArray.count) {
                CTPrettyNumData *data = [self.dataArray objectAtIndex:index];
                [self createCellInView:data cell:cell.leftView viewIndex:index];
            } else {
                [self createCellInView:nil cell:cell.leftView viewIndex:index] ;
            }
            
            index = indexPath.row*2+1;
            if (index<self.dataArray.count) {
                CTPrettyNumData *data = [self.dataArray objectAtIndex:index];
                [self createCellInView:data cell:cell.rightView viewIndex:index];
            } else {
                [self createCellInView:nil cell:cell.rightView viewIndex:index];
            }
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"SearchCell";
            CTPrettyNumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil)
            {
                cell = [[CTPrettyNumViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ViewListCellType:bussinessCellType];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            int index = indexPath.row*2  ;
            if (index < self.searchArray.count) {
                CTPrettyNumData *data = [self.searchArray objectAtIndex:index];
                [self createCellInView:data cell:cell.leftView viewIndex:index];
            } else {
                [self createCellInView:nil cell:cell.leftView viewIndex:index] ;
            }
            
            index = indexPath.row*2+1;
            if (index<self.searchArray.count) {
                CTPrettyNumData *data = [self.searchArray objectAtIndex:index];
                [self createCellInView:data cell:cell.rightView viewIndex:index];
            } else {
                [self createCellInView:nil cell:cell.rightView viewIndex:index];
            }
            
            return cell ;
        }
    }
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
    
    float reload_distance = 10;
    if(y > h + reload_distance) {
        if (self.type == normalModel) {
            if (self.isFinish) {
                return;
            }
            
            if (!self.isLoading) {
                self.isLoading = YES ;
                [self.tableView reloadData];
                [self qryNumByCnl:@""];
            }
        }else{
            if (self.isSearchFinish) {
                return;
            }
            
            if (!self.isSearchLoading) {
                self.isSearchLoading = YES ;
                [self.tableView reloadData];
                [self qryNumByCnl:self.searchText];
            }
        }
    }
    
}

@end
