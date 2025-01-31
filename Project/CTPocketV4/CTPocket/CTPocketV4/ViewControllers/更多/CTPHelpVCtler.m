//
//  CTPHelpVCtler.m
//  CTPocketv3
//
//  Created by lyh on 13-4-17.
//
//

#import "CTPHelpVCtler.h"
#import "UIView+RoundRect.h"

@implementation CTPHelpVCtler
{
    UIActivityIndicatorView *activeV;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setTitle:@"使用指南"];
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    CGSize mainSize = [UIScreen mainScreen].bounds.size;
    
    UIScrollView *scrollV = [[UIScrollView alloc]initWithFrame:
                             CGRectMake(0, 0, mainSize.width, mainSize.height-50)];
    scrollV.backgroundColor = RGB(240, 240, 240, 1);
    [self.view addSubview:scrollV];
    
    CGFloat webH = scrollV.frame.size.height;
    CGFloat webY = 0;
    if(isIOS7)
        webY = 20;
    
    webH -= 20;
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, webY, mainSize.width, webH)];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:SERVICE_Help]];
    [webView loadRequest:request];
    webView.delegate = self;
    [scrollV addSubview:webView];
    
    activeV = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat sw = 20;
    activeV.frame = CGRectMake((scrollV.frame.size.width-sw)/2, (scrollV.frame.size.height-sw)/2, sw, sw);
    [scrollV addSubview:activeV];
}

#pragma mark- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    if([url.absoluteString hasSuffix:@"back_to_app"])
    {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activeV startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activeV stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activeV stopAnimating];
}

@end
