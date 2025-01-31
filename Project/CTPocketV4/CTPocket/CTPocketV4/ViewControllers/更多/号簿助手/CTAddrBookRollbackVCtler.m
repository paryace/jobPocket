//
//  CTAddrBookRollbackVCtler.m
//  CTPocketV4
//
//  Created by apple on 14-3-27.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTAddrBookRollbackVCtler.h"
#import "ABLogItem.h"
#import "CTAddrBookRollView.h"
#import "SIAlertView.h"
#import "AddressBookLogger.h"
#import "AppDelegate.h"
#import "ToastAlertView.h"
#import "Utils.h"

extern NSString* const CTAddrBookSyncBackgroundTaskFinish;
extern NSString* const CTHomeVCtlerDidRefreshUserInfoNotification;

@interface CTAddrBookRollbackVCtler ()

@property (nonatomic, strong) UIButton*     maskBtn;
@property (nonatomic, strong) UILabel*      msgLab;
@property (nonatomic, strong) CTAddrBookRollView*   rollView;

@property (nonatomic, assign) dispatch_queue_t      rollQueue;
@property (nonatomic, strong) NSDateFormatter*      dateFormatter;

@end

@implementation CTAddrBookRollbackVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogChanged) name:CTAddressBookLogChanged object:nil];
        _viewType = CTRollbackInfoViewTypeTipMsg;
        _rollQueue = dispatch_queue_create("com.eshore.ctpocket.abrollback", DISPATCH_QUEUE_CONCURRENT);
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onCTHomeVCtlerDidRefreshUserInfoNotification)
                                                     name:CTHomeVCtlerDidRefreshUserInfoNotification
                                                   object:nil];
    }
    return self;
}

- (void)onCTHomeVCtlerDidRefreshUserInfoNotification
{
    [self resetUI];
}

- (void)didLogChanged
{
    self.viewType = CTRollbackInfoViewTypeLogMsg;
    [self performSelectorOnMainThread:@selector(resetUI) withObject:nil waitUntilDone:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.rollQueue) {
        dispatch_release(self.rollQueue);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self resetUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetUI
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.msgLab = nil;
    self.rollView = nil;
    [self resetMessageView];
    {
        int height = 50, offsetX = 50;
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled = NO;
        btn.frame = CGRectMake(offsetX, CGRectGetHeight(self.view.frame)-height, CGRectGetWidth(self.view.frame) - offsetX, height);
        btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [btn setImage:[UIImage imageNamed:@"addrbook_logo"] forState:UIControlStateNormal];
        [btn setTitle:@"与号簿助手使用相同的云端存储\r\n电脑登入pim.189.cn管理云端通讯录" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        btn.titleLabel.numberOfLines = 2;
        [btn.titleLabel sizeToFit];
        [self.view addSubview:btn];
        [self.view sendSubviewToBack:btn];
    }
}

- (ABLogItem*)getLastSuccessLog:(NSArray*)logs
{
    if (logs.count <= 0) {
        return nil;
    }
    
    ABLogItem* ret = nil;
    for (int i = logs.count-1; i>=0; i--) {
        ABLogItem* item = logs[i];
        if (item.success) {
            ret = item;
            break;
        }
    }
    return ret;
}

- (void)resetMessageView
{
    int originX = 10, originY = 10;
    NSArray* logs = [self.addrbookHelper loadABLog];
    ABLogItem* lastLog = [self getLastSuccessLog:logs];
    if (logs.count <= 0 || !lastLog) {
        // 无操作记录+云端无数据＋更换终端
        NSMutableString *content = [NSMutableString stringWithString:@"通讯录小助手可以帮你备份通讯录，\r\n开始第一次操作吧~"];
        if ([self getUserName]) {
            [content insertString:[self getUserName] atIndex:0];
        }
        UILabel* lab = [self labelWithFrame:CGRectMake(originX, originY, CGRectGetWidth(self.view.frame) - 20, 50)
                                       text:content];
        [self.view addSubview:lab];
        self.msgLab = lab;
        return;
    }
    
    BOOL canRoll = [self.addrbookHelper localBackupCacheExist];
    if (canRoll&&lastLog.type != ABLogTypeUpload) {
        // 显示回滚页面
        CTAddrBookRollView* v = [[CTAddrBookRollView alloc] initWithFrame:CGRectMake(0, originY,
                                                                                     CGRectGetWidth(self.view.frame),
                                                                                     CGRectGetHeight(self.view.frame)-originY)];
        v.logInfo = lastLog;
        [self.view addSubview:v];
        originY = CGRectGetMaxY(v.frame);
        self.rollView = v;
        
        __weak typeof(self) wself = self;
        [v setRollbackBlock:^(CTAddrBookRollView *rollView) {
            [wself onRollbackBtn:rollView];
        }];
    } else {
        {
            UILabel* lab = [self labelWithFrame:CGRectMake(originX, originY, CGRectGetWidth(self.view.frame) - 20, 50)
                                           text:nil];
            [self.view addSubview:lab];
            
            NSMutableString* text = [NSMutableString new];
            [text appendString:@"最后一次成功"];
            if (lastLog.type == ABLogTypeUpload) {
                [text appendString:@"上传"];
            } else if (lastLog.type == ABLogTypeDownload) {
                [text appendString:@"下载"];
            } else {
                [text appendString:@"操作"];
            }
            [text appendString:@"时间\r\n"];
            if (lastLog.time) {
                NSDate* dt = [NSDate dateWithTimeIntervalSince1970:lastLog.time];
                NSDateFormatter* formatter = [NSDateFormatter new];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                [text appendString:[formatter stringFromDate:dt]];
            }
            if ([self getUserName]) {
                [text insertString:[self getUserName] atIndex:0];
            }
            lab.text = text;
            
            originY = CGRectGetMaxY(lab.frame) + 5;
        }
        {
            UIImage* img = [UIImage imageNamed:@"addrbook_log_graypoint"];
            UIImageView* iv = [[UIImageView alloc] initWithImage:img];
            iv.frame = CGRectMake((CGRectGetWidth(self.view.frame) - img.size.width)/2, originY, img.size.width, img.size.height);
            [self.view addSubview:iv];
            originY = CGRectGetMaxY(iv.frame) + 10;
        }
    }
}

- (void)setSuccessView
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.msgLab = nil;
    self.rollView = nil;
    int originX = 10, originY = 10;
    NSArray* logs = [self.addrbookHelper loadABLog];
    {
        ABLogItem* lastLog = [logs lastObject];
        {
            UILabel* lab = [self labelWithFrame:CGRectMake(originX, originY, CGRectGetWidth(self.view.frame) - 20, 50)
                                           text:nil];
            [self.view addSubview:lab];
            
            NSMutableString* text = [NSMutableString new];
            [text appendString:@"最后一次成功"];
            if (lastLog.type == ABLogTypeUpload) {
                [text appendString:@"上传"];
            } else if (lastLog.type == ABLogTypeDownload) {
                [text appendString:@"下载"];
            } else {
                [text appendString:@"操作"];
            }
            [text appendString:@"时间\r\n"];
            if (lastLog.time) {
                NSDate* dt = [NSDate dateWithTimeIntervalSince1970:lastLog.time];
                NSDateFormatter* formatter = [NSDateFormatter new];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                [text appendString:[formatter stringFromDate:dt]];
            }
            if ([self getUserName]) {
                [text insertString:[self getUserName] atIndex:0];
            }
            lab.text = text;
            
            originY = CGRectGetMaxY(lab.frame) + 5;
        }
        {
            UIImage* img = [UIImage imageNamed:@"addrbook_log_greenpoint"];
            UIImageView* iv = [[UIImageView alloc] initWithImage:img];
            iv.frame = CGRectMake((CGRectGetWidth(self.view.frame) - img.size.width)/2, originY, img.size.width, img.size.height);
            [self.view addSubview:iv];
            originY = CGRectGetMaxY(iv.frame) + 10;
        }
    }
    {
        int height = 50, offsetX = 50;
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled = NO;
        btn.frame = CGRectMake(offsetX, CGRectGetHeight(self.view.frame)-height, CGRectGetWidth(self.view.frame) - offsetX, height);
        btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [btn setImage:[UIImage imageNamed:@"addrbook_logo"] forState:UIControlStateNormal];
        [btn setTitle:@"与号簿助手使用相同的云端存储\r\n电脑登入pim.189.cn管理云端通讯录" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        btn.titleLabel.numberOfLines = 2;
        [btn.titleLabel sizeToFit];
        [self.view addSubview:btn];
        [self.view sendSubviewToBack:btn];
    }
}

- (UILabel* )labelWithFrame:(CGRect)frame text:(NSString* )text
{
    UILabel* lab = [[UILabel alloc] initWithFrame:frame];
    lab.backgroundColor = [UIColor clearColor];
    lab.font = [UIFont systemFontOfSize:12];
    lab.textColor = [UIColor darkGrayColor];
    lab.text = text?text:@"";
    lab.textAlignment = UITextAlignmentCenter;
    lab.numberOfLines = 0;
    
    return lab;
}

- (ABLogItem*)getLastDownloadLog:(NSArray*)logarr
{
    ABLogItem* log = nil;
    int count = logarr.count;
    for (int i = count-1; i >= 0; i--) {
        ABLogItem* item = logarr[i];
        if (item.type == ABLogTypeDownload) {
            log = item;
            break;
        }
    }
    
    return log;
}

- (void)popupLocalNotification:(NSString*)content
{
    if (content.length <= 0) {
        return;
    }
    UILocalNotification* notification = [UILocalNotification new];
    notification.alertBody = content;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)syncFailed
{
    if (self.syncStatus != NULL) {
        *self.syncStatus = CTAddrBookSyncStatusNone;
        [self didSyncStatusChanged];
    }
    NSString *comment = @"回滚失败";
    [self.addrbookHelper saveLog:[NSDate date]
                            type:ABLogTypeRollback
                        contacts:0
                         comment:comment
                         success:NO];
    
    // 弹出本地通知
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self popupLocalNotification:comment];
        [[NSNotificationCenter defaultCenter] postNotificationName:CTAddrBookSyncBackgroundTaskFinish object:nil];
    }
}

- (void)onRollbackBtn:(CTAddrBookRollView*)rollView
{
    __weak typeof(self) wself = self;
    
    NSArray* logs = [self.addrbookHelper loadABLog];
    ABLogItem* lastLog = [self getLastDownloadLog:logs];
    NSDate* dt = [NSDate dateWithTimeIntervalSince1970:lastLog.time];
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *tipMsg=[NSString stringWithFormat:@"亲，即将倒流到%@下载前的状态，是否继续？",[formatter stringFromDate:dt]];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                     andMessage:tipMsg];
    [alertView addButtonWithTitle:@"继续" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView){
        dispatch_async(wself.rollQueue, ^{
            if (wself.syncStatus != NULL) {
                *wself.syncStatus = CTAddrBookSyncStatusRollback;
                [wself didSyncStatusChanged];
            }
            
            [wself.addrbookHelper localRollback:^(BOOL success, int totalCnt, NSTimeInterval backupTimestamp) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (wself.syncStatus != NULL) {
                        *wself.syncStatus = CTAddrBookSyncStatusNone;
                        [wself didSyncStatusChanged];
                    }
                    [wself removeMaskView];
                    
                    // 回滚失败
                    if (!success) {
                        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                         andMessage:@"亲，本次操作没成功，再试一次吧~"];
                        [alertView addButtonWithTitle:@"确定" type:SIAlertViewButtonTypeDefault handler:nil];
                        alertView.transitionStyle = SIAlertViewTransitionStyleFade;
                        [alertView show];
                        [wself resetUI];
                        [wself syncFailed];
                        return ;
                    }
                    
                    // 保存操作记录
                    [wself.addrbookHelper saveLog:[NSDate date]
                                             type:ABLogTypeRollback
                                         contacts:totalCnt
                                          comment:[NSString stringWithFormat:@"回滚成功：通讯录成功恢复至 %@ 版本", [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:backupTimestamp]]]
                                          success:YES];
                    
                    // 回滚成功
                    [wself setSuccessView];
                    ToastAlertView* alert = [ToastAlertView new];
                    [alert showAlertMsg:@"亲，已成功倒流上次操作前的状态~"];
                    
                    // 弹出本地通知
                    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                        [wself popupLocalNotification:@"亲，通讯录回滚成功〜"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:CTAddrBookSyncBackgroundTaskFinish object:nil];
                    }
                }); // dispatch_async(dispatch_get_main_queue()
            } progressChanged:^(double progress) {
                [rollView setRollProgress:progress];
            }]; // [wself.addrbookHelper localRollback:
        }); // dispatch_async(dispatch_get_global_queue
        [rollView startRollback];
        [wself addMaskView];
    }]; // [alertView addButtonWithTitle:@"继续"
    
    [alertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeDefault handler:nil];
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    [alertView show];
}

- (void)addMaskView
{
    [self removeMaskView];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = MyAppDelegate.window.bounds;
    [btn addTarget:self action:@selector(onMaskBtn) forControlEvents:UIControlEventTouchUpInside];
    [MyAppDelegate.window addSubview:btn];
    [MyAppDelegate.window bringSubviewToFront:btn];
    self.maskBtn = btn;
}

- (void)onMaskBtn
{
    ToastAlertView* alert = [ToastAlertView new];
    [alert showAlertMsg:@"通讯录回滚中，请稍候..."];
}

- (void)removeMaskView
{
    [self.maskBtn removeFromSuperview];
    self.maskBtn = nil;
}

- (void)setTipMessage:(NSString *)tipMessage
{
    _tipMessage = tipMessage;
    self.msgLab.text = _tipMessage?_tipMessage:@"";
}

- (void)didSyncStatusChanged
{
    if (self.syncStatus != NULL) {
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        [def setObject:[NSNumber numberWithInt:*self.syncStatus] forKey:kCTAddrBookSyncStatusKey];
        [def synchronize];
    }
}

- (void)rollback
{
    [self onRollbackBtn:self.rollView];
}

- (NSString *)getUserName
{
    NSMutableString *content = [NSMutableString stringWithString:@"你好,\r\n"];
    NSDictionary *custInfoDict = [Global sharedInstance].userInfoDict;
    if (custInfoDict[@"Cust_Name"]) {
        [content insertString:custInfoDict[@"Cust_Name"] atIndex:0];
    }
    return content;
}

@end
