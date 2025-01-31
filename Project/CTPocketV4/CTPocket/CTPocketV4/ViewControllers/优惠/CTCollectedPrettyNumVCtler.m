//
//  CTCollectedPrettyNumVCtler.m
//  CTPocketV4
//
//  Created by liuruxian on 14-1-12.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTCollectedPrettyNumVCtler.h"
#import "CTQryCollected.h"
#import "CTCollectedPrettyNumCell.h"
#import "CTPrettyNumberVCtler.h"
#import "SIAlertView.h"
#import "CTPlanSelectVCtler.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "CTAddPackageVCtler.h"

@interface CTCollectedPrettyNumVCtler () <CollectedPrettyNumCollectedDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *collectedView;
@property (nonatomic, strong) NSDictionary *phoneDict;
@end

@implementation CTCollectedPrettyNumVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:239/255. green:239/255. blue:239/255. alpha:1];
    self.title = @"临时收藏夹";
    [self setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
    
    UIView *divideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    divideView.backgroundColor = [UIColor colorWithRed:213/255. green:213/255. blue:213/255. alpha:1];
    [self.view addSubview:divideView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:
                              CGRectMake(13,
                                         1,
                                         self.view.bounds.size.width-13,
                                         iPhone5?340:250)];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    tableView.delegate = (id<UITableViewDelegate>)self;
    tableView.dataSource = (id<UITableViewDataSource>)self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UIView *collectedView = [[UIView alloc] initWithFrame:CGRectMake(13,
                                                                     1,
                                                                     self.view.bounds.size.width,
                                                                     iPhone5?340:250)];
    collectedView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectedView];
    self.collectedView = collectedView ;
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 70, self.view.frame.size.width, 80)];
        label.text = @"还没有初选号码哟~\n\n马上进行心仪号码第一轮海选吧";
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = UITextAlignmentCenter ;
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        [label sizeToFit];
        [collectedView addSubview:label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn_hl.png"] forState:UIControlStateHighlighted];
        button.frame = CGRectMake(15, CGRectGetMaxY(label.frame)+40, CGRectGetWidth(collectedView.frame)-50, 40);
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"现在去选" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectedPrettyNumber) forControlEvents:UIControlEventTouchUpInside];
        [collectedView addSubview:button];
    }
    
    if ([[CTQryCollected shareQryCollected].collectedMutableDict count] > 0) {
        self.collectedView.hidden = YES ;
    }
    
    UIView *tipView = [[UIView alloc] initWithFrame:
                       CGRectMake(22,
                                  CGRectGetMaxY(tableView.frame),
                                  self.view.bounds.size.width - 44,
                                  112)];
    tipView.backgroundColor = [UIColor clearColor];
    tipView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    [self.view addSubview:tipView];
    {
        UILabel *label = [[UILabel alloc] initWithFrame:tipView.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.numberOfLines = 0;
        label.textColor = [UIColor blackColor];
        label.text = @"温馨提示:\n1.收藏夹内为最新收藏号码,最多可收藏10个号码;\n2.将号码放入收藏夹内,并未实现对号码的预占。请尽快选中号码,完成订单支付,以确保获得您心仪的号码";
        [tipView addSubview:label];
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
  
}

#pragma mark - CollectedPrettyNumCollectedDelegate

- (void) cancelCollected:(CTCollectedPrettyNumCell *)collectedCell
{
    NSMutableArray *array = [[CTQryCollected shareQryCollected].collectedMutableDict copy];
    NSString *phoneNum = collectedCell.infoDict[@"PhoneNumber"];
    for (NSMutableDictionary *dict in array) {
        if ([phoneNum isEqualToString:dict[@"PhoneNumber"]]) {
            [[CTQryCollected shareQryCollected].collectedMutableDict removeObject:dict];
        }
    }
    if ([[CTQryCollected shareQryCollected].collectedMutableDict count] == 0) {
        self.collectedView.hidden = NO ;
    }
    
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATACOLLECTEDSTATUS object:nil];//更新收藏状态
    [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTPRETTYNUMBERCOUNT object:nil];//收藏得个数
}

#pragma mark - datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[CTQryCollected shareQryCollected].collectedMutableDict count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifi = @"collectedCell";
    CTCollectedPrettyNumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifi ];
    if (cell == nil) {
        cell = [[CTCollectedPrettyNumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifi];
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate =  self ;
    }
    
    [cell setInfo:[[CTQryCollected shareQryCollected].collectedMutableDict objectAtIndex:indexPath.row]];
    
    return  cell ;
}

#pragma mark - netWork

- (void) getNumProudInfo
{
    //靓号-频道选择接口 (测试)
    NSString *PhoneNumber = self.phoneDict[@"PhoneNumber"];
    NSString *ShopId = BUSSINESS_SHOPID;

    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               PhoneNumber,@"PhoneNumber",
                               ShopId,@"ShopId",
                               nil];
    __weak typeof(self) wself = self;
    [MyAppDelegate.cserviceEngine
                          postXMLWithCode:@"getNumProudInfo"
                          params:params
                          onSucceeded:^(NSDictionary *dict) {
                              DDLogInfo(@"%s--%@", __func__, dict.description);
                              id data = dict[@"Data"];
                              if (data) {
                                  NSString *Status = data[@"Status"];
                                  if ([Status isEqualToString:@"2"]) {
                                      //跳转到套餐页面
                                      CTAddPackageVCtler *vc = [CTAddPackageVCtler new];
                                      vc.item = wself.phoneDict;
                                      //保存数据
                                      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                      [defaults setObject:wself.selectedDict forKey:CITYINFO];
                                      [defaults synchronize];
                                      
                                      [wself.navigationController pushViewController:vc animated:YES];
                                  }
                                  else {
                                      SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                       andMessage:@"您选的号码必定人人喜爱，已被人抢先一步，请重新选择一个号码。"];
                                      [alertView addButtonWithTitle:@"换个号码"
                                                               type:SIAlertViewButtonTypeDefault
                                                            handler:^(SIAlertView *alertView) {
                                                                NSMutableArray *array = [[CTQryCollected shareQryCollected].collectedMutableDict copy];
                                                                NSString *phoneNum = wself.phoneDict[@"PhoneNumber"];
                                                                for (NSMutableDictionary *dict in array) {
                                                                    if ([phoneNum isEqualToString:dict[@"PhoneNumber"]]) {
                                                                        [[CTQryCollected shareQryCollected].collectedMutableDict removeObject:dict];
                                                                    }
                                                                }
                                                                [wself.tableView reloadData];
                                                                if ([[CTQryCollected shareQryCollected].collectedMutableDict count] == 0) {
                                                                    self.collectedView.hidden = NO ;
                                                                }
                                                            }];
                                      
                                      alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                      [alertView show];
                                  }
                              }
                              
                              
                          } onError:^(NSError *engineError) {
                              DDLogInfo(@"%s--%@", __func__, engineError);
                              [SVProgressHUD dismiss];

                          }];
}

#pragma mark - delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    CTCollectedPrettyNumCell *cell = (CTCollectedPrettyNumCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.phoneDict = cell.infoDict;
    [self getNumProudInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (void) onLeftBtnAction:(id)sender  {
    [self.navigationController popViewControllerAnimated:YES];
    //发送更新消息
    [[CTQryCollected shareQryCollected] saveCacheArea];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATACOLLECTEDSTATUS object:nil];//更新收藏状态
    
    [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTPRETTYNUMBERCOUNT object:nil];//收藏得个数
}

- (void) selectedPrettyNumber
{
    [self.navigationController popViewControllerAnimated:YES];
    [[CTQryCollected shareQryCollected] saveCacheArea];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATACOLLECTEDSTATUS object:nil];//更新收藏状态
    [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTPRETTYNUMBERCOUNT object:nil];//收藏得个数
}

@end
