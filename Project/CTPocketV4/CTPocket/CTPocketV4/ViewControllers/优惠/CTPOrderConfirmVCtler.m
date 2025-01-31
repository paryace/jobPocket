//
//  OrderConfirmVCtler.m
//  CTPocketv3
//
//  Created by apple on 13-6-4.
//
//

#import "CTPOrderConfirmVCtler.h"
#import "AppDelegate.h"
#import "NSDataAdditions.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "CTPNewAddrVCtler.h"
#import "CTPInvoiceInfoVCtler.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "CserviceOperation.h"
#import "SVProgressHUD.h"
#import "UIView+RoundRect.h"
#import "CTPPointExchangeVCtler.h"
#import "ToastAlertView.h"
#import "CTLoginVCtler.h"
#import "SIAlertView.h"
#import "CTOrderRechargeVCtler.h"

@interface CTPOrderConfirmVCtler ()

@property (strong, nonatomic) CserviceOperation *orderOpt;
@property (strong, nonatomic) NSString *orderId;

- (void)resetUI;
- (void)onProductBtn:(id)sender;
- (void)onAddrinfoBtn:(id)sender;
- (void)onInvoiceinfoBtn:(id)sender;
- (void)onConfirmBtn:(id)sender;
- (void)submitOrder;

- (void)onNotificationAddrinfo:(NSNotification *)sender;
- (void)onNotificationModifyinfo:(NSNotification *)sender;
- (void)onNotificationLogin:(NSNotification *)sender;

@property (strong, nonatomic) NSString *comboName;
@property (nonatomic, strong) NSDictionary *salesProInfo; // 哈哈，新需求 shallow 2014.5.8

@end

@implementation CTPOrderConfirmVCtler

@synthesize DeliveryInfo;
@synthesize InvoiceInfo;
@synthesize CustomerInfo;
@synthesize salesProductInfoDict;
@synthesize orderInfoDict;
@synthesize ContractInfo;
@synthesize PackageInfoDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        if (!((AppDelegate *)[UIApplication sharedApplication].delegate).mainVctler.isTabbarHidden)
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:CTP_MSG_HIDE_TABBAR object:nil];
//        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationAddrinfo:) name:CTP_MSG_MODIFY_ADDR_INFO object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationModifyinfo:) name:CTP_MSG_MODIFY_INVOICE_INFO object:nil];
//        self.needGoHomeView = NO;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
    self.DeliveryInfo = nil;
    self.InvoiceInfo = nil;
    self.CustomerInfo = nil;
    self.ContractInfo = nil;
    self.salesProductInfoDict = nil;
    self.orderInfoDict = nil;
    self.PackageInfoDict = nil;
    
    if (self.orderOpt) {
        [self.orderOpt cancel];
        self.orderOpt = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"提交订单";
    [self setLeftButton:[UIImage imageNamed:@"btn_back_recharge.png"]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    {
        UIImage * img = [UIImage imageNamed:@"huidi.png"];
        UIImageView * bgview = [[UIImageView alloc] initWithImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)]];
         bgview.frame = CGRectMake(10, 0, CGRectGetWidth(self.view.frame) - 20, CGRectGetHeight(self.view.frame) -15-49 - 40);
        [self.view addSubview:bgview];
        
        UIScrollView * scrollview = [[UIScrollView alloc] initWithFrame:CGRectInset(bgview.frame, 5, 5)];
        scrollview.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scrollview];
        _contentScroll = scrollview;
        
        [scrollview release];
        [bgview release];
    }
    [self resetUI];
    
    NSLog(@"salesProductInfoDict %@",self.salesProductInfoDict);
    NSLog(@"orderInfoDict %@",self.orderInfoDict);
    NSLog(@"DeliveryInfo %@",self.DeliveryInfo);
    NSLog(@"InvoiceInfo %@",self.InvoiceInfo);
    NSLog(@"CustomerInfo %@",self.CustomerInfo);
    NSLog(@"ContractInfo %@",self.ContractInfo);
    NSLog(@"PackageInfoDict %@",self.PackageInfoDict);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _contentScroll = nil;
    _confirmBtn = nil;
    _activityviewInfo = nil;
    _addrBtn = nil;
    _invoiceBtn = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark - CTPNavBarDelegate
-(void)onleftBtnAction:(id)sender
{
//    [_netSubmit cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark private
- (void)resetUI
{
    for (UIView * v in _contentScroll.subviews)
    {
        [v removeFromSuperview];
    }
    
    int originX = 10;
    int originY = 10;
    
    {
        // 商品信息
        UIButton * bgbtn            = [UIButton buttonWithType:UIButtonTypeCustom];
        bgbtn.frame                 = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame), 0);
        [bgbtn addTarget:self action:@selector(onProductBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_contentScroll addSubview:bgbtn];

        {
            // 图片
            originY = 0;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0 , originY, 50, 50)];
            imageView.userInteractionEnabled = YES;
            [imageView dwMakeRoundCornerWithRadius:5];
            [bgbtn addSubview:imageView];
            if ([[self.salesProductInfoDict objectForKey:@"IconUrl"] isKindOfClass:[NSString class]] &&
                [[self.salesProductInfoDict objectForKey:@"IconUrl"] length])
            {
                NSURL *url = [NSURL URLWithString:[self.salesProductInfoDict objectForKey:@"IconUrl"]];
                [imageView setImageWithURL:url];
            }
            originX = CGRectGetMaxX(imageView.frame) + 10;
        }
        
        {
            // 商品描述 
            UILabel * lab           = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(bgbtn.frame) - originX - 30, 32)];
            lab.backgroundColor     = [UIColor clearColor];
            lab.textColor           = [UIColor colorWithRed:64/255. green:64/255. blue:64/255. alpha:1];
            lab.font                = [UIFont systemFontOfSize:14];
            lab.textAlignment       = UITextAlignmentLeft;
            lab.numberOfLines       = 0;
            
            NSMutableString * text  = [NSMutableString string];
            if ([[self.salesProductInfoDict objectForKey:@"Name"] isKindOfClass:[NSString class]] &&
                [[self.salesProductInfoDict objectForKey:@"Name"] length])
            {
                [text appendFormat:@"产品: %@", [self.salesProductInfoDict objectForKey:@"Name"]];
            }
            
            if ([[self.ContractInfo objectForKey:@"discription"] isKindOfClass:[NSString class]] &&
                [[self.ContractInfo objectForKey:@"discription"] length])
            {
                [text appendFormat:@"\n合约: %@", [self.ContractInfo objectForKey:@"discription"]];
            }
            
            if ([[self.PackageInfoDict objectForKey:@"ContractName"] isKindOfClass:[NSString class]] &&
                [[self.PackageInfoDict objectForKey:@"ContractName"] length])
            {
                [text appendFormat:@"\n套餐: %@", [self.PackageInfoDict objectForKey:@"ContractName"]];
                self.comboName = [self.PackageInfoDict objectForKey:@"ContractName"];
            }
            if ([[self.CustomerInfo objectForKey:@"Phone_Number"] isKindOfClass:[NSString class]] &&
                [[self.CustomerInfo objectForKey:@"Phone_Number"] length])
            {
                [text appendFormat:@"\n号码: %@", [self.CustomerInfo objectForKey:@"Phone_Number"]];
            }
            lab.text                = text;
            [lab sizeToFit];
            lab.frame               = CGRectMake(CGRectGetMinX(lab.frame), CGRectGetMinY(lab.frame), CGRectGetWidth(lab.frame), MAX(18, CGRectGetHeight(lab.frame)));
            [bgbtn addSubview:lab];
            originY                 += MAX(50, CGRectGetHeight(lab.frame)) + 10;
            [lab release];
            
            bgbtn.frame               = CGRectMake(CGRectGetMinX(bgbtn.frame), CGRectGetMinY(bgbtn.frame), CGRectGetWidth(bgbtn.frame), originY);
        }
        
#if 0
        {
            UIImageView * arrowimg  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_arrow.png"]];
            arrowimg.frame          = CGRectMake(CGRectGetWidth(bgbtn.frame) - 30, (50 - 13)/2, 12, 13);
            [bgbtn addSubview:arrowimg];
            [arrowimg release];
        }
#endif
        
        originX     = 0;
        originY     = CGRectGetMaxY(bgbtn.frame);
        {
            UIImage * img       = [UIImage imageNamed:@"query_fengexian.png"];
            UIImageView * lineview = [[UIImageView alloc] initWithImage:img];
            lineview.frame      = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - 2*originX, 1);
            lineview.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1];
            [_contentScroll addSubview:lineview];
            originY             = CGRectGetMaxY(lineview.frame) + 10;
            [lineview release];
        }
    }
    
    {
        originX     = 10;
        // 收货地址信息
        UIButton * bgbtn            = [UIButton buttonWithType:UIButtonTypeCustom];
        bgbtn.frame                 = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame), 0);
        [_contentScroll addSubview:bgbtn];

        {
            // 地址信息
            originY     = 0;
            UILabel * lab           = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, CGRectGetWidth(bgbtn.frame) - 30, 18)];
            lab.backgroundColor     = [UIColor clearColor];
            lab.textColor           = [UIColor colorWithRed:64/255. green:64/255. blue:64/255. alpha:1];
            lab.font                = [UIFont systemFontOfSize:14];
            lab.textAlignment       = UITextAlignmentLeft;
            lab.numberOfLines       = 0;
            
            NSMutableString * text  = [NSMutableString string];
            if (![self.DeliveryInfo count])
            {
                [text appendString:@"您还没有创建收货人信息"];
            }
            else
            {
                [text appendString:@"收货人信息: "];
                NSString * UserName = [self.DeliveryInfo objectForKey:@"UserName"] ? [self.DeliveryInfo objectForKey:@"UserName"] : @"";
                NSString * CusMobile = [self.DeliveryInfo objectForKey:@"CusMobile"] ? [self.DeliveryInfo objectForKey:@"CusMobile"] : @"";
                NSString * ProvinceName = [self.DeliveryInfo objectForKey:@"ProvinceName"] ? [self.DeliveryInfo objectForKey:@"ProvinceName"] : @"";
                NSString * CityName = [self.DeliveryInfo objectForKey:@"CityName"] ? [self.DeliveryInfo objectForKey:@"CityName"] : @"";
                NSString * CountyName = [self.DeliveryInfo objectForKey:@"CountyName"] ? [self.DeliveryInfo objectForKey:@"CountyName"] : @"";
                NSString * Address  = [self.DeliveryInfo objectForKey:@"Address"] ? [self.DeliveryInfo objectForKey:@"Address"] : @"";
                if ([UserName length] && [CusMobile length])
                {
                    [text appendFormat:@"\n%@ , %@", UserName, CusMobile];
                }
                if ([ProvinceName length])
                {
                    [text appendFormat:@"\n%@", ProvinceName];
                    if ([CityName length])
                    {
                        [text appendFormat:@", %@", CityName];
                        if ([CountyName length])
                        {
                            [text appendFormat:@", %@", CountyName];
                        }
                    }
                }
                if ([Address length])
                {
                    [text appendFormat:@"\n%@", Address];
                }
            }
            
            lab.text                = text;
            [lab sizeToFit];
            lab.frame               = CGRectMake(CGRectGetMinX(lab.frame), CGRectGetMinY(lab.frame), CGRectGetWidth(lab.frame), MAX(18, CGRectGetHeight(lab.frame)));
            [bgbtn addSubview:lab];
            originY                 += CGRectGetHeight(lab.frame) + 10;
            [lab release];
            
            bgbtn.frame               = CGRectMake(CGRectGetMinX(bgbtn.frame), CGRectGetMinY(bgbtn.frame), CGRectGetWidth(bgbtn.frame), originY);
        }
        
        {
            UIImageView * arrowimg  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_arrow.png"]];
            arrowimg.frame          = CGRectMake(CGRectGetWidth(bgbtn.frame) - 30, (originY - 13 - 10)/2, 12, 13);
            [bgbtn addSubview:arrowimg];
            
            {
                UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame           = CGRectInset(arrowimg.frame, -30, -20);
                [btn addTarget:self action:@selector(onAddrinfoBtn:) forControlEvents:UIControlEventTouchUpInside];
                [bgbtn addSubview:btn];
                _addrBtn            = btn;
            }
            [arrowimg release];
        }
        
        originX     = 0;
        originY     = CGRectGetMaxY(bgbtn.frame);
        {
            UIImage * img       = [UIImage imageNamed:@"query_fengexian.png"];
            UIImageView * lineview = [[UIImageView alloc] initWithImage:img];
            lineview.frame      = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - 2*originX, 1);
            lineview.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1];
            [_contentScroll addSubview:lineview];
            originY             = CGRectGetMaxY(lineview.frame) + 10;
            [lineview release];
        }
    }
    
    {
        originX     = 10;
        // 发票信息
        UIButton * bgbtn            = [UIButton buttonWithType:UIButtonTypeCustom];
        bgbtn.frame                 = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame), 0);
        [_contentScroll addSubview:bgbtn];
        
        {
            originY     = 0;
            UILabel * lab           = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, CGRectGetWidth(bgbtn.frame) - 30, 18)];
            lab.backgroundColor     = [UIColor clearColor];
            lab.textColor           = [UIColor colorWithRed:64/255. green:64/255. blue:64/255. alpha:1];
            lab.font                = [UIFont systemFontOfSize:14];
            lab.textAlignment       = UITextAlignmentLeft;
            lab.numberOfLines       = 0;
            
            NSMutableString * text  = [NSMutableString string];
            [text appendString:@"发票信息 "];
            [text appendString:@"\n发票类型: 普通发票"];
            
            NSString * aInvoiceInfo = [self.InvoiceInfo objectForKey:@"InvoiceInfoType"] ? [self.InvoiceInfo objectForKey:@"InvoiceInfoType"] : @"";
            if ([aInvoiceInfo intValue] == 0)
            {
                aInvoiceInfo = @"个人";
            }
            else if ([aInvoiceInfo intValue] == 1)
            {
                aInvoiceInfo = @"单位";
            }
            
            NSString * InvoiceContentType  = [self.InvoiceInfo objectForKey:@"InvoiceContentType"] ? [self.InvoiceInfo objectForKey:@"InvoiceContentType"] : @"";
            if ([InvoiceContentType intValue] == 0)
            {
                InvoiceContentType = @"通信器材";
            }
            else if ([InvoiceContentType intValue] == 1)
            {
                InvoiceContentType = @"商品明细";
            }
            
            if ([aInvoiceInfo length])
            {
                [text appendFormat:@"\n发票抬头: %@", aInvoiceInfo];
            }
            if ([InvoiceContentType length])
            {
                [text appendFormat:@"\n发票内容: %@", InvoiceContentType];
            }
            lab.text                = text;
            [lab sizeToFit];
            lab.frame               = CGRectMake(CGRectGetMinX(lab.frame), CGRectGetMinY(lab.frame), CGRectGetWidth(lab.frame), MAX(18, CGRectGetHeight(lab.frame)));
            [bgbtn addSubview:lab];
            originY                 += CGRectGetHeight(lab.frame) + 10;
            [lab release];
            
            bgbtn.frame               = CGRectMake(CGRectGetMinX(bgbtn.frame), CGRectGetMinY(bgbtn.frame), CGRectGetWidth(bgbtn.frame), originY);
        }
        
        {
            UIImageView * arrowimg  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_arrow.png"]];
            arrowimg.frame          = CGRectMake(CGRectGetWidth(bgbtn.frame) - 30, (originY - 13 - 10)/2, 12, 13);
            [bgbtn addSubview:arrowimg];
            
            {
                UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame           = CGRectInset(arrowimg.frame, -30, -20);
                [btn addTarget:self action:@selector(onInvoiceinfoBtn:) forControlEvents:UIControlEventTouchUpInside];
                [bgbtn addSubview:btn];
                _invoiceBtn         = btn;
            }
            [arrowimg release];
        }
        
        originX     = 0;
        originY     = CGRectGetMaxY(bgbtn.frame);
        {
            UIImage * img       = [UIImage imageNamed:@"query_fengexian.png"];
            UIImageView * lineview = [[UIImageView alloc] initWithImage:img];
            lineview.frame      = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - 2*originX, 1);
            lineview.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1];
            [_contentScroll addSubview:lineview];
            originY             = CGRectGetMaxY(lineview.frame) + 10;
            [lineview release];
        }
    }
    
    {
        originX     = 10;
        // 商品金额
        {
            UILabel * lab           = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - 30, 18)];
            lab.backgroundColor     = [UIColor clearColor];
            lab.textColor           = [UIColor colorWithRed:64/255. green:64/255. blue:64/255. alpha:1];
            lab.font                = [UIFont systemFontOfSize:14];
            lab.textAlignment       = UITextAlignmentLeft;
            lab.text                = @"订单金额";
            [_contentScroll addSubview:lab];
            [lab release];
            
            {
                UILabel * lab           = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - 30, 18)];
                lab.backgroundColor     = [UIColor clearColor];
                lab.textColor           = [UIColor colorWithRed:64/255. green:64/255. blue:64/255. alpha:1];
                lab.font                = [UIFont systemFontOfSize:14];
                lab.textAlignment       = UITextAlignmentRight;
                lab.text                = [self.orderInfoDict objectForKey:@"TotalPrice"] ? [NSString stringWithFormat:@"%@元", [self.orderInfoDict objectForKey:@"TotalPrice"]] : @"";
                [_contentScroll addSubview:lab];
                originY                 += CGRectGetHeight(lab.frame) + 5;
                [lab release];
            }
        }
        
        // 运费  删掉
#if 0
        {
            UILabel * lab           = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - 30, 18)];
            lab.backgroundColor     = [UIColor clearColor];
            lab.textColor           = [UIColor colorWithRed:64/255. green:64/255. blue:64/255. alpha:1];
            lab.font                = [UIFont systemFontOfSize:14];
            lab.textAlignment       = UITextAlignmentLeft;
            lab.text                = @"运费";
            [_contentScroll addSubview:lab];
            [lab release];
            
            {
                UILabel * lab           = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - 30, 18)];
                lab.backgroundColor     = [UIColor clearColor];
                lab.textColor           = [UIColor colorWithRed:64/255. green:64/255. blue:64/255. alpha:1];
                lab.font                = [UIFont systemFontOfSize:14];
                lab.textAlignment       = UITextAlignmentRight;
                lab.text                = @"5元";
                [_contentScroll addSubview:lab];
                originY                 += CGRectGetHeight(lab.frame) + 10;
                [lab release];
            }
        }
        
        {
            originX     = 0;
            UIImage * img       = [UIImage imageNamed:@"query_fengexian.png"];
            UIImageView * lineview = [[UIImageView alloc] initWithImage:img];
            lineview.frame      = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - 2*originX, 1);
            lineview.backgroundColor = kRGBUIColor(235, 235, 235, 1);
            [_contentScroll addSubview:lineview];
            originY             = CGRectGetMaxY(lineview.frame) + 10;
            [lineview release];
        }
#endif
    }
    
    {
        originX     = 10;
        // 应付总额  删掉
#if 0
        {
            UILabel * lab           = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - 30, 34)];
            lab.backgroundColor     = [UIColor clearColor];
            lab.textColor           = [UIColor blackColor];
            lab.font                = [UIFont systemFontOfSize:16];
            lab.textAlignment       = UITextAlignmentLeft;
            lab.text                = @"应付总额 : 100元";
            [_contentScroll addSubview:lab];
            [lab release];
        }
#endif
        
        // 确认付款
        {
            UIImage * img       = [UIImage imageNamed:@"query_btn.png"];
            UIImage * himg      = [UIImage imageNamed:@"query_btn_highlight.png"];
            UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame           = CGRectMake(30, originY + 15, CGRectGetWidth(_contentScroll.frame) - 60, 44);
            [btn setBackgroundImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)] forState:UIControlStateNormal];
            [btn setBackgroundImage:[himg resizableImageWithCapInsets:UIEdgeInsetsMake(himg.size.height/2, himg.size.width/2, himg.size.height/2, himg.size.width/2)] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[himg resizableImageWithCapInsets:UIEdgeInsetsMake(himg.size.height/2, himg.size.width/2, himg.size.height/2, himg.size.width/2)] forState:UIControlStateDisabled];
            [btn setTitle:@"确认付款" forState:UIControlStateNormal];
            [btn setTitle:@"" forState:UIControlStateDisabled];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [btn addTarget:self action:@selector(onConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_contentScroll addSubview:btn];
            originY             = CGRectGetMaxY(btn.frame) + 10;
            _confirmBtn         = btn;
        }
    }
    
    {
        UIActivityIndicatorView * activityview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityview.frame = CGRectMake(0, 0, 14, 14);
        activityview.hidesWhenStopped = YES;
        [_contentScroll addSubview:activityview];
        _activityviewInfo = activityview;
        _activityviewInfo.center = _confirmBtn.center;
        [activityview release];
    }
    
    _contentScroll.contentSize  = CGSizeMake(CGRectGetWidth(_contentScroll.frame), MAX(originY, CGRectGetHeight(_contentScroll.frame) + 1));
}

- (void)onProductBtn:(id)sender
{
    ;
}

- (void)onAddrinfoBtn:(id)sender
{
    CTPNewAddrVCtler * vctler = [CTPNewAddrVCtler new];
    vctler.isSalesproduct     = YES;
    vctler.isModifyAddrinfo   = YES;
    vctler.addrInfo           = self.DeliveryInfo;
    [self.navigationController pushViewController:vctler animated:YES];
    [vctler release];
}

- (void)onInvoiceinfoBtn:(id)sender
{
    CTPInvoiceInfoVCtler * vctler = [CTPInvoiceInfoVCtler new];
    vctler.isModifyInvoiceinfo    = YES;
    vctler.invoiceInfo            = self.InvoiceInfo;
    [self.navigationController pushViewController:vctler animated:YES];
    [vctler release];
}

- (void)onConfirmBtn:(id)sender
{
    [_activityviewInfo startAnimating];
    [self submitOrder];
}

- (void)submitOrder
{
    // 3：工作日、双休日与假日均可送货    0：网上支付 1:普通订单
    NSString * code         = @"submitOrder";
    {
        if ([Global sharedInstance].isLogin == NO) {
            CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
            }];
            return;
        }
    }
    
    NSString * UserId       = [[Global sharedInstance].custInfoDict objectForKey:@"UserId"] ? [[Global sharedInstance].custInfoDict objectForKey:@"UserId"] : @"FSD88888";
    NSString * OrderId      = [self.orderInfoDict objectForKey:@"OrderId"] ? [self.orderInfoDict objectForKey:@"OrderId"] : @"";
    NSString * PayMethod    = @"0";
    NSString * Type         = @"1";
    id aDeliveryInfo        = self.DeliveryInfo ? self.DeliveryInfo : @"";
    id aInvoiceInfo         = self.InvoiceInfo ? self.InvoiceInfo : @"";
    id aCustomerInfo        = self.CustomerInfo ? self.CustomerInfo : @"";
    if ([aDeliveryInfo isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary * tmpdict = [NSMutableDictionary dictionaryWithDictionary:aDeliveryInfo];
        [tmpdict removeObjectForKey:@"ProvinceName"];
        [tmpdict removeObjectForKey:@"CityName"];
        [tmpdict removeObjectForKey:@"CountyName"];
        aDeliveryInfo = tmpdict;
    }
    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"123", @"Remark",
                               @"3", @"DeliveryTime",
                               @"1", @"OrderSource",
                               UserId, @"UserId",
                               OrderId , @"OrderId",
                               PayMethod, @"PayMethod",
                               Type, @"Type",
                               aDeliveryInfo, @"DeliveryInfo",
                               aInvoiceInfo, @"InvoiceInfo",
                               aCustomerInfo, @"CustomerInfo",
                               nil];

    if (self.orderOpt) {
        [self.orderOpt cancel];
        self.orderOpt = nil;
    }
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    self.orderOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:code
                                                           params:params
                      onSucceeded:^(NSDictionary *dict) {
                          DDLogInfo(@"%s--%@", __func__, dict.description);
                          id Data = [dict objectForKey:@"Data"];
                          if (Data && [Data respondsToSelector:@selector(objectForKey:)]) {
                              _addrBtn.enabled        = YES;
                              _invoiceBtn.enabled     = YES;
                              _confirmBtn.enabled     = YES;
                              [_activityviewInfo stopAnimating];
                              
                              if ([Data objectForKey:@"OrderId"])
                              {
                                  // 支付
                                  id OrderId = [Data objectForKey:@"OrderId"];
                                  id userid = [[Global sharedInstance].loginInfoDict objectForKey:@"UserId"] ? [[Global sharedInstance].loginInfoDict objectForKey:@"UserId"] : @"FSD88888";
                                  NSString *payUrl = [NSString stringWithFormat:@"http://wapzt.189.cn/pay/onlinePay.do?method=getOrder&userid=%@&id=%@", userid, OrderId];
                                  
#if 0
                                  CTPPointExchangeVCtler * vctler = [CTPPointExchangeVCtler new];
                                  vctler.jumpUrl = payUrl;
                                  vctler.title = @"订单支付";
                                  vctler.fullScreen = YES;
                                  vctler.needBack2Rootview = YES;
#else
                                  //不管什么类型都传6
                                  [Utils saveOrderType:6];
                                  CTOrderRechargeVCtler *vctler =[CTOrderRechargeVCtler new];
                                  vctler.jumpUrl = payUrl;
                                  vctler.title = @"订单支付";
                                  vctler.fullScreen = YES;
                                  vctler.comeType   = 3;
#endif
                                  vctler.orderId = OrderId; // haha,重新加的订单确认页面
                                  vctler.comboName = self.comboName ? self.comboName : @"";
                                  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.salesProductInfoDict];
                                  NSString *tPhoneNumber = [self.CustomerInfo objectForKey:@"Phone_Number"];
                                  [dic setValue:tPhoneNumber?tPhoneNumber:@"" forKey:@"PhoneNumber"];//更改号码key
                                  NSString *tSalesProName = [self.salesProductInfoDict objectForKey:@"Name"];
                                  [dic setValue:tSalesProName forKey:@"SalesProName"]; //更改销售品名称key
                                  vctler.salesProInfo = dic;
                                  [self.navigationController pushViewController:vctler animated:YES];
                                  [vctler release];
                              }
                          }
                        [SVProgressHUD dismiss];
                      } onError:^(NSError *engineError) {
                          DDLogInfo(@"%s--%@", __func__, engineError);
                          
                          [SVProgressHUD dismiss];
                          _addrBtn.enabled        = YES;
                          _invoiceBtn.enabled     = YES;
                          _confirmBtn.enabled     = YES;
                          [_activityviewInfo stopAnimating];
                          
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
                                  [alertView release];
                              }
                          }
                          else{
                              ToastAlertView *alert = [ToastAlertView new];
                              [alert showAlertMsg:@"系统繁忙,请重新提交"];
                              [alert release];
                          }
                      }];

    
    _confirmBtn.enabled     = NO;
    _addrBtn.enabled        = NO;
    _invoiceBtn.enabled     = NO;
    [_activityviewInfo startAnimating];
}

#pragma mark notification
- (void)onNotificationAddrinfo:(NSNotification *)sender
{
    if ([[sender object] isKindOfClass:[NSDictionary class]])
    {
        self.DeliveryInfo = [sender object];
        [self resetUI];
    }
}

- (void)onNotificationModifyinfo:(NSNotification *)sender
{
    if ([[sender object] isKindOfClass:[NSDictionary class]])
    {
        self.InvoiceInfo = [sender object];
        [self resetUI];
    }
}

- (void)onNotificationLogin:(NSNotification *)sender
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0)
    {
        if (self.modalViewController)
        {
            [self.modalViewController dismissModalViewControllerAnimated:YES];
        }
    }
    else
    {
        if (self.presentedViewController)
        {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    [self onConfirmBtn:nil];
}

@end
