//
//  CTOrderRechargeVCtler.h
//  CTPocketV4
//
//  Created by apple on 13-11-4.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTBaseViewController.h"

@interface CTOrderRechargeVCtler : CTBaseViewController
{
    
}

@property (nonatomic, copy) NSString * jumpUrl;

//是否要占满tabBar的位置
@property (nonatomic, assign)BOOL fullScreen;

@property (nonatomic, assign) BOOL isLogoTitle; // 是否显示电信logo＋掌上营业厅 这个标题

@property (nonatomic, assign) BOOL needBack2Rootview;   // 是否返回到tab首页

@property (nonatomic, assign) int rechargeType ;    //充值方式
@property (nonatomic, assign) int rechargeChannel;  //充值类型

@property (nonatomic, strong) NSMutableDictionary *orderInfo;

@property (nonatomic, strong) NSString *OrderId;
@property (nonatomic, assign) int  pageType ;

@property (nonatomic, assign)int comeType;//1 为订单查询 2为充值 3为百搭产品或者其他
@property (nonatomic, assign)int orderType;//传进来的订单类型 决定显示的位置
@property (nonatomic, assign) NSString *cardType;
@property (nonatomic, assign) NSInteger payStyle;
@property (nonatomic, assign) BOOL noFirstPay;//是否是首次支付

//支付场景
//1：话费直充
//2：流量直充
//3：购话费卡
//4：购流量卡
//5：购买号卡
//6：购买手机

//不知道什么意思  只是传进来了
@property (nonatomic, strong) NSString *comboName;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) NSDictionary *salesProInfo;
@end
