//
//  CTPointConfirmExchangeVCtler.m
//  CTPocketV4
//
//  Created by Y W on 14-3-11.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTPointConfirmExchangeVCtler.h"

#import "ThreeSubView.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"

#import "UIColor+Category.h"
#import "UIImage+Category.h"

#import "IgUserInfo.h"
#import "IgRndCode.h"
#import "IgCreateOrder.h"
#import "IgPay.h"
#import "Global.h"

#import "CTExchangeSucessVCtler.h"

@interface CTPointConfirmExchangeVCtler () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger timerSecs;

@property (nonatomic, assign) NSUInteger commodityCount;
@property (nonatomic, strong) NSString *RndCode;
@property (nonatomic, strong) ThreeSubView *countControlThreeSubView;
@property (nonatomic, strong) ThreeSubView *countThreeSubView;
@property (nonatomic, strong) ThreeSubView *rndCodeThreeSubView;
@property (nonatomic, strong) UITextField *verificationTextField;
@property (nonatomic, strong) UILabel *noticeLabel;
@property (nonatomic, strong) ThreeSubView *totalPriceThreeSubView;
@property (nonatomic, strong) UIButton *exchangeButton;

@property (nonatomic, strong) IgRndCode *igRndCodeNetworking;
@property (nonatomic, strong) IgCreateOrder *igCreateOrderNetworking;
@property (nonatomic, strong) IgPay *igPayNetworking;

@end

@implementation CTPointConfirmExchangeVCtler

- (id)init
{
    self = [super init];
    if (self) {
        self.commodityCount = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"确认兑换";
    
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *DeviceNo = loginInfoDict[@"UserLoginName"];
    
    int yOffset = 10;
    {
        ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, yOffset, 0, 26) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        threeSubView.backgroundColor = self.view.backgroundColor;
        
        [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [threeSubView.leftButton setTitle:@" " forState:UIControlStateNormal];
        [threeSubView.leftButton setBackgroundColor:[UIColor colorWithR:95 G:189 B:42 A:1]];
        
        [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
        [threeSubView.centerButton setTitle:[NSString stringWithFormat:@" 用户名：%@  积分：", DeviceNo] forState:UIControlStateNormal];
        
        [threeSubView.rightButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [threeSubView.rightButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
        [threeSubView.rightButton setTitle:[NSString stringWithFormat:@"%d", self.Integral] forState:UIControlStateNormal];
        
        [threeSubView autoLayout];
        
        [self.view addSubview:threeSubView];
        
        self.countThreeSubView = threeSubView;
        
        yOffset = CGRectGetMaxY(threeSubView.frame) + 10;
    }
    
    int xOffset = 20;
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset, 110, 110)];
        imageView.backgroundColor = self.view.backgroundColor;
        imageView.image = [UIImage imageNamed:@"CommodityListDefault"];
        NSString *PicUrl = [self.commodityInfo objectForKey:@"PicUrl"];
        if (PicUrl.length > 0) {
            [imageView setImageWithURL:[NSURL URLWithString:PicUrl] placeholderImage:[UIImage imageNamed:@"CommodityListDefault"]];
        }
        [self.view addSubview:imageView];
        
        xOffset = CGRectGetMaxX(imageView.frame) + xOffset;
    }
    /**
    yOffset += 10;
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, CGRectGetWidth(self.view.frame) - xOffset - 20, 15)];
        label.backgroundColor = self.view.backgroundColor;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
        label.text = [self.commodityInfo objectForKey:@"CommodityName"];
        [self.view addSubview:label];
        
        yOffset = CGRectGetMaxY(label.frame) + 8;
    }
    */
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, CGRectGetWidth(self.view.frame) - xOffset - 8, 63)];
        label.backgroundColor = self.view.backgroundColor;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
        label.text = [self.commodityInfo objectForKey:@"CommodityName"];
        label.numberOfLines=3;
        [self.view addSubview:label];
        
        yOffset = CGRectGetMaxY(label.frame) + 8;
    }
    
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, CGRectGetWidth(self.view.frame) - xOffset - 20, 15)];
        label.backgroundColor = self.view.backgroundColor;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
        label.text = [NSString stringWithFormat:@"单价：%@分", [self.commodityInfo objectForKey:@"IntegralPrice"]];
        [self.view addSubview:label];
    }
    
    xOffset = 20;
    yOffset = 180;
    if (!iPhone5) {
        yOffset -= 15;
    }
    
    {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = self.view.backgroundColor;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
        label.text = @"兑换数量： ";
        CGSize size = [label.text sizeWithFont:label.font];
        CGRect rect = CGRectZero;
        rect.origin = CGPointMake(xOffset, yOffset);
        rect.size.width = size.width;
        rect.size.height = 30;
        label.frame = rect;
        [self.view addSubview:label];
        
        xOffset = CGRectGetMaxX(rect);
    }
    
    int price = [[self.commodityInfo objectForKey:@"IntegralPrice"] floatValue];
    {
         __weak typeof(self) weakSelf = self;
         ThreeSubView *threeSubView = [[ThreeSubView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)
                                                   leftButtonSelectBlock:^{
                                                       __strong typeof(weakSelf) strongSelf = weakSelf;
                                                       if (strongSelf.commodityCount - 1 > 0) {
                                                           strongSelf.commodityCount -= 1;
                                                           [strongSelf refreshView];
                                                       }
                                                   }
                                                 centerButtonSelectBlock:^{
                                                     
                                                 }
                                                  rightButtonSelectBlock:^{
                                                      __strong typeof(weakSelf) strongSelf = weakSelf;
                                                      if (1|| (strongSelf.commodityCount + 1) * price <= strongSelf.Integral) {
                                                          //此处不再屏蔽
                                                          strongSelf.commodityCount += 1;
                                                          [strongSelf refreshView];
                                                      }
                                                  }];
//        [threeSubView setLeftButtonSelectBlock:^{
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            if (strongSelf.commodityCount - 1 > 0) {
//                strongSelf.commodityCount -= 1;
//                [strongSelf refreshView];
//            }
//        } centerButtonSelectBlock:nil
//          rightButtonSelectBlock:^{
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            if (1|| (strongSelf.commodityCount + 1) * price <= strongSelf.Integral) { //此处不再屏蔽
//                strongSelf.commodityCount += 1;
//                [strongSelf refreshView];
//            }
//        }];
        
        
        threeSubView.backgroundColor = self.view.backgroundColor;
        
        [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [threeSubView.leftButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
        [threeSubView.leftButton setTitle:@"   —   " forState:UIControlStateNormal];
        [threeSubView.leftButton setBackgroundImage:[UIImage imageNamed:@"PointQuery_Button_1"] forState:UIControlStateNormal];
        [threeSubView.leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 5, 0)];
        
        [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
        [threeSubView.centerButton setTitle:[NSString stringWithFormat:@"      %d     ", self.commodityCount] forState:UIControlStateNormal];
        [threeSubView.centerButton setBackgroundImage:[UIImage imageNamed:@"PointQuery_Button_2"] forState:UIControlStateNormal];
        threeSubView.centerButton.adjustsImageWhenHighlighted = NO;
        
        [threeSubView.rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [threeSubView.rightButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
        [threeSubView.rightButton setTitle:@"   +   " forState:UIControlStateNormal];
        [threeSubView.rightButton setBackgroundImage:[UIImage imageNamed:@"PointQuery_Button_3"] forState:UIControlStateNormal];
        [threeSubView.rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 5, 0)];
        
        [threeSubView autoLayout];
        
        CGRect rect = threeSubView.frame;
        rect.origin = CGPointMake(xOffset, yOffset);
        threeSubView.frame = rect;
        
        [self.view addSubview:threeSubView];
        self.countThreeSubView = threeSubView;
        yOffset = CGRectGetMaxY(rect) + 8;
    }
    
    xOffset = 20;
    {
        // 分割线
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, self.view.bounds.size.width - 2 * xOffset, 1)];
        separator.backgroundColor = [UIColor colorWithRed:0.84f green:0.84f blue:0.84f alpha:1.00f];
        [self.view addSubview:separator];
        
        yOffset = CGRectGetMaxY(separator.frame) + 10;
    }
    
    {
        __weak typeof(self) weakSelf = self;
        ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xOffset, yOffset, 0, 40)
                                                   leftButtonSelectBlock:nil centerButtonSelectBlock:^{
            
        } rightButtonSelectBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf sendVerificationCodeAction];
        }];
        threeSubView.backgroundColor = self.view.backgroundColor;
        
        [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [threeSubView.leftButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
        [threeSubView.leftButton setTitle:@"手机验证码 " forState:UIControlStateNormal];
        
        [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [threeSubView.centerButton setTitle:@"                         " forState:UIControlStateNormal];
        [threeSubView.centerButton setBackgroundColor:[UIColor whiteColor]];
        
        [threeSubView.rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [threeSubView.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [threeSubView.rightButton setTitle:@" 获取验证码 " forState:UIControlStateNormal];
        [threeSubView.rightButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:95 G:189 B:42 A:1] cornerRadius:1] forState:UIControlStateNormal];
        [threeSubView.rightButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] cornerRadius:1] forState:UIControlStateDisabled];
        
        [threeSubView autoLayout];
        
        [self.view addSubview:threeSubView];
        
        self.rndCodeThreeSubView = threeSubView;
        
        yOffset = CGRectGetMaxY(threeSubView.frame) + 10;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:threeSubView.centerButton.bounds];
        textField.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
        textField.font = [UIFont systemFontOfSize:15];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation ; // modified by shallow 2014-5-12
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        {
            UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, CGRectGetHeight(textField.frame))];
            mView.backgroundColor = [UIColor clearColor];
            textField.leftView = mView;
            textField.leftViewMode = UITextFieldViewModeAlways;
        }
        [threeSubView.centerButton addSubview:textField];
        
        self.verificationTextField = textField;
    }
    
    if (!iPhone5) {
        yOffset -= 3;
    }
    
    {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = self.view.backgroundColor;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithR:234 G:99 B:85 A:1];
        label.text = @"已发送验证码到你手机，请注意查收短信";
        CGSize size = [label.text sizeWithFont:label.font];
        CGRect rect = CGRectZero;
        rect.origin = CGPointMake(ceilf((CGRectGetWidth(self.view.frame) - size.width)/2.0), yOffset);
        rect.size = size;
        label.frame = rect;
        [self.view addSubview:label];
        
        label.hidden = YES;
        
        self.noticeLabel = label;
        
        yOffset = CGRectGetMaxY(label.frame) + 10;
    }
    
    if (!iPhone5) {
        yOffset -= 2;
    }
    
    xOffset = 150;
    {
        ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xOffset, yOffset, 0, 20) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        threeSubView.backgroundColor = self.view.backgroundColor;
        
        [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [threeSubView.leftButton setTitle:@"使用积分：" forState:UIControlStateNormal];
        [threeSubView.leftButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1]  forState:UIControlStateNormal];
        
        [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [threeSubView.centerButton setTitleColor:[UIColor colorWithR:232 G:66 B:50 A:1] forState:UIControlStateNormal];
        [threeSubView.centerButton setTitle:[NSString stringWithFormat:@"%d", self.commodityCount * price] forState:UIControlStateNormal];
        
        [threeSubView.rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [threeSubView.rightButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
        [threeSubView.rightButton setTitle:@"分" forState:UIControlStateNormal];
        
        [threeSubView autoLayout];
        
        CGRect rect = threeSubView.frame;
        rect.origin.x = ceilf((CGRectGetWidth(self.view.frame) - rect.size.width)/2.0);
        threeSubView.frame = rect;
        
        [self.view addSubview:threeSubView];
        
        self.totalPriceThreeSubView = threeSubView;
        yOffset = CGRectGetMaxY(threeSubView.frame) + 30;
    }
    
    xOffset = 20;
    {
        if (!iPhone5) {
            yOffset -= 20;
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.frame = CGRectMake(xOffset, yOffset, CGRectGetWidth(self.view.frame) - 2 * xOffset, 40);
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:95 G:189 B:42 A:1] cornerRadius:5] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor darkGrayColor] cornerRadius:5] forState:UIControlStateDisabled];
        [button setTitle:@"确认兑换" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [button addTarget:self action:@selector(igCreateOrder) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        self.exchangeButton = button;
    }
    
    {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
}

#pragma mark - funcs

- (void)refreshView
{
    int price = [[self.commodityInfo objectForKey:@"IntegralPrice"] floatValue];
    
    NSString *title = [NSString stringWithFormat:@"    %d    ", self.commodityCount];
//    [self.countControlThreeSubView.centerButton setTitle:title forState:UIControlStateDisabled];
    [self.countThreeSubView.centerButton setTitle:title forState:UIControlStateNormal];
    
    if (self.commodityCount * price > self.Integral) {
        [self.totalPriceThreeSubView.leftButton setTitle:@"亲，你还需要" forState:UIControlStateNormal];
        [self.totalPriceThreeSubView.rightButton setTitle:@"积分即可兑换此宝贝了喔！" forState:UIControlStateNormal];
        title = [NSString stringWithFormat:@"%d", self.commodityCount * price - self.Integral];
        [self.totalPriceThreeSubView.centerButton setTitle:title forState:UIControlStateDisabled];
        
        [self.exchangeButton setBackgroundImage:[UIImage imageNamed:@"spot_exchange_disable"] forState:UIControlStateNormal];
//        self.exchangeButton.enabled = NO;
        self.exchangeButton.userInteractionEnabled=NO;
    } else {
        [self.totalPriceThreeSubView.leftButton setTitle:@"使用积分：" forState:UIControlStateNormal];
        [self.totalPriceThreeSubView.rightButton setTitle:@"分" forState:UIControlStateNormal];
        title = [NSString stringWithFormat:@"%d", self.commodityCount * price];
        [self.totalPriceThreeSubView.centerButton setTitle:title forState:UIControlStateDisabled];
        
        
        [self.exchangeButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:95 G:189 B:42 A:1] cornerRadius:5] forState:UIControlStateNormal];
        [self.exchangeButton setBackgroundImage:[UIImage imageWithColor:[UIColor darkGrayColor] cornerRadius:5] forState:UIControlStateDisabled];
//        self.exchangeButton.enabled = YES;
        self.exchangeButton.userInteractionEnabled=YES;
    }
    
    [self.totalPriceThreeSubView autoLayout];
    CGRect rect = self.totalPriceThreeSubView.frame;
    rect.origin.x = ceilf((CGRectGetWidth(self.view.frame) - rect.size.width)/2.0);
    self.totalPriceThreeSubView.frame = rect;
}

- (void)startTimer
{
    self.timerSecs = 60;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (self.timerSecs >= 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.timerSecs == 0)
                {
                    self.rndCodeThreeSubView.rightButton.enabled = YES;
                    self.noticeLabel.hidden = YES;
                } else {
                    self.rndCodeThreeSubView.rightButton.enabled = NO;
                    [self.rndCodeThreeSubView.rightButton setTitle:[NSString stringWithFormat:@"%d", self.timerSecs] forState:UIControlStateDisabled];
                }
            });
            
            sleep(1);
            
            self.timerSecs -= 1;
        }
    });
}

- (void)sendVerificationCodeAction
{
//    [self.verificationTextField resignFirstResponder];
    [self sendVerificationCode];
     [self.verificationTextField becomeFirstResponder];
}

- (void)endEditing
{
    [self.view endEditing:YES];
}


#pragma mark - networking

- (void)checkError:(NSError *)error
{
    if (error.userInfo[@"ResultCode"])
    {
        if ([error.userInfo[@"ResultCode"] isEqualToString:@"X104"])
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
        } else {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                             andMessage:[error localizedDescription]];
            [alertView addButtonWithTitle:@"确定"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:nil];
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            [alertView show];
        }
    } else{
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:error.localizedDescription];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
//        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}

- (void)sendVerificationCode
{
    if (self.igRndCodeNetworking == nil) {
        self.igRndCodeNetworking = [[IgRndCode alloc] init];
    } else {
        [self.igRndCodeNetworking cancel];
    }
    
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *DeviceNo = loginInfoDict[@"UserLoginName"];
    
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeGradient];
    __weak typeof(self) weakSelf = self;
    [self.igRndCodeNetworking igRndCodeWithDeviceNo:DeviceNo finishBlock:^(NSDictionary *resultParams, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        if (error) {
            [strongSelf checkError:error];
            return;
        }
        
        strongSelf.noticeLabel.hidden = NO;
        
        [strongSelf startTimer];
    }];
}

- (void)igCreateOrder
{
    self.RndCode = [self.verificationTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.RndCode.length == 0) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:@"别忘记填写验证码~"];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:nil];
        [alertView show];
        return;
    }
    
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    __block NSString *DeviceNo = loginInfoDict[@"UserLoginName"];
    
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeGradient];
    __weak typeof(self) weakSelf = self;
    [[IgUserInfo shareIgUserInfo] igUserInfoWithDeviceNo:DeviceNo finishBlock:^(NSDictionary *resultParams, NSError *error) {
        
        __weak typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf checkError:error];
            [SVProgressHUD dismiss];
            return;
        }

        NSDictionary *data = resultParams[@"Data"];
        NSString *CustId = [data objectForKey:@"CustId"];
        if (CustId) {
            if (strongSelf.igCreateOrderNetworking == nil) {
                strongSelf.igCreateOrderNetworking = [[IgCreateOrder alloc] init];
            } else {
                [strongSelf.igCreateOrderNetworking cancel];
            }
            NSString *CommodityId = [strongSelf.commodityInfo objectForKey:@"CommodityID"];
            CGFloat IntegralPrice = [[strongSelf.commodityInfo objectForKey:@"IntegralPrice"] floatValue];
            NSString *totalPrice = [NSString stringWithFormat:@"%d", (int)IntegralPrice * strongSelf.commodityCount];
            [strongSelf.igCreateOrderNetworking igCreateOrderWithCustId:CustId DeviceNo:DeviceNo CommodityId:CommodityId BuyNum:strongSelf.commodityCount PayVoucher:@"0" PayIntegral:totalPrice finishBlock:^(NSDictionary *resultParams, NSError *error) {
                if (error) {
                    [strongSelf checkError:error];
                    [SVProgressHUD dismiss];
                    return;
                }
                NSDictionary *data = resultParams[@"Data"];
                [strongSelf igPayWithOrderId:[data objectForKey:@"OrderId"]];
            }];
        } else {
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)igPayWithOrderId:(NSString *)OrderId
{
    if (self.igPayNetworking == nil) {
        self.igPayNetworking = [[IgPay alloc] init];
    } else {
        [self.igPayNetworking cancel];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.igPayNetworking igPayWithOrderId:OrderId RndCode:self.RndCode finishBlock:^(NSDictionary *resultParams, NSError *error) {
        [SVProgressHUD dismiss];
        __weak typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf checkError:error];
            return;
        }
        
        // add by liuruxian 2014-03-19
        CGFloat IntegralPrice = [[strongSelf.commodityInfo objectForKey:@"IntegralPrice"] floatValue];//单个商品积分价格
        NSString *SmallCategoryName = [strongSelf.commodityInfo objectForKey:@"CommodityName"]; //名称
        NSString *totalPoints = [NSString stringWithFormat:@"%d", (int)IntegralPrice * strongSelf.commodityCount];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    totalPoints,@"totalPoints" ,
                                    SmallCategoryName,@"CommodityName",
                                    [NSNumber numberWithUnsignedInteger:strongSelf.commodityCount], @"commodityCount",
                                    nil];
        
        CTExchangeSucessVCtler *vc = [[CTExchangeSucessVCtler alloc] init];
        vc.infoDict = dictionary;
        [strongSelf.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!iPhone5) {
        CGRect rect = self.view.frame;
        rect.origin.y -= 115;
        [UIView animateWithDuration:0.25 animations:^{
            self.view.frame = rect;
        }];
    } else {
        CGRect rect = self.view.frame;
        rect.origin.y -= 15;
        [UIView animateWithDuration:0.25 animations:^{
            self.view.frame = rect;
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!iPhone5) {
        CGRect rect = self.view.frame;
        rect.origin.y += 115;
        [UIView animateWithDuration:0.25 animations:^{
            self.view.frame = rect;
        }];
    } else {
        CGRect rect = self.view.frame;
        rect.origin.y += 15;
        [UIView animateWithDuration:0.25 animations:^{
            self.view.frame = rect;
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.countThreeSubView.superview];
    if (CGRectContainsPoint(self.countThreeSubView.frame, point)
        || CGRectContainsPoint(self.rndCodeThreeSubView.frame, point)
        || CGRectContainsPoint(self.exchangeButton.frame, point)) {
        
        return NO;
    }
    return YES;
}

@end



