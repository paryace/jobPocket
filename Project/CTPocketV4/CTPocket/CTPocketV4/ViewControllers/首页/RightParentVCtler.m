//
//  RightParentVCtler.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-5-29.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "RightParentVCtler.h"
#import "CustomShareVC.h"
@interface RightParentVCtler ()

@end

@implementation RightParentVCtler

 -(void)resetRecommend
{
    
}
-(void)showShare
{
    NSString *sc=self.shareContent?self.shareContent:@"";
    [[NSUserDefaults standardUserDefaults]
     setObject:[NSString stringWithFormat:@"%@ 请您下载：%@",sc,SHARE_DOWNLOAD_URL]
     forKey:@"shareContent"];
    //    UIImage *image = [CustomShare getNormalImage:self.view];
    UIImage *image =[UIImage imageNamed:@"mine_share_icon"];
    //    [CustomShare shareHandler:image];
    [CustomShareVC shareHandler:image];
}
@end
