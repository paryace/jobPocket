//
//  Utils.h
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-28.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@interface Utils : NSObject

// 获取设备型号
+ (NSString *)modelId;

// 获取设备名称
+ (NSString *)deviceName;

// 利用正则表达式验证email
+ (BOOL)isValidateEmail:(NSString *)email;
// 利用正则表达式验证url
+ (BOOL)isValidateUrl:(NSString *)url;

// 判断是否有效身份证号码
+(BOOL)isIDNumberValid:(NSString*)idnumber;

// 利用正则表达式验证手机号码
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

// 利用正则表达式验证电信手机号码
+ (BOOL)isCTMobileNumber:(NSString *)mobileNum;

// 利用正则表达式判断是否全数字
+ (BOOL)isNumber:(NSString *)mobileNum;

+ (NSString *)getNetMessageByCode:(NSString *)code;

// 根据给定区域的宽度计算字符串显示的高度
+ (CGSize) measureFrame: (CGRect)rc text:(NSAttributedString*)text;

//  3DES
+ (NSString *)tripleDES:(NSString *)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt key:(NSString *)key;

//  保存，读取用户名、密码
+ (void)savePhone:(NSString *)phone andPwd:(NSString *)pwd;
+ (NSString *)getPhone;
+ (NSString *)getPwd;
+ (void)clearPhoneAndPwd;

// 保存，读取首页显示模式  0为圆环，1为简介模式
+ (void)saveDisplayMode:(NSString *)mode;
+ (NSString *)getDisplayMode;

// 保存，读取首页自定义列表
+ (void)saveCustomIconList:(NSArray *)array;
+ (NSArray *)getCustomIconList;

// 保存，读取最近的5次付款
+ (void)saveRecentlyPayList:(NSArray *)array;
+ (NSArray *)getRecentlyPayList;
//数组嵌套数组，二层是数组嵌套字典
+ (NSArray *)getRecentlyPayDict;

//小区宽带的归属地的index
+ (NSInteger)getIndexForLocation:(NSArray *)locationArray Location:(NSString *)locationMent;

//传输的订单类型
+ (void)saveOrderType:(NSInteger)type;
+ (NSInteger)getOrderType;

// 获取2个日期的相差的天数
+ (NSInteger)getDayCountBetween:(NSDate *)star end:(NSDate *)end;

+ (UIImage *)imageWithView:(UIView *)view;

//  MD5加密
+ (NSString *)MD5:(NSString *)str;

+ (NSString*)getDocumentPath;
+ (NSString*)getDocumentFolderByName:(NSString *)foldername;

+ (NSString*)encodedURLParameterString:(NSString* )text;    // added by zy, 2014-02-24

//将字符转换为价格
+ (NSString *)smartNumberStringWithFloat:(float)number;     // added by yw, 2014-03-24
//提醒用户评价
+(void)showRecommend; // added by gongxt, 2014-03-24

/**
 *  把id对象格式成数组对象 added by lip, 2014-06-09
 *
 *  @param tempData 要格式的数据
 *  @param path     要格式的路径地址
 *
 *  @return 返回数组
 */
+(NSMutableDictionary*)objFormatArray:(NSDictionary*)tempData path:(NSString*)path;

/*
 @method 获取字符串的宽度
 @param value 待计算的字符串
 @param font 字体的大小
 @result CGFloat 返回的款度
 */
+(CGFloat)widthForString:(NSString*)value font:(UIFont*)font;

/*
 @method 获取指定字符宽度的高
 @param  value待计算的字符串
 @param  font字体的大小
 @param  andWidth限制字符显示区域的宽度
 @param  返回字符的高度
 */
+(CGFloat)heightForString:(NSString*)value font:(UIFont*)font andWidth:(CGFloat)width;
@end
