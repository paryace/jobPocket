//
//  BBCenterManager.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  中间的视图的逻辑管理

#import "BBCenterViewManager.h"
#import "BBCenterItem.h"
#import "AppDelegate.h"

#import "BBCenterRepDataModel.h"
#import "BBCenterItemDataModel.h"
#import "BBCRequestParamModel.h"
#import "CTLoadingCell.h"
#import "EGORefreshTableHeaderView2.h"
#import "ToastAlertView.h"
#import "SIAlertView.h"
@interface BBCenterViewManager ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UINib *nib;
} 
@property (assign,nonatomic ) BBCenterViewType           type;
@property (strong,nonatomic ) NSMutableArray             *datas;
@property (assign,nonatomic ) int                        PageIndex;
@property (assign,nonatomic ) int                        PageSize;
@property (nonatomic, assign) BOOL                       reloading;
@property (nonatomic, assign) BOOL                       isfinished;
@property (nonatomic, strong) EGORefreshTableHeaderView2 *refreshHeaderView;
@property (strong,nonatomic ) UIView                     *maskView;//用来隐藏键盘
@end
@implementation BBCenterViewManager
-(instancetype)init
{
    self=[super init];
    if (self) {
        _datas=[NSMutableArray array];
    }
    return self;
}
#pragma mark - IBAction
-(IBAction)search:(id)sender
{
    [self.textField resignFirstResponder];
    //清楚旧数据
    [self reset];
    
    BBCRequestParamModel *requestParma=[BBCRequestParamModel new];
    requestParma.ComName=self.textField.text;
    requestParma.PageIndex=self.PageIndex;
    requestParma.PageSize=self.PageSize;
    [self.process requestSearch:requestParma];
}
-(IBAction)hideKeyWord:(UITapGestureRecognizer*)gueture
{
    [self.textField resignFirstResponder];
}

#pragma mark - method
-(void)reset
{
    //清楚旧数据
    self.PageIndex=1;
    [self.datas removeAllObjects];
    [self.tableView reloadData];
    [self updateWithType:BBC_NONE];
    self.isfinished = NO;
    self.reloading = NO;
    self.PageSize=20;
    self.PageIndex=1;
}
-(void)initial
{

    self.noDataView.backgroundColor=[UIColor clearColor];
    self.textField.exclusiveTouch=YES;
    self.searchButton.exclusiveTouch=YES;
    self.textField.delegate=self;
    self.isfinished = NO;
    self.reloading = NO;
    self.PageSize=20;
    self.PageIndex=1;
    self.tableView.rowHeight=77;
    self.tableView.backgroundColor=[UIColor clearColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]-7.0>=0) {
       self.tableView.separatorInset =UIEdgeInsetsMake(0, 0, 0, 0);
    } 
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _refreshHeaderView = [[EGORefreshTableHeaderView2 alloc] initWithFrame:CGRectMake(0.0f, 0.0f-_tableView.frame.size.height, self.tableView.frame.size.width, _tableView.frame.size.height)];
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    _refreshHeaderView.delegate = (id<EGORefreshTableHeaderDelegate2>)self;
    [self.tableView addSubview:_refreshHeaderView];
    [self updateWithType:BBC_NONE];
}
-(void)updateWithType:(BBCenterViewType)type
{
    self.type=type;
    switch (self.type)
    {
        case BBC_NONE:
            {
                self.tableView.hidden=YES;
                self.tipView1.hidden=YES;
                self.tipView2.hidden=YES;
            }
            self.noDataView.hidden=YES;
            break;
        case BBC_HasData:
            {
                self.tableView.hidden=NO;
                self.tipView1.hidden=NO;
                self.tipView2.hidden=NO;
            }
            self.noDataView.hidden=YES;
            break;
        case BBC_NoData:
            {
                self.tableView.hidden=YES;
                self.tipView1.hidden=YES;
                self.tipView2.hidden=YES;
            }
            self.noDataView.hidden=NO;
            break;
        default:
            break;
    }
    
}

-(void)updateWithData:(BBCenterRepDataModel*)repData
{
    
    [self doneLoadingTableViewData];
    self.reloading = NO;
    int totalCount=repData.TotalCount;
    if (totalCount>0)
    {
        [self updateWithType:BBC_HasData];
        NSArray *array=repData.DataList;
        if (array.count<self.PageSize)
        {
            self.isfinished = YES;
        }else
        {
            self.PageIndex++;
        }
        [self.datas addObjectsFromArray:array];
        [self.tableView reloadData];
    }
    else
    {
        [self.datas removeAllObjects];
        [self.tableView reloadData];
        [self updateWithType:BBC_NoData];
    }
 
}
#pragma mark 请求网络发生错误
-(void)occurError:(NSError *)error
{
    NSString* msg = [error localizedDescription];
    if ([error code] == -1001) {
        msg = @"网络不给力，请稍后再试";
    } else if ([error code] == -1004 ||
               [error code] == -1009) {
        msg = @"无网络连接，请检查网络设置";
    }
    // 取消掉全部请求和回调，避免出现多个弹框
    [MyAppDelegate.cserviceEngine cancelAllOperations];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                     andMessage:msg];
    __weak typeof(self) weakSelf=self;
    [alertView addButtonWithTitle:@"确定"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView){
                              [weakSelf doneLoadingTableViewData];
                              weakSelf.reloading=NO;
                              weakSelf.isfinished=NO;
                              [weakSelf.tableView reloadData];
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
 
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        
        if (self.isfinished) {
            return 0;
        }
        return 1;
    }
    return self.datas.count ;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        static NSString *loadcell = @"loadcell";
        CTLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:loadcell];
        if (cell==nil) {
            cell = [[CTLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadcell];
        }
        if (self.reloading) {
            [cell setView:YES];
            
        } else {
            [cell setView:NO];
        }
        
        return  cell;
    }
    
    static NSString *Identifier=@"Identifier";
    if (nib==nil)
    {
        nib=[UINib nibWithNibName:@"BBCenterItem" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:Identifier];
    }
    int row=indexPath.row;
    BBCenterItem *item=[tableView dequeueReusableCellWithIdentifier:Identifier];
    BBCenterItemDataModel *model=[self.datas objectAtIndex:row];
    [item renderData:model withRow:row];
    return item;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 45;
    }
    return 77;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGPoint offset = scrollView.contentOffset;
    if (offset.y<0) {
        if (!self.reloading) {
            [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
        }
    }else
    {
        if (self.datas && self.datas.count>0 &&
            self.PageIndex >= 1){
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
                if (!self.reloading) {
                    
                    self.reloading = YES ;
                    [self.tableView reloadData];
                    
                    BBCRequestParamModel *requestParma=[BBCRequestParamModel new];
                    requestParma.ComName=self.textField.text;
                    requestParma.PageIndex=self.PageIndex;
                    requestParma.PageSize=self.PageSize;
                    [self.process requestSearch:requestParma];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.isfinished) {
//        ToastAlertView *alert = [ToastAlertView new];
//        [alert showAlertMsg:@"已经加载完"];
        return;
    }
}
#pragma mark -refresh-
- (void)reloadTableViewDataSource
{
//    NSLog(@"==开始加载数据");
//    [self.tableView reloadData];//这里tableview要reloadData
    [self.datas removeAllObjects];
    [self.tableView reloadData];
    self.PageIndex=1;
    BBCRequestParamModel *requestParma=[BBCRequestParamModel new];
    requestParma.ComName=self.textField.text;
    requestParma.PageIndex=self.PageIndex;
    requestParma.PageSize=self.PageSize;
    [self.process requestSearch:requestParma];
}

- (void)doneLoadingTableViewData
{
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];//这里要改成自己定义的tableview
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView2*)view{
    
    [self reloadTableViewDataSource];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView2*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView2*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   CGPoint p=[self.textField convertPoint:CGPointZero toView:MyAppDelegate.window];
    CGRect maskFrame=CGRectMake(0, 0, CGRectGetWidth(MyAppDelegate.window.frame), p.y-8);
    self.maskView=[[UIView alloc] initWithFrame:maskFrame];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(hideKeyWord:)];
    [self.maskView addGestureRecognizer:tap];
    [MyAppDelegate.window addSubview:self.maskView];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.maskView removeFromSuperview];
}
@end
