//
//  CTPreferentialVCtler+Share.m
//  CTPocketV4
//
//  Created by apple on 14-4-3.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTPreferentialVCtler+Share.h"
#import "CustomShare.h"
#import "WeiBoShareVC.h"
#import "CustomShareVC.h"

@implementation CTPreferentialVCtler (Share)

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
    }
    
    return self;
}

- (void)share
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"#中国%@-----精品手机集中营#   合约机、套餐、靓号、裸终端，你要的实惠，我们提供！！请您下载：%@",APPTITLE,SHARE_DOWNLOAD_URL] forKey:@"shareContent"];
    //    UIImage *image = [CustomShare getNormalImage:self.view];
    UIImage *image = [CustomShare fullScreenshots];
    //    [CustomShare shareHandler:image];
    [CustomShareVC shareHandler:image];
    
}

@end
