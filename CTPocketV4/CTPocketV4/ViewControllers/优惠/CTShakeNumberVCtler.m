//
//  CTShakeNumberVCtler.m
//  CTPocketV4
//
//  Created by liuruxian on 14-1-13.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTShakeNumberVCtler.h"
#import <CoreMotion/CoreMotion.h>
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"
#import "ToastAlertView.h"
#import <CoreLocation/CoreLocation.h>
#import "CTServiceHallMapVCtler.h"
#import "ToastAlertView.h"
#import "CTHelperMap.h"
#import "CTCitySelectedVCtler.h"
#import "CTPlanSelectVCtler.h"
#import "CTLoadMoreCell.h"
#import "UIView+RoundRect.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CTSelectPhoneVCtler.h"
#import "CTPackageSelectVCtler.h"
#import "CTAddPackageVCtler.h"

// 启动的缓冲时间
#define StartBuff 0.3
// 延迟结束的时间
#define EndBuf 0.5
// 两次Shake之间的最小时间
#define WaitBuf 1.5

typedef NS_ENUM(NSInteger, ShakeStatus)
{
    ShakeStatus_PrepareBegin,
    ShakeStatus_Shaking,
    ShakeStatus_PrepareEnd,
    ShakeStatus_Ended
};

@interface CTShakeNumberVCtler ()
{
     SystemSoundID _shake_cheers;
}
@property (nonatomic,strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIImageView *shakeImageView;
@property (nonatomic, strong) UIView *shakeStarView;
@property (nonatomic, strong) UIView *shakeEndView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSOperationQueue *operationQueue ;
@property (nonatomic, assign) __block ShakeStatus currentStatus ;
@property (nonatomic, assign) __block NSTimeInterval statusTime ;
@property (nonatomic, assign) __block BOOL isAnimate;

@property (nonatomic, strong) UILabel *phoneNumLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *saveMoneyLabel;
@property (nonatomic, strong) UILabel *consumeLabel;
@property (nonatomic, strong) UILabel *funnyLabel;

@property (nonatomic, assign) BOOL isLocated;
@property (nonatomic, strong) NSDictionary *phoneInfo;
@property (nonatomic, assign) BOOL isQrygetRcdNumber ;
@property (nonatomic, strong) UIView *endView;
@property (nonatomic, strong) UIView *startView;
@property (nonatomic, strong) UIButton *cityButton ;


//new add
@property (nonatomic, strong) NSMutableArray *phoneNumArray;
@property (nonatomic, assign) int phoneNumIndex;
@property (nonatomic, assign) int pageIndex;
@property (nonatomic, assign) int shakeNum;
@property (nonatomic, strong) UIImageView *bgImageView;


@property (nonatomic, assign) BOOL isShakeBegin;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, assign) BOOL isTimeOut;
@property (nonatomic, assign) BOOL isSuccessed;

@property (nonatomic, assign) BOOL firstQry;

//@property (nonatomic, assign)

@end

@implementation CTShakeNumberVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization;
        self.isLocated = NO;
        self.isQrygetRcdNumber = YES;
        _motionManager = [[CMMotionManager alloc] init];
        _operationQueue = [[NSOperationQueue alloc] init];
        self.phoneNumArray = [NSMutableArray array];
        _motionManager.accelerometerUpdateInterval = 0.1;
        self.pageIndex = 1;
        self.shakeNum = 8;
        self.phoneNumIndex = 0;
        self.isShakeBegin = NO;
        self.isSuccessed = NO;
        self.firstQry = NO;
        self.selectedCity = nil ;
        _jumpType = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"选择号码";
    [self setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor colorWithRed:239/255. green:239/255. blue:239/255. alpha:1];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView ;
    
    UIImage *image = [UIImage imageNamed:@"prettyNum_shake_image.png"];
    self.shakeImageView = [[UIImageView alloc] initWithImage:image];
    self.shakeImageView.backgroundColor = [UIColor clearColor];
    self.shakeImageView.frame = CGRectMake((self.view.bounds.size.width - image.size.width)/2,
                                           20, image.size.width, image.size.height);
    [scrollView addSubview:self.shakeImageView];
    
    UIView *startView = [[UIView alloc] initWithFrame:
                         CGRectMake(0,
                                    CGRectGetMaxY(self.shakeImageView.frame)+30,
                                    self.scrollView.bounds.size.width,
                                    self.scrollView.frame.size.height - CGRectGetMaxY(self.shakeImageView.frame)-30)];
    startView.backgroundColor = [UIColor clearColor];
    startView.userInteractionEnabled = YES ;
    [self.scrollView addSubview:startView];
    self.shakeStarView = startView;
    {
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        label1.backgroundColor = [UIColor clearColor];
        label1.font = [UIFont boldSystemFontOfSize:16];
        label1.text = @"茫茫号海,";
        label1.textColor = [UIColor blackColor];
        label1.numberOfLines = 0;
        [startView addSubview:label1];
        [label1 sizeToFit];
        
        label1.frame = CGRectMake((startView.frame.size.width - CGRectGetWidth(label1.frame))/2,
                                  label1.frame.origin.x,
                                  label1.frame.size.width,
                                  label1.frame.size.height);
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont boldSystemFontOfSize:16];
        label2.text = @"总有一个合适你的。";
        label2.textColor = [UIColor blackColor];
        label2.numberOfLines = 0;
        [startView addSubview:label2];
        [label2 sizeToFit];
        
        label2.frame = CGRectMake((startView.frame.size.width - CGRectGetWidth(label2.frame))/2+4
                                  ,
                                  CGRectGetMaxY(label1.frame)+10,
                                  label2.frame.size.width,
                                  label2.frame.size.height);
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        label3.backgroundColor = [UIColor clearColor];
        label3.font = [UIFont boldSystemFontOfSize:16];
        label3.text = @"在等你......";
        label3.textColor = [UIColor blackColor];
        label3.numberOfLines = 0;
        [startView addSubview:label3];
        [label3 sizeToFit];
        
        label3.frame = CGRectMake((startView.frame.size.width - CGRectGetWidth(label3.frame))/2+2,
                                  CGRectGetMaxY(label2.frame)+10,
                                  label3.frame.size.width,
                                  label3.frame.size.height);
        
        UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        label4.backgroundColor = [UIColor clearColor];
        label4.font = [UIFont boldSystemFontOfSize:16];
        label4.text = @"摇TA出来。";
        label4.textColor = [UIColor blackColor];
        label4.numberOfLines = 0;
        [startView addSubview:label4];
        [label4 sizeToFit];
        
        label4.frame = CGRectMake((startView.frame.size.width - CGRectGetWidth(label4.frame))/2+6,
                                  CGRectGetMaxY(label3.frame)+10,
                                  label4.frame.size.width,
                                  label4.frame.size.height);
        
        UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        label5.backgroundColor = [UIColor clearColor];
        label5.font = [UIFont boldSystemFontOfSize:16];
        label5.text = @"选择号码归属地,晃动手机,幸运等着你";
        label5.textColor = [UIColor colorWithRed:39/255. green:205/255. blue:45/255. alpha:1];
        label5.numberOfLines = 0;
        [startView addSubview:label5];
        [label5 sizeToFit];
        
        label5.frame = CGRectMake((startView.frame.size.width - CGRectGetWidth(label5.frame))/2,
                                  CGRectGetMaxY(label4.frame)+20,
                                  label5.frame.size.width,
                                  label5.frame.size.height);

        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.backgroundColor = [UIColor clearColor];
        button.frame = CGRectMake((self.scrollView.frame.size.width - 197)/2,CGRectGetMaxY(label5.frame)+15, 197, 38);
        [button setBackgroundImage:[UIImage imageNamed:@"prettyNum_belongs_btn.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(phoneNumberBelongsAction) forControlEvents:UIControlEventTouchUpInside];
        [startView addSubview:button];
        self.cityButton = button;
        {
            UIImage *image = [UIImage imageNamed:@"prettyNum_arrow_icon.png"];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:
                                      CGRectMake(197-25,
                                                 (CGRectGetHeight(button.frame)-image.size.height)/2,
                                                 image.size.width,
                                                 image.size.height)];
            imageView.userInteractionEnabled = YES ;
            imageView.image = image ;
            [button addSubview:imageView];
        }
        
        CGRect rect = startView.frame;
        rect.size.height = CGRectGetMaxY(button.frame) + 20;
        startView.frame = rect;
        
        
        
    }
    
    startView.hidden = NO;
    UIView *endView = [[UIView alloc] initWithFrame:
                                            CGRectMake(0,
                                            CGRectGetMaxY(self.shakeImageView.frame)+30,
                                            self.scrollView.bounds.size.width,
                                            self.view.bounds.size.height - CGRectGetMaxY(self.shakeImageView.frame)+30)];
    endView.hidden = YES;
    endView.backgroundColor = [UIColor clearColor];
    self.shakeEndView = endView ;
    [self.scrollView addSubview:endView];
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.text = @"不喜欢?接着摇吧!";
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 0;
        [endView addSubview:label];
        [label sizeToFit];
        label.frame = CGRectMake((endView.frame.size.width - CGRectGetWidth(label.frame))/2,
                                 0,
                                 label.frame.size.width,
                                 label.frame.size.height);
        UIImage *image = [UIImage imageNamed:@"prettyNum_shakeResult_bg.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:
                                  CGRectMake((endView.frame.size.width-image.size.width)/2,
                                             CGRectGetMaxY(label.frame)+13,
                                             image.size.width,
                                             image.size.height)];
        self.bgImageView = imageView ;
        imageView.image = image ;
        [endView addSubview:imageView];
        {
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 0, 0)];
            label1.backgroundColor = [UIColor clearColor];
            label1.font = [UIFont boldSystemFontOfSize:15];
            label1.text = @"189 2214 4120";
            label1.textColor = [UIColor colorWithRed:39/255. green:205/255. blue:45/255. alpha:1];
            [imageView addSubview:label1];
            self.phoneNumLabel = label1 ;
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            label2.backgroundColor = [UIColor clearColor];
            label2.font = [UIFont boldSystemFontOfSize:13];
            label2.text = @"江苏 南京";
            label2.textColor = [UIColor blackColor];
            [imageView addSubview:label2];
            self.addressLabel = label2 ;
            
            UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            label3.backgroundColor = [UIColor clearColor];
            label3.font = [UIFont boldSystemFontOfSize:15];
            label3.text = @"预存话费1000元";
            label3.textColor = [UIColor blackColor];
            label3.numberOfLines = 0;
            [imageView addSubview:label3];
            
            self.saveMoneyLabel = label3;
            
            UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            label4.backgroundColor = [UIColor clearColor];
            label4.font = [UIFont boldSystemFontOfSize:15];
            label4.text = @"每月最低消费289元";
            label4.textColor = [UIColor blackColor];
            [imageView addSubview:label4];
            self.consumeLabel = label4 ;
            
            UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            label5.backgroundColor = [UIColor clearColor];
            label5.font = [UIFont boldSystemFontOfSize:13];
            label5.text = @"此号大吉, 适合白羊座,金牛座(仅供娱乐)";
            label5.textColor = [UIColor colorWithRed:39/255. green:205/255. blue:45/255. alpha:1];
            label5.numberOfLines = 0;
            label5.textAlignment = UITextAlignmentCenter ;
            [imageView addSubview:label5];
            self.funnyLabel = label5 ;
        }
        
        //加载的菊花
        UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(imageView.frame.origin.x -2, imageView.frame.origin.y-1, CGRectGetWidth(imageView.frame)+4, CGRectGetHeight(imageView.frame)+2)];
        loadingView.backgroundColor = [UIColor clearColor];
        loadingView.hidden = NO;
        [loadingView dwMakeRoundCornerWithRadius:10];
        [endView addSubview:loadingView];
        self.loadingView = loadingView ;
        {
            
            UIImageView *bgimageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 10, CGRectGetWidth(loadingView.frame)-100, CGRectGetHeight(loadingView.frame)-20)];
            bgimageView.backgroundColor = [UIColor blackColor];
            bgimageView.alpha = 0.7;
            [bgimageView dwMakeRoundCornerWithRadius:5];
            [loadingView addSubview:bgimageView];
            
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [activityView setFrame:CGRectMake(95, 15, 70, 70)];
            [activityView startAnimating];
            activityView.backgroundColor = [UIColor clearColor];
            [loadingView addSubview:activityView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 0, 0)];
            label.font = [UIFont systemFontOfSize:16];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"请稍候...";
            label.textColor = [UIColor whiteColor];
            label.numberOfLines = 0;
            [label sizeToFit];
            [loadingView addSubview:label];
            
            label.frame = CGRectMake((CGRectGetWidth(loadingView.frame)-CGRectGetWidth(label.frame))/2,
                                     75, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
            
        }
        
        
        UIImage *image1 = [UIImage imageNamed:@"prettyNum_shake_commit.png"];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setBackgroundImage:image1 forState:UIControlStateNormal];
        [button addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake((endView.frame.size.width - image1.size.width)/2,
                                  CGRectGetMaxY(imageView.frame)+20,
                                  image1.size.width,
                                  image1.size.height);
        [endView addSubview:button];
    }
    
    
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetMaxY(startView.frame));
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeCity:)
                                                 name:@"ShakeChangeCity"
                                               object:nil];
    self.shakeNum = 6;
    [self shakeFirstInPage]; //进来第一次摇动
    
    
    //再添加一次定位 不然会没有默认值。 默认为北京
    //再次判断是否存在归属地信息或者定位信息
    
    if (!self.selectedCity) {
        __weak __typeof(&*self)weakSelf = self;
        if (![CTHelperMap shareHelperMap].isSuccess) {
            [[CTHelperMap shareHelperMap] getAreaInfo:^(CTCity *city,NSError *error)
             {
                 __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                 if (!strongSelf) {
                     return;
                 }
                 if (city) {
                     strongSelf.selectedCity = city ;
                     NSString *cityName = city.cityname;
                     if ([cityName hasSuffix:@"市"]) {
                         cityName = [cityName substringToIndex:cityName.length-1];
                     }
                     [weakSelf.cityButton setTitle:cityName forState:UIControlStateNormal];
                 }
             }];
        }
        else{
            self.selectedCity = [CTHelperMap shareHelperMap].areaInfo ;
            NSString *cityName = self.selectedCity.cityname;
            if ([cityName hasSuffix:@"市"]) {
                cityName = [cityName substringToIndex:cityName.length-1];
            }
            [weakSelf.cityButton setTitle:cityName forState:UIControlStateNormal];
        }
    } else{
        NSString *cityName = self.selectedCity.cityname;
        if ([cityName hasSuffix:@"市"]) {
            cityName = [cityName substringToIndex:cityName.length-1];
        }
        [self.cityButton setTitle:cityName forState:UIControlStateNormal];
    }
    
    
    // 注册音频
    {
        // Get the full path of Sound12.aif
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Shake_Sound"
                                                              ofType:@"mp3"];
        // If this file is actually in the bundle...
        if (soundPath) {
            // Create a file URL with this path
            NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
            
            // Register sound file located at that URL as a system sound
            OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)(soundURL),
                                                            &_shake_cheers);
            if (err != kAudioServicesNoError)
                NSLog(@"Could not load %@, error code: %ld", soundURL, err);
        }
    }
}

#pragma mark - fun

// 线程检测手机摇动
- (void)initShake
{
    self.currentStatus = ShakeStatus_Ended ;
    
    [self.motionManager startAccelerometerUpdatesToQueue:self.operationQueue
                                         withHandler:^(CMAccelerometerData *latestAcc, NSError *error){
                                             dispatch_sync(dispatch_get_main_queue(), ^(void) {
                                                 // 所有操作进行同步
                                                 @synchronized(_motionManager) {
                                                     BOOL isNowShake = [self isShake:_motionManager.accelerometerData andIsStrong:NO];
                                                     NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
                                                     
                                                     switch (_currentStatus) {
                                                         case ShakeStatus_PrepareBegin:
                                                         {
                                                             //间隔时间每次有0.3s 再次检测有摇动 则认为摇动开始
                                                             //摇动间隔在0.3s内  且 加速度超过2
                                                             if (nowTime - _statusTime < StartBuff && isNowShake) {
                                                                 _currentStatus = ShakeStatus_Shaking;
                                                                 _statusTime = nowTime;
                                                                 if (!self.firstQry) {
                                                                     [self getRcdNumber];
                                                                     self.isAnimate = YES ;
                                                                     self.loadingView.hidden = YES ;
                                                                     self.isShakeBegin = YES;
                                                                 } else {
                                                                     if (self.phoneNumIndex < self.phoneNumArray.count) {
                                                                         self.isShakeBegin = YES;
                                                                         [self timer:1];
                                                                     } else {
                                                                         self.isShakeBegin = YES;
                                                                         [self getRcdNumber];
                                                                         [self timer:0];
                                                                     }
                                                                 }
                                                             } else if (nowTime - _statusTime > StartBuff && !isNowShake) {
                                                                 // 没有摇动超过0.3s 则认为摇动结束
                                                                 _currentStatus = ShakeStatus_Ended;
                                                                 _statusTime = 0.0;
                                                             }
                                                         }
                                                             break;
                                                             
                                                         case ShakeStatus_Shaking:
                                                         {
                                                             //在0.5s内没有摇动 则认为摇动结束
                                                             if (nowTime - _statusTime > EndBuf && !isNowShake) {
                                                                 _currentStatus = ShakeStatus_PrepareEnd;
                                                                 _statusTime = nowTime;
                                                             } else if (isNowShake) //仍然在摇动 继续停留ShakeStatus_Shaking
                                                                 _statusTime = nowTime;
                                                         }
                                                             break;
                                                             
                                                         case ShakeStatus_PrepareEnd:
                                                         {
                                                             //准备结束 此时判断网络请求是否结束
                                                             if (isNowShake && _isAnimate) {
                                                                 //仍在摇动 且 网络请求未结束 跳转到ShakeStatus_Shaking
                                                                 _currentStatus = ShakeStatus_Shaking;
                                                                 _statusTime = nowTime;
                                                             } else if (!_isAnimate) {  //网络请求结束
                                                                 _currentStatus = ShakeStatus_Ended;
                                                                 _statusTime = nowTime;
                                                             }
                                                         }
                                                             break;
                                                             
                                                         case ShakeStatus_Ended:
                                                         {
                                                             if (isNowShake && nowTime - _statusTime > WaitBuf) { //有摇动
                                                                 //判断此时是否超过2或者1.8的加速度 摇动开始
                                                                 if ([self isShake:_motionManager.accelerometerData
                                                                       andIsStrong:YES]) {
                                                                     _currentStatus = ShakeStatus_Shaking; //摇一摇开启

                                                                     if (!self.firstQry) {
                                                                         [self getRcdNumber];
                                                                         self.isAnimate = YES;
                                                                         self.loadingView.hidden = YES ;
//                                                                         [self timer:0];
                                                                         self.isShakeBegin = YES;
                                                                     } else {
                                                                         if (self.phoneNumIndex < self.phoneNumArray.count) {
                                                                             self.isShakeBegin = YES;
                                                                             [self timer:1];
                                                                         } else {
                                                                             self.isShakeBegin = YES;
                                                                             [self getRcdNumber];
                                                                             [self timer:0];
                                                                         }
                                                                     }
                                                         
                                                                 } else
                                                                     _currentStatus = ShakeStatus_PrepareBegin;
                                                                     _statusTime = nowTime; //摇动第一次的时候记录下时间
                                                             }
                                                         }
                                                             break;
                                                             
                                                         default:
                                                             break;
                                                     }
                                                 }
                                             });
                                         }];
    
}

- (void) timer : (int) type
{
    //定时3秒
    self.loadingView.hidden = NO ;
    self.isAnimate = YES;
    
     __weak __typeof(&*self)weakSelf = self;

    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (!weakSelf.firstQry) {
            if (type==0) { //网络请求  假如没有返回就一直等到超时
                // 先判断网络返回是否未成功还是失败
                if (weakSelf.isQrygetRcdNumber) {
                    if (weakSelf.isSuccessed) {   //网络返回成功
                        weakSelf.isQrygetRcdNumber = NO;
                        weakSelf.isAnimate = NO;            //释放摇动
                        weakSelf.loadingView.hidden = YES ;  //隐藏加载
                        weakSelf.isTimeOut = NO;             //超时设置
                        
                        AudioServicesPlaySystemSound(_shake_cheers);
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        
                        if (weakSelf.phoneNumIndex == 0 && weakSelf.phoneNumArray.count == 0 && self.pageIndex == 1) {
                            //显示没有数据的view
                        } else {
                            [weakSelf setShakeInfo:weakSelf.phoneNumArray[weakSelf.phoneNumIndex]];
                            weakSelf.phoneNumIndex ++;
                        }
                    } else {
                        AudioServicesPlaySystemSound(_shake_cheers);
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        
                        ToastAlertView *alert = [ToastAlertView new];
                        [alert showAlertMsg:@"没有找到您想要的号码，请再次尝试，或选择其他地区"];
                        weakSelf.loadingView.hidden = YES ;  //隐藏加载
                        weakSelf.isTimeOut = NO;
                        weakSelf.isAnimate = NO;
                        weakSelf.isQrygetRcdNumber = NO;
                        weakSelf.loadingView.hidden = YES;
                    }
                    
                } else {
                    //超时
                    weakSelf.isTimeOut = YES;
                }
                
            } else {
                AudioServicesPlaySystemSound(_shake_cheers);
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                
                weakSelf.isAnimate = NO ;
                weakSelf.loadingView.hidden = YES ;
                [weakSelf setShakeInfo:weakSelf.phoneNumArray[weakSelf.phoneNumIndex]];
                weakSelf.phoneNumIndex ++;
            }
            
        } else {
            
            if (type==0) { //网络请求  假如没有返回就一直等到超时
                // 先判断网络返回是否未成功还是失败
                if (weakSelf.isQrygetRcdNumber) {
                    if (weakSelf.isSuccessed) {   //网络返回成功
                        weakSelf.isQrygetRcdNumber = NO;
                        weakSelf.isAnimate = NO;            //释放摇动
                        weakSelf.loadingView.hidden = YES ;  //隐藏加载
                        weakSelf.isTimeOut = NO;             //超时设置
                        
                        AudioServicesPlaySystemSound(_shake_cheers);
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        
                        if (weakSelf.phoneNumIndex == 0 && weakSelf.phoneNumArray.count == 0 && self.pageIndex == 1) {
                            //显示没有数据的view
                        } else {
                            if (weakSelf.phoneNumArray.count>0) {
                                [weakSelf setShakeInfo:weakSelf.phoneNumArray[weakSelf.phoneNumIndex]];
                                weakSelf.phoneNumIndex ++;
                            }
                        }
                    } else {
                        
                        AudioServicesPlaySystemSound(_shake_cheers);
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        
                        ToastAlertView *alert = [ToastAlertView new];
                        [alert showAlertMsg:@"亲,没有摇到哦,再摇一次吧..."];
                        weakSelf.loadingView.hidden = YES ;  //隐藏加载
                        weakSelf.isTimeOut = NO;
                        weakSelf.isAnimate = NO;
                        weakSelf.isQrygetRcdNumber = NO;
                        weakSelf.loadingView.hidden = YES;
                    }
                    
                } else {
                    //超时
                    weakSelf.isTimeOut = YES;
                    
                }
            } else {
                AudioServicesPlaySystemSound(_shake_cheers);
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                
                weakSelf.isAnimate = NO ;
                weakSelf.loadingView.hidden = YES ;
                [weakSelf setShakeInfo:weakSelf.phoneNumArray[weakSelf.phoneNumIndex]];
                weakSelf.phoneNumIndex ++;
            }
        }
    
    });
}

- (void) shakeAnimation
{
    self.isAnimate = YES;
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         self.shakeImageView.transform = CGAffineTransformMakeRotation(30*M_PI/180);
                     }
                     completion:^(BOOL finish){
                         [UIView animateWithDuration:0.3
                                          animations:^(void){
                                              self.shakeImageView.transform = CGAffineTransformMakeRotation(0);
                                          }
                                          completion:^(BOOL finish){
                                              if (self.isQrygetRcdNumber && self.currentStatus != ShakeStatus_Shaking) {
                                                  self.isAnimate = NO;
                                                  
                                              }else{
                                                  [self shakeAnimation];
                                              }
                                          }];
                     }];
}

- (void) shakeFirstInPage
{
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         self.shakeImageView.transform = CGAffineTransformMakeRotation(30*M_PI/180);
                     }
                     completion:^(BOOL finish){
                         [UIView animateWithDuration:0.3
                                          animations:^(void){
                                              self.shakeImageView.transform = CGAffineTransformMakeRotation(0);
                                          }
                                          completion:^(BOOL finish){
                                              if (self.shakeNum == 0 || self.isShakeBegin == YES) {
                                                  
                                              }else{
                                                  self.shakeNum --;
                                                  [self shakeFirstInPage];
                                              }
                                          }];
                     }];
}

- (BOOL)isShake:(CMAccelerometerData *)newestAccel andIsStrong:(BOOL)strong
{
    // 上下升降不视作Shake，只有x或y中其中一个加速度大于2.0才立即视为Shake
    // x或y中其中一个加速度大于1.8，且在StartBuff时间内能触发2次，也视为Shake
    double cmpNum;
    
    if (strong)
        cmpNum = 2.0;
    else
        cmpNum = 1.8;
    
    if (ABS(newestAccel.acceleration.x) > cmpNum ||
        ABS(newestAccel.acceleration.y) > cmpNum)
        return YES;
    else
        return NO;
}

#pragma mark - netWork

- (void) getRcdNumber
{
    self.isQrygetRcdNumber = NO;
    
    NSString *ProvinceCode = self.selectedCity.provincecode ;//;
    NSString *AreaCode = self.selectedCity.citycode;//;
    NSString *ShopId = @"20004";
    NSString *PageIndex = [NSString stringWithFormat:@"%d",self.pageIndex];
    NSString *PageSize = @"20";
    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               ProvinceCode,@"ProvinceCode",
                               AreaCode,@"AreaCode",
                               ShopId,@"ShopId",
                               PageIndex,@"PageIndex",
                               PageSize,@"PageSize",
                               nil];
    if (!self.firstQry) {
        [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    }

    [MyAppDelegate.cserviceEngine
     postXMLWithCode:@"getRcdNumber"
     params:params
     onSucceeded:^(NSDictionary *dict) {
         DDLogInfo(@"%s--%@", __func__, dict.description);
         [SVProgressHUD dismiss];
         id Data = [dict objectForKey:@"Data"];
         //获取信息失败
         if (Data) {
             
             if (self.phoneNumArray && self.phoneNumArray.count>0) {
                 [self.phoneNumArray removeAllObjects];
             }
             
             self.phoneNumIndex = 0;
             id Items = [Data objectForKey:@"Items"];
             if ([Items isKindOfClass:[NSDictionary class]]) {
                 self.phoneInfo = Items ;
                 [self setShakeInfo:Items];
             } else if ([Items isKindOfClass:[NSArray class]]){
                 [self.phoneNumArray addObjectsFromArray:Items];
             }
             
             
             self.shakeStarView.hidden = YES;
             self.shakeEndView.hidden = NO ;
             
             if (!self.firstQry) {
                 //假如没有号码情况
                 if (self.pageIndex == 1 && self.phoneNumArray.count == 0) {
                     self.firstQry = NO;
                     self.shakeStarView.hidden = NO;
                     self.isAnimate = NO;
                     self.shakeEndView.hidden = YES ;
                     ToastAlertView *alert = [ToastAlertView new];
                     [alert showAlertMsg:@"没有找到您想要的号码，请再次尝试，或选择其他地区"];
                     
                     AudioServicesPlaySystemSound(_shake_cheers);
                     AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                     
                 } else {
                     
                     AudioServicesPlaySystemSound(_shake_cheers);
                     AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                     
                     self.firstQry = YES ;
                     self.isAnimate = NO;
                     [self setShakeInfo:self.phoneNumArray[self.phoneNumIndex]];
                     self.phoneNumIndex ++;
                     self.pageIndex++;
                 }
             } else {
                 if (self.isTimeOut) {  //超时
                     if (self.phoneNumIndex == 0 && self.phoneNumArray.count == 0) {
                         //提示没有号码
                         AudioServicesPlaySystemSound(_shake_cheers);
                         AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                         
                         self.pageIndex = 1;
                         [self getRcdNumber];
                     } else {
                         AudioServicesPlaySystemSound(_shake_cheers);
                         AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                         
                         self.isAnimate = YES;
                         self.isTimeOut = NO;
                         self.isSuccessed = NO ;
                         self.isQrygetRcdNumber = YES;
                         self.loadingView.hidden = YES ;
                         [self setShakeInfo:self.phoneNumArray[self.phoneNumIndex]];
                         self.phoneNumIndex ++;
                         self.pageIndex ++;
                     }
                 } else {
                     if (self.phoneNumIndex == 0 && self.phoneNumArray.count == 0) {
                         //提示没有号码
                         NSLog(@"没有号码了");
                         self.pageIndex = 1;
                         [self getRcdNumber];
                     } else {
                         self.isQrygetRcdNumber = YES;
                         self.isAnimate = NO;
                         self.phoneNumIndex = 0;
                         self.isSuccessed = YES ;
                         self.pageIndex ++;
                     }
                 }
             }
         }
     } onError:^(NSError *engineError) {
         DDLogInfo(@"%s--%@", __func__, engineError);
         [SVProgressHUD dismiss];
         if ([engineError.userInfo objectForKey:@"ResultCode"])
         {
             if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"X104"])
             {
                 // 取消掉全部请求和回调，避免出现多个弹框
                 [MyAppDelegate.cserviceEngine cancelAllOperations];
                 // 提示重新登录
                 SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                  andMessage:@"长时间未登录，请重新登录。"];
                 [alertView addButtonWithTitle:@"确定"
                                          type:SIAlertViewButtonTypeDefault
                                       handler:^(SIAlertView *alertView) {
                                           [MyAppDelegate showReloginVC];
                                           if (self.navigationController != nil)
                                           {
                                               [self.navigationController popViewControllerAnimated:NO];
                                           }
                                       }];
                 
                 alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                 [alertView show];
             }
         }
         else {
             if (!self.firstQry) {
                 self.firstQry = NO ;
                 ToastAlertView *alert = [ToastAlertView new];
                 [alert showAlertMsg:@"没有找到您想要的号码，请再次尝试，或选择其他地区"];
                 self.isAnimate = NO;
             } else {
                 if (self.isTimeOut) {
                     self.isAnimate = NO;
                     self.isTimeOut = NO;
                     self.isQrygetRcdNumber = YES;
                     self.loadingView.hidden = YES ;
                     
                     ToastAlertView *alert = [ToastAlertView new];
                     [alert showAlertMsg:@"亲,没有摇到哦，再摇一次吧..."];
                     self.isSuccessed = NO;
                 } else {
                     self.isQrygetRcdNumber = YES ;  //网路请求返回标志位
                     self.isSuccessed = NO ;
                     self.isAnimate = YES;
                 }
             }
         }
     }];
}

- (void) setShakeInfo : (NSDictionary *) dict
{
    NSMutableString *phone = [NSMutableString stringWithString:[dict objectForKey:@"PhoneNumber"]];
    [phone insertString:@" " atIndex:3];
    [phone insertString:@" " atIndex:8];
    self.phoneNumLabel.text = phone;
    self.phoneNumLabel.numberOfLines = 0 ;
    [self.phoneNumLabel sizeToFit];
    self.phoneNumLabel.frame = CGRectMake((self.bgImageView.frame.size.width - CGRectGetWidth(self.phoneNumLabel.frame))/2,
                              10,
                              self.phoneNumLabel.frame.size.width,
                              self.phoneNumLabel.frame.size.height);
    
    self.addressLabel.text = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"Province"],[dict objectForKey:@"City"]];
    self.addressLabel.numberOfLines = 0 ;
    [self.addressLabel sizeToFit];
    self.addressLabel.frame = CGRectMake((self.bgImageView.frame.size.width - CGRectGetWidth(self.addressLabel.frame))/2
                              ,
                              CGRectGetMaxY(self.phoneNumLabel.frame)+3,
                              self.addressLabel.frame.size.width,
                              self.addressLabel.frame.size.height);

    self.saveMoneyLabel.text = [NSString stringWithFormat:@"预存话费%@元",[dict objectForKey:@"PrepayMent"]];
    self.saveMoneyLabel.numberOfLines = 1;
    [self.saveMoneyLabel sizeToFit];
    self.saveMoneyLabel.frame = CGRectMake((self.bgImageView.frame.size.width - CGRectGetWidth(self.saveMoneyLabel.frame))/2,
                              CGRectGetMaxY(self.addressLabel.frame)+3,
                              self.saveMoneyLabel.frame.size.width,
                              self.saveMoneyLabel.frame.size.height);
    
    self.consumeLabel.text = [NSString stringWithFormat:@"每月最低消费%@元",[dict objectForKey:@"MinAmount"]];
    self.consumeLabel.numberOfLines = 1;
    [self.consumeLabel sizeToFit];
    self.consumeLabel.frame = CGRectMake((self.bgImageView.frame.size.width - CGRectGetWidth(self.consumeLabel.frame))/2+2,
                                           CGRectGetMaxY(self.saveMoneyLabel.frame)+3,
                                           self.consumeLabel.frame.size.width,
                                           self.consumeLabel.frame.size.height);

    if([[dict objectForKey:@"TipText"] isEqualToString:@"null"]){
        self.funnyLabel.text = [dict objectForKey:@"TipText"];
    } else {
        self.funnyLabel.text = @"";
    }
}

- (void) setViewFrame : (BOOL) isShow
{
    if(isShow)
    {
        self.shakeStarView.hidden = YES;
        self.endView.hidden = NO;
        
    } else {
        self.shakeStarView.hidden = NO;
        self.endView.hidden = YES;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    // 打开检测线程
    [self initShake];
    
    [super viewWillAppear:YES];
}

- (void) dealloc{
    [self.motionManager stopAccelerometerUpdates];
    AudioServicesDisposeSystemSoundID(_shake_cheers);
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    [self.motionManager stopAccelerometerUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (void) phoneNumberBelongsAction
{
    CTCitySelectedVCtler *vc = [CTCitySelectedVCtler new];
    vc.pageType = 1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) commitAction
{
    if (self.jumpType == 0) {
        if (self.phoneNumArray && self.phoneNumArray.count > self.phoneNumIndex ) {
//            CTPlanSelectVCtler *vc = [CTPlanSelectVCtler new];
            CTAddPackageVCtler *vc = [CTAddPackageVCtler new];
            NSDictionary *dictionary = [self.phoneNumArray objectAtIndex:self.phoneNumIndex -1];
            if (dictionary) {
                NSString *Status = dictionary[@"Status"];
                if ([Status isEqualToString:@"2"]) {
                    //保存信息
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:[self.selectedCity dictionaryRepresentation] forKey:CITYINFO];
                    [defaults synchronize];
                    vc.item = dictionary;
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    ToastAlertView *alert = [ToastAlertView new];
                    [alert showAlertMsg:@"您选的号码必定人人喜爱，已被人抢先一步，请重新选择一个号码。"];
                }
            }
        }
    } else {
//        if (self.phoneNumArray && self.phoneNumArray.count > self.phoneNumIndex ) {
//            NSArray *VCAry = self.navigationController.viewControllers ;
//            for (id vc in VCAry) {
//                if ([vc isKindOfClass:[CTSelectPhoneVCtler class]]) {
//                    CTSelectPhoneVCtler *vctler = vc;
//                    NSDictionary *dictionary = [self.phoneNumArray objectAtIndex:self.phoneNumIndex -1];
//                    CTPrettyNumData *data = [CTPrettyNumData modelObjectWithDictionary:dictionary];
//                    if (dictionary) {
//                        NSString *Status = dictionary[@"Status"];
//                        if ([Status isEqualToString:@"2"]) {
//                            //保存信息
//                            vctler.phoneData = data;
//                            [self.navigationController popToViewController:vctler animated:YES];
//                        } else {
//                            ToastAlertView *alert = [ToastAlertView new];
//                            [alert showAlertMsg:@"您选的号码必定人人喜爱，已被人抢先一步，请重新选择一个号码。"];
//                        }
//                    }
//                }
//            }
        
//        }
    }
}

- (void)onLeftBtnAction:(id)sender
{
     [self.navigationController popViewControllerAnimated:YES];
//    if (_jumpType == 0) {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    } else {
//        NSArray *array = [self.navigationController viewControllers];
//        BOOL isExt = NO;
//        for (id vc in array) {
//            if ([vc isKindOfClass:[CTSelectPhoneVCtler class]]) {
//                [self.navigationController popToViewController:vc animated:YES];
//                isExt = YES;
//            }
//        }
//        if (!isExt) {
//           
//        }
//    }
}

#pragma mark - notification

- (void) changeCity : (NSNotification *) notification
{
    CTCity *city = [notification object];
    self.selectedCity = city ;
    NSString *cityName = self.selectedCity.cityname;
    if ([cityName hasSuffix:@"市"]) {
        cityName = [cityName substringToIndex:cityName.length-1];
    }
    [self.cityButton setTitle:cityName forState:UIControlStateNormal];

}


@end
