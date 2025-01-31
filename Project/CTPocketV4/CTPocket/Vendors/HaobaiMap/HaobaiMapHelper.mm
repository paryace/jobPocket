//
//  HaobaiMapHelper.m
//  CTPocketv3
//
//  Created by apple on 13-5-7.
//
//

#import "HaobaiMapHelper.h"

@implementation HaobaiMapHelper

+ (BOOL)checkLocationServiceEnableAndTipMsg
{
    if (![CLLocationManager locationServicesEnabled])
    {
        NSURL * url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]; //用户允许打开定位服务
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            // 未开定位
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:@"需要开启定位服务哦！"
                                                            delegate:(id<UIAlertViewDelegate>)self
                                                   cancelButtonTitle:@"开启去"
                                                   otherButtonTitles:@"取消", nil];
            alert.tag = 1;
            [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
        else
        {
            // 未开定位
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:[NSString stringWithFormat:@"定位服务不可用，请开启定位，并允许%@使用定位服务：设置->隐私->定位服务",APPTITLE]
                                                            delegate:(id<UIAlertViewDelegate>)self
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
            [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
        
        return NO;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
    {
        NSURL * url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            // 未授权访问
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:[NSString stringWithFormat:@"亲，需要授权允许%@使用定位服务哦！",APPTITLE]
                                                            delegate:(id<UIAlertViewDelegate>)self
                                                   cancelButtonTitle:@"授权去"
                                                   otherButtonTitles:@"取消", nil];
            alert.tag = 1;
            [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:[NSString stringWithFormat:@"请允许%@使用定位服务：设置->隐私->定位服务",APPTITLE]
                                                            delegate:(id<UIAlertViewDelegate>)self
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
            [alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
        
        return NO;
    }
    
    return YES;
}

+ (BOOL)checkLocationServiceEnable
{
    if (![CLLocationManager locationServicesEnabled])
    {
        return NO;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
    {
        return NO;
    }
    
    return YES;
}

@end
