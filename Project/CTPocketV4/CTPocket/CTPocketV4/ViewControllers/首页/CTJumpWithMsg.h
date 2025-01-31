//
//  CTJumpWithMsg.h
//  CTPocketV4
//
//  Created by liuruxian on 14-6-16.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CTJumpPageWithMsgNotification ;

@protocol jumpPageDelegate <NSObject>

@required

- (void)pushToViewCtler:(UIViewController *)viewController ;

@end


typedef enum _JUMPTYPE
{
    push = 0,
    addvertise = 1
}JUMPTYPE;

@interface CTJumpWithMsg : NSObject

- (instancetype)init:(UIViewController *)tabbar type:(JUMPTYPE)pushType ;
@property (weak,nonatomic) id<jumpPageDelegate> delegate;
- (void)jumpPage:(NSDictionary *)dictionary;

@end
