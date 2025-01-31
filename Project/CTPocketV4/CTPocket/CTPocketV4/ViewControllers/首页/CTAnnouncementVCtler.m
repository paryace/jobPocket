//
//  CTAnnouncementVCtler.m
//  CTPocketV4
//
//  Created by apple on 13-11-12.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTAnnouncementVCtler.h"
#import "CserviceOperation.h"
#import "AppDelegate.h"
#import "CTMessageCenterViewCell.h"
#import "CTLoadMoreCell.h"
#import "CTDetailVCtler.h"
#import "CTQryPackageVctler.h"
#import "Utils.h"
#import "CTRechargeVCtler.h" 
#import "SIAlertView.h"
#import "CTLoadingCell.h"
#import "SVProgressHUD.h"

//手势判断
typedef enum TableViewGesture
{
    PULL = 0,   //上拉
    DOWN        //下拉
}
Gesture;

#define kLoadMoreCellHeight 45.0f

extern NSString *ESRefreshItemsNotification;

@interface CTAnnouncementVCtler () <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, strong) CserviceOperation *annouceOpt;
@property (nonatomic, strong) NSMutableArray *announceArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) int pageIndex;
@property (nonatomic, assign) int pageSize;
@property (nonatomic, assign) int curPageIndex;

@property (nonatomic, assign) BOOL isLoadingMore; //判断请求已经返回
@property (nonatomic, assign) BOOL isLoadEnd;    //判断已经数据请求
@property (nonatomic, assign) int msgNum;        //未读的消息条数
@property (nonatomic, strong) NSMutableArray *readAry;
@property (nonatomic, assign) Gesture gesture;

@end

@implementation CTAnnouncementVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.msgNum = 0;
        self.pageIndex = 1;
        self.pageSize = 30;
        self.curPageIndex = 1;
        self.isLoadEnd = NO;
        self.isLoadingMore = NO;
         self.gesture = PULL ;
        
        self.announceArray = [[NSMutableArray alloc]init];
        self.readAry = [[NSMutableArray alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshItemsNotification:)
                                                     name:ESRefreshItemsNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tableView.backgroundColor = [UIColor colorWithRed:239/255. green:239/255. blue:239/255. alpha:1];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    [self.view addSubview:tableView];

    [self loadMore];
}

- (void) viewDidAppear:(BOOL)animated
{

}

#pragma mark - refleshTableView

- (void)handleRefreshItemsNotification:(NSNotification *)notification
{
    // 清除数据
    [self.announceArray removeAllObjects];
    [self.readAry removeAllObjects];
    [self.tableView reloadData];
    
    self.msgNum = 0;
    self.pageIndex = 1;
    self.pageSize = 30;
    self.isLoadingMore = NO ;
    self.isLoadEnd = NO;
    [self loadMore];
}

#pragma  mark - fun

- (void) refleshData
{
    self.isLoadEnd = NO;
}

- (void) loadMore
{
    if (self.isLoadEnd) {
        NSLog(@"数据加载完成");
        return;
    }
    
    self.gesture = PULL;
    
    if (!self.isLoadingMore) {  //判断加载是否完成
        self.isLoadingMore = YES;
        [self qryAnnounceData];
    }else{
        
    }
}
//匹配未读的数据 (请求数据后匹配文件以及当前未读的条数)
- (void) matchDataCount : (NSArray *) array
{
    //读取文件 按链表读取
    NSString *configname = [NSString stringWithFormat:@"%@/%@", [Utils getDocumentPath],ANNOUNCEFILE];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    self.msgNum += array.count ;
    
    if ([fm fileExistsAtPath:configname])
    {
        NSMutableArray *configArray = [[NSMutableArray alloc] initWithArray: [NSMutableArray arrayWithContentsOfFile:configname]];
        if (configArray.count>0) {
            for (int i=0; i<[array count]; i++) {
                NSDictionary *dictionary = array[i];
                int flg = 0; BOOL isAdd = NO;
                for (int j =0; j<configArray.count; j++) {
                    NSString *title  = [dictionary objectForKey:@"Title"];
                    NSString *title1 = [configArray[j] objectForKey:@"Title"];
                    if ([title isEqualToString:title1]) {
                        self.msgNum--;
                        flg = 1;
                        [self.readAry addObject:[NSString stringWithFormat:@"%d",flg]];
                        isAdd = NO;
                        break;
                    }
                    isAdd = YES;
                }
                if (isAdd) {
                    [self.readAry addObject:[NSString stringWithFormat:@"%d",flg]];
                }
                
            }
        }
        else{
            for (int i=0;i<self.msgNum;i++) {
                int flg = 0;
                [self.readAry addObject:[NSString stringWithFormat:@"%d",flg]];
            }
        }
    }else{
        self.msgNum = self.announceArray.count ;
        for (int i=0;i<self.msgNum;i++) {
            int flg = 0; // 0 出现 1 隐藏
            [self.readAry addObject:[NSString stringWithFormat:@"%d",flg]];
        }
    }
    
    //发送通知
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"viewIndex",[NSString stringWithFormat:@"%d",self.msgNum], @"msgNum",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOADMSGMSG object:dictionary];
    
    [self.tableView reloadData];
}

//选中cell匹配数据 写入文件
- (void) matchData : (NSDictionary *) dict cellIndex : (int) index
{
    //已读数据写入文件
    NSMutableArray *array ;
    NSString *configname = [NSString stringWithFormat:@"%@/%@", [Utils getDocumentPath],ANNOUNCEFILE];

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:configname])  //判断当前文件是否存在
    {
        array = [NSMutableArray arrayWithContentsOfFile:configname]; // 读数据
        if (array) {
            NSMutableArray *configArray = [[NSMutableArray alloc] initWithArray: array];
            //匹配数据
            {
                [configArray addObject:dict];
                [configArray writeToFile:configname atomically:YES]; // 写入数据
                self.msgNum -- ;
                
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"viewIndex",[NSString stringWithFormat:@"%d",self.msgNum] ,@"msgNum",nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:RELOADMSGMSG object:dictionary];
            }
        }
    }
    else{
        array = [NSMutableArray new];
        [array addObject:dict];
        self.msgNum -- ;
        [array writeToFile:configname atomically:YES]; // 写入数据
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"viewIndex",[NSString stringWithFormat:@"%d",self.msgNum] ,@"msgNum",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOADMSGMSG object:dictionary];
    }
    
    [self.tableView reloadData];
}

#pragma mark - netWork

- (void) qryAnnounceData
{
    //返回个数小于10 
    if (self.pageSize < 10) {
        return ;
    }
    
    if (self.annouceOpt) {
        [self.annouceOpt cancel];
        self.annouceOpt = nil;
    }
    /*
     轮换分类：
     1：消息中心
     2：首页轮换位
     3：促销优惠列表
     4：公告
     5：天翼应用轮换位
     6：优惠广告位
     */
    
    NSString *PhoneNbr = [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] ? [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"] : @"";
    
    NSString *Type = @"3";

    NSString *Index =  [NSString stringWithFormat:@"%d",self.pageIndex]; //页码
    NSString *PageSize = @"30"; //每页显示的数量

    __block CTAnnouncementVCtler *weakSelf = self ;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            PageSize      , @"PageSize",
                            Type          , @"Type",
                            BUSSINESS_SHOPID , @"ShopId",
                            PhoneNbr      , @"PhoneNbr",
                            Index         , @"Index",
                            nil];
 
    self.annouceOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"queryadlist"
                                                               params:params
                                                          onSucceeded:^(NSDictionary *dict)
     {
         //格式化数据(将指定的数据格式化成数组)
         dict = [Utils objFormatArray:dict path:@"Data/AdItem"];
         
         DDLogInfo(@"获取第一步的订单id成功 %s--%@", __func__, dict.description);
         NSDictionary *Data = [dict objectForKey:@"Data"];
         if (Data && [Data respondsToSelector:@selector(objectForKey:)]){
             switch (weakSelf.gesture) {
                 case PULL:     //上拉
                 {
                     NSString *TotalCount = [Data objectForKey:@"TotalCount"]; //返回数量个数
                     if (TotalCount && TotalCount.length > 0) {
                         
                         [weakSelf.announceArray addObjectsFromArray:[Data objectForKey:@"AdItem"]];
                         [weakSelf matchDataCount:[Data objectForKey:@"AdItem"]];
                         
                
                         weakSelf.pageSize = [TotalCount intValue];
                         if (weakSelf.pageSize < 20) {
                             weakSelf.isLoadEnd = YES;
                         }
                         
                         weakSelf.isLoadingMore = NO; //已经加载完数据 下拉刷新请求终止
                         weakSelf.pageIndex ++;
                     }
                 }
                     break;
                 case DOWN:
                 {
                     NSString *TotalCount = [Data objectForKey:@"TotalCount"]; //返回数量个数
                     if (TotalCount && TotalCount.length > 0) {
                         [weakSelf.announceArray removeAllObjects];
                         [weakSelf.announceArray addObjectsFromArray:[Data objectForKey:@"AdItem"]];
                         
                         
                         //已经加载完数据 下拉刷新请求终止
                         weakSelf.pageSize = [TotalCount intValue];
                         if (weakSelf.pageSize < 20) {
                             weakSelf.isLoadEnd = YES;
                         }
                         weakSelf.isLoadingMore = NO;
                         weakSelf.pageIndex ++;
                     }
                 }
                     break;
             }
            
             //请求成功后再刷新数据
             [weakSelf.tableView reloadData];
         }
     } onError:^(NSError *engineError) {
         DDLogInfo(@"%s--%@", __func__, engineError);
         //网络出现超时 或者 返回错误时 仍可下拉加载
         double delayInSeconds = 1.0;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             self.isLoadingMore = NO;
             [self.tableView reloadData];
             [SVProgressHUD showErrorWithStatus:engineError.localizedDescription];
         });
    
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
                                           if (self.navigationController != nil)
                                           {
                                               [self.navigationController popViewControllerAnimated:NO];
                                           }
                                       }];
                 alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                 [alertView show];
             }
         }
     }];
}

#pragma mark - UITbaleView delegate
//设置cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {   // 复用cell 滚动到section = 1时 cell进行复用 调用网络请求数据
        static NSString *loadMoreCell = @"LoadMoreCell";
        CTLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:loadMoreCell];
        if (cell == nil) {
            cell = [[CTLoadingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone ;
            [cell setCellHeight:kLoadMoreCellHeight];
        }
        [cell.spin startAnimating];
        if (self.isLoadingMore) {
            [cell setView:YES];
        } else {
            [cell setView:NO];
        }
        return cell ;
    }
    
    static NSString *identifier = @"AnnounceCell";
    CTMessageCenterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CTMessageCenterViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    }
    //匹配当前的数据
    [cell setInfo:[self.announceArray objectAtIndex:indexPath.row]dataType:0 mark:[self.readAry objectAtIndex:indexPath.row]];
    
    return cell; 
}

//cell数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        if (self.isLoadEnd) {
            return 0;
        }
        return 1;
    }
    
    return [self.announceArray count];
}

//返回高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return  kLoadMoreCellHeight;
    }
    return 93;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 1个好友的Sections+1个Load More Section
    return 2;
}

//选中的cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[CTLoadMoreCell class]]) {
        return ;
    }
    if (indexPath.section == 1) {
        return ;
    }
    
    NSDictionary * dict = [self.announceArray objectAtIndex:[indexPath row]];
    int LinkType = [[dict objectForKey:@"LinkType"] intValue];
    int Usertype = [[dict objectForKey:@"Usertype"] intValue];
    
    if (Usertype == 0)
    {

    }
    
    BOOL isRead = NO;
    /*
     由于当前还有功能没有实现 所以有写类是没法跳转的 等做完再添加进去
     */
    switch (LinkType) {
        case 2: // 网络链接
        {
            CTMessageCenterViewCell *cell = (CTMessageCenterViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            NSString *jumpUrl = [cell.infoDict objectForKey:@"Link"];
            CTDetailVCtler *vc = [CTDetailVCtler new];
            vc.infoDict = dict ;
            
            NSString *title=dict[@"Title"];
            [[NSUserDefaults standardUserDefaults]setObject:title?title:@"" forKey:@"ShareDetail"]; 
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTitle" object:nil userInfo:dict]; //通知传值
            vc.jumpUrl = jumpUrl ;
            [self.parentVC.navigationController pushViewController:vc animated:YES];
            
        }break;
        case 1:
        {
            // 跳转到其他页面
            NSArray * uiDatas = [self loadUIConfigure];
            int Link = [[dict objectForKey:@"Link"] intValue];
            
            static NSDictionary * uiDict = nil;
            [uiDatas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSDictionary class]] &&
                    [obj objectForKey:@"id"] &&
                    [[obj objectForKey:@"id"] respondsToSelector:@selector(intValue)] &&
                    [[obj objectForKey:@"id"] intValue] == Link)
                {
                    uiDict = obj;
                    *stop = YES;
                }
            }];
            
            if (![uiDict objectForKey:@"class"])
            {
                break;
            }
            
            
            NSString * clsname = [uiDict objectForKey:@"class"];
            NSLog(@"%@", clsname);
            
            if ([clsname isEqualToString:[NSString stringWithFormat:@"%@", [self class]]])
            {
                return;
            }
            else if ([clsname isEqualToString:@"CTHomeVCtler"])
            {
                [self.parentVC.navigationController popToRootViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTQueryVCtler"])
            {
                // 查询首页
                MyAppDelegate.tabBarController.selectedIndex = 1;
                [MyAppDelegate.tabBarController.viewControllers[1] popViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTPreferentialVCtler"])
            {
                // 优惠首页
                MyAppDelegate.tabBarController.selectedIndex = 3;
                [MyAppDelegate.tabBarController.viewControllers[3] popViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTMoreVCtler"])
            {
                // 更多首页
                MyAppDelegate.tabBarController.selectedIndex = 4;
                [MyAppDelegate.tabBarController.viewControllers[4] popViewControllerAnimated:YES];
            }
            else if ([clsname isEqualToString:@"CTRechargeVCtler"])
            {
                // 充话费
                CTRechargeVCtler *vc = [[CTRechargeVCtler alloc] init];
                vc.isPush = YES;
                NSString *type = [uiDict objectForKey:@"type"];
                if ([type intValue]==0) {
                    [vc pageIndex:0];
                }else if([type intValue]==1)
                {
                    [vc pageIndex:1];
                }else if([type intValue]==2)
                {
                    [vc pageIndex:2];
                }
                [self.parentVC.navigationController pushViewController:vc animated:YES];
            }
            else if ([clsname isEqualToString:@"CTRechargeVCtler2"])
            {
                // 充流量
                MyAppDelegate.tabBarController.selectedIndex = 2;
                [MyAppDelegate.tabBarController.viewControllers[2] popViewControllerAnimated:YES];
            }
            else
            {
                
                if ([clsname length] <= 0)
                {
                    break;
                }

                Class cls   = NSClassFromString(clsname);
                id anInstance  = [[cls alloc] init];
                if (anInstance)
                {
                   [self.parentVC.navigationController pushViewController:anInstance animated:YES];
                }
            }
        }break;
        default:
            break;
    }
    
    isRead = ((CTMessageCenterViewCell *)cell).isRead;
    if (isRead==0) {  //0 未读 1 已读
        [self.readAry setObject:@"1" atIndexedSubscript:[indexPath row]];
        [self matchData:[self.announceArray objectAtIndex:indexPath.row] cellIndex:indexPath.row];
    }
}

- (NSArray *)loadUIConfigure
{
    static NSArray *__uiConfiguredata = nil; // only load the data array once
    if (__uiConfiguredata == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"UIConfigure" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:path];
		NSPropertyListFormat format;
		NSError * error;
		__uiConfiguredata = [NSPropertyListSerialization propertyListWithData:plistData
                                                                      options:NSPropertyListImmutable
                                                                       format:&format
                                                                        error:&error];
        if (!__uiConfiguredata)
        {
            NSLog(@"Failed to read uiconfige data. ");
        }
    }
    return __uiConfiguredata;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma 加载更多
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGPoint offset = scrollView.contentOffset;
    if (offset.y>0) {
        {
            //判断是否到达底部
            CGRect bounds = scrollView.bounds;
            CGSize size = scrollView.contentSize;
            UIEdgeInsets inset = scrollView.contentInset;
            float y = offset.y + bounds.size.height - inset.bottom;
            float h = size.height;
            
            float reload_distance = 5;
            if(y > h + reload_distance) {
                if (self.isLoadEnd) {
                    return;
                }
                
                if (!self.isLoadingMore) {
                    [self loadMore];
                    [self.tableView reloadData];
                }
            }
        }
    }
}

@end
