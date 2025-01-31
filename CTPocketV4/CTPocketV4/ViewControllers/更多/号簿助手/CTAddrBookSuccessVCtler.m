//
//  CTAddrBookSuccessVCtler.m
//  CTPocketV4
//
//  Created by apple on 14-3-27.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTAddrBookSuccessVCtler.h"
#import "CTAddrBookSuccessCell.h"
#import "CTAddrBookLogVCtler.h"
#import "CTRechargeVCtler.h"
#import "CTPreferentialVCtler.h"

@interface CTAddrBookSuccessVCtler ()

@end

@implementation CTAddrBookSuccessVCtler

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
    [self setTitle:@"通讯录助手"];
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    int originY = 40;
    if (self.tipMsgLine1)
    {
        UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, CGRectGetWidth(self.view.frame), 25)];
        lab.backgroundColor = [UIColor clearColor];
        lab.text = self.tipMsgLine1;
        lab.textAlignment = UITextAlignmentCenter;
        lab.font = [UIFont boldSystemFontOfSize:18];
        lab.textColor = self.cololrTipMsgLine1?self.cololrTipMsgLine1:[UIColor colorWithRed:102/255. green:196/255. blue:81/255. alpha:1];
        [self.view addSubview:lab];
        originY = CGRectGetMaxY(lab.frame);
    }
    if (self.tipMsgLine2)
    {
        UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, CGRectGetWidth(self.view.frame), 30)];
        lab.backgroundColor = [UIColor clearColor];
        lab.text = self.tipMsgLine2;
        lab.textAlignment = UITextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:15];
        lab.textColor = [UIColor blackColor];
        [self.view addSubview:lab];
        originY = CGRectGetMaxY(lab.frame) + 5;
    }
    {
        UIImage* img = [UIImage imageNamed:@"myOrderBtn"];
        int btnWidth = img.size.width + 40;
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((int)(CGRectGetWidth(self.view.frame) - btnWidth)/2, originY, btnWidth, img.size.height);
        [btn setBackgroundImage:img forState:UIControlStateNormal];
        [btn setTitle:@"查看操作记录" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [btn addTarget:self action:@selector(onLogBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        originY = CGRectGetMaxY(btn.frame) + 40;
    }
    
    {
        UITableView* tv = [[UITableView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - kCTAddrBookSuccessTableCellWidth)/2,
                                                                        originY,
                                                                        kCTAddrBookSuccessTableCellWidth,
                                                                        150)
                                                       style:UITableViewStylePlain];
        tv.backgroundColor   = [UIColor clearColor];
        tv.separatorStyle   = UITableViewCellSeparatorStyleNone;
        tv.delegate         = (id<UITableViewDelegate>)self;
        tv.dataSource       = (id<UITableViewDataSource>)self;
        tv.showsVerticalScrollIndicator = NO;
        [self.view addSubview:tv];
        
        {
            UIView * grayView        = [[UIView alloc] initWithFrame:tv.bounds];
            grayView.backgroundColor = [UIColor colorWithRed:225/255. green:225/255. blue:225/255. alpha:1];
            grayView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            tv.backgroundView        = grayView;
            
            UIView * maskView        = [[UIView alloc] initWithFrame:CGRectInset(grayView.frame, 1, 1)];
            maskView.backgroundColor = PAGEVIEW_BG_COLOR;
            maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [grayView addSubview:maskView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogBtn
{
    CTAddrBookLogVCtler* vctler = [CTAddrBookLogVCtler new];
    [self.navigationController pushViewController:vctler animated:YES];
}

#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifierStr = @"cell";
    CTAddrBookSuccessCell* cell = (CTAddrBookSuccessCell*)[tableView dequeueReusableCellWithIdentifier:identifierStr];
    if (!cell)
    {
        cell = [[CTAddrBookSuccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.title = @"为他人充值";
            cell.icon = [UIImage imageNamed:@"addrbook_success_icon1"];
        }break;
        case 1:
        {
            cell.title = @"充流量";
            cell.icon = [UIImage imageNamed:@"recharge_keeprecharge_icon"];
        }break;
        case 2:
        {
            cell.title = @"优惠活动";
            cell.icon = [UIImage imageNamed:@"recharge_preference_icon"];
        }break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCTAddrBookSuccessTableCellHight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            CTRechargeVCtler *vc =  [[CTRechargeVCtler alloc] init];
            vc.isPush = YES;
            [vc pageIndex:0];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case 1:
        {
            CTRechargeVCtler *vc =  [[CTRechargeVCtler alloc] init];
            vc.isPush = YES;
            [vc pageIndex:1];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case 2:
        {
            CTPreferentialVCtler *vc = [[CTPreferentialVCtler alloc] init];
            [vc setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        default:
            break;
    }
    
}

@end
