//
//  HBZSNetworkEngine.m
//  CTPocketV4
//
//  Created by apple on 14-3-5.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "HBZSNetworkEngine.h"

/*
 说明：
 1. 测试环境对应的web端：pimportal2.189.cn（需要配置host：219.143.33.51），第一次使用可能需要注册号簿帐号或重置密码
 2. 生产环境对应的web端：pim.189.cn
 */

#if isDeBug
    // 测试环境
    static NSString* HBZSNetworkHostName__ = @"219.143.33.51";
    static NSInteger HBZSNetworkPortNum__ = 8001;
#else
    // 生产环境
    static NSString* HBZSNetworkHostName__ = @"118.85.200.203/UabSyncService";
    static NSInteger HBZSNetworkPortNum__ = -1; // 生产环境无需端口号
#endif

static NSString* HBZSNetworkContentType__ = @"application/x-protobuf";

@implementation HBZSNetworkEngine

+ (NSString* )userAgentInfo
{
    /*ua信息：iphone版本：4100000XXX
     后面三位根据版本来定
     比如1.0.0是100*/
    NSMutableString* ua = [NSMutableString stringWithString:@"4100000"];
    NSString* curViersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    curViersion = [curViersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (curViersion.length >= 3) {
        [ua appendString:[curViersion substringToIndex:3]];
    } else {
        [ua appendString:curViersion];
        for (int i = 0; i < 3-curViersion.length; i++) {
            [ua appendString:@"0"];
        }
    }
    
    return ua;
}

- (instancetype)initWithDefaultSetting
{
    NSDictionary* headerDict = @{@"User-Agent" : [[self class] userAgentInfo],
                                 @"Content-Type" : HBZSNetworkContentType__};
    if (HBZSNetworkPortNum__ == -1) {
        self = [super initWithHostName:HBZSNetworkHostName__
                               apiPath:nil
                    customHeaderFields:headerDict];
    } else {
        self = [super initWithHostName:HBZSNetworkHostName__
                            portNumber:HBZSNetworkPortNum__
                               apiPath:nil
                    customHeaderFields:headerDict];
    }
    
    if (self) {
        [self registerOperationSubclass:[HBZSNetworkOperation class]];
    }
    
    return self;
}

- (id)initWithHostName:(NSString *)hostName {
    
    NSDictionary* headerDict = @{@"User-Agent" : [[self class] userAgentInfo],
                                 @"Content-Type" : HBZSNetworkContentType__};
    self = [super initWithHostName:hostName
                           apiPath:nil
                customHeaderFields:headerDict];
    if (self) {
        [self registerOperationSubclass:[HBZSNetworkOperation class]];
    }
    return self;
}

- (instancetype)initWithoutContentType:(NSString* )hostname
{
    NSDictionary* headerDict = @{@"User-Agent" : [[self class] userAgentInfo]};
    self = [super initWithHostName:hostname
                           apiPath:nil
                customHeaderFields:headerDict];
    if (self) {
        [self registerOperationSubclass:[HBZSNetworkOperation class]];
    }
    return self;
}

#pragma mark - UrlRequest Methods

- (HBZSNetworkOperation* )getRequestWithPath:(NSString* )path
                                  headerDict:(NSDictionary* )headerDict
                   onDownloadProgressChanged:(void(^)(double progress))downloadProgressChanged
                                 onSucceeded:(void(^)(NSData* responseData))succeededBlock
                                     onError:(ErrorBlock)errorBlock
{
    HBZSNetworkOperation* netOperation = (HBZSNetworkOperation* )[self operationWithPath:path
                                                                                  params:nil
                                                                              httpMethod:@"GET"];
    
    for (NSString* key in headerDict)
    {
        [netOperation setHeader:key withValue:headerDict[key]];
    }
    
    [netOperation onDownloadProgressChanged:^(double progress) {
        if (downloadProgressChanged) {
            downloadProgressChanged(progress);
        }
    }];
    
    [netOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        if (succeededBlock) {
            succeededBlock(completedOperation.responseData);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
    
    [self enqueueOperation:netOperation];
    return netOperation;
}

- (HBZSNetworkOperation* )postRequestWithData:(NSData* )reqData
                                   headerDict:(NSDictionary* )headerDict
                      onUploadProgressChanged:(void(^)(double progress))uploadProgressChanged
                                  onSucceeded:(void(^)(NSData* responseData))succeededBlock
                                      onError:(ErrorBlock)errorBlock
{
    HBZSNetworkOperation* netOperation = (HBZSNetworkOperation* )[self operationWithPath:nil
                                                                                  params:nil
                                                                              httpMethod:@"POST"];
    
    for (NSString* key in headerDict)
    {
        [netOperation setHeader:key withValue:headerDict[key]];
    }
    [netOperation setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        return (id)reqData;
    } forType:HBZSNetworkContentType__];
    
    [netOperation onUploadProgressChanged:^(double progress) {
        if (uploadProgressChanged) {
            uploadProgressChanged(progress);
        }
    }];
    
    [netOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        if (succeededBlock) {
            succeededBlock(completedOperation.responseData);
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
    
    [self enqueueOperation:netOperation];
    return netOperation;
}

@end
