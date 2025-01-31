//
//  Global.h
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-29.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GetConfigResponse;
@class CTCity;

@interface Global : NSObject

/**
 *  登录信息 包括 @"UserLoginName", @"pwd", @"Token"
 */
@property (nonatomic, copy) NSDictionary *loginInfoDict;

/**
 *  用户信息
 {
    BasicInfo =     {
        Address = null;
        BindAccounts = "";
        CityCode = null;
        CountyCode = null;
        EmailVerified = "";
        LinePhoneNumber = null;
        NickName = null;
        PhoneNumber = null;
        PostCode = null;
        ProvinceCode = null;
        RealName = null;
        UserEmail = null;
        UserName = 13360009659;
    };
    DetailInfo =     {
        Age = 0;
        CertificateNumber = null;
        CertificateType = 0;
        Company = "2013-06-28 09:14:53";
        CustomHobby = null;
        Duty = null;
        Hobbies = "";
        Sex = 0;
    };
    UserId = 119930472;
 }
 */
@property (nonatomic, copy) NSDictionary *custInfoDict;

@property (nonatomic) BOOL isLogin;

@property (nonatomic, copy) NSString *ticket;
@property (nonatomic) BOOL isShowBusiProc;
@property (nonatomic, copy) NSArray *configArray;

@property (nonatomic, strong) NSDate *reloadHomeTime;

//added by wensj 20140303
@property (nonatomic, strong) NSDate *latestLoadTime;

// added by zy, 2014-03-24
@property (nonatomic, strong) GetConfigResponse*    respConfigure;

// added by zy, 2014-04-18
@property (nonatomic, strong) NSDictionary*    userInfoDict;

// 折扣信息 added by lip, 2014-06-16
@property (nonatomic, strong) NSDictionary *discountDict;

// 归属地信息 added by huangfq, 2014-06-27
@property (nonatomic, strong) CTCity *areaInfo;

// 单例
+ (Global *)sharedInstance;

@end
