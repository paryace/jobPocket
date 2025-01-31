//
//  CTQueryVCtler.h
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTBaseViewController.h"

@protocol SliderDelegate ;
@class LeftTableView_CTQueryVCtler;
@class RightTableView_CTQueryVCtler;
@interface CTQueryVCtler : CTBaseViewController
{
    LeftTableView_CTQueryVCtler*    leftTableView;//_tableview
    UIImageView*    _leftNavBg;
    UIImageView*    _leftNavArrow;
    
    //
    RightTableView_CTQueryVCtler*    rightTableView;//_tablesubView
}

@property(weak,nonatomic)id<SliderDelegate> sliederDelegate;
@property (nonatomic, assign) int selectedIndex;

@end
