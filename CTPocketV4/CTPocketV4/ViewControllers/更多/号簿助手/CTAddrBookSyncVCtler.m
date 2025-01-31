//
//  CTAddrBookSyncVCtler.m
//  CTPocketV4
//
//  Created by apple on 14-3-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTAddrBookSyncVCtler.h"
#import "AddressBookHelper.h"
#import "SIAlertView.h"
#import "CTAddrBookProgressView.h"
#import "AppDelegate.h"
#import "CTAddrBookLoadingView.h"
#import "CTAddrBookSuccessVCtler.h"
#import "CTAddrBookRollbackVCtler.h"
#import "ToastAlertView.h"
#import "ABAddressBookCache.h"
#import "CTAddrBookLogVCtler.h"

#import "Get_user_cloud_summary_proto.pb.h"

extern NSString* const CTRefreshNewFlag;

NSString* const CTAddrBookSyncBackgroundTaskFinish = @"CTAddrBookSyncBackgroundTaskFinish";

@interface CTAddrBookSyncVCtler ()

@property (nonatomic, strong) UIButton*             uploadBtn;
@property (nonatomic, strong) UIButton*             downloadBtn;

@property (nonatomic, strong) CTAddrBookLoadingView*    loadingView;
@property (nonatomic, strong) CTAddrBookProgressView*   progressView;
@property (nonatomic, strong) CTAddrBookRollbackVCtler* rollbackVC;

@property (nonatomic, strong) AddressBookHelper*        addrbookHelper;
@property (nonatomic, assign) CTAddrBookSyncStatus      syncStatus;
@property (nonatomic, assign) dispatch_queue_t          uploadQueue;
@property (nonatomic, assign) dispatch_queue_t          downloadQueue;

@property (nonatomic, assign) UIBackgroundTaskIdentifier  backgroundTask;

@property (nonatomic, strong) UIImageView *directedImageView;

@end

@implementation CTAddrBookSyncVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.addrbookHelper = [AddressBookHelper new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAppDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [self addObserver:self forKeyPath:@"syncStatus" options:NSKeyValueObservingOptionNew context:nil];
        
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        BOOL needRefreshUI = ![def objectForKey:kCTAddrBookSyncStatusKey];
        if ([def objectForKey:kCTAddrBookSyncStatusKey]) {
            self.syncStatus = [def integerForKey:kCTAddrBookSyncStatusKey];
        } else {
            self.syncStatus = CTAddrBookSyncStatusNone;
        }
        if (needRefreshUI) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CTRefreshNewFlag object:nil];
        }
        
        self.uploadQueue = dispatch_queue_create("com.eshore.ctpocket.abupload", DISPATCH_QUEUE_CONCURRENT);
        self.downloadQueue = dispatch_queue_create("com.eshore.ctpocket.abdownload", DISPATCH_QUEUE_CONCURRENT);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBackgroundTaskFinish)
                                                     name:CTAddrBookSyncBackgroundTaskFinish
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    DDLogInfo(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"syncStatus"];
    
    if (self.uploadQueue) {
        dispatch_release(self.uploadQueue);
    }
    if (self.downloadQueue) {
        dispatch_release(self.downloadQueue);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setTitle:@"通讯录助手"];
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    [self setRightButton:[UIImage imageNamed:@"addrbook_icon_right_menu"]];
    
    {
        UIImage* bgimg = [UIImage imageNamed:@"addrbook_icon_bg_left"];
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.exclusiveTouch = YES;
        btn.frame = CGRectMake(0, -1, bgimg.size.width, bgimg.size.height-(iPhone5?0:30));
        btn.backgroundColor = [UIColor colorWithPatternImage:[bgimg resizableImageWithCapInsets:UIEdgeInsetsMake(bgimg.size.height/2, bgimg.size.width/2,bgimg.size.height/2, bgimg.size.width/2)]];
        [btn setImage:[UIImage imageNamed:@"addrbook_upload_icon_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"addrbook_upload_icon_disable"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(onUploadBtn) forControlEvents:UIControlEventTouchUpInside];
        if (!iPhone5) {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(15, 0, CGRectGetHeight(btn.frame)-15-btn.currentImage.size.height, 0)];
        }
        [self.view addSubview:btn];
        _uploadBtn = btn;
        
        {
            UILabel* lab = [self labelWithframe:CGRectMake(0, CGRectGetMaxY(btn.imageView.frame) + 2,
                                                           CGRectGetWidth(btn.frame), 20)
                                       withText:@"上传通讯录"
                                   withFontSize:14
                                  withTextColor:[UIColor blackColor]];
            [btn addSubview:lab];
            
            lab = [self labelWithframe:CGRectMake(0, CGRectGetMaxY(lab.frame),
                                                  CGRectGetWidth(btn.frame), 20)
                              withText:@"将手机通讯录上传到云端"
                          withFontSize:12
                         withTextColor:[UIColor lightGrayColor]];
            [btn addSubview:lab];
        }
    }
    {
        UIImage* bgimg = [UIImage imageNamed:@"addrbook_icon_bg_right"];
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.exclusiveTouch = YES;
        btn.frame = CGRectMake(bgimg.size.width - 1, -1, bgimg.size.width + 1, bgimg.size.height-(iPhone5?0:30));
        btn.backgroundColor = [UIColor colorWithPatternImage:[bgimg resizableImageWithCapInsets:UIEdgeInsetsMake(bgimg.size.height/2, bgimg.size.width/2,bgimg.size.height/2, bgimg.size.width/2)]];
        [btn setImage:[UIImage imageNamed:@"addrbook_download_icon_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"addrbook_download_icon_disable"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(onDownloadBtn) forControlEvents:UIControlEventTouchUpInside];
        if (!iPhone5) {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(15, 0, CGRectGetHeight(btn.frame)-15-btn.currentImage.size.height, 0)];
        }
        [self.view addSubview:btn];
        _downloadBtn = btn;
        
        {
            UILabel* lab = [self labelWithframe:CGRectMake(0, CGRectGetMaxY(btn.imageView.frame) + 2,
                                                           CGRectGetWidth(btn.frame), 20)
                                       withText:@"下载通讯录"
                                   withFontSize:14
                                  withTextColor:[UIColor blackColor]];
            [btn addSubview:lab];
            
            lab = [self labelWithframe:CGRectMake(0, CGRectGetMaxY(lab.frame),
                                                  CGRectGetWidth(btn.frame), 20)
                              withText:@"从云端下载通讯录到手机"
                          withFontSize:12
                         withTextColor:[UIColor lightGrayColor]];
            [btn addSubview:lab];
        }
    }
    
    {
        CTAddrBookRollbackVCtler* vctler = [CTAddrBookRollbackVCtler new];
        vctler.addrbookHelper = self.addrbookHelper;
        vctler.syncStatus = &_syncStatus;
        vctler.view.frame = CGRectMake(0, CGRectGetMaxY(_downloadBtn.frame), CGRectGetWidth(self.view.frame),
                                       CGRectGetHeight(self.view.frame) - CGRectGetMaxY(_downloadBtn.frame));
        vctler.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addChildViewController:vctler];
        [self.view addSubview:vctler.view];
        self.rollbackVC = vctler;
    }
    
    if (self.syncStatus == CTAddrBookSyncStatusUpload) {
        // 上传
        [self onUploadBtn];
    } else if (self.syncStatus == CTAddrBookSyncStatusDownload) {
        // 下载
        [self onDownloadBtn];
    } else if (self.syncStatus == CTAddrBookSyncStatusRollback) {
        // 回滚
        [self.rollbackVC rollback];
    }
    
    
    //  引导层 遮罩层
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *isShow = [defaults objectForKey:@"AddrBookSync"];
    
    if ([isShow isEqualToString:@"YES"]) {
        
    }
    else
    {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        UIImageView *directedImageView ;
        
        if (!iPhone5)
        {
            directedImageView = [[UIImageView alloc] initWithFrame:
                                 CGRectMake(0, 0,
                                            CGRectGetWidth(window.frame),
                                            480)];
            
            directedImageView.backgroundColor = [UIColor clearColor];
            directedImageView.userInteractionEnabled = YES ;
            directedImageView.autoresizingMask = UIViewContentModeScaleAspectFill;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                directedImageView.image = [UIImage imageNamed:@"AddrBookSync_iphone4"];
            } else {
                directedImageView.image = [UIImage imageNamed:@"AddrBookSync_iphone4"];
            }
        } else
        {
            directedImageView = [[UIImageView alloc] initWithFrame:
                                 CGRectMake(0, 0,
                                            CGRectGetWidth(window.frame),
                                            568)];
            
            directedImageView.backgroundColor = [UIColor clearColor];
            directedImageView.userInteractionEnabled = YES ;
            directedImageView.autoresizingMask = UIViewContentModeScaleAspectFill;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                directedImageView.image = [UIImage imageNamed:@"AddrBookSync_iphone5"];
            } else {
                directedImageView.image = [UIImage imageNamed:@"AddrBookSync_iphone5"];
            }
            
        }
        
        self.directedImageView = directedImageView;
        [window addSubview:directedImageView];
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = directedImageView.bounds;
            [button addTarget:self action:@selector(removeDirected) forControlEvents:UIControlEventTouchUpInside];
            [directedImageView addSubview:button];
        }
        
        [defaults setObject:@"YES" forKey:@"AddrBookSync"];
        [defaults synchronize];
    }
}

- (void) removeDirected
{
    __weak typeof(self)wSelf = self ;
    [UIView animateWithDuration:0.3 animations:^()
     {
         wSelf.directedImageView.alpha = 0;
     }completion:^(BOOL finished){
         
         [wSelf.directedImageView removeFromSuperview];
     }];
}

- (UILabel* )labelWithframe:(CGRect)frame withText:(NSString* )text withFontSize:(int)fontSize withTextColor:(UIColor* )textColor
{
    UILabel* lab = [[UILabel alloc] initWithFrame:frame];
    lab.backgroundColor = [UIColor clearColor];
    lab.font = [UIFont systemFontOfSize:fontSize];
    lab.textColor = textColor?textColor:[UIColor blackColor];
    lab.text = text?text:@"";
    lab.textAlignment = UITextAlignmentCenter;
    
    return lab;
}

- (void)removeLoadingView
{
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    self.uploadBtn.enabled = YES;
    self.downloadBtn.enabled = YES;
}

- (void)showLoadingView
{
    // 显示loading＋菊花
    self.uploadBtn.enabled = NO;
    self.downloadBtn.enabled = NO;
    [self.loadingView removeFromSuperview];
    self.loadingView = [[CTAddrBookLoadingView alloc] initWithFrame:CGRectZero];
    [self.loadingView startAnimate];
    [MyAppDelegate.window addSubview:self.loadingView];
}

- (void)showProgressView
{
    // 显示loading＋进度条
    [self.loadingView stopAnimate];
    [self.progressView removeFromSuperview];
    CTAddrBookProgressView* v = [[CTAddrBookProgressView alloc] initWithFrame:CGRectZero];
    v.frame = CGRectMake(0, CGRectGetHeight(self.loadingView.frame) - CGRectGetHeight(v.frame), CGRectGetWidth(v.frame), CGRectGetHeight(v.frame));
    v.progress = 0;
    [self.loadingView addSubview:v];
    self.progressView = v;
}

- (void)popupConfirmAlertView:(NSString*)title
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:title?title:@""];
    [alertView addButtonWithTitle:@"确定" type:SIAlertViewButtonTypeDefault handler:nil];
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    [alertView show];
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

- (NSString*)getErrorMsg:(NSError*)error
{
    if (!error) {
        return @"";
    }
    
    NSString* msg = [error localizedDescription];
    if ([error code] == -1001) {
        msg = @"网络不给力，请稍后再试";
    } else if ([error code] == -1004 ||
               [error code] == -1009) {
        msg = @"无网络连接，请检查网络设置";
    }
    return msg;
}

- (void)delayDispatchInMainQueue:(dispatch_block_t)delayedBlock
{
    int64_t delayseconds = 1;
    dispatch_time_t delaytimer = dispatch_time(DISPATCH_TIME_NOW,delayseconds*NSEC_PER_SEC);
    dispatch_after(delaytimer, dispatch_get_main_queue(), delayedBlock);
}

- (void)syncFailed:(ABLogType)type
{
    NSString *comment = [NSString stringWithFormat:@"%@失败", (type == ABLogTypeUpload) ? @"上传" : @"下载"];
    self.syncStatus = CTAddrBookSyncStatusNone;
    [self.addrbookHelper saveLog:[NSDate date]
                            type:type
                        contacts:0
                         comment:comment
                         success:NO];
    
    // 弹出本地通知
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self popupLocalNotification:comment];
        [[NSNotificationCenter defaultCenter] postNotificationName:CTAddrBookSyncBackgroundTaskFinish object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRightBtnAction:(id)sender
{
    CTAddrBookLogVCtler *vctler = [CTAddrBookLogVCtler new];
    [self.navigationController pushViewController:vctler animated:YES];
}

#pragma mark private methods
- (void)checkInitState:(void(^)(void))completion
{
    if (![self.addrbookHelper hasGetConfigureSuccess]) {
        __weak typeof(self) wself = self;
        [self.addrbookHelper getConfigure:^(BOOL success, NSError *error) {
            if (!success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* tipmsg = [wself getErrorMsg:error];
                    if (tipmsg.length <= 0) {
                        tipmsg = @"亲，本次操作没成功，再试一次吧~";
                    }
                    [wself popupConfirmAlertView:tipmsg];
                    [wself removeLoadingView];
                    
                    if (wself.syncStatus != CTAddrBookSyncStatusNone) {
                        [wself syncFailed:ABLogTypeUpload];  // 保存操作失败记录
                    }
                });
            } else {
                [wself auth:^() {
                    if (completion) {
                        completion();
                    }
                }];
            }
        }];
    } else if (![self.addrbookHelper hasAuthSuccess]) {
        [self auth:^() {
            if (completion) {
                completion();
            }
        }];
    } else if (completion) {
        completion();
    }
}

- (void)auth:(void(^)(void))completion
{
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *PhoneNumber = loginInfoDict[@"UserLoginName"];
    __weak typeof(self) wself = self;
    [self.addrbookHelper auth:PhoneNumber completion:^(BOOL success, NSError *error) {
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* tipmsg = [wself getErrorMsg:error];
                if (tipmsg.length <= 0) {
                    tipmsg = @"亲，本次操作没成功，再试一次吧~";
                }
                [wself popupConfirmAlertView:tipmsg];
                [wself removeLoadingView];
                
                if (wself.syncStatus != CTAddrBookSyncStatusNone) {
                    [wself syncFailed:ABLogTypeUpload];  // 保存操作失败记录
                }
            });
        } else {
            if (completion) {
                completion();
            }
        }
    }];
}

- (void)onUploadBtn
{
    // 二次确认
    __weak typeof(self) wself = self;
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                     andMessage:@"本操作将使用手机通讯录替换云端通讯录，是否继续？"];
    [alertView addButtonWithTitle:@"继续" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        [wself upload];
    }];
    [alertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeDefault handler:nil];
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    [alertView show];
}

- (void)upload
{
    [self showLoadingView];
    
    __weak typeof(self) wself = self;
    dispatch_async(self.uploadQueue, ^{
        // 1. 读取通讯录
        [wself.addrbookHelper readAddressBook:^(BOOL success, BOOL hasPopedAlertMsg) {
            // 1.1 读取失败
            if (!success) {
                // 延迟1秒提示，避免页面会有一闪的现象
                [wself delayDispatchInMainQueue:^{
                    if (!hasPopedAlertMsg) {
                        [wself popupConfirmAlertView:@"本次操作未成功，请稍候再试!"];
                    }
                    [wself removeLoadingView];
                }];
                [wself syncFailed:ABLogTypeUpload];  // 保存操作失败记录
                return;
            }
            
            // 1.2 通讯录为空
            if ([wself.addrbookHelper isAddrBookEmpty]) {
                // 延迟1秒提示，避免页面会有一闪的现象
                [wself delayDispatchInMainQueue:^{
                    if (!hasPopedAlertMsg) {
                        [wself popupConfirmAlertView:@"亲，你的手机中没有联系人哦~"];
                    }
                    [wself removeLoadingView];
                }];
                [wself syncFailed:ABLogTypeUpload];  // 保存操作失败记录
                return;
            }
            
            // 1.3 通讯录不为空
            [wself performSelectorOnMainThread:@selector(showProgressView) withObject:nil waitUntilDone:YES];
            [wself checkInitState:^{
                // 2. 上传
                wself.syncStatus = CTAddrBookSyncStatusUpload;
                [wself.addrbookHelper uploadAll:^(BOOL success, NSError *error, int totalCnt) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wself.syncStatus = CTAddrBookSyncStatusNone;
                        [wself removeLoadingView];
                        
                        // 2.1 上传失败
                        NSString* tipmsg = [wself getErrorMsg:error];
                        if (!success) {
                            if (tipmsg.length <= 0) {
                                tipmsg = @"亲，本次操作没成功，再试一次吧~";
                            }
                            [wself syncFailed:ABLogTypeUpload];  // 保存失败操作记录
                        } else {
                            tipmsg = [NSString stringWithFormat:@"您成功上传%d条联系人!",totalCnt];
                            // 保存成功操作记录
                            [wself.addrbookHelper saveLog:[NSDate date]
                                                     type:ABLogTypeUpload
                                                 contacts:totalCnt
                                                  comment:[NSString stringWithFormat:@"上传%d条联系人到云端", totalCnt]
                                                  success:YES];
                        }
                        
                        // 3. 弹出本地通知
                        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                            [wself popupLocalNotification:@"亲，通讯录上传成功〜"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:CTAddrBookSyncBackgroundTaskFinish object:nil];
                        }
                        
                        // 4. 跳转到结果页面
                        CTAddrBookSuccessVCtler* vctler = [CTAddrBookSuccessVCtler new];
                        vctler.tipMsgLine1 = (success ? @"上传成功" : @"上传失败");
                        vctler.tipMsgLine2 = (success ? tipmsg : nil);
                        vctler.cololrTipMsgLine1 = (!success?[UIColor redColor]:nil);
                        [wself.navigationController pushViewController:vctler animated:YES];
                    }); // dispatch_async(dispatch_get_main_queue())
                } progressChanged:^(double progress) {
                    wself.progressView.progress = progress;
                } totalCountSetter:^(int totalcnt) {
                    wself.progressView.total = totalcnt;
                }]; // [wself.addrbookHelper uploadAll:]
            }]; // [wself checkInitState:]
        }]; // [wself.addrbookHelper readAddressBook:]
    }); // dispatch_async(self.uploadQueue)
}

- (void)onDownloadBtn
{
    __weak typeof(self) wself = self;
    // 本地联系人不为空，需要二次确认
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"下载后，云端通讯录替换手机通讯录，是否继续？"];
    [alertView addButtonWithTitle:@"继续" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
        [wself download];
    }];
    [alertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeDefault handler:nil];
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    [alertView show];
}

- (void)download
{
    [self showLoadingView];
    
    __weak typeof(self) wself = self;
    dispatch_async(self.downloadQueue, ^{
        [wself checkInitState:^{
            wself.syncStatus = CTAddrBookSyncStatusDownload;
            // 1. 客户端判断云端是否有联系人
            [wself.addrbookHelper getUserCloudSummary:^(BOOL success, NSError *error, id resp) {
                // 1.1 获取云端联系人失败
                if (!success || ![resp isKindOfClass:[GetUserCloudSummaryResponse class]]) {
                    // 延迟1秒提示，避免页面会有一闪的现象
                    [wself delayDispatchInMainQueue:^{
                        NSString* tipmsg = [wself getErrorMsg:error];
                        if (tipmsg.length <= 0) {
                            tipmsg = @"亲，本次操作没成功，再试一次吧~";
                        }
                        [wself popupConfirmAlertView:tipmsg];
                        [wself removeLoadingView];
                    }];
                    [wself syncFailed:ABLogTypeDownload];  // 保存操作失败记录
                    return;
                }
                
                // 1.2 云端没有联系人
                GetUserCloudSummaryResponse* sumaryResp = (GetUserCloudSummaryResponse*)resp;
                if (sumaryResp.contactCount <= 0) {
                    // 延迟1秒提示，避免页面会有一闪的现象
                    [wself delayDispatchInMainQueue:^{
                        [wself popupConfirmAlertView:@"亲，云端没有联系人，立即上传吧~"];
                        [wself removeLoadingView];
                    }];
                    [wself syncFailed:ABLogTypeDownload];  // 保存操作失败记录
                    return;
                }
                
                // 2. 下载
                [wself performSelectorOnMainThread:@selector(showProgressView) withObject:nil waitUntilDone:YES];
                wself.progressView.title = @"正在下载通讯录";
                [wself.addrbookHelper downloadAll:^(BOOL success, NSError *error, int totalCnt) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wself.syncStatus = CTAddrBookSyncStatusNone;
                        [wself removeLoadingView];
                        
                        // 2.1 下载失败
                        NSString* tipmsg = [wself getErrorMsg:error];
                        if (!success) {
                            if (tipmsg.length <= 0) {
                                tipmsg = @"亲，本次操作没成功，再试一次吧~";
                            }
                            [wself syncFailed:ABLogTypeDownload];  // 保存失败操作记录
                        } else {
                            tipmsg = [NSString stringWithFormat:@"您成功下载%d条联系人!",totalCnt];
                            // 保存成功操作记录
                            [wself.addrbookHelper saveLog:[NSDate date]
                                                     type:ABLogTypeDownload
                                                 contacts:totalCnt
                                                  comment:[NSString stringWithFormat:@"下载%d条联系人到手机", totalCnt]
                                                  success:YES];
                            
                            // 3. 弹出本地通知
                            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                                [wself popupLocalNotification:@"亲，通讯录下载成功〜"];
                                [[NSNotificationCenter defaultCenter] postNotificationName:CTAddrBookSyncBackgroundTaskFinish object:nil];
                            }
                        }
                        
                        // 4. 跳转到结果页面
                        CTAddrBookSuccessVCtler* vctler = [CTAddrBookSuccessVCtler new];
                        vctler.tipMsgLine1 = (success ? @"下载成功" : @"下载失败");
                        vctler.tipMsgLine2 = tipmsg;
                        vctler.cololrTipMsgLine1 = (!success?[UIColor redColor]:nil);
                        [wself.navigationController pushViewController:vctler animated:YES];
                    }); // dispatch_async(dispatch_get_main_queue())
                } progressChanged:^(double progress) {
                    wself.progressView.progress = progress;
                } totalCountSetter:^(int totalcnt) {
                    wself.progressView.total = totalcnt;
                }]; // [wself.addrbookHelper downloadAll:]
            }]; // [wself.addrbookHelper getUserCloudSummary:]
        }]; // [wself checkInitState:]
    }); // dispatch_async(self.downloadQueue)
}

#pragma mark notification
- (void)onAppDidEnterBackground
{
    DDLogCInfo(@"%s", __func__);
    if (self.syncStatus != CTAddrBookSyncStatusNone) {
        // 本地通知
        NSString* msg = [NSString stringWithFormat:@"%@",
                         (self.syncStatus == CTAddrBookSyncStatusUpload ? @"上传" :
                          (self.syncStatus == CTAddrBookSyncStatusDownload ? @"下载" :
                           (self.syncStatus == CTAddrBookSyncStatusRollback ? @"回滚" : @"")))];
        [self popupLocalNotification:[NSString stringWithFormat:@"通讯录%@中，请勿将掌厅退出后台运行，否则会%@失败〜", msg, msg]];
        
        UIApplication *application = [UIApplication sharedApplication];
        DDLogCInfo(@"=====>%s appstate=%d", __func__, application.applicationState);
        self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
            DDLogCInfo(@"====>%s beginBackgroundTaskWithExpirationHandler", __func__);
        }];
    }
}

- (void)onBackgroundTaskFinish
{
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
    DDLogCInfo(@"====>%s beginBackgroundTaskWithExpirationHandler", __func__);
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"syncStatus"]) {
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        [def setObject:[NSNumber numberWithInt:self.syncStatus] forKey:kCTAddrBookSyncStatusKey];
        [def setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:kCTAddrBookSyncStatusTimestamp];
        [def synchronize];
    }
}

@end
