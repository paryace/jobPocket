//
//  CTRechargeVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTRechargeVCtler.h"

#import "RechargeTypeView.h"
#import "CTOrderRechargeVCtler.h"
#import "CserviceOperation.h"
#import "AppDelegate.h"
#import "CTRechargeSucessVCtler.h"
#import "CTOrderConfirmVCtler.h"
#import "CTCallsRechargeVCtler.h"
#import "CTFlowRechargeVCtler.h"
#import "CTBuyRechargeVCtler.h"
#import "CTOrderConfirmVCtler.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "CTContractPhoneVCtler.h"
#import "CTOrderDetailVCtler.h"

@interface CTRechargeVCtler () <rechargeTypeDelegate>


@property (nonatomic, strong) CTCallsRechargeVCtler *callsVCtler;
@property (nonatomic, strong) CTFlowRechargeVCtler  *flowVCtler;
@property (nonatomic, strong) CTBuyRechargeVCtler   *buyCardVCtler;

@property (nonatomic, strong) UIViewController      *curVCtler;
@property (nonatomic, assign) int                   chargeType;

@property (nonatomic, strong) CserviceOperation *rechargeQueryOpt;

@end

@implementation CTRechargeVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"充值";
        self.isPush = NO ;
//        [self setLeftButton:[UIImage imageNamed:@"navigationBar_message_icon"]];
//        [self setRightButton:[UIImage imageNamed:@"navigationBar_user_icon"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRechagerByBankAction:)
                                                     name:CTP_MSG_RECHARGE_BANK
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRechargeByCardAction:)
                                                     name:CTP_MSG_RECHARGE_CARD
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBuyCardAction:)
                                                     name:CTP_MSG_RECHARGE_BUYCARD
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isPush == YES) {
        [self setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
    }
    
    //初始化
    self.chargeType = 0;
    NSArray *textAry = [NSArray arrayWithObjects:@"充话费",
                                                 @"充流量",
                                                 @"买充值卡", nil];

    NSArray *imageAry = [NSArray arrayWithObjects:@"recharge_call_icon.png",
                                                  @"recharge_flow_icon.png",
                                                  @"recharge_buy_icon.png", nil];
    
    self.rechargeTypeView = [[RechargeTypeView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
    self.rechargeTypeView.delegate = self;
    self.rechargeTypeView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.rechargeTypeView];
    [self.rechargeTypeView initView:imageAry title:textAry xOriginal:12 msgMark:NO];
    
    self.callsVCtler = [[CTCallsRechargeVCtler alloc]init];

    self.callsVCtler.view.frame = CGRectMake(0, CGRectGetHeight(self.rechargeTypeView.frame), self.view.frame.size.width, self.view.frame.size.height - 40);
    self.callsVCtler.view.backgroundColor = PAGEVIEW_BG_COLOR;//[UIColor colorWithRed:230/255. green:230/255. blue:230/255. alpha:1]; // modified by zy，2014-02-19
    self.callsVCtler.rechargeView = self.rechargeTypeView ;
    [self.view addSubview:self.callsVCtler.view];
}

#pragma mark - rechargevView Delegate

- (void) rechargeType:(int)Type
{
    if (self.curVCtler) {
        [self.curVCtler.view removeFromSuperview];
    }
    self.chargeType = Type; 
    switch (Type) {
            
        case 0:
            if (!self.callsVCtler) {
                self.callsVCtler.view.frame = CGRectMake(0,
                                                    42,
                                                    self.view.frame.size.width,
                                                    self.view.frame.size.height - 40);
                
                //self.callsVCtler.view.backgroundColor = [UIColor colorWithRed:230/255. green:230/255. blue:230/255. alpha:1]; // modified by zy
            }
            self.curVCtler = self.callsVCtler;
            [self.view addSubview:self.curVCtler.view];
            break;
        case 1:
            if (!self.flowVCtler) {
                self.flowVCtler = [[CTFlowRechargeVCtler alloc]init];
                //self.flowVCtler.view.backgroundColor = [UIColor colorWithRed:230/255. green:230/255. blue:230/255. alpha:1]; // modified by zy
//                self.flowVCtler.parentVCtler = self;
                self.flowVCtler.rechargeView = self.rechargeTypeView ;
                
                self.flowVCtler.view.frame = CGRectMake(0,
                                                        42,
                                                        self.view.frame.size.width,
                                                        self.view.frame.size.height - 40);

            }
            self.curVCtler = self.flowVCtler;
            [self.view addSubview:self.curVCtler.view];
            break;
        case 2:
            if (!self.buyCardVCtler) {
                self.buyCardVCtler = [[CTBuyRechargeVCtler alloc]init];
                //self.buyCardVCtler.view.backgroundColor = [UIColor colorWithRed:230/255. green:230/255. blue:230/255. alpha:1]; // modified by zy
                self.buyCardVCtler.view.frame = CGRectMake(0,
                                                           42,
                                                           self.view.frame.size.width,
                                                           self.view.frame.size.height - 40);
            }
            
            self.curVCtler = self.buyCardVCtler;
            [self.view addSubview:self.curVCtler.view];
            break;
    }
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action
//监听响应事件
//银行卡充值跳转页面
- (void) onRechagerByBankAction : (NSNotification *) notication
{
    NSMutableDictionary *orderInfo = (NSMutableDictionary *)[notication object];
    if (orderInfo) {
        
        CTOrderConfirmVCtler * vctler = [CTOrderConfirmVCtler new];
        vctler.title = @"订单确认";
        vctler.pageType = [[orderInfo objectForKey:@"PageType"]intValue];
        vctler.orderInfo = orderInfo ;
        [self.navigationController pushViewController:vctler animated:YES];
    }
}

//购买充值卡
- (void)onBuyCardAction : (NSNotification *) notication
{
    NSMutableDictionary *orderInfo = (NSMutableDictionary *)[notication object];
    if (orderInfo) {
        CTOrderConfirmVCtler * vctler = [CTOrderConfirmVCtler new];
        vctler.title = @"订单确认";
        vctler.pageType = 3;
        vctler.orderInfo = orderInfo ;
        [self.navigationController pushViewController:vctler animated:YES];
    }
}

//充值卡充值
- (void) onRechargeByCardAction : (NSNotification *) notication
{
    NSMutableDictionary *dictionay = (NSMutableDictionary *)[notication object];
    if (dictionay) {
        CTRechargeSucessVCtler *vc = [CTRechargeSucessVCtler new];
        vc.rechargeInfoDict = dictionay;  //设置显示信息
        NSString *OrderStatus = [dictionay objectForKey:@"OrderStatus"];
        if ([OrderStatus isEqualToString:@"0"]) {
            vc.title = @"充值成功";
        }else{
            vc.title = @"充值失败";
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) setRechargeCardInfo
{
    //跳转到充值页面
    if ([[self.orderInfo objectForKey:@"OrderStatusCode"]isEqualToString:@"11108"]) {
        int page = [[self.orderInfo objectForKey:@"CardType"]intValue]; //充值卡类型 即 充值页面
        
        NSString *cardPsd = [self.orderInfo objectForKey:@"CardPwd"];
        //页面分类
        switch (page) {
            case 0:
//                [self pageIndex:page];
//                [self.rechargeTypeView selectedChargeType:page];
                [self.callsVCtler showView:1];
                [self.rechargeTypeView selectedChargeType:page];
                self.callsVCtler.phoneNumTextField.text = [self.orderInfo objectForKey:@"PhoneNumber"];
                self.callsVCtler.carPassWrdTextField.text = cardPsd;
                break;
            case 1:
//                [self pageIndex:page];
                [self.rechargeTypeView selectedChargeType:page];
                [self.flowVCtler showView:1];
                self.flowVCtler.phoneNumTextField.text = [self.orderInfo objectForKey:@"PhoneNumber"];
                self.flowVCtler.carPassWrdTextField.text = cardPsd;
                break;
        }
    }
}

//页面跳转  
- (void) pageIndex : (int) page
{
    [self rechargeType:page];
    [self.rechargeTypeView selectedChargeType:page];
    if (page==0) {
        [self.callsVCtler showView:0];
    }else if(page == 1){
        [self.flowVCtler showView:0];
    }else if(page == 2){
    }
    
    if (self.isPush == YES) {
        [self setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
    }
}

//订单查询页面跳转到支付页面得接口方法

- (void) recharge : (int) cardType  cardPsdWord : (NSString *)psdword rechageNum : (BOOL) isRecharge
{
    [self rechargeType:cardType];
    [self.rechargeTypeView selectedChargeType:cardType];
    switch (cardType) {
        case 0:
            [self.callsVCtler showView:1];
            
            if (isRecharge) {  //本机充值
                self.callsVCtler.phoneNumTextField.text = [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"];
            }else{
                self.callsVCtler.phoneNumTextField.text = @"";
            }
            self.callsVCtler.carPassWrdTextField.text = psdword;
            break;
        case 1:
            [self.flowVCtler showView:1];
            if (isRecharge) {  //本机充值
                self.flowVCtler.phoneNumTextField.text = [[Global sharedInstance].loginInfoDict objectForKey:@"UserLoginName"];
            }else{
                self.flowVCtler.phoneNumTextField.text = @"";
            }
            self.flowVCtler.carPassWrdTextField.text = psdword;
            break;
    }
}

- (void) onRightBtnAction:(id)sender
{
    CTRechargeSucessVCtler * vc = [CTRechargeSucessVCtler new];
//    vc.recha
    [self.navigationController pushViewController:vc animated:YES];
}

@end
