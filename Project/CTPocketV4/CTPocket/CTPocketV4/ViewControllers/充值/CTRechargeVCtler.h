//
//  CTRechargeVCtler.h
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTBaseViewController.h"
#import "RechargeTypeView.h"

@protocol SliderDelegate ;
@interface CTRechargeVCtler : CTBaseViewController
- (void) rechargeType:(int)Type ;
@property(weak,nonatomic)id<SliderDelegate> sliederDelegate;
@property (nonatomic, strong) RechargeTypeView      *rechargeTypeView;
@property (nonatomic, strong) NSMutableDictionary   *orderInfo;
@property (nonatomic, assign) BOOL isPush;

- (void) setRechargeCardInfo ;
- (void) pageIndex : (int) page;
- (void) recharge : (int) cardType  cardPsdWord : (NSString *)psdword rechageNum : (BOOL) isRecharge;

@end
