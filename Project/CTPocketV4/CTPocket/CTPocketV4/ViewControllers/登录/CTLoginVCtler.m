//
//  CTLoginVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-11-13.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//  登录

#import "CTLoginVCtler.h"
#import "Utils.h"
#import "SIAlertView.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "CTChangePasswordVCtler.h"
#import "ToastAlertView.h"
#import "CTDetailVCtler.h"
#import "CTMoreVCtler.h"
#import "CTRechargeVCtler.h"
#import "CTCity.h"

NSString * const tipTitle = @"小贴士：密码可点击“忘记密码”修改！";
NSString * const codeTipTitle = @"已发送随机密码到您的手机，请注意查收！";

@interface CTLoginVCtler () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *phoneTF;
@property (strong, nonatomic) UITextField *pwdTF;
@property (strong, nonatomic) UIButton *randomBtn;

@property (strong, nonatomic) UILabel *tipLabel;

@property (strong, nonatomic) UIImageView *autoLoginIcon;
@property (strong, nonatomic) UILabel *autoLoginLabel;
@property (strong, nonatomic) UIButton *autoLoginBtn;

@property (strong, nonatomic) UIImageView *forgetIcon;
@property (strong, nonatomic) UILabel *forgetLabel;
@property (strong, nonatomic) UIButton *forgetBtn;

@property (strong, nonatomic) UIImageView *switchModeIcon;
@property (strong, nonatomic) UILabel *switchModeLabel;
@property (strong, nonatomic) UIButton *switchModeBtn;

@property (assign, nonatomic) BOOL isSend;

@end

@implementation CTLoginVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.navigationItem.title = @"登录";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //统计插码
//    [TrackingHelper trackPageLoadedState:NSStringFromClass([self class])];
    
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    // 隐藏键盘按钮
    {
        UIButton *tBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tBtn.frame = self.view.bounds;
        tBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [tBtn addTarget:self action:@selector(hideAllKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:tBtn];
    }
    
    // 手机号
    {
        self.phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(30, 34, 260, 38)];
        self.phoneTF.backgroundColor = [UIColor whiteColor];
        self.phoneTF.placeholder = @"请输入电信手机号码";
        self.phoneTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.phoneTF.font = [UIFont systemFontOfSize:14.0f];
        self.phoneTF.borderStyle = UITextBorderStyleNone;
        self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, 21)];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 16, 21)];
            imageView.image = [UIImage imageNamed:@"login_icon1"];
            [view addSubview:imageView];
            self.phoneTF.leftView = view;
        }
        self.phoneTF.leftViewMode = UITextFieldViewModeAlways;
        self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
        if ([Utils getPhone]) {
            self.phoneTF.text = [Utils getPhone];
        }
        self.phoneTF.delegate = self;
        
        [self.view addSubview:self.phoneTF];
    }
    
    // 密码
    {
        self.pwdTF = [[UITextField alloc] initWithFrame:CGRectMake(30, 100, 260, 38)];
        self.pwdTF.backgroundColor = [UIColor whiteColor];
        self.pwdTF.placeholder = @"请输入密码";
        self.pwdTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.pwdTF.font = [UIFont systemFontOfSize:14.0f];
        //self.pwdTF.textColor
        self.pwdTF.borderStyle = UITextBorderStyleNone;
        self.pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.pwdTF.clearsOnBeginEditing = YES;
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, 21)];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 16, 21)];
            imageView.image = [UIImage imageNamed:@"login_icon2"];
            [view addSubview:imageView];
            self.pwdTF.leftView = view;
        }
        self.pwdTF.leftViewMode = UITextFieldViewModeAlways;
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 78, 38)];
            
            self.randomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.randomBtn.frame = view.bounds;
            [self.randomBtn setBackgroundImage:[UIImage imageNamed:@"login_green"] forState:UIControlStateNormal];
            [self.randomBtn setBackgroundImage:[UIImage imageNamed:@"login_gray"] forState:UIControlStateDisabled];
            self.randomBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            [self.randomBtn setTitle:@"获取随机码" forState:UIControlStateNormal];
            [self.randomBtn addTarget:self action:@selector(getRandomInfo) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:self.randomBtn];
            
            self.pwdTF.rightView = view;
        }
        self.pwdTF.rightViewMode = UITextFieldViewModeNever;
        self.pwdTF.keyboardType = UIKeyboardTypeASCIICapable;
        self.pwdTF.secureTextEntry = YES;
        self.pwdTF.returnKeyType = UIReturnKeyDone;
        if ([Utils getPwd]) {
            self.pwdTF.text = [Utils getPwd];
        }
        self.pwdTF.delegate = self;
        
        [self.view addSubview:self.pwdTF];
    }
    
    // 验证码提示语
    {
        self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 138+8, 260, 35)];
        self.tipLabel.backgroundColor = [UIColor clearColor];
        self.tipLabel.font = [UIFont systemFontOfSize:13.0f];
        self.tipLabel.textColor = RGB(238,104,86, 1);
        self.tipLabel.textAlignment = NSTextAlignmentLeft;
        self.tipLabel.text = tipTitle;
        [self.view addSubview:self.tipLabel];
        self.tipLabel.numberOfLines = 0;
    }
    
    // 自动登录
    {
        self.autoLoginIcon = [[UIImageView alloc] initWithFrame:CGRectMake(30, 188, 15, 14)];
        self.autoLoginIcon.image = [UIImage imageNamed:@"login_button1_selected"];
        [self.view addSubview:self.autoLoginIcon];
        
        self.autoLoginLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 188, 70, 14)];
        self.autoLoginLabel.backgroundColor = [UIColor clearColor];
        self.autoLoginLabel.font = [UIFont systemFontOfSize:13.0f];
        self.autoLoginLabel.textColor = [UIColor blackColor];
        self.autoLoginLabel.text = @"自动登录";
        [self.view addSubview:self.autoLoginLabel];
        
        self.autoLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.autoLoginBtn.frame = CGRectMake(30, 188, 72, 14);
        self.autoLoginBtn.selected = YES;
        [self.autoLoginBtn addTarget:self action:@selector(onAutoLoginAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.autoLoginBtn];
    }
    
    // 忘记密码
    {
        self.forgetIcon = [[UIImageView alloc] initWithFrame:CGRectMake(122, 188, 15, 14)];
        self.forgetIcon.image = [UIImage imageNamed:@"login_button2"];
        [self.view addSubview:self.forgetIcon];
        
        self.forgetLabel = [[UILabel alloc] initWithFrame:CGRectMake(142, 188, 70, 14)];
        self.forgetLabel.backgroundColor = [UIColor clearColor];
        self.forgetLabel.font = [UIFont systemFontOfSize:13.0f];
        self.forgetLabel.textColor = [UIColor blackColor];
        self.forgetLabel.text = @"忘记密码？";
        [self.view addSubview:self.forgetLabel];
        
        self.forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.forgetBtn.frame = CGRectMake(122, 188, 82, 14);
        [self.forgetBtn addTarget:self action:@selector(onForgetAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.forgetBtn];
    }
    
    // 切换密码、随机密码
    {
        self.switchModeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(215, 188, 15, 14)];
        self.switchModeIcon.image = [UIImage imageNamed:@"login_button3_mode2"];
        [self.view addSubview:self.switchModeIcon];
        
        self.switchModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 188, 70, 14)];
        self.switchModeLabel.backgroundColor = [UIColor clearColor];
        self.switchModeLabel.font = [UIFont systemFontOfSize:13.0f];
        self.switchModeLabel.textColor = [UIColor blackColor];
        self.switchModeLabel.text = @"随机密码";
        [self.view addSubview:self.switchModeLabel];
        
        self.switchModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.switchModeBtn.frame = CGRectMake(215, 188, 72, 14);
        self.switchModeBtn.selected = NO;
        [self.switchModeBtn addTarget:self action:@selector(onSwitchModeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.switchModeBtn];
    }
    
    // 登录按钮
    {
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        loginBtn.frame = CGRectMake(32, 240, 256, 42);
        [loginBtn setBackgroundImage:[UIImage imageNamed:@"login_button"] forState:UIControlStateNormal];
        [loginBtn setBackgroundImage:[UIImage imageNamed:@"login_button_hl"] forState:UIControlStateHighlighted];
        [loginBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
        [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [loginBtn addTarget:self action:@selector(onLoginAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginBtn];
    }
    
    // 灯泡icon
    UIImageView *lightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(30, 300, 35, 35)];
    lightIcon.image = [UIImage imageNamed:@"login_icon4"];
    [self.view addSubview:lightIcon];
    
    // 文字
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 300, 225, 35)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = [UIFont systemFontOfSize:13.0f];
    textLabel.textColor = [UIColor grayColor];
    textLabel.text = @"登录后即可查询流量及话费使用情况";
    [self.view addSubview:textLabel];
}

#pragma mark - Self Func

// 自动登录
- (void)onAutoLoginAction:(UIButton *)sender
{
    if (sender.selected == YES) {
        self.autoLoginIcon.image = [UIImage imageNamed:@"login_button1"];
        sender.selected = NO;
    }
    else
    {
        self.autoLoginIcon.image = [UIImage imageNamed:@"login_button1_selected"];
        sender.selected = YES;
    }
}

// 忘记密码
- (void)onForgetAction
{
    [self hideAllKeyboard];
    
    CTChangePasswordVCtler *vc = [[CTChangePasswordVCtler alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

// 切换密码、随机密码
- (void)onSwitchModeAction:(UIButton *)sender
{
    if (sender.selected == YES) {
        // 随机密码-->用户密码
        self.switchModeIcon.image = [UIImage imageNamed:@"login_button3_mode2"];
        self.switchModeLabel.text = @"随机密码";
        sender.selected = NO;
        
        self.pwdTF.placeholder = @"请输入密码";
        self.pwdTF.text = @"";
        self.pwdTF.rightViewMode = UITextFieldViewModeNever;
        self.pwdTF.keyboardType = UIKeyboardTypeASCIICapable;
        self.pwdTF.secureTextEntry = YES;
        if ([Utils getPwd]) {
            self.pwdTF.text = [Utils getPwd];
        }
        [self.pwdTF reloadInputViews];
        
        self.autoLoginBtn.enabled = YES;
        if (self.autoLoginBtn.selected == YES) {
            self.autoLoginIcon.image = [UIImage imageNamed:@"login_button1_selected"];
        }
        else
        {
            self.autoLoginIcon.image = [UIImage imageNamed:@"login_button1"];
        }
        self.autoLoginLabel.textColor = [UIColor blackColor];
        
        self.forgetBtn.enabled = YES;
        self.forgetIcon.image = [UIImage imageNamed:@"login_button2"];
        self.forgetLabel.textColor = [UIColor blackColor];
        self.tipLabel.text = tipTitle;
    }
    else
    {
        // 用户密码-->随机密码
        self.switchModeIcon.image = [UIImage imageNamed:@"login_button3_mode1"];
        self.switchModeLabel.text = @"用户密码";
        sender.selected = YES;
        
        self.pwdTF.placeholder = @"请输入随机密码";
        self.pwdTF.text = @"";
        self.pwdTF.rightViewMode = UITextFieldViewModeAlways;
        self.pwdTF.keyboardType = UIKeyboardTypeNumberPad;
        self.pwdTF.secureTextEntry = YES;
        [self.pwdTF reloadInputViews];
        
        self.autoLoginBtn.enabled = NO;
        self.autoLoginIcon.image = [UIImage imageNamed:@"login_button1_disable"];
        self.autoLoginLabel.textColor = [UIColor grayColor];
        
        self.forgetBtn.enabled = NO;
        self.forgetIcon.image = [UIImage imageNamed:@"login_button2_disable"];
        self.forgetLabel.textColor = [UIColor grayColor];
        if(!self.randomBtn.enabled)
            self.tipLabel.text = codeTipTitle;
    }
}

// 获取验证码
- (void)getRandomInfo
{
    // 手机号码错误
    if (self.phoneTF.text.length != 11 ||
        ![Utils isNumber:self.phoneTF.text]) {
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:@"手机号码是11位哦，请检查"];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  NSLog(@"确定");
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
        
        return;
    }
    
    // add by liuruxian
    //判断手机号是否为电信手机号码
    {
        
    }
    [self.pwdTF becomeFirstResponder];
    
    // 获取验证码
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.phoneTF.text, @"PhoneNbr",
                                @"2000004", @"AccountType", nil];
        
        [MyAppDelegate.cserviceEngine postXMLWithCode:@"getRandomInfo"
                                               params:params
                                          onSucceeded:^(NSDictionary *dict) {
                                              
                                              // 显示提示语
                                              self.tipLabel.text = codeTipTitle;
                                              
                                              self.isSend = YES;
                                              // 成功获取验证码，倒计时
                                              [self countDown:60];
                                              
                                          } onError:^(NSError *engineError) {
                                              
                                              [SVProgressHUD showErrorWithStatus:@"出错了，再试一次吧"];
                                              [self countDown:0];
                                              
                                          }];
    }
}

// 倒计时
- (void)countDown:(NSInteger)count
{
    if (count == 0) {
        self.randomBtn.enabled = YES;
        self.tipLabel.text = tipTitle;
    }
    else
    {
        self.randomBtn.enabled = NO;
        [self.randomBtn setTitle:[NSString stringWithFormat:@"%d", count] forState:UIControlStateDisabled];
        
        __weak id wSelf = self;
        // 延迟一秒执行的内容
        double delayInSeconds = 1.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on the main queue after delay
            [wSelf countDown:count - 1];
        });
    }
}

// 隐藏键盘
- (void)hideAllKeyboard
{
    [self.phoneTF resignFirstResponder];
    [self.pwdTF resignFirstResponder];
}

// 登录
- (void)onLoginAction
{
    if (self.switchModeBtn.selected == YES)
    {
        // 随机密码登录
        {
            // 手机号码错误
            if (self.phoneTF.text.length != 11 ||
                ![Utils isNumber:self.phoneTF.text]) {
                
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                 andMessage:@"手机号码是11位哦，请检查"];
                [alertView addButtonWithTitle:@"确定"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alertView) {
                                          NSLog(@"确定");
                                      }];
                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                [alertView show];
                
                return;
            }
            
            // 密码错误
            if (self.pwdTF.text.length == 0) {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                 andMessage:@"请输入随机密码！"];
                [alertView addButtonWithTitle:@"确定"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alertView) {
                                          NSLog(@"确定");
                                      }];
                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                [alertView show];
                
                return;
            }
            
            [self hideAllKeyboard];
            [SVProgressHUD showWithStatus:@"玩命登录中...请稍候" maskType:SVProgressHUDMaskTypeGradient];
            
            //__weak id weakSelf = self;
            __weak typeof(self)weakSelf = self; //修复登录崩溃 by shallow 2014-5-20 参见https://github.com/iwasrobbed/RPFloatingPlaceholders/issues/11
            
            NSString *DeviceToken = @"";
            NSUserDefaults *df  = [NSUserDefaults standardUserDefaults];
            if ([df objectForKey:@"devicetoken"])
            {
                DeviceToken = [df objectForKey:@"devicetoken"];
            }
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.phoneTF.text, @"PhoneNbr",
                                    self.pwdTF.text, @"PhonePsw",
                                    @"04", @"PswType",
                                    @"c2000004", @"AccountType",
                                    DeviceToken, @"DeviceToken", nil];
            
            [MyAppDelegate.cserviceEngine postXMLWithCode:@"loginInfo"
                                                   params:params
                                              onSucceeded:^(NSDictionary *dict) {
                                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                                  [SVProgressHUD dismiss];
                                                  
                                                  DDLogInfo(@"登录成功！");
                                                  [Global sharedInstance].loginInfoDict = @{@"UserLoginName": self.phoneTF.text,
                                                                                            @"Token": dict[@"Data"][@"Token"]};
                                                  [Global sharedInstance].isLogin = YES;
                                                  [MyAppDelegate custIdInfo];
                                                  [strongSelf dismissViewControllerAnimated:YES completion:^(void){
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadHomeView" object:nil];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMsg" object:nil];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:LOCATIONCURMSG object:nil];
                                                      //modified by gongxt 2014-06-12
                                                      if (MyAppDelegate.jumpInfo) //推送
                                                      {
                                                          [MyAppDelegate jumpPage:MyAppDelegate.jumpInfo];
                                                          MyAppDelegate.jumpInfo = nil;
                                                      }
                                                      //add by liuruxian 登录后自动跳转
                                                      if(self.isPush)
                                                      {
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"autoJumpPage" object:nil];
                                                          self.isPush = NO;
                                                      }
                                                      
                                                      // added by liuruxian 2014-06-19
                                                      if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(autoPushVCtler)]) {
                                                          [self.loginDelegate autoPushVCtler];
                                                      }
                                                      //modified by gongxt 2014-06-16
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccess
                                                                                                          object:nil];
                                                  }];
                                                  //add by liuruxian 2014-03-20
//                                                  [weakSelf loginEvtMeasure];
                                                  
                                              } onError:^(NSError *engineError) {
                                                  
                                                  [SVProgressHUD dismiss];
                                                  
                                                  if (engineError.userInfo[@"ResultCode"])
                                                  {
                                                      if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"8001"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8002"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8003"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8004"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8007"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8010"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8011"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8012"])
                                                      {
                                                          ToastAlertView *alert = [ToastAlertView new];
                                                          [alert showAlertMsg:@"系统繁忙，请稍后再试"];
                                                      }
                                                      else if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"8005"])
                                                      {
                                                          ToastAlertView *alert = [ToastAlertView new];
                                                          [alert showAlertMsg:@"您的密码过于简单啦，请重置密码后再登录吧"];
                                                      }
                                                      else if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"8006"])
                                                      {
                                                          ToastAlertView *alert = [ToastAlertView new];
                                                          [alert showAlertMsg:@"啊哦，您输入5次错误密码啦，请24小时后再试吧"];
                                                      }
                                                      else if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"8008"])
                                                      {
                                                          ToastAlertView *alert = [ToastAlertView new];
                                                          [alert showAlertMsg:@"亲，您输入的手机号码不存在哦"];
                                                      }
                                                      else if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"8009"])
                                                      {
                                                          ToastAlertView *alert = [ToastAlertView new];
                                                          [alert showAlertMsg:@"您输入密码错误啦，再试一次吧"];
                                                      }
                                                      else
                                                      {
                                                          SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                                           andMessage:engineError.localizedDescription];
                                                          [alertView addButtonWithTitle:@"确定"
                                                                                   type:SIAlertViewButtonTypeDefault
                                                                                handler:^(SIAlertView *alertView) {
                                                                                    NSLog(@"取消");
                                                                                }];
                                                          alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                          [alertView show];
                                                      }
                                                  }
                                                  else
                                                  {
                                                      SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                                       andMessage:engineError.localizedDescription];
                                                      [alertView addButtonWithTitle:@"确定"
                                                                               type:SIAlertViewButtonTypeDefault
                                                                            handler:^(SIAlertView *alertView) {
                                                                                NSLog(@"取消");
                                                                            }];
                                                      alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                      [alertView show];
                                                  }
                                              }];
        }
    }
    else
    {
        // 用户密码登录
        {
            // 手机号码错误
            if (self.phoneTF.text.length != 11 ||
                ![Utils isNumber:self.phoneTF.text]) {
                
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                 andMessage:@"手机号码是11位哦，请检查"];
                [alertView addButtonWithTitle:@"确定"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alertView) {
                                          NSLog(@"确定");
                                      }];
                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                [alertView show];
                
                return;
            }
            
            // 密码错误
            if (self.pwdTF.text.length == 0) {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                 andMessage:@"亲，别忘记填写密码"];
                [alertView addButtonWithTitle:@"确定"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alertView) {
                                          NSLog(@"确定");
                                      }];
                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                [alertView show];
                
                return;
            }
            
            //add by liuruxian
            
            [self hideAllKeyboard];
            [SVProgressHUD showWithStatus:@"玩命登录中...请稍候" maskType:SVProgressHUDMaskTypeGradient];
            
            //__weak id weakSelf = self;
            __weak typeof(self)weakSelf = self;
            
            NSString *DeviceToken = @"";
            NSUserDefaults *df  = [NSUserDefaults standardUserDefaults];
            if ([df objectForKey:@"devicetoken"])
            {
                DeviceToken = [df objectForKey:@"devicetoken"];
            }
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.phoneTF.text, @"PhoneNbr",
                                    self.pwdTF.text, @"PhonePsw",
                                    @"01", @"PswType",
                                    @"c2000004", @"AccountType",
                                    DeviceToken, @"DeviceToken", nil];
            
            [MyAppDelegate.cserviceEngine postXMLWithCode:@"loginInfo"
                                                   params:params
                                              onSucceeded:^(NSDictionary *dict) {
                                                  
                                                  
                                                  __strong typeof(weakSelf)strongSelf = weakSelf;
                                       
                                                  
                                                  [SVProgressHUD dismiss];
                                                  
                                                  DDLogInfo(@"登录成功！");
                                                  [Utils savePhone:self.phoneTF.text andPwd:self.pwdTF.text];
                                                  if (self.autoLoginBtn.selected == YES) {
                                                      
                                                      // 保存自动登录标志
                                                      NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
                                                      [settings setObject:@"YES" forKey:@"AutoLogin"];
                                                      [settings synchronize];
                                                  }
                                                  else
                                                  {
                                                      NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
                                                      [settings setObject:@"NO" forKey:@"AutoLogin"];
                                                      [settings synchronize];
                                                  }
                                                  [Global sharedInstance].loginInfoDict = @{@"UserLoginName": self.phoneTF.text,
                                                                                            @"Token": dict[@"Data"][@"Token"]};
                                                  [Global sharedInstance].isLogin = YES;
                                                  [MyAppDelegate custIdInfo];
                                                  [strongSelf dismissViewControllerAnimated:YES completion:^(void){
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadHomeView" object:nil];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMsg" object:nil];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:LOCATIONCURMSG object:nil];
                                                      //modified by gongxt 2014-06-12
                                                      if (MyAppDelegate.jumpInfo)
                                                      {
                                                          [MyAppDelegate jumpPage:MyAppDelegate.jumpInfo];
                                                          MyAppDelegate.jumpInfo = nil;
                                                      }
                                                      //add by liuruxian 登录后自动跳转
                                                      if(self.isPush)
                                                      {
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"autoJumpPage" object:nil];
                                                          self.isPush = NO;
                                                      }
                                                      
                                                      // added by liuruxian 2014-06-19
                                                      if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(autoPushVCtler)]) {
                                                          [self.loginDelegate autoPushVCtler];
                                                      }
                                                      
                                                      // added by zy, 2014-02-17
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccess
                                                                                                          object:nil];
                                                      
                                                      //added by huangfq 2014-6-27
                                                      [strongSelf getLocationByphoneNbrInfo];
                                                  }];
                                                  //add by liuruxian 2014-03-20
//                                                  [weakSelf loginEvtMeasure];
                                                  
                                              } onError:^(NSError *engineError) {
                                                  
                                                  [SVProgressHUD dismiss];
                                                  
                                                  if (engineError.userInfo[@"ResultCode"])
                                                  {
                                                      if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"8002"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8003"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8004"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8007"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8010"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8011"] ||
                                                          [engineError.userInfo[@"ResultCode"] isEqualToString:@"8012"])
                                                      {
                                                          ToastAlertView *alert = [ToastAlertView new];
                                                          [alert showAlertMsg:@"系统繁忙，请稍后再试"];
                                                      }
                                                      else if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"8005"])
                                                      {
                                                          ToastAlertView *alert = [ToastAlertView new];
                                                          [alert showAlertMsg:@"您的密码过于简单啦，请重置密码后再登录吧"];
                                                      }
                                                      else if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"8006"])
                                                      {
                                                          ToastAlertView *alert = [ToastAlertView new];
                                                          [alert showAlertMsg:@"啊哦，您输入5次错误密码啦，请24小时后再试吧"];
                                                      }
                                                      else if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"8008"])
                                                      {
                                                          ToastAlertView *alert = [ToastAlertView new];
                                                          [alert showAlertMsg:@"亲，您输入的手机号码不存在哦"];
                                                      }
                                                      else if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"8009"])
                                                      {
                                                          ToastAlertView *alert = [ToastAlertView new];
                                                          [alert showAlertMsg:@"您输入密码错误啦，再试一次吧"];
                                                      }
                                                      else
                                                      {
                                                          SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                                           andMessage:engineError.localizedDescription];
                                                          [alertView addButtonWithTitle:@"确定"
                                                                                   type:SIAlertViewButtonTypeDefault
                                                                                handler:^(SIAlertView *alertView) {
                                                                                    NSLog(@"取消");
                                                                                }];
                                                          alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                          [alertView show];
                                                      }
                                                  }
                                                  else
                                                  {
                                                      SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                                       andMessage:engineError.localizedDescription];
                                                      [alertView addButtonWithTitle:@"确定"
                                                                               type:SIAlertViewButtonTypeDefault
                                                                            handler:^(SIAlertView *alertView) {
                                                                                NSLog(@"取消");
                                                                            }];
                                                      alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                      [alertView show];
                                                  }
                                              }];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==self.phoneTF && range.location>=11) {
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.pwdTF) {
        [self onLoginAction];
    }
    
    return YES;
}

#pragma mark - Nav

- (void)onLeftBtnAction:(id)sender
{
    [self hideAllKeyboard];
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

////登录事件收集及埋点 add by liuruxian 2014-03-20
//- (void)loginEvtMeasure
//{
//    //用户账号：eVar11="用户账号";    //如手机号码
//    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
//    if (loginInfoDict) {
//        NSString *phoneNbr = loginInfoDict[@"UserLoginName"];
//        
//        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//        
//        // 跟踪登录相关事件
//        NSMutableDictionary *evtDic = [[NSMutableDictionary alloc] init];
//        if (phoneNbr) {
//            [evtDic setObject:phoneNbr forKey:@"11"];
//            [evtDic setObject:app_Version forKey:@"12"];
//            [evtDic setObject:@"LOGIN" forKey:@"13"];
//        }
//        
//        [TrackingHelper trackPage:NSStringFromClass([self class]) events:evtDic];
//    }
//}

#pragma mark - NetRequest
- (void) getLocationByphoneNbrInfo
{
    //用户归属地查询
    NSString *PhoneNbr = [Global sharedInstance].loginInfoDict [@"UserLoginName"];
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               PhoneNbr, @"PhoneNbr",
                               nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"getLocationByphoneNbrInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          DDLogInfo(@"%s--%@", __func__, dict.description);
                                          id Data = [dict objectForKey:@"Data"];
                                          if (Data) {
                                              
                                              NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                          [Data objectForKey:@"ProvinceCode"],@"provincecode",
                                                                          [Data objectForKey:@"CityCode"],@"citycode",
                                                                          [Data objectForKey:@"City"],@"cityname",
                                                                          @"",@"hbcitycode",
                                                                          @"",@"hbprovincecode",
                                                                          @"",@"citynameAlph",
                                                                          [Data objectForKey:@"Province"],@"provincename",
                                                                          nil];
                                              
                                              CTCity *city = [CTCity modelObjectWithDictionary:dictionary];
                                              [Global sharedInstance].areaInfo = city;
                                              
                                          }
                                      } onError:^(NSError *engineError) {
                                          
                                          
                                    }];

}


@end
