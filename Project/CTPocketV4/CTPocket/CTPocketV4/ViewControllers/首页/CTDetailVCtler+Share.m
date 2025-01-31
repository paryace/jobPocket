//
//  CTDetailVCtler+Share.m
//  CTPocketV4
//
//  Created by apple on 14-4-3.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTDetailVCtler+Share.h"
#import "CustomShare.h"
#import "CustomShareVC.h"

@implementation CTDetailVCtler (Share)

- (id)init
{
    self = [super init];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"btn_share"];
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0.0, 0.0, image.size.width , image.size.height)];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"btn_share_press"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        
        //注册通知
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:nil name:@"changeTitle" object:nil];
    }
    
    return self;
}

- (void)share
{
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"ShareDetail"]; //存储
    
//    NSDictionary *dic = [notif userinfo]; //通知
//    str = dic[@"Title"];
    str = [NSString stringWithFormat:@"中国%@#%@#更多活动更多优惠等待您的参与！请您下载：%@",APPTITLE, str,SHARE_DOWNLOAD_URL];
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:@"shareContent"];
    UIImage *image = [CustomShare fullScreenshots];
//    [CustomShare shareHandler:image];
    [CustomShareVC shareHandler:image];
    
}

@end
