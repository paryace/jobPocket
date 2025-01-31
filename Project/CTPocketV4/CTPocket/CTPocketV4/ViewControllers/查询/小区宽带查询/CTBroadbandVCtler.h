//
//  CTBroadbandVCtler.h
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-5.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  小区宽带的主controller

#import "CTBaseViewController.h"
#import "BBTopViewManager.h"
#import "BBCenterViewManager.h"
#import "BBNWRequstProcess.h"
#import "BBSearchField.h"
@interface CTBroadbandVCtler : CTBaseViewController

@property(weak,nonatomic)IBOutlet UIView *centerView;
@property(weak,nonatomic)IBOutlet UIView *topView;
@property(weak,nonatomic)IBOutlet BBSearchField *textField;
@property(weak,nonatomic)IBOutlet UIButton *searchButton;


@property(strong,nonatomic)IBOutlet BBTopViewManager *topManager;
@property(strong,nonatomic)IBOutlet BBCenterViewManager *centerManager;
@property(strong,nonatomic)IBOutlet BBNWRequstProcess *requestProcess;;


-(IBAction)hideKeyWord:(UITapGestureRecognizer*)gueture;
@end
