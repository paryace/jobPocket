//
//  CTMoreVCtler.h
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTBaseViewController.h"
@protocol SliderDelegate ;
extern NSString* const CTRefreshNewFlag;

@interface CTMoreVCtler : CTBaseViewController
@property(weak,nonatomic)id<SliderDelegate> sliederDelegate;
@end
