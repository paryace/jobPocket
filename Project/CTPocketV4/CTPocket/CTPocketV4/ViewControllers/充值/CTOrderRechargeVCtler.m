//
//  CTOrderRechargeVCtler.m
//  CTPocketV4
//
//  Created by apple on 13-11-4.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTOrderRechargeVCtler.h"
#import "AppDelegate.h"
#import "CserviceOperation.h"
#import "CTRechargeSucessVCtler.h"
#import "CTOrderConfirmVCtler.h"
#import "SVProgressHUD.h"
#import "ToastAlertView.h"
#import "SIAlertView.h"
#import "UIColor+Category.h"
#import "UIImage+Category.h"
#import "Utils.h"

#import "PartnerConfig.h"
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "AlixPayOrder.h"
#import "AlixLibService.h"
#import "CTMyOrderListVCtler.h"
#import "COQueryVctler.h"
#import "CTContractPayDoneVCterl.h"
#import <SDWebImage/SDWebImageManager.h>
#import "NSString+Des3Util.h"


#define kCTORVcFont             14.0f
#define kTableViewHeaderHeight  40.0
#define kDownTag                8818
#define kButtonTag              8000

//added by huangfq 2014-5-28
#define kNoFirstPayMent         @"NoFirstPayMent"
#define kRecentlyPay            @"RecentlyPay"

@interface CTOrderRechargeVCtler ()
{
    
    NSInteger previousTag;
    NSInteger currentTag;
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityViewInfo;
@property (nonatomic, strong) CserviceOperation *rechargeQueryOpt;
@property (nonatomic, strong) CserviceOperation *payTypeQueryOpt;
@property (nonatomic, strong) CserviceOperation *zfbQueryOpt;

@property (nonatomic, strong)UITableView *tableView;//added by huangfq 20140-5-26
@property (nonatomic, strong)UIView      *headerView;
@property (nonatomic, strong)UIButton    *downBtn;
@property (nonatomic, strong)UILabel     *downLabel;
@property (nonatomic, assign)BOOL isLoading;
@property (nonatomic, assign)BOOL isLoadingMore;
@property (nonatomic, assign)BOOL isFinished;
@property (nonatomic, assign)BOOL isDown;
@property (nonatomic, assign)UIScrollView *scrollView;

@property (nonatomic, strong)NSDictionary *payDict;//记录采取付款的方式
@property (nonatomic, strong)NSMutableArray *payArray;//请求返回的付款渠道
@property (nonatomic, strong)NSMutableArray *recentlyArray;//最近5次最多的渠道
@property (nonatomic, strong)NSMutableDictionary *selectDict;
@property (nonatomic, strong)UIViewController  *curVCtler;//当前的view
@property (nonatomic, strong)NSString *zfbqbOrderString;//支付宝生成的订单
//用户未登录，
//如果是充值订单userid传：bank888
//如果是其他订单userid传：FSD88888
//指除了充话费，流量、买充值卡三种情况，都属于其他订单
//支付场景
//1：话费直充
//2：流量直充
//3：购话费卡
//4：购流量卡
//5：购买号卡
//6：购买手机
@end

@implementation CTOrderRechargeVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // 通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(payResult:)
                                                     name:CTZFBOnPaySucessed
                                                   object:nil];
        
    }
    return self;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"订单支付";
    [self setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
    self.isDown              = YES;
    
//    NSLog(@"Utils:%d",[Utils getOrderType]);
    //1：话费直充
    //2：流量直充
    //3：购话费卡
    //4：购流量卡
    //5：购买号卡
    //6：购买手机
    self.orderType = [Utils getOrderType];
    if (self.orderInfo) {
        
        self.cardType = self.orderInfo[@"CardType"];
        
    }
    
    [self qryDetailOrder];
}

#pragma mark -- 界面元素
- (void)initView{
    
    
    //1：话费直充
    //2：流量直充
    //3：购话费卡
    //4：购流量卡
    //5：购买号卡
    //6：购买手机
    self.orderType = [Utils getOrderType];
    
    self.isDown              = YES;
    CGFloat xxOffset         = 20.0f;
    CGFloat yPos             = 100;
    self.jumpUrl             = @"";
    
    
    NSLog(@"orderType:%d",self.orderType);
    if (self.orderType == 1 || self.orderType == 2 || self.orderType == 3 || self.orderType == 4) {
            
        //added by huangfq 2014-5-26
        {
            
            CGFloat xOffset     = 0.0f;
            CGFloat ySpace      = 5.0f;
            CGFloat labelWidth  = 65.0f;
            UIFont *font        = [UIFont systemFontOfSize:kCTORVcFont];
            
            CGFloat width = self.view.bounds.size.width - xxOffset * 2;
            UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(20, 10, width, yPos)];
            
            UIImageView *briImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(view.frame), 6, 30)];
            briImageView.backgroundColor = [UIColor colorWithRed:0x6f/255. green:0xc5/255. blue:0x37/255. alpha:1];
            [self.view addSubview:briImageView];
            
            UILabel *order = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 5,labelWidth, 20)];
            order.backgroundColor = [UIColor clearColor];
            order.text     = @"订单号码:";
            order.font     = font;
            
            CGRect rect          = order.frame;
            rect.origin.x        = rect.origin.x + rect.size.width + 10;
            rect.size.width      = view.frame.size.width - labelWidth - xxOffset;
            
            UILabel *orderNumber = [[UILabel alloc] initWithFrame:rect];
            orderNumber.backgroundColor = [UIColor clearColor];
            orderNumber.text     = self.orderInfo[@"OrderId"];
            orderNumber.numberOfLines = 0;
            [orderNumber sizeToFit];
            orderNumber.font     = font;
            
            [view addSubview:order];
            [view addSubview:orderNumber];
            
            rect.origin.x        = xOffset;
            rect.origin.y        = orderNumber.frame.size.height + orderNumber.frame.origin.y + ySpace;
            rect.size.width      = labelWidth;
            rect.size.height     = 20;
            
            
//            if ([self.orderInfo[@"Type"] isEqualToString:@"1"] || [self.orderInfo[@"Type"] isEqualToString:@"2"]) {
            if (self.orderType == 1 ||self.orderType == 2) {
                
            
                UILabel *phone       = [[UILabel alloc] initWithFrame:rect];
                phone.backgroundColor = [UIColor clearColor];
                phone.font           = font;
                phone.text           = [NSString stringWithFormat:@"%@",@"充值号码:"];
                
                rect = phone.frame;
                rect.origin.x        = rect.origin.x + rect.size.width + 10;
                rect.size.width      = view.frame.size.width - labelWidth - 20;
                
                UILabel *phoneNumber = [[UILabel alloc] initWithFrame:rect];
                phoneNumber.backgroundColor = [UIColor clearColor];
                phoneNumber.font     = font;
                phoneNumber.text     = [NSString stringWithFormat:@"%@",self.orderInfo[@"PhoneNumber"]];
                
                [view addSubview:phone];
                [view addSubview:phoneNumber];
                
                rect.origin.x        = xOffset;
                rect.origin.y        = phoneNumber.frame.size.height + phoneNumber.frame.origin.y + ySpace;
                rect.size.width      = labelWidth;
                rect.size.height     = 20;
            }
            
                UILabel *pay       = [[UILabel alloc] initWithFrame:rect];
                pay.backgroundColor = [UIColor clearColor];
                pay.font           = font;
                pay.text           = [NSString stringWithFormat:@"%@",@"充值金额:"];
                
                rect = pay.frame;
                rect.origin.x        = rect.origin.x + rect.size.width + 10;
                rect.size.width      = view.frame.size.width - labelWidth - 20;
                
                UILabel *payAmount = [[UILabel alloc] initWithFrame:rect];
                payAmount.backgroundColor = [UIColor clearColor];
                payAmount.font     = font;
                if (self.orderInfo[@"OrderPrice"]) {
                    
                    payAmount.text     = [NSString stringWithFormat:@"%@",self.orderInfo[@"OrderPrice"]];
                }
                else
                {
                    payAmount.text     = [NSString stringWithFormat:@"%@",self.orderInfo[@"Price"]];
                    
                }
            
                payAmount.numberOfLines = 0;
                [payAmount sizeToFit];
                payAmount.textColor= [UIColor colorWithRed:0x6f/255. green:0xc5/255. blue:0x37/255. alpha:1];
                payAmount.textColor = [UIColor colorWithRed:76/255. green:185/255. blue:0/255. alpha:1];
                [view addSubview:pay];
                [view addSubview:payAmount];
            
                CGRect rect1 = payAmount.frame;
                rect1.origin.x += rect1.size.width;
                rect1.size.width = 20;
                UILabel *yuanLabel = [[UILabel alloc] initWithFrame:rect1];
                yuanLabel.backgroundColor = [UIColor clearColor];
                yuanLabel.text = @"元";
                yuanLabel.font = pay.font;
                [view addSubview:yuanLabel];
            
            
                rect.origin.x        = xOffset;
                rect.origin.y        = payAmount.frame.size.height + payAmount.frame.origin.y + ySpace;
                rect.size.width      = labelWidth;
                rect.size.height     = 20;
                
                UILabel *rpay       = [[UILabel alloc] initWithFrame:rect];
                rpay.backgroundColor = [UIColor clearColor];
                rpay.font           = font;
                rpay.text           = [NSString stringWithFormat:@"%@",@"实付金额:"];
                
                rect = rpay.frame;
                rect.origin.x        = rect.origin.x + rect.size.width + 10;
                rect.size.width      = view.frame.size.width - labelWidth - 20;
            
                UILabel *realPay = [[UILabel alloc] initWithFrame:rect];
                realPay.backgroundColor = [UIColor clearColor];
                realPay.font     = font;
                realPay.text     = [NSString stringWithFormat:@"%@",self.orderInfo[@"RealPrice"]];
                realPay.textColor= [UIColor colorWithRed:255/255. green:93/255. blue:62/255. alpha:1];
                realPay.font     = [UIFont boldSystemFontOfSize:18.0f];
                realPay.numberOfLines = 0;
                [realPay sizeToFit];
            
                [view addSubview:rpay];
                [view addSubview:realPay];
            
            
            
                rect1 = realPay.frame;
                rect1.origin.x += rect1.size.width;
                rect1.size.width = 20;
                yuanLabel = [[UILabel alloc] initWithFrame:rect1];
                yuanLabel.backgroundColor = [UIColor clearColor];
                yuanLabel.text = @"元";
                yuanLabel.font = rpay.font;
                [view addSubview:yuanLabel];
            
                CGRect frame      = view.frame;
                frame.size.height = CGRectGetMaxY(realPay.frame);
                view.frame        = frame;
                yPos              = CGRectGetMaxY(view.frame);
            
        
                [self.view addSubview:view];
        }
    }
    else
    {
        yPos = 10;
    }
    
    yPos += 25;
    {
        
        self.noFirstPay   = [[NSUserDefaults standardUserDefaults] boolForKey:kNoFirstPayMent];
        CGFloat width   = self.view.bounds.size.width - xxOffset * 2;
        CGFloat yOffset = 0.0;
        
        {
            
            UIImageView *briImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,yPos-5, 6, 30)];
            briImageView.backgroundColor = [UIColor colorWithRed:0x6f/255. green:0xc5/255. blue:0x37/255. alpha:1];
            [self.view addSubview:briImageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xxOffset, yPos, width, 20)];
            label.text     = @"选择支付方式";
            label.font     = [UIFont systemFontOfSize:kCTORVcFont];
            label.textAlignment = UITextAlignmentLeft;
            label.backgroundColor = [UIColor clearColor];
            [self.view addSubview:label];
//            self.noFirstPay = YES;
            yPos += label.frame.size.height + 15;
            
            if (self.noFirstPay) {
                
                yOffset = CGRectGetMaxY(label.frame) + 10;
                
                UILabel *recentlyPay = [[UILabel alloc] initWithFrame:CGRectMake(xxOffset, yOffset, 100, 20)];
                recentlyPay.backgroundColor = [UIColor clearColor];
                recentlyPay.text     = @"最近使用";
                recentlyPay.font     = [UIFont systemFontOfSize:kCTORVcFont];
                [self.view addSubview:recentlyPay];
                
                self.recentlyArray = [NSMutableArray arrayWithArray:[Utils getRecentlyPayDict]];
                //                NSLog(@"recentlyArray:%@ %@",self.recentlyArray,[Utils getRecentlyPayList]);
                
                yPos += recentlyPay.frame.size.height;
            }
        }
        yPos += 5;
        CGFloat height  = self.view.bounds.size.height - yPos - 56;

            
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(xxOffset, yPos, width, height)];
        scrollView.showsVerticalScrollIndicator   = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.backgroundColor = [UIColor clearColor];
      
        [self.view addSubview:scrollView];
        self.scrollView = scrollView;
        if (self.noFirstPay)
        {
            self.recentlyArray = [NSMutableArray arrayWithArray:[Utils getRecentlyPayDict]];
            UIView *view       = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    
            view.layer.cornerRadius = 5.0f;
            view.backgroundColor = [UIColor whiteColor];
            CGFloat height = 44.0f;
            for (int i = 0; i < [self.recentlyArray count]; i++) {

                UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 4 + i * height, 36, 36)];
                iconImageView.userInteractionEnabled = YES;
                iconImageView.contentMode = UIViewContentModeScaleAspectFit;
                iconImageView.backgroundColor = [UIColor clearColor];
                
                UILabel *payTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake (70,12 + i * height, 150, 20)];
                payTypeLabel.backgroundColor = [UIColor clearColor];
                
                UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                selectBtn.frame = CGRectMake(0, 4 + i * height, view.frame.size.width, 36);
                [selectBtn setImage:[UIImage imageNamed:@"PayRadioButtonNoSelected.png"] forState:UIControlStateNormal];
                [selectBtn setImage:[UIImage imageNamed:@"PayRadioButtonSelected.png"] forState:UIControlStateSelected];
                [selectBtn addTarget:self action:@selector(selectPay:) forControlEvents:UIControlEventTouchUpInside];
                selectBtn.tag = kButtonTag + i + 1;
                selectBtn.imageEdgeInsets = UIEdgeInsetsMake(0, width - 40, 0, 0);
                
                [view addSubview:iconImageView];
                [view addSubview:payTypeLabel];
                [view addSubview:selectBtn];
                view.tag      = kButtonTag + 100 + i + 1;
            
                NSDictionary *dict = self.recentlyArray[i];
                [iconImageView setImageWithURL:[NSURL URLWithString:dict[@"bankIcon"]]];
                payTypeLabel.text = dict[@"bankName"];
            }
            [self.scrollView addSubview:view];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame     = CGRectMake(0, view.frame.size.height, view.frame.size.width, view.frame.size.height);
            [button addTarget:self action:@selector(pullBack) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *down = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, kTableViewHeaderHeight)];
            down.text     = @"展开更多";
            down.textAlignment = UITextAlignmentLeft;
            down.textColor     = [UIColor grayColor];
            down.font = [UIFont systemFontOfSize:kCTORVcFont];
            [button addSubview:down];
            [down sizeToFit];
        
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(down.frame)+5,0,20, 20)];
            imageView.contentMode  = UIViewContentModeScaleAspectFit;
            [imageView setImage:[UIImage imageNamed:@"PayMore.png"]];
            imageView.userInteractionEnabled = NO;
            [down addSubview:imageView];
            
            CGRect rect = down.frame;
            rect.size.width += 25;
            rect.origin.x    = (width - rect.size.width)/2;
            rect.origin.y    = (button.frame.size.height - down.frame.size.height)/2;
            down.frame = rect;
            
            imageView.tag = kDownTag;
            self.downBtn = button;
            self.downLabel = down;
            
            [self.scrollView addSubview:self.downBtn];
        }
        
        float y = self.view.frame.size.height - 56;
     
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.view.frame), 56)];
        view.backgroundColor = [UIColor clearColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(ceilf((CGRectGetWidth(view.frame) - 260)/2.0), ceilf((CGRectGetHeight(view.frame) - 36)/2.0), 260, 36);
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:94 G:189 B:42 A:1] cornerRadius:4] forState:UIControlStateNormal];
        [button setBackgroundImage:nil forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(nowPay) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"立即支付" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [view addSubview:button];
        
        [self.view addSubview:view];
        
    }
 
    //如果是首次支付侧获取支付方式
    if (!self.noFirstPay) {
        
        [self qryPayType];
    }

}

//modified by huangfq 2014-5-26
- (void) viewWillAppear:(BOOL)animated{
    

    {
        UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        webView.delegate = (id<UIWebViewDelegate>)self;
        webView.backgroundColor = [UIColor whiteColor];
        webView.scalesPageToFit = YES;
//        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:([self.jumpUrl length] ? self.jumpUrl : @"http://jf.189.cn/wap")]]];
        self.webView = webView ;
        [self.view addSubview:webView];
        self.webView.alpha = 0;
        
    }
    {
        UIActivityIndicatorView * activityview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityview.frame = CGRectMake(100, 250, 14, 14);
        activityview.center = self.webView.center;
        activityview.hidesWhenStopped = YES;
        [self.view addSubview:activityview];
        self.activityViewInfo = activityview;
    }
    
    if (self.curVCtler) {
        
        [self.curVCtler.view removeFromSuperview];
    }
}
#pragma mark __fun__
- (void)nowPay
{
    
    if(currentTag == 0){
        
        ToastAlertView *alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲，要先选择支付方式哦"];
        return;
    }
    
    if (!self.noFirstPay) {
        
        int index  = currentTag - kButtonTag - 1;
        
//        调用方式
//        1：支付宝钱包
//        2：wap页面
//        3：扩展预留
        self.payStyle = [self.payArray[index][@"linkType"] integerValue];
        
        //保存支付方式
        self.payDict = self.payArray[index];
        
        switch (self.payStyle) {
            case 1:
            {
                //调用支付宝插件
                [self creatZFBQBOrder];
            }
            break;
            case 2:
            {
                //网页支付
                self.jumpUrl = self.payArray[index][@"linkUrl"];
                self.webView.alpha = 1;
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:([self.jumpUrl length] ? [self.jumpUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @"http://jf.189.cn/wap")]]];
                [self.view bringSubviewToFront:self.webView];
                [self.view bringSubviewToFront:self.activityViewInfo];
            }
            break;
                
            default:
                break;
        }
        
        
    }
    else
    {
        int index  = currentTag - kButtonTag - 1;
        NSMutableArray *__payArray = [NSMutableArray array];
        
        [__payArray addObjectsFromArray:self.recentlyArray];
        [__payArray addObjectsFromArray:self.payArray];
//        NSLog(@"__payArray:%@",__payArray);

    //        调用方式
    //        1：支付宝钱包
    //        2：wap页面
    //        3：扩展预留
        self.payStyle = [__payArray[index][@"linkType"] integerValue];
        //保存支付方式
        self.payDict = __payArray[index];
        
        switch (self.payStyle) {
            case 1:
            {
                //调用支付宝插件
                [self creatZFBQBOrder];
                
            }
                break;
            case 2:
            {
                //网页支付
                self.jumpUrl = __payArray[index][@"linkUrl"];
                self.webView.alpha = 1;
                
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:([self.jumpUrl length] ? [self.jumpUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @"http://jf.189.cn/wap")]]];
                
                [self.view bringSubviewToFront:self.webView];
                [self.view bringSubviewToFront:self.activityViewInfo];
            }
                break;
                
            default:
                break;
        }
        NSLog(@"payStyle:%d",self.payStyle);
        
        
    }
    
}

//获取从服务器生成的支付宝的订单
- (void)creatZFBQBOrder
{
    
    NSString *OrderId =[self.orderInfo objectForKey:@"OrderId"];
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            OrderId, @"OrderId",nil];
    
    if (self.zfbQueryOpt) {
        
        [self.zfbQueryOpt cancel];
        self.zfbQueryOpt = nil;
    }
//    __block CTOrderRechargeVCtler *weakSelf = self;
    self.payTypeQueryOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"payOrderAli"
                                                                  params:params
                                                             onSucceeded:^(NSDictionary *dict)
                            {

                                NSString *payString =  dict[@"Data"][@"PayString"];
                                self.zfbqbOrderString = [payString decodeByDesc3];

                                if (self.zfbqbOrderString) {
                                    
                                    self.zfbqbOrderString = [self.zfbqbOrderString stringByReplacingOccurrencesOfString:@"\\" withString:@""];

                                }
                                
                                [SVProgressHUD dismiss];
                                [self toZFBApp];
                                
                            }onError:^(NSError *engineError) {
                                
                                
                                NSLog(@"获取数据失败");
                                DDLogInfo(@"--%@", engineError);
                                
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
                                else{
                                    [SVProgressHUD dismiss];
                                    ToastAlertView *alert = [ToastAlertView new];
                                    [alert showAlertMsg:@"系统繁忙，请稍后再试"];
                                }
                            }];

    
}

- (void)payResult:(NSNotification *)notification{
   
    [self popViewController];
}

//查询订单详情
- (void)qryDetailOrder{
    
    
    if (self.rechargeQueryOpt) {
        [self.rechargeQueryOpt cancel];
        self.rechargeQueryOpt = nil;
    }
    
    self.OrderId = self.OrderId?self.OrderId:[self.orderInfo objectForKey:@"OrderId"];

    NSString *UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"bank888";
    
    //百搭
    if (self.comeType == 3) {
        
        UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"FSD88888";
        
    }

    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.OrderId, @"OrderId",
                            UserId, @"UserId",nil];
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    __block CTOrderRechargeVCtler *weakSelf = self;
    self.rechargeQueryOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrderInfo"
                                                                   params:params
                                                              onSucceeded:^(NSDictionary *dict)
                             {
                                 //跳转到充值成功页
                                 NSLog(@"成功");
                                 /*
                                  10702	支付中	    10702	支付中（用户点击支付按钮到支付反馈）
                                  10101	已支付	    10101	支付成功（货到付款没有此状态）
                                  10102	订单待审核	10102	系统审核订单
                                  10103	订单已审核	10102	系统审核订单
                                  10104	订单不通过	10104	订单关闭（超时未支付）
                                  10701	已取消	    10701	已取消（用户取消）
                                  10105	备货中	    10105	开始备货
                                  10106	写卡	        10105	开始备货
                                  10107	打印协议	    10105	开始备货
                                  10108	配件准备	    10105	开始备货
                                  10109	发票打印	    10105	开始备货
                                  10110	备货完成	    10105	开始备货
                                  10111	物流配送	    10111	已发货（线上支付时有效）
                                  10120	物流配送	    10120	货物抵达自提点(上门自提时有效)
                                  
                                  11104	充值中
                                  11105	充值成功
                                  11106	充值失败
                                  11108	购买成功
                                  11109	购买失败
                                  11201	退款中
                                  11202	退款成功
                                  11203	退款失败
                                  */
                                
                                 NSDictionary *data = [dict objectForKey:@"Data"];
                        
                                 if (data && [data respondsToSelector:@selector(objectForKey:)]) {
                                     NSString *OrderStatusCode = [data objectForKey:@"OrderStatusCode"];

                                     
                                     if (OrderStatusCode && OrderStatusCode.length>0) {
                                         { //充值成功
                                             
                                             weakSelf.orderInfo = [data mutableCopy];
                                             
                                             if ([data[@"Item"] isKindOfClass:[NSDictionary class]])
                                             {
                                                 
                                                 [weakSelf.orderInfo setObject:data[@"Item"][@"RealPrice"] forKey:@"RealPrice"];
                                                 [weakSelf.orderInfo setObject:data[@"Item"][@"PhoneNumber"] forKey:@"PhoneNumber"];
                                             }
                                             
                                             //靓号专区
                                             else if([data[@"Item"] isKindOfClass:[NSArray class]])
                                             {
                                                 [weakSelf.orderInfo setObject:data[@"Item"][0][@"RealPrice"] forKey:@"RealPrice"];
                                                 [weakSelf.orderInfo setObject:data[@"Item"][0][@"PhoneNumber"] forKey:@"PhoneNumber"];
                                                 
                                             }
                                             
                                             //从查询订单进来不知道什么类型
//                                             if(self.comeType == 1)
//                                             {
                                             
                                                 if ([weakSelf.orderInfo[@"OrderType"] isEqualToString:@"1"]) {
                                                     
                                                     //added by huangfq 2014-5-30
                                                     //保存选择的订单类型
                                                     [Utils saveOrderType:6];
                                                 }
                                                 //充值卡 统一传3
                                                 else if ([weakSelf.orderInfo[@"OrderType"] isEqualToString:@"3"])
                                                 {
                                                     //added by huangfq 2014-5-30
                                                     //保存选择的订单类型
                                                     [Utils saveOrderType:3];
                                                     
                                                 }
                                                 else if ([weakSelf.orderInfo[@"OrderType"] isEqualToString:@"4"])
                                                 {
                                                     //added by huangfq 2014-5-30
                                                     //保存选择的订单类型
                                                     [Utils saveOrderType:1];
                                                     
                                                 }
                                                 else
                                                 {
                                                     //added by huangfq 2014-5-30
                                                     //保存选择的订单类型
                                                     [Utils saveOrderType:0];
                                                     
                                                 }
                                                 
//                                             }

                                             [SVProgressHUD dismiss];
                                             [weakSelf initView];

                                         }
                                
                                     }
                                 }else{
                                     //跳转充值失败页面
                                     [SVProgressHUD dismiss];
                                  
                                 }
                                 
                                 
                             }onError:^(NSError *engineError) {
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
                                 else{
                                     [SVProgressHUD dismiss];
                                     ToastAlertView *alert = [ToastAlertView new];
                                     [alert showAlertMsg:@"系统繁忙，请稍后再试"];
                                 }
                             }];

    
}


//支付包插件支付后 成功或失败的跳转
- (void)payJump:(NSNotification *)notification
{
    
    NSString *key = [notification name];
    NSDictionary *dict = [notification userInfo];
    BOOL suceessed = [dict[key] boolValue];
    
    if (suceessed) {
        
        //判断是否登录
        if ([Global sharedInstance].isLogin == YES) {
            CTMyOrderListVCtler *vc = [[CTMyOrderListVCtler alloc] init];
            vc.orderType = @"0";
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            COQueryVctler *vc = [[COQueryVctler alloc] init];
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }
    }
    else
    {
        
        if (self.curVCtler) {
            
            [self.curVCtler.view  removeFromSuperview];
        }
        
    }
    
}

//支付方式的 获取
- (void)qryPayType{
    
    if (self.payTypeQueryOpt) {
        [self.payTypeQueryOpt cancel];
        self.payTypeQueryOpt = nil;
    }
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    //    NSLog(@"orderInfo:%@",self.orderInfo);
    NSString *OrderId = @"";
    NSString *ShopId  = @"";
    
    if (self.orderType == 0) {
        
        self.orderType = 6;
    }
    NSString *PayScene = [NSString stringWithFormat:@"%d",self.orderType];
    ShopId = [self.orderInfo objectForKey:@"ShopId"];//@"20002";
    OrderId =[self.orderInfo objectForKey:@"OrderId"];
    
    NSString *UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"bank888";
    
    //用户未登录，
    //如果是充值订单userid传：bank888
    //如果是其他订单userid传：FSD88888
    //指除了充话费，流量、买充值卡三种情况，都属于其他订单
    //支付场景
    //1：话费直充
    //2：流量直充
    //3：购话费卡
    //4：购流量卡
    //5：购买号卡
    //6：购买手机

    if ([PayScene isEqualToString:@"1"] || [PayScene isEqualToString:@"2"] || [PayScene isEqualToString:@"3"] || [PayScene isEqualToString:@"4"])
    {
        
        UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"bank888";
        
    }
    else
    {
        UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"FSD88888";
        
    }
    
    //用户未登录，
    //如果是充值订单userid传：bank888
    //如果是其他订单userid传：FSD88888
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            ShopId, @"ShopId",
                            OrderId, @"OrderId",
                            PayScene ,@"PayScene",
                            UserId,@"UserId",nil];
    
    
    __block CTOrderRechargeVCtler *weakSelf = self;
    self.payTypeQueryOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryPayment"
                                                                  params:params
                                                             onSucceeded:^(NSDictionary *dict)
    {
        //格式化数据(将指定的数据格式化成数组)
        dict = [Utils objFormatArray:dict path:@"Data/Items/Item"];
        NSDictionary *data = [dict objectForKey:@"Data"];
        if (data && [data respondsToSelector:@selector(objectForKey:)])
        {
            if(data[@"Items"][@"Item"])
            {
                
                weakSelf.payArray = [NSMutableArray arrayWithArray:data[@"Items"][@"Item"]];
                NSDictionary *recentlyDict = self.recentlyArray[0];
                if (recentlyDict&&[recentlyDict respondsToSelector:@selector(objectForKey:)]) {
                    
                    NSString *rectlyCode = recentlyDict[@"bankCode"];
                    
                    for (NSDictionary *dict in weakSelf.payArray) {
                        
                        NSString *payCode = dict[@"bankCode"];
                        
                        if ([rectlyCode isEqualToString:payCode]) {
                            
                            [self.payArray removeObject:dict];
                            break;
                        }
                        
                    }
                }
                
                [weakSelf reloadData];
                
                {
                    if (weakSelf.noFirstPay) {
                        
                        weakSelf.isFinished = YES;
                        weakSelf.isLoadingMore = NO;
                        weakSelf.isLoading = NO;
                        [weakSelf disable];
                    }
                    
                }
            
            }
            else
            {
                //跳转充值失败页面
                ToastAlertView *alert = [ToastAlertView new];
                [alert showAlertMsg:@"系统繁忙，获取支付方式失败"];
            }
        }
        else
        {
            //跳转充值失败页面
            ToastAlertView *alert = [ToastAlertView new];
            [alert showAlertMsg:@"系统繁忙，获取支付方式失败"];
            
        }
        [SVProgressHUD dismiss];
        
    }onError:^(NSError *engineError) {
        
        NSLog(@"获取数据失败");
        DDLogInfo(@"qryPayType:--%@", engineError);
        
        
        {
            if (weakSelf.noFirstPay) {
                
                weakSelf.isFinished = YES;
                weakSelf.isLoadingMore = NO;
                weakSelf.isLoading = NO;
                [weakSelf disable];
            }
            
        }

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
        else{
            [SVProgressHUD dismiss];
            ToastAlertView *alert = [ToastAlertView new];
            [alert showAlertMsg:@"系统繁忙，请稍后再试"];
        }
    }];
    
    
}
//是否更在加载更多支付方式
- (void)loadMore
{
    
    self.isLoadingMore = YES;
    [self qryPayType];
    
}
//重新添加支付方式
- (void)reloadData
{
    
    NSInteger tag   = self.noFirstPay ? 1:0;
    CGFloat xOffset = 20.0f;
    CGFloat yPos    = self.noFirstPay ? 50:0;
    CGFloat width   = self.view.bounds.size.width - xOffset * 2;
    CGFloat height  = 44.0f;
    CGFloat viewHeight = [self.payArray count] * height + yPos > self.scrollView.frame.size.height ?  [self.payArray count] * height + yPos:self.scrollView.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, yPos, width, [self.payArray count] * height)];
    view.layer.cornerRadius = 5.0f;
    view.backgroundColor    = [UIColor whiteColor];
    
    for (int i = 0; i < [self.payArray count]; i++) {
    
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 4 + i * height, 36, 36)];
        iconImageView.userInteractionEnabled = YES;
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.backgroundColor = [UIColor clearColor];
        
        UILabel *payTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake (70,12 + i * height, 150, 20)];
        payTypeLabel.backgroundColor = [UIColor clearColor];
        
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectBtn.frame = CGRectMake(0, 4 + i * height, view.frame.size.width, 36);//240
        [selectBtn setImage:[UIImage imageNamed:@"PayRadioButtonNoSelected.png"] forState:UIControlStateNormal];
        [selectBtn setImage:[UIImage imageNamed:@"PayRadioButtonSelected.png"] forState:UIControlStateSelected];
        selectBtn.tag = kButtonTag + i + tag + 1;
        [selectBtn addTarget:self action:@selector(selectPay:) forControlEvents:UIControlEventTouchUpInside];
        selectBtn.imageEdgeInsets = UIEdgeInsetsMake(0, width - 40, 0, 0);
        
        
        [view addSubview:iconImageView];
        [view addSubview:payTypeLabel];
        [view addSubview:selectBtn];
        
        UIImageView *line  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PayLine.png"]];
        line.frame = CGRectMake(2, (i+1)*height-2, view.frame.size.width-4, 2);
        [view addSubview:line];
        
        NSDictionary *dict = self.payArray[i];
        [iconImageView setImageWithURL:[NSURL URLWithString:dict[@"bankIcon"]]];
        payTypeLabel.text = dict[@"bankName"];
        
        
    }
    
    [self.scrollView addSubview:view];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, viewHeight)];
}
#pragma mark 使按钮失效
-(void)enable
{
    self.downBtn.alpha = 1;
//    self.isDown = YES;
}
#pragma mark 使按钮有效
-(void)disable
{
    self.downBtn.alpha = 0;
//    self.isDown = NO;
}
//下拉
- (void)pullBack{
    
#if 0
    if (self.isDown) {
        
        return;
    }
    [self.payArray removeAllObjects];
    if (self.noFirstPay) {
        
        [self.selectDict removeAllObjects];
        [self.selectDict setObject:[NSNumber numberWithBool:YES] forKey:@"0"];
    }
    self.isLoading      = NO;
    self.isFinished     = YES;
    self.isLoadingMore  = NO;
    [self.tableView reloadData];
    [self enable];
#else
    
    [self disable];
    [self loadMore];
    
#endif
    
    
}
//选择支付方式后  标记已经选择
- (void)selectPay:(id)sender
{

    int tag = [sender tag];
    UIButton *previousBtn = previousTag ? (UIButton *)[self.scrollView viewWithTag:previousTag]:nil;
    UIButton *selectBtn = (UIButton *)[self.scrollView viewWithTag:tag];
    
    if (previousBtn) {
        
        previousBtn.selected = NO;
    }
    if (selectBtn) {
        
        selectBtn.selected = YES;
    }
    previousTag = currentTag = tag;
}

- (void)popViewController
{
    
    self.view.userInteractionEnabled = NO;
    
    //网页付款的返回
    if (self.rechargeQueryOpt) {
        [self.rechargeQueryOpt cancel];
        self.rechargeQueryOpt = nil;
    }
    
    NSString *OrderId = @"";
    OrderId =[self.orderInfo objectForKey:@"OrderId"];
    NSString *PayScene = self.orderInfo[@"Type"];
    NSString *UserId = @"";
    
    if ([PayScene isEqualToString:@"1"] || [PayScene isEqualToString:@"2"] || [PayScene isEqualToString:@"3"] || [PayScene isEqualToString:@"4"])
    {
        UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"bank888";
    }
    else
    {
        UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"FSD88888";
        
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            OrderId, @"OrderId",
                            UserId, @"UserId",nil];
    
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    __block CTOrderRechargeVCtler *weakSelf = self;
    self.rechargeQueryOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrderInfo"
                                                                   params:params
                                                              onSucceeded:^(NSDictionary *dict)
                             {
                                 //跳转到充值成功页
                                 NSLog(@"成功");
                                 /*
                                  10702	支付中	    10702	支付中（用户点击支付按钮到支付反馈）
                                  10101	已支付	    10101	支付成功（货到付款没有此状态）
                                  10102	订单待审核	10102	系统审核订单
                                  10103	订单已审核	10102	系统审核订单
                                  10104	订单不通过	10104	订单关闭（超时未支付）
                                  10701	已取消	    10701	已取消（用户取消）
                                  10105	备货中	    10105	开始备货
                                  10106	写卡	        10105	开始备货
                                  10107	打印协议	    10105	开始备货
                                  10108	配件准备	    10105	开始备货
                                  10109	发票打印	    10105	开始备货
                                  10110	备货完成	    10105	开始备货
                                  10111	物流配送	    10111	已发货（线上支付时有效）
                                  10120	物流配送	    10120	货物抵达自提点(上门自提时有效)
                                  
                                  11104	充值中
                                  11105	充值成功
                                  11106	充值失败
                                  11108	购买成功
                                  11109	购买失败
                                  11201	退款中
                                  11202	退款成功
                                  11203	退款失败
                                  */
                                 NSDictionary *data = [dict objectForKey:@"Data"];
                                 if (data && [data respondsToSelector:@selector(objectForKey:)]) {
                                     NSString *OrderStatusCode = [data objectForKey:@"OrderStatusCode"];
                                     NSString *OrderStatusDescription = [data objectForKey:@"OrderStatusDescription"];
                                     if (OrderStatusCode && OrderStatusCode.length>0) {
                                         { //充值成功
                                             
                                             //                                             OrderStatusCode
                                             //                                             1
                                             //                                             string
                                             
                                             //充值  进来。 侧返回的原来的界面
                                             if (self.comeType == 2) {
                                                 
                                                 CTOrderConfirmVCtler *rechargeSuceessVCtler = [CTOrderConfirmVCtler new] ;
                                                 [self.orderInfo setObject:OrderStatusDescription forKey:@"OrderStatusDescription"]; //状态描述
                                                 [self.orderInfo setObject:OrderStatusCode forKey:@"OrderStatusCode"];
                                                 //                                             [self.orderInfo setObject: forKey:OrderCreatedDate];
                                                 rechargeSuceessVCtler.orderInfo = self.orderInfo;
                                                 
                                                 rechargeSuceessVCtler.rechargeInfoDict = [NSMutableDictionary dictionaryWithDictionary:data] ;
                                                 rechargeSuceessVCtler.rechargeType = weakSelf.rechargeType;  //支付成功或者是失败
                                                 
#if 0
                                                 NSString *pageType = [self.orderInfo objectForKey:@"PageType"];
                                                 if ([pageType intValue] == 0) {
                                                     rechargeSuceessVCtler.pageType = 2;    // 0 确认  1 银行卡充值  2 购买卡密
                                                 }else{
                                                     rechargeSuceessVCtler.pageType = 4;    // 跳转购买卡密的页面
                                                 }
#else
                                                 if (self.orderType == 1 || self.orderType == 2) {
                                                     
                                                     rechargeSuceessVCtler.pageType = 2;
                                                 }
                                                 else
                                                 {
                                                     rechargeSuceessVCtler.pageType = 4;
                                                 }
#endif
                                                 //如果是购买话费卡或者充值卡
                                                 if (self.cardType) {
                                                     
                                                     [self.orderInfo setObject:self.cardType forKey:@"CardType"];
                                                 }
                                                 
                                                 //网页支付形式
                                                 if (self.pageType == 2) {
                                                     
                                                     //订单状态的完成
                                                     if ([OrderStatusCode isEqualToString:@"10101"]) {
                                                         
                                                         
                                                         //保存最近支付方式
                                                         NSMutableArray *rArray = [NSMutableArray arrayWithArray:[Utils getRecentlyPayList]];
                                                         [rArray insertObject:self.payDict atIndex:0];
                                                         if ([rArray count] > 5) {
                                                             
                                                             [rArray removeLastObject];
                                                         }
                                                         [Utils saveRecentlyPayList:rArray];
                                                         
                                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNoFirstPayMent];
                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                         
                                                     }
                                                 }
                                                 [weakSelf.navigationController pushViewController:rechargeSuceessVCtler animated:YES];
                                             }
                                             
                                             //跳转充值成功页面 (跳转到确认页面 )
                                             //百搭产品进来
                                             else if(self.comeType ==3)
                                             {
                                                 
                                                 if (self.pageType == 2) {
                                                     
                                                     //订单状态的完成
                                                     if ([OrderStatusCode isEqualToString:@"10101"]) {
                                                         
                                                         
                                                         //保存最近支付方式
                                                         NSMutableArray *rArray = [NSMutableArray arrayWithArray:[Utils getRecentlyPayList]];
                                                         [rArray insertObject:self.payDict atIndex:0];
                                                         if ([rArray count] > 5) {
                                                             
                                                             [rArray removeLastObject];
                                                         }
                                                         [Utils saveRecentlyPayList:rArray];
                                                         
                                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNoFirstPayMent];
                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                         
                                                     }
                                                 }
                                                 
                                                 CTContractPayDoneVCterl *vc = [[CTContractPayDoneVCterl alloc] init];
                                                 vc.pOrderId = self.OrderId;
                                                 vc.pOrderStatusDescription = dict[@"Data"][@"OrderStatusDescription"];
                                                 vc.pComboName = self.comboName;
                                                 NSMutableDictionary *salesDict = [NSMutableDictionary dictionaryWithObject:self.salesProInfo forKey:@"item"]; //modified by shallow 2014-4-23
                                                 //vc.info = self.info ;
                                                 vc.info = salesDict;
                                                 vc.salesProInfo = self.salesProInfo;
                                                 [self.navigationController pushViewController:vc animated:YES];
                                                 
                                             }
                                             //订单查询
                                             else
                                             {
                                                 if (self.pageType == 2) {
                                                     
                                                     //订单状态的完成
                                                     if ([OrderStatusCode isEqualToString:@"10101"]) {
                                                         
                                                         //保存最近支付方式
                                                         NSMutableArray *rArray = [NSMutableArray arrayWithArray:[Utils getRecentlyPayList]];
                                                         [rArray insertObject:self.payDict atIndex:0];
                                                         if ([rArray count] > 5) {
                                                             
                                                             [rArray removeLastObject];
                                                         }
                                                         [Utils saveRecentlyPayList:rArray];
                                                         
                                                     }
                                                     
                                                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNoFirstPayMent];
                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                 }
                                                 
                                                 [self.navigationController popViewControllerAnimated:YES];
                                                 
                                                 
                                             }
                                         }
                                     }
                                 }else{
                                     
                                     
                                 }
                                 
                                 [SVProgressHUD dismiss];
                             }onError:^(NSError *engineError) {
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
                                 else{
                                     [SVProgressHUD dismiss];
                                     ToastAlertView *alert = [ToastAlertView new];
                                     [alert showAlertMsg:@"系统繁忙，请稍后再试"];
                                 }
                             }];

    
}

#pragma mark -
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [_webView stopLoading];
    _webView = nil;
    self.activityViewInfo = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CTPNavBarDelegate
-(void)onleftBtnAction:(id)sender
{
    [_webView stopLoading];
    if (!self.needBack2Rootview)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void) onLeftBtnAction:(id)sender
{
    
#if 1
    [self popViewController];
#else
    
    
    //网页付款的返回
    if (self.rechargeQueryOpt) {
        [self.rechargeQueryOpt cancel];
        self.rechargeQueryOpt = nil;
    }
    
    NSString *OrderId = @"";
    OrderId =[self.orderInfo objectForKey:@"OrderId"];
    NSString *PayScene = self.orderInfo[@"Type"];
    NSString *UserId = @"";
    
    if ([PayScene isEqualToString:@"1"] || [PayScene isEqualToString:@"2"] || [PayScene isEqualToString:@"3"] || [PayScene isEqualToString:@"4"])
    {
        UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"bank888";
    }
    else
    {
        UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"FSD88888";
        
    }

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            OrderId, @"OrderId",
                            UserId, @"UserId",nil];
    
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    __block CTOrderRechargeVCtler *weakSelf = self;
    self.rechargeQueryOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrderInfo"
                                                                   params:params
                                                              onSucceeded:^(NSDictionary *dict)
                             {
                                 //跳转到充值成功页
                                 NSLog(@"成功");
                                 /*
                                     10702	支付中	    10702	支付中（用户点击支付按钮到支付反馈）
                                     10101	已支付	    10101	支付成功（货到付款没有此状态）
                                     10102	订单待审核	10102	系统审核订单
                                     10103	订单已审核	10102	系统审核订单
                                     10104	订单不通过	10104	订单关闭（超时未支付）
                                     10701	已取消	    10701	已取消（用户取消）
                                     10105	备货中	    10105	开始备货
                                     10106	写卡	        10105	开始备货
                                     10107	打印协议	    10105	开始备货
                                     10108	配件准备	    10105	开始备货
                                     10109	发票打印	    10105	开始备货
                                     10110	备货完成	    10105	开始备货
                                     10111	物流配送	    10111	已发货（线上支付时有效）
                                     10120	物流配送	    10120	货物抵达自提点(上门自提时有效)
                                  
                                                          11104	充值中
                                                          11105	充值成功
                                                          11106	充值失败
                                                          11108	购买成功
                                                          11109	购买失败
                                                          11201	退款中
                                                          11202	退款成功
                                                          11203	退款失败
                                  */
                                 NSDictionary *data = [dict objectForKey:@"Data"];
                                 if (data && [data respondsToSelector:@selector(objectForKey:)]) {
                                     NSString *OrderStatusCode = [data objectForKey:@"OrderStatusCode"];
                                     NSString *OrderStatusDescription = [data objectForKey:@"OrderStatusDescription"];
                                     if (OrderStatusCode && OrderStatusCode.length>0) {
                                         { //充值成功
                                             
//                                             OrderStatusCode
//                                             1
//                                             string
                                             
                                             //充值  进来。 侧返回的原来的界面
                                             if (weakSelf.comeType == 2) {
                                                 
                                                 CTOrderConfirmVCtler *rechargeSuceessVCtler = [CTOrderConfirmVCtler new] ;
                                                 [weakSelf.orderInfo setObject:OrderStatusDescription forKey:@"OrderStatusDescription"]; //状态描述
                                                 [weakSelf.orderInfo setObject:OrderStatusCode forKey:@"OrderStatusCode"];
                                                 //                                             [self.orderInfo setObject: forKey:OrderCreatedDate];
                                                 rechargeSuceessVCtler.orderInfo = weakSelf.orderInfo;
                                                 
                                                 rechargeSuceessVCtler.rechargeInfoDict = [NSMutableDictionary dictionaryWithDictionary:data] ;
                                                 rechargeSuceessVCtler.rechargeType = weakSelf.rechargeType;  //支付成功或者是失败
                                                 
#if 0
                                                 NSString *pageType = [weakSelf.orderInfo objectForKey:@"PageType"];
                                                 if ([pageType intValue] == 0) {
                                                     rechargeSuceessVCtler.pageType = 2;    // 0 确认  1 银行卡充值  2 购买卡密
                                                 }else{
                                                     rechargeSuceessVCtler.pageType = 4;    // 跳转购买卡密的页面
                                                 }
#else
                                                 if (weakSelf.orderType == 1 || weakSelf.orderType == 2) {
                                                     
                                                     rechargeSuceessVCtler.pageType = 2;
                                                 }
                                                 else
                                                 {
                                                     rechargeSuceessVCtler.pageType = 4;
                                                 }
#endif
                                                 //如果是购买话费卡或者充值卡
                                                 if (weakSelf.cardType) {
                                                     
                                                     [self.orderInfo setObject:self.cardType forKey:@"CardType"];
                                                 }
                                                 
                                                 //网页支付形式
                                                 if (weakSelf.pageType == 2) {
                                                     
                                                     //订单状态的完成
                                                     if ([OrderStatusCode isEqualToString:@"10101"]) {
                                                         
                                                        
                                                         //保存最近支付方式
                                                         NSMutableArray *rArray = [NSMutableArray arrayWithArray:[Utils getRecentlyPayList]];
                                                         [rArray insertObject:self.payDict atIndex:0];
                                                         if ([rArray count] > 5) {
                                                             
                                                             [rArray removeLastObject];
                                                         }
                                                         [Utils saveRecentlyPayList:rArray];
                                                         
                                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNoFirstPayMent];
                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                         
                                                     }
                                                 }
                                                 [weakSelf.navigationController pushViewController:rechargeSuceessVCtler animated:YES];
                                             }

                                            //跳转充值成功页面 (跳转到确认页面 )
                                             //百搭产品进来
                                             else if(weakSelf.comeType ==3)
                                             {
                                                 
                                                 if (weakSelf.pageType == 2) {
                                                     
                                                     //订单状态的完成
                                                     if ([OrderStatusCode isEqualToString:@"10101"]) {
                                                         
                                                         
                                                         //保存最近支付方式
                                                         NSMutableArray *rArray = [NSMutableArray arrayWithArray:[Utils getRecentlyPayList]];
                                                         [rArray insertObject:self.payDict atIndex:0];
                                                         if ([rArray count] > 5) {
                                                             
                                                             [rArray removeLastObject];
                                                         }
                                                         [Utils saveRecentlyPayList:rArray];
                                                         
                                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNoFirstPayMent];
                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                         
                                                     }
                                                 }

                                                 CTContractPayDoneVCterl *vc = [[CTContractPayDoneVCterl alloc] init];
                                                 vc.pOrderId = weakSelf.OrderId;
                                                 vc.pOrderStatusDescription = dict[@"Data"][@"OrderStatusDescription"];
                                                 vc.pComboName = weakSelf.comboName;
                                                 NSMutableDictionary *salesDict = [NSMutableDictionary dictionaryWithObject:self.salesProInfo forKey:@"item"]; //modified by shallow 2014-4-23
                                                 //vc.info = self.info ;
                                                 vc.info = salesDict;
                                                 vc.salesProInfo = weakSelf.salesProInfo;
                                                 [self.navigationController pushViewController:vc animated:YES];
                                                
                                             }
                                             //订单查询
                                             else
                                             {
                                                 if (weakSelf.pageType == 2) {
                                                     
                                                     //订单状态的完成
                                                     if ([OrderStatusCode isEqualToString:@"10101"]) {
                                                         
                                                         //保存最近支付方式
                                                         NSMutableArray *rArray = [NSMutableArray arrayWithArray:[Utils getRecentlyPayList]];
                                                         [rArray insertObject:weakSelf.payDict atIndex:0];
                                                         if ([rArray count] > 5) {
                                                             
                                                             [rArray removeLastObject];
                                                         }
                                                         [Utils saveRecentlyPayList:rArray];
                                                         
                                                     }
                                                     
                                                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNoFirstPayMent];
                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                 }
                                                 
                                                 [weakSelf.navigationController popViewControllerAnimated:YES];
                                                 
                                                 
                                             }
                                         }
                                     }
                                 }else{
                                     //跳转充值失败页面 
                                 }
                                 
                                 [SVProgressHUD dismiss];
                             }onError:^(NSError *engineError) {
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
                                 else{
                                     [SVProgressHUD dismiss];
                                     ToastAlertView *alert = [ToastAlertView new];
                                     [alert showAlertMsg:@"系统繁忙，请稍后再试"];
                                 }
                             }];
#endif
    
}
#pragma mark
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationTyp
{
    return YES ;
}
#pragma mark - WebViewDelegate
//added by huangfq 2014-5-27
#if 1
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityViewInfo startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    [self.activityViewInfo stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityViewInfo stopAnimating];
}
#endif
//added by huangfq 2014-5-28
#pragma mark - 支付宝插件

//调用支付宝插件
- (void)toZFBApp{
    
    NSString *appScheme = kZFBQBURLScheme;
#if 0   //测试
    
    NSString *orderString = @"";
    NSString* orderInfo = [self getOrderInfo];
    NSString* signedStr = [self doRsa:orderInfo];
    
    orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                   orderInfo, signedStr, @"RSA"];
    
    NSLog(@"orderInfo:%@",orderString);
    
#endif
    
    
    [AlixLibService payOrder:self.zfbqbOrderString AndScheme:appScheme seletor:@selector(paymentResult:) target:self];
}

//支付宝签名
-(NSString*)doRsa:(NSString*)orderInfo
{
    id<DataSigner> signer;
    signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderInfo];
    return signedString;
}
//订单详情  测试用
-(NSString*)getOrderInfo
{
    /*
	 *点击获取prodcut实例并初始化订单信息
	 */
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.partner = PartnerID;
    order.seller = SellerID;
    
    order.tradeNO = [self generateTradeNO];//self.orderInfo[@"OrderId"]; //订单ID（由商家自行制定）
	order.productName = @"银行卡直充-.1元"; //商品标题
	order.productDescription = @"银行卡直充-.1"; //商品描述
	order.amount = @"0.1";[NSString stringWithFormat:@"%f",0.1]; //商品价格
	order.notifyURL = @"http%3A%2F%2Fwwww.xxx.com"; //回调URL
	
	return [order description];
}


- (NSString *)generateTradeNO
{
	const int N = 15;
	
	NSString *sourceString = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	NSMutableString *result = [[NSMutableString alloc] init] ;
	srand(time(0));
	for (int i = 0; i < N; i++)
	{
		unsigned index = rand() % [sourceString length];
		NSString *s = [sourceString substringWithRange:NSMakeRange(index, 1)];
		[result appendString:s];
	}
	return result;
}

//wap回调函数
-(void)paymentResult:(NSString *)resultd
{
    
    //结果处理
#if ! __has_feature(objc_arc)
    AlixPayResult* result = [[[AlixPayResult alloc] initWithString:resultd] autorelease];
#else
    AlixPayResult* result = [[AlixPayResult alloc] initWithString:resultd];
#endif
	if (result)
    {
		
		if (result.statusCode == 9000)
        {
			/*
			 *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			 */
            
//            //交易成功
//            NSString* key = AlipayPubKey;//签约帐户后获取到的支付宝公钥
//			id<DataVerifier> verifier;
//            verifier = CreateRSADataVerifier(key);
//            
//			if ([verifier verifyString:result.resultString withSign:result.signString])
//            {
//                //验证签名成功，交易结果无篡改
//			}
        
            
            //交易失败
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CTZFBOnPaySucessed];
            [[NSNotificationCenter defaultCenter] postNotificationName:CTZFBOnPaySucessed object:nil userInfo:dict];
            
        }
        else
        {
            //交易失败
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CTZFBOnPaySucessed];
            [[NSNotificationCenter defaultCenter] postNotificationName:CTZFBOnPaySucessed object:nil userInfo:dict];
        }
    }
    else
    {
        //失败
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
