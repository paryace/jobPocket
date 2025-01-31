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

@end
