//
//  CTPPointExchangeVCtler.m
//  CTPocketv3
//
//  Created by apple on 13-4-27.
//
//

#import "CTPPointExchangeVCtler.h"
//#import "CTPTabBar.h"
//#import "CTPNavBar.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "CTContractPayDoneVCterl.h"
#import "SIAlertView.h"

@interface CTPPointExchangeVCtler ()

@end

@implementation CTPPointExchangeVCtler

@synthesize jumpUrl;
@synthesize fullScreen;
@synthesize isLogoTitle;
@synthesize needBack2Rootview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.fullScreen = NO;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.fullScreen = NO;
    }
    return self;
}

- (void)dealloc
{
    [_webView stopLoading];
    [_webView setDelegate:nil];
    self.jumpUrl = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    {
        self.title = ([self.title length] ? self.title : @"积分兑换");
        [self setLeftButton:[UIImage imageNamed:@"btn_back_recharge.png"]];
        {
        }
        if (self.isLogoTitle)
        {
            self.title = @"";
            UIButton * logobtn      = [UIButton buttonWithType:UIButtonTypeCustom];
            logobtn.frame           = CGRectInset(self.navigationController.navigationBar.bounds, 60, 0);
            logobtn.userInteractionEnabled = NO;
            UIImage * img           = [UIImage imageNamed:@"telecom-logo.png"];
            [logobtn setImage:img forState:UIControlStateNormal];
            [logobtn setImageEdgeInsets:UIEdgeInsetsMake((CGRectGetHeight(logobtn.frame) - img.size.height)/2, 10, (CGRectGetHeight(logobtn.frame) - img.size.height)/2, (CGRectGetWidth(logobtn.frame) - img.size.width) - 10)];
            [logobtn setTitle:@"掌上营业厅" forState:UIControlStateNormal];
            [logobtn setTitleColor:[UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1] forState:UIControlStateNormal];
            [logobtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
            [self.navigationController.navigationItem.titleView addSubview:logobtn];
            
        }
    }
    
    {
        UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        webView.delegate = (id<UIWebViewDelegate>)self;
        webView.backgroundColor = [UIColor whiteColor];
        webView.scalesPageToFit = YES; 
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:([self.jumpUrl length] ? self.jumpUrl : @"http://jf.189.cn/wap")]]];
        [self.view addSubview:webView];
        _webView = webView;
        [webView release];
    }
    
    {
        UIActivityIndicatorView * activityview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityview.frame = CGRectMake(0, 0, 14, 14);
        activityview.center = _webView.center;
        activityview.hidesWhenStopped = YES;
        [self.view addSubview:activityview];
        _activityviewInfo = activityview;
        [activityview release];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [_webView stopLoading];
    _webView = nil;
    _activityviewInfo = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - CTPNavBarDelegate
- (void) onLeftBtnAction:(id)sender
{
    [_webView stopLoading];
    if (!self.needBack2Rootview)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        
//        [self.navigationController popToRootViewControllerAnimated:YES];
        // 哈哈，这里是要添加百搭的一个需求了，订单确认？yes:no
//        [self.navigationController popToRootViewControllerAnimated:YES];
        [self queryOrderId];
    }
}

#pragma mark - 查询订单
- (void)queryOrderId
{
    
    [SVProgressHUD showWithStatus:@"查询订单状态中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSDictionary *params = @{@"UserId": ([[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] ? [[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] : @"bank888"),
                             @"OrderId": self.orderId};
    // 查询订单状态
    DDLogInfo(@"查询订单状态");
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrderInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
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
    [_activityviewInfo startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activityviewInfo stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activityviewInfo stopAnimating];
}
@end
