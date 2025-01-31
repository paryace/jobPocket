//
//  CTLoginVCtler.h
//  CTPocketV4
//
//  Created by 许忠洲 on 13-11-13.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//  登录

#import "CTBaseViewController.h"
#import "CTJumpWithMsg.h"

@protocol loginSucDelegate <NSObject>

@optional

- (void)autoPushVCtler;

@end

@interface CTLoginVCtler : CTBaseViewController
@property (assign,nonatomic) BOOL isPush;
@property (weak, nonatomic) id<loginSucDelegate> loginDelegate;

@end
