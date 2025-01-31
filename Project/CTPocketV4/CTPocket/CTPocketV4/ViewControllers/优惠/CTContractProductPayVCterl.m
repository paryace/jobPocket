//
//  CTContractProductPayVCterl.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 14-3-27.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTContractProductPayVCterl.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "CTContractPayDoneVCterl.h"

@interface CTContractProductPayVCterl ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *mWebView;
@property (nonatomic, strong) UIActivityIndicatorView *mAIView;
@end

@implementation CTContractProductPayVCterl

- (UIWebView *)mWebView
{
    if (!_mWebView) {
        _mWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _mWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _mWebView.backgroundColor = [UIColor whiteColor];
        _mWebView.scalesPageToFit = YES;
        _mWebView.delegate = self;
        [_mWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.payUrl]]];
    }
    return _mWebView;
}

- (UIActivityIndicatorView *)mAIView
{
    if (!_mAIView) {
        _mAIView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _mAIView.frame = CGRectMake(0, 0, 14, 14);
        _mAIView.center = self.mWebView.center;
        _mAIView.hidesWhenStopped = YES;
        [self.view addSubview:_mAIView];
    }
    return _mAIView;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 标题
    self.title = @"订单支付";
    
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    [self.view addSubview:self.mWebView];
}

#pragma mark - Nav

- (void)onLeftBtnAction:(id)sender
{

    [SVProgressHUD showWithStatus:@"查询订单状态中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSDictionary *params = @{@"UserId": ([[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] ? [[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] : @"bank888"),
                             @"OrderId": self.orderId};
    // 查询订单状态
    DDLogInfo(@"查询订单状态");
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrderInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict)
    {
                                          
          [SVProgressHUD dismiss];
          // OrderStatusCode
          // OrderStatusDescription
          CTContractPayDoneVCterl *vc = [[CTContractPayDoneVCterl alloc] init];
          vc.pOrderId = self.orderId;
          vc.pOrderStatusDescription = dict[@"Data"][@"OrderStatusDescription"];
          vc.pComboName = self.comboName;
          NSMutableDictionary *salesDict = [NSMutableDictionary dictionaryWithObject:self.salesProInfo forKey:@"item"]; //modified by shallow 2014-4-23
          //vc.info = self.info ;
          vc.info = salesDict;
          vc.salesProInfo = self.salesProInfo;
          [self.navigationController pushViewController:vc animated:YES];
          
      } onError:^(NSError *engineError) {
          
          [SVProgressHUD showErrorWithStatus:engineError.localizedDescription];
          
          if (engineError.userInfo[@"ResultCode"])
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
                                        }];
                  alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                  [alertView show];
              }
          }
      }];
    
    
}

#pragma mark
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.mAIView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.mAIView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.mAIView stopAnimating];
}


@end
