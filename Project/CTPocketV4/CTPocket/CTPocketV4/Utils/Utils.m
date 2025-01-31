//
//  Utils.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-28.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "Utils.h"
#import "SIAlertView.h"
#include <sys/sysctl.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "BBTopItemDataModel.h"

#define tripleDESKey @"ThisIsTripleKey4CTPocketV4MakeByXzz"

@implementation Utils

// 获取设备型号
+ (NSString *)modelId
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

// 获取设备名称
+ (NSString *)deviceName
{
    NSString *modelId = [self modelId];
    
    // The ever mysterious iFPGA
    if ([modelId isEqualToString:@"iFPGA"])        return @"iFPGA";
    
    // iPhone
    if ([modelId isEqualToString:@"iPhone1,1"])    return @"iPhone";
    if ([modelId isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([modelId hasPrefix:@"iPhone2"])            return @"iPhone 3GS";
    if ([modelId hasPrefix:@"iPhone3"])            return @"iPhone 4";
    if ([modelId hasPrefix:@"iPhone4"])            return @"iPhone 4s";
    
    if ([modelId isEqualToString:@"iPhone5,1"] ||
        [modelId isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    
    if ([modelId isEqualToString:@"iPhone5,3"] ||
        [modelId isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    
    if ([modelId hasPrefix:@"iPhone6"])            return @"iPhone 5s";
    
    // iPod
    if ([modelId hasPrefix:@"iPod1"])              return @"iPod touch";
    if ([modelId hasPrefix:@"iPod2"])              return @"iPod touch 2";
    if ([modelId hasPrefix:@"iPod3"])              return @"iPod touch 3";
    if ([modelId hasPrefix:@"iPod4"])              return @"iPod touch 4";
    if ([modelId hasPrefix:@"iPod5"])              return @"iPod touch 5";
    
    // iPad
    if ([modelId hasPrefix:@"iPad1"])              return @"iPad";
    if ([modelId isEqualToString:@"iPad2,1"] ||
        [modelId isEqualToString:@"iPad2,2"] ||
        [modelId isEqualToString:@"iPad2,3"] ||
        [modelId isEqualToString:@"iPad2,4"])      return @"iPad 2";
    
    if ([modelId isEqualToString:@"iPad3,1"] ||
        [modelId isEqualToString:@"iPad3,2"] ||
        [modelId isEqualToString:@"iPad3,3"])      return @"iPad 3";
    
    if ([modelId isEqualToString:@"iPad3,4"] ||
        [modelId isEqualToString:@"iPad3,5"] ||
        [modelId isEqualToString:@"iPad3,6"])      return @"iPad 4";
    
    if ([modelId isEqualToString:@"iPad2,5"] ||
        [modelId isEqualToString:@"iPad2,6"] ||
        [modelId isEqualToString:@"iPad2,7"])      return @"iPad mini";
    
    if ([modelId isEqualToString:@"iPad4,1"] ||
        [modelId isEqualToString:@"iPad4,2"])      return @"iPad Air";
    
    // Apple TV
    if ([modelId hasPrefix:@"AppleTV1"])           return @"Apple TV 1";
    if ([modelId hasPrefix:@"AppleTV2"])           return @"Apple TV 2";
    if ([modelId hasPrefix:@"AppleTV3"])           return @"Apple TV 3";
    
    if ([modelId hasPrefix:@"iPhone"])             return @"Unknown iPhone";
    if ([modelId hasPrefix:@"iPod"])               return @"Unknown iPod";
    if ([modelId hasPrefix:@"iPad"])               return @"Unknown iPad";
    if ([modelId hasPrefix:@"AppleTV"])            return @"Unknown Apple TV";
    
    // Simulator thanks Jordan Breeding
    if ([modelId hasSuffix:@"86"] || [modelId isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? @"iPhone Simulator" : @"iPad Simulator";
    }
    
    return @"Unknown iOS device";
}

// 利用正则表达式验证email
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateUrl:(NSString *)url
{
    if (url==nil) return NO;
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:url];
    
}
// 利用正则表达式验证手机号码
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,181,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,181,189
     22         */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// 利用正则表达式验证电信手机号码
+ (BOOL)isCTMobileNumber:(NSString *)mobileNum
{
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,181,189
     22         */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if ([regextestct evaluateWithObject:mobileNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// 利用正则表达式判断是否全数字
+ (BOOL)isNumber:(NSString *)mobileNum
{
    NSString *num = [NSString stringWithFormat:@"^\\d{%d}$", [mobileNum length]];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", num];
    if ([regextestct evaluateWithObject:mobileNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSString *)getNetMessageByCode:(NSString *)code
{
    /*
     如果接口返回2410、2411、2412 等错误码，需要按下面的要求处理
     
     2410   查询结果显示：“--”
     
     2411、2412提示信息：
     2411   尊敬的用户，您的号码不支持此功能查询，请咨询客户经理或拨打10000号。
     2412   账单处于出账期，请于5号以后进行查询。
     
     1.客户信息查询
     custInfo
     2.积分消费记录
     pointCosumeHistory
     3.积分信息查询
     pointInfo
     4.帐户总余额查询
     queryAll
     5.可用余额查询
     queryCanUse
     6.欠费查询
     queryAcctBillInfo
     7.套餐使用情况查询
     queryPpaccuInfo
     8.实时话费及账单查询[帐户级]
     queryBillInfo
     9.缴费记录查询
     queryPaymentRecord
     10.流量信息查询
     queryFlowInfo
     11.实时话费及账单查询[用户级]
     queryBillInfoUser
     12.实时话费及账单查询[用户级/帐户级]
     queryBillInfoAll
     13.套餐及流量集合查询
     ppaccuFlowInfo
     */
    NSString *msg = @"";
    if ([code isEqualToString:@"2410"])
    {
        msg = @"--";
    }
    else if ([code isEqualToString:@"2411"])
    {
        msg = @"尊敬的用户，您的号码不支持此功能查询，请咨询客户经理或拨打10000号。";
    }
    else if ([code isEqualToString:@"2412"])
    {
        msg = @"账单处于出账期，请于5号以后进行查询。";
    }
    
    return msg;
}

// 根据给定区域的宽度计算字符串显示的高度
+ (CGSize) measureFrame: (CGRect)rc text:(NSAttributedString*)text
{
	if (!text	||
		[text length] <= 0)
	{
		return CGSizeMake(rc.size.width, 0);
	}
    return CGSizeMake(0,0);
}

//  3DES
+ (NSString *)tripleDES:(NSString *)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt key:(NSString *)key
{
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        // hexToBytes
        NSMutableData *data = [NSMutableData data];
        int idx;
        for (idx = 0; idx+2 <= plainText.length; idx+=2) {
            NSRange range = NSMakeRange(idx, 2);
            NSString *hexStr = [plainText substringWithRange:range];
            NSScanner *scanner = [NSScanner scannerWithString:hexStr];
            unsigned int intValue;
            [scanner scanHexInt:&intValue];
            [data appendBytes:&intValue length:1];
        }
        
        NSData *EncryptData = data;
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else
    {
        NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [data length];
        vplainText = (const void *)[data bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    // uint8_t ivkCCBlockSize3DES;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    NSString *initVec = @"init Vec";
    const void *vkey = (const void *) [key UTF8String];
    const void *vinitVec = (const void *) [initVec UTF8String];
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionECBMode|kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    DDLogInfo(@"ccStatus:%d. \"0 is success\"", ccStatus);
    
    NSString *result;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                               length:(NSUInteger)movedBytes]
                                       encoding:NSUTF8StringEncoding];
    }
    else
    {
        NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        
        Byte *myByte = (Byte *)[myData bytes];
        NSMutableString *tResult = [NSMutableString string];
        NSMutableString *newHexStr = [NSMutableString string];
        for (int i = 0 ; i < [myData length]; i++) {
            [newHexStr setString:[NSString stringWithFormat:@"%x", myByte[i]&0xff]];
            if([newHexStr length] == 1) {
                [tResult appendFormat:@"0%@", newHexStr];
            }
            else {
                [tResult appendString:newHexStr];
            }
        }
        result = tResult;
        
        result = [result uppercaseString];
    }
    free(bufferPtr);
    
    return result;
}

//  保存，读取用户名、密码
+ (void)savePhone:(NSString *)phone andPwd:(NSString *)pwd
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if (phone) {
        [settings setObject:[self tripleDES:phone encryptOrDecrypt:kCCEncrypt key:tripleDESKey] forKey:@"Phone"];
    }
    if (pwd) {
        [settings setObject:[self tripleDES:pwd encryptOrDecrypt:kCCEncrypt key:tripleDESKey] forKey:@"Password"];
    }
    [settings synchronize];
}

+ (NSString *)getPhone
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings objectForKey:@"Phone"] && [[settings objectForKey:@"Phone"] length]>0) {
        return [self tripleDES:[settings objectForKey:@"Phone"] encryptOrDecrypt:kCCDecrypt key:tripleDESKey];
    }
    else
    {
        return @"";
    }
}

+ (NSString *)getPwd
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings objectForKey:@"Password"] && [[settings objectForKey:@"Password"] length]>0) {
        return [self tripleDES:[settings objectForKey:@"Password"] encryptOrDecrypt:kCCDecrypt key:tripleDESKey];
    }
    else
    {
        return @"";
    }
}

+ (void)clearPhoneAndPwd
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"Phone"];
    [settings removeObjectForKey:@"Password"];
    [settings synchronize];
}

// 保存，读取首页显示模式  0为圆环，1为简介模式
+ (void)saveDisplayMode:(NSString *)mode
{
    if (mode) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:mode forKey:@"DisplayMode"];
        [settings synchronize];
    }
}

+ (NSString *)getDisplayMode
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings objectForKey:@"DisplayMode"]) {
        return [settings objectForKey:@"DisplayMode"];
    }
    else {
        [settings setObject:@"0" forKey:@"DisplayMode"];
        [settings synchronize];
        return @"0";
    }
}

// 保存，读取首页自定义列表
+ (void)saveCustomIconList:(NSArray *)array
{
    if (array) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:array forKey:@"CustomIconList"];
        [settings synchronize];
    }
}

+ (NSArray *)getCustomIconList
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings objectForKey:@"CustomIconList"]) {
        return [settings objectForKey:@"CustomIconList"];
    }
    else {
        [settings setObject:[NSArray array] forKey:@"CustomIconList"];
        [settings synchronize];
        return [NSArray array];
    }
}

//added by huangfq 2014-5-27
// 保存，最近的5次付款
+ (void)saveRecentlyPayList:(NSArray *)array
{
    if (array) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:array forKey:@"RecentlyPay"];
        [settings synchronize];
    }
}

+ (NSArray *)getRecentlyPayList
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings objectForKey:@"RecentlyPay"]) {
        
        return [settings objectForKey:@"RecentlyPay"];
    }
    else {
        [settings setObject:[NSArray array] forKey:@"RecentlyPay"];
        [settings synchronize];
        return [NSArray array];
    }
}

//最近5次付款频率最高的，次数相同侧取最近一次
+ (NSArray *)getRecentlyPayDict{
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self getRecentlyPayList]];
    if ([array count] > 0) {
    
        //ZFBQB 支付宝唯一标识
//        NSDictionary *dict = array[0];
        //找出最近的付款渠道
        NSMutableArray *bankCodeArray = [[NSMutableArray alloc] init];
        NSMutableArray *itemsArray    = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in array) {
            
            NSString *newBankCode = dict[@"bankCode"];
            if ([bankCodeArray containsObject:newBankCode]) {
                
                int k = 0;
                for (NSMutableArray *item in [itemsArray mutableCopy]) {
                    
                    NSString *oldBankCode = item[0][@"bankCode"];
                    
                    if ([newBankCode isEqualToString:oldBankCode]) {
                        
                        NSMutableArray *itmes = itemsArray[k];
                        [itmes addObject:dict];
                        [itemsArray replaceObjectAtIndex:k withObject:itmes];
                    }
                    
                    k++;
                }
            }
            else
            {
                if (newBankCode)
                {
                    [bankCodeArray addObject:newBankCode];
                }
                NSMutableArray *itemArray = [NSMutableArray arrayWithObject:dict];
                [itemsArray addObject:itemArray];

            }
            
        }
        
        //获取最近使用的付款渠道
        if ([itemsArray count] == 1) {
            
            NSDictionary *dict = itemsArray[0][0];
            return [NSArray arrayWithObject:dict];
        }
        
        int count = [[itemsArray firstObject] count];
        int index = 0;
        for (int i = 1; i < [itemsArray count]; i++) {
            
            if (count < [itemsArray[i] count]) {
                
                index = i;
            }
        }
        NSDictionary *dict = itemsArray[index][0];
        return [NSArray arrayWithObject:dict];
        
    }
   
    return nil;
}
#define kOrderType              @"orderType"  //订单类型
//added by huangfa 2014-5-30
//传输的订单类型
+ (void)saveOrderType:(NSInteger)type
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setInteger:type forKey:kOrderType];
    [settings synchronize];
}
+ (NSInteger)getOrderType
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if ([settings integerForKey:kOrderType]) {
        
        return [settings integerForKey:kOrderType];
    }
    else {
        
        [settings setInteger:0 forKey:kOrderType];
        [settings synchronize];
        return 0;
    }
//    PayScene	1
//    string
//    支付场景
//    1：话费直充
//    2：流量直充
//    3：购话费卡
//    4：购流量卡
//    5：购买号卡
//    6：购买手机
    //7是自己加进去的

}

//索取城市的编码
+ (NSInteger)getIndexForLocation:(NSArray *)locationArray Location:(NSString *)locationMent
{
    
    if (!locationArray || [locationArray count] == 0) {
        
        return -1;
    }
    
    if (!locationMent || [locationMent length] ==0 || [locationMent isKindOfClass:[NSNull class]]) {
        
        return  -1;
    }

    {
        //比较字符串是否包含，不包含取前面两个字符来比较
        static NSInteger index = 0;
        [locationArray enumerateObjectsUsingBlock:^ (id odj, NSUInteger idx,BOOL *stop){
            
            if (odj && [odj isKindOfClass:[BBTopItemDataModel class]]) {
                
                NSString *areaString = ((BBTopItemDataModel *)odj).Freight_Area_Name;
        
                if ([areaString length] > [locationMent length]) {
                    
                    NSRange range = [areaString rangeOfString:locationMent];
                    if (range.location != NSNotFound) {
  
                        index = [locationArray indexOfObject:odj];
                        return ;
                    }
            
                }
                else
                {
                    NSRange range = [locationMent rangeOfString:areaString];
                    if (range.location != NSNotFound) {

                        index = [locationArray indexOfObject:odj];
                        return ;
                    }
                    
                }
                
                //如果不包含则取前面两个字符进行比较
                if ([areaString length] >= 2 && [locationMent length] >= 2) {
                    
                    NSString *subAreaString = [locationMent substringToIndex:2];
                    NSRange range = [areaString rangeOfString:subAreaString];
                    if (range.location != NSNotFound) {

                        index = [locationArray indexOfObject:odj];
                        return ;
                    }

                }
            }
        
        }];
        
        return index;
    }
}
// 获取2个日期的相差的天数
+ (NSInteger)getDayCountBetween:(NSDate *)star end:(NSDate *)end
{
    NSTimeInterval timeBetween =[end timeIntervalSinceDate:star];
    int days= ((int)timeBetween)/(3600*24);
    
    return days;
}

+ (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//  MD5加密
+ (NSString *)MD5:(NSMutableString *)str
{
    if (str == nil || [str length] <= 0) {
        return nil;
    }
    
    const char *cStr = [str UTF8String];
	unsigned char result[32];
	CC_MD5( cStr, strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

+ (NSString*)getDocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString*)getDocumentFolderByName:(NSString *)foldername
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if ([foldername length])
    {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:foldername];
    }
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileMgr fileExistsAtPath:documentsDirectory isDirectory:&isDir])
    {
        [fileMgr createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return documentsDirectory;
}

// 判断是否有效身份证号码
+ (BOOL)isIDNumberValid:(NSString*)idnumber
{
	if ([idnumber length] != 15 &&
		[idnumber length] != 18)
	{
		return NO;
	}
	
	NSLog(@"%@",idnumber);
	int provCode = [[idnumber substringToIndex:2] intValue];
	if ( provCode < 11  ||
		(provCode > 15	&&	provCode < 21)	||
		(provCode > 23	&&	provCode < 31)	||
		(provCode > 37	&&	provCode < 41)	||
		(provCode > 46	&&	provCode < 50)	||
		(provCode > 54	&&	provCode < 61)	||
		(provCode > 65)	)
	{
		// 行政区码错误
		NSLog(@"province code error");
		return NO;
	}
	
	int len = [idnumber length];
	int year = 0;
	int month = 0;
	int day = 0;
	if (len == 15)
	{
		year = [[idnumber substringWithRange:NSMakeRange(6, 2)] intValue];
		if (year > 20)
		{
			year = 1900 + year;
		}
		else
		{
			year = 2000 + year;
		}
		
		month = [[idnumber substringWithRange:NSMakeRange(8, 2)] intValue];
		day = [[idnumber substringWithRange:NSMakeRange(10, 2)] intValue];
	}
	else if (len == 18)
	{
		year = [[idnumber substringWithRange:NSMakeRange(6, 4)] intValue];
		month = [[idnumber substringWithRange:NSMakeRange(10, 2)] intValue];
		day = [[idnumber substringWithRange:NSMakeRange(12, 2)] intValue];
	}
	if (year < 1900 ||
		year > 2200)
	{
		// 年份错误
		NSLog(@"year error");
		return NO;
	}
	
	if (month < 1 ||
		month > 12)
	{
		// 月份错误
		NSLog(@"month error");
		return NO;
	}
	
	if (day < 1 ||
		day > 31)
	{
		// 日期错误
		NSLog(@"day error");
		return NO;
	}
	
	// 检查最后一位
	NSRange xrange = [idnumber rangeOfString:@"x"];
	NSRange Xrange = [idnumber rangeOfString:@"X"];
	if ((xrange.length == 1 && xrange.location != len - 1)	||
		(Xrange.length == 1 && Xrange.location != len - 1))
	{
		NSLog(@"x position error");
		return NO;
	}
	
	if (len == 15)
	{
		return YES;
	}
	
	int Wi[17] = {7, 9, 10, 5, 8 ,4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2};
	int lastBit[11] = {1, 0, 'x', 9, 8, 7, 6, 5, 4, 3, 2};
	int sum = 0;
	NSMutableString * idnum18 = [[NSMutableString alloc] initWithString:idnumber];
    
	for (int i = 0; i < 17; i++)
	{
		int nVal = [[idnum18 substringWithRange:NSMakeRange(i, 1)] intValue];
		sum += nVal*Wi[i];
	}
    
	int ret = sum%11;
	NSLog(@"ret=%d",ret);
	if ((ret == 2 && [[[idnum18 substringWithRange:NSMakeRange(17, 1)] lowercaseString] isEqualToString:@"x"])	||
        lastBit[ret] == [[idnum18 substringWithRange:NSMakeRange(17, 1)] intValue])
	{
        //		[idnum18 release];
		return YES;
	}
	else
	{
		// 校验码错误
		NSLog(@"verify code error");
        //		[idnum18 release];
		return NO;
	}
	
    //	[idnum18 release];
	return NO;
}

#pragma mark 中文编码
+ (NSString*)encodedURLParameterString:(NSString* )text
{
    if (!text || text.length <= 0)
    {
        return @"";
    }
    NSString *result = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                            (__bridge CFStringRef)text,
                                                                                            NULL,
                                                                                            CFSTR(":/=,!$&'()*+;[]@#?^%\"`<>{}\\|~ "),
                                                                                            kCFStringEncodingUTF8);
	return result;
}

//将字符转换为价格
+ (NSString *)smartNumberStringWithFloat:(float)number
{
    NSString *numberString = nil;
    if (number - (int)number < 0.1) {
        numberString = [NSString stringWithFormat:@"%d", (int)number];
    } else {
        numberString = [NSString stringWithFormat:@"%.1f", number];
    }
    return numberString;
}
static int showTimes=0;
+(void)showRecommend
{
    ++showTimes;
    if (showTimes!=2)return;
    NSUserDefaults *df=[NSUserDefaults standardUserDefaults];
    NSString *recommend=[df stringForKey:kFirstLoginForRecommend];
    if (![@"YES" isEqualToString:recommend])
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:@"您的评价是我们最渴求的激励\r\n好用，就请叫个好！"];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView addButtonWithTitle:@"残忍拒绝"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alert){
                              }];
        [alertView addButtonWithTitle:@"叫个好"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert)
         {
             [df setObject:@"YES" forKey:kFirstLoginForRecommend];
             [df synchronize];
             NSString *items=[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",@"513836029"];
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:items]];
         }
         ];
        [alertView show]; 
    }
}

/**
 *  把指定的对象格式成数组对象 added by lip, 2014-06-09
 *
 *  @param tempData 要格式的数据
 *  @param path     要格式的路径地址 (data/param/param)
 *
 *  @return 返回数组
 */
+(NSMutableDictionary*)objFormatArray:(NSDictionary*)tempData path:(NSString*)path
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:tempData];
    
    NSArray *strArr = [path componentsSeparatedByString:@"/"];
    id tempD = dic;
    for(NSString *spit in strArr)
    {
        tempD = tempD[spit];
        if(tempD == nil)
            break;
    }
    
    //转换为数组
    if(tempD != nil && ![tempD isKindOfClass:[NSArray class]])
    {
        NSArray *array = [[NSArray alloc]initWithObjects:tempD, nil];
        tempD = array;
    }else
        return dic;
    
    //替换原来的值
    NSMutableDictionary *dic2 = dic;
    int i= 0;
    for(NSString *spit in strArr)
    {
        if(i == [strArr count]-1)
        {
            dic2[spit] = tempD;
            break;
        }else
            dic2 = dic2[spit];
        i++;
    }
    
    return dic;
}

/*
 @method 获取字符串的宽度
 @param value 待计算的字符串
 @param font 字体的大小
 @result CGFloat 返回的款度
 */
+(CGFloat)widthForString:(NSString*)value font:(UIFont*)font
{
    CGSize sizeToFit;
    if([value respondsToSelector:@selector(sizeWithAttributes:)])
    {//iOS7
        sizeToFit = [value sizeWithAttributes:@{NSFontAttributeName:font}];
    }else
    {
        sizeToFit = [value sizeWithFont:font];
    }
    return sizeToFit.width;
}

/*
 @method 获取指定字符宽度的高
 @param  value待计算的字符串
 @param  font字体的大小
 @param  andWidth限制字符显示区域的宽度
 @param  返回字符的高度
 */
+(CGFloat)heightForString:(NSString*)value font:(UIFont*)font andWidth:(CGFloat)width
{
    CGSize sizeToFit;
    if([value respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        //NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
        NSDictionary *attributes = @{NSFontAttributeName: font};
        
        sizeToFit = [value boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }else{
        sizeToFit = [value sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
    }
    return sizeToFit.height;
}

@end
