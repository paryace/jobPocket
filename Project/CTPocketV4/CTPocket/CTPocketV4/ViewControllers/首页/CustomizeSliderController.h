//
//  CustomizeSliderController.h
//  CTPocketV4
//
//  Created by Gong Xintao on 14-5-26.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//抽屉交互的实现

#import "MMDrawerController.h"
@class CTBaseViewController;
@class CTNavigationController;
//定义协议用于右侧界面的改变
@protocol ChangeRightDelegate<NSObject>
-(void)changeRight:(CTBaseViewController*)rightVCtler;
-(void)pushRightViewController:(CTBaseViewController*)viewController; 
@end
//定义协议用于显示右侧界面
@protocol SliderDelegate<NSObject>
-(void)expandRight;
-(void)shrinkRight;
@end
 
@interface CustomizeSliderController : MMDrawerController<SliderDelegate,
                                                          ChangeRightDelegate>
+(instancetype)instance;
-(UINavigationController*)navigationController;
@end
