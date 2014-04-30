//
//  CTPointExchangeVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-11-30.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//  积分兑换

#import "CTPointExchangeVCtler.h"
#import "SVProgressHUD.h"

@interface CTPointExchangeVCtler () <UIWebViewDelegate>
{
    UIWebView *     _webView;
    UIActivityIndicatorView * _activityviewInfo;
}

@end

@implementation CTPointExchangeVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // 标题
        self.title = @"积分兑换";
        // 左按钮
        [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        webView.delegate = (id<UIWebViewDelegate>)self;
        webView.backgroundColor = [UIColor whiteColor];
        webView.scalesPageToFit = YES;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://jf.189.cn/wap"]]];
        [self.view addSubview:webView];
        _webView = webView;
    }
    {
        UIActivityIndicatorView *activityview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityview.frame = CGRectMake(0, 0, 14, 14);
        activityview.center = _webView.center;
        activityview.hidesWhenStopped = YES;
        [self.view addSubview:activityview];
        _activityviewInfo = activityview;
    }
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
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

@end
