//
//  WeiBoShareVC.h
//  iMovie
//
//  Created by 许 忠洲 on 13-5-21.
//  Copyright (c) 2013年 eshore. All rights reserved.
//  微博分享编辑视图

#import <UIKit/UIKit.h>
#import "CTBaseViewController.h"

//  微博分享类型：新浪微博、腾讯微博
typedef enum {
    SinaWeibo = 0,
    TencentWeibo = 1,
    renrenWeibo = 2
} WeiboType;

@class ZoomingViewController;

@interface WeiBoShareVC : CTBaseViewController <UITextViewDelegate>
{
    UITextView *shareTextView;
    UILabel *tip;
    UIImageView *coverImage;
    UIButton *btnImage;
    ZoomingViewController *zoomingViewController;
    
    WeiboType shareType;
    NSString *shareText;
    NSString *imageUrl;
    NSString *filmName;
    NSString *shareUrlStr;
    NSString *showDate;
    
}
@property (nonatomic, assign)WeiboType shareType;
@property (nonatomic, copy)NSString *shareText;
@property (nonatomic, copy)NSString *imageUrl;
@property (nonatomic, copy)NSString *filmName;
@property (nonatomic, copy)NSString *shareUrlStr;
@property (nonatomic, copy)NSString *showDate;
@property (nonatomic, copy) NSString *extraText;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, strong) UITextView *shareTextView;

@end
