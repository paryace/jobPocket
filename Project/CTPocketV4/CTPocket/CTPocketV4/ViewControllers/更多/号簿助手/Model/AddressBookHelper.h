//
//  AddressBookHelper.h
//  CTPocketV4
//
//  Created by apple on 14-3-7.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "ABLogItem.h"

@interface AddressBookHelper : NSObject
- (void)getAddressBookRef:(void(^)(ABAddressBookRef addrBookRef, BOOL hasPopedAlertMsg))completion;
- (void)readAddressBook:(void(^)(BOOL success, BOOL hasPopedAlertMsg))completion;

- (void)getConfigure:(void(^)(BOOL success, NSError* error))completion;
- (void)auth:(NSString* )phone completion:(void(^)(BOOL success, NSError* error))completion;
- (void)getUserCloudSummary:(void(^)(BOOL success, NSError* error, id resp))completion;

- (BOOL)hasGetConfigureSuccess;
- (BOOL)hasAuthSuccess;
- (BOOL)isAddrBookEmpty;

// 全量上传
- (void)uploadAll:(void(^)(BOOL success, NSError* error, int totalCnt))completion
  progressChanged:(void(^)(double progress))progressChanged
 totalCountSetter:(void(^)(int totalcnt))totalCountSetter;

// 全量下载
- (void)downloadAll:(void(^)(BOOL success, NSError* error, int totalCnt))completion
    progressChanged:(void(^)(double progress))progressChanged
   totalCountSetter:(void(^)(int totalcnt))totalCountSetter;

// 本地回滚
- (void)localRollback:(void(^)(BOOL success, int totalCnt, NSTimeInterval backupTimestamp))completion
      progressChanged:(void(^)(double progress))progressChanged;

// 记录操作
- (void)saveLog:(NSDate*)time type:(ABLogType)type contacts:(int)contacts comment:(NSString*)comment success:(BOOL)success;
- (NSArray*)loadABLog;
- (BOOL)checkIfSamePlatform;

- (BOOL)localBackupCacheExist;
- (void)deleteLocalBackupCache; // 删除本地备份

@end
