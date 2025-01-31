//
//  CTOrderConfirmVCtler.m
//  CTPocketV4
//
//  Created by apple on 13-11-8.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTOrderConfirmVCtler.h"
#import "CTOrderRechargeVCtler.h"
#import "UIView+RoundRect.h"
#import "CserviceOperation.h"
#import "AppDelegate.h"
#import "CTRechargeVCtler.h"
#import "SVProgressHUD.h"
#import "SIAlertView.h"
#import "ToastAlertView.h"

@interface CTOrderConfirmVCtler ()

@property (nonatomic, strong) UIView  *rechargeView;
@property (nonatomic, strong) UILabel *phoneNumLb;
@property (nonatomic, strong) UILabel *orderPayedDateLb;
@property (nonatomic, strong) UILabel *orderPriceLb;
@property (nonatomic, strong) UILabel *realPriceLb;
@property (nonatomic, strong) UILabel *orderResultLabel;
@property (nonatomic, strong) UILabel *orderIdLabel ;
@property (nonatomic, strong) UILabel *orderStatusLabel ;
@property (nonatomic, strong) UILabel *cardPsdLabel ;
@property (nonatomic, strong) UILabel *rechargeFailedLabel;
//@property (nonatomic, assign) BOOL    rechargeSta
@property (nonatomic, strong) NSDictionary *orderStatusDict;
@property (nonatomic, strong) UIButton *rechargeBtn;

//购买充值卡
@property (nonatomic, strong) UILabel *cardTypeLabel;


//网络请求

@property (nonatomic, strong) CserviceOperation  *qryOrderStatusOpt;
@property (nonatomic, strong) CserviceOperation  *qryCardPsdOpt;

@property (nonatomic, strong) UILabel *realPriceUnitLb;
@property (nonatomic, strong) UILabel *orderPriceUnitLb;

@end

@implementation CTOrderConfirmVCtler

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
    self.view.backgroundColor = PAGEVIEW_BG_COLOR;  // added by zy
    
    self.title = @"订单确认";
    [self setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
    if (self.pageType > 1) {
//        [self setRightButton:[UIImage imageNamed:@"btn_user.png"]];//刷新按钮
    }
    float yPos = 0;
    
    self.orderStatusDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"支付中",@"10702",
                                     @"支付成功",@"10101",
                                     @"系统审核订单",@"10102",
                                     @"订单关闭（超时未支付）",@"10104",
                                     @"订单已审核",@"10103",
                                     @"已取消",@"10701",
                                     @"充值中",@"11104",
                                     @"充值成功",@"11105",
                                     @"充值失败",@"11106",
                                     @"购买成功",@"11108",
                                     @"购买失败",@"11109",
                                     nil];
    [self.view setBackgroundColor:PAGEVIEW_BG_COLOR];

    
    
    //横线
    UIImage *image = [UIImage imageNamed:@"recharge_horline_bg.png"];
    {
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        line.autoresizingMask = UIViewContentModeScaleToFill ;
        line.image = image ;
        [self.view addSubview:line];
    }
    
    
    if (self.pageType > 1) {
//        UILabel *orderResultLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5,self.view.frame.size.width, 20)];
//        orderResultLabel.backgroundColor = [UIColor clearColor];
//        orderResultLabel.text = @"充值成功";
//        orderResultLabel.textColor = [UIColor blackColor];
//        orderResultLabel.textAlignment = UITextAlignmentCenter ;
//        orderResultLabel.font = [UIFont systemFontOfSize:18];
//        [self.view addSubview:orderResultLabel];
//        yPos = CGRectGetMaxY(orderResultLabel.frame) + 10;
//        self.orderResultLabel = orderResultLabel ;
//
//
        UILabel *statusLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 30)];
        statusLb.backgroundColor = [UIColor clearColor];
        statusLb.text = @"充值结果";
        statusLb.textColor = [UIColor blackColor];
        statusLb.textAlignment = UITextAlignmentCenter ;
        statusLb.font = [UIFont systemFontOfSize:18];
        self.orderStatusLabel = statusLb ;
        [self.view addSubview:statusLb];
        
        yPos = CGRectGetMaxY(statusLb.frame) ;
        
    }else{
        yPos = 23;
    }

    //绿色边缘
    {
        UIImageView *briImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, yPos, 6, 28)];
        briImageView.backgroundColor = [UIColor colorWithRed:0x6f/255. green:0xc5/255. blue:0x37/255. alpha:1];//[UIColor colorWithRed:46/255. green:205/255. blue:46/255. alpha:1];    // modified by zy
        [self.view addSubview:briImageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(22, yPos,200, 28)];
        label.backgroundColor = [UIColor clearColor];
        if (self.pageType == 1 || self.pageType == 4) {
            label.text = @"购卡信息";
        }else{
            label.text = @"充值信息";
        }
        label.textColor = [UIColor blackColor];
        label.textAlignment = UITextAlignmentLeft ;
        label.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:label];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(22, CGRectGetMaxY(briImageView.frame)+10, 70, 14)];
        label1.backgroundColor = [UIColor clearColor];
        label1.textColor = [UIColor blackColor];
        if (self.pageType == 4 || self.pageType == 1) {
            label1.text = @"购卡类型 : ";
        }else{
            label1.text = @"充值号码 : ";
        }
        
        label1.font = [UIFont systemFontOfSize:14];
        label1.textAlignment = UITextAlignmentLeft ;
        [self.view addSubview:label1];
        
        UILabel *phoneLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame), CGRectGetMaxY(briImageView.frame)+10, 200, 14)];
        phoneLb.text = @"";
        phoneLb.backgroundColor = [UIColor clearColor];
        phoneLb.textColor = [UIColor colorWithRed:0x6f/255. green:0xc5/255. blue:0x37/255. alpha:1];//[UIColor colorWithRed:46/255. green:205/255. blue:46/255. alpha:1];   // modified by zy
        phoneLb.font = [UIFont systemFontOfSize:14];
        phoneLb.textAlignment = UITextAlignmentLeft ;
        [self.view addSubview:phoneLb];
        self.phoneNumLb = phoneLb ;
        
  
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(22, CGRectGetMaxY(phoneLb.frame)+11,70, 14)];
        label2.backgroundColor = [UIColor clearColor];
        if (self.pageType == 1 || self.pageType == 4) {
            label2.text = @"购卡时间 : ";
        }else{
            label2.text = @"充值时间 : ";
        }
        
        label2.textColor = [UIColor blackColor];
        label2.textAlignment = UITextAlignmentLeft ;
        label2.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:label2];
        
        UILabel *timeLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label2.frame), CGRectGetMaxY(phoneLb.frame)+11, 200, 14)];
        timeLb.backgroundColor = [UIColor clearColor];
        timeLb.textColor = [UIColor blackColor];
        timeLb.font = [UIFont systemFontOfSize:14];
        timeLb.text = @"2013-10-16   19:33:41";
        timeLb.textAlignment = UITextAlignmentLeft ;
        [self.view addSubview:timeLb];
        self.orderPayedDateLb = timeLb ;
        
        //新增
        
        UILabel *label7 = [[UILabel alloc]initWithFrame:CGRectMake(22, CGRectGetMaxY(timeLb.frame)+11,70, 14)];
        label7.backgroundColor  = [UIColor clearColor];
        label7.text = @"订单号    : ";
        label7.textColor = [UIColor blackColor];
        label7.textAlignment = UITextAlignmentLeft ;
        label7.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:label7];
    
        UILabel *labOrderId = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label7.frame), CGRectGetMaxY(timeLb.frame)+11,220, 26)];
        [labOrderId setNumberOfLines:0];
        labOrderId.lineBreakMode = UILineBreakModeWordWrap;
        labOrderId.backgroundColor = [UIColor clearColor];
        labOrderId.text = @"32342343253432423423423";
        labOrderId.textColor = [UIColor blackColor];
        labOrderId.textAlignment = UITextAlignmentLeft ;
        labOrderId.font = [UIFont systemFontOfSize:14];
        self.orderIdLabel = labOrderId ;
        [self.orderIdLabel sizeToFit];
        [self.view addSubview:labOrderId];
        
        //当前为购买卡密成功页或失败页
        yPos = CGRectGetMaxY(labOrderId.frame) ;
        
        if (self.pageType == 4 && [[self.orderInfo objectForKey:@"OrderStatusCode"]isEqualToString:@"11108"]) {
            UILabel *label9 = [[UILabel alloc]initWithFrame:CGRectMake(22,yPos+11,70, 14)];
            label9.backgroundColor = [UIColor clearColor];
            label9.text = @"卡密        : ";
            label9.textColor = [UIColor blackColor];
            label9.textAlignment = UITextAlignmentLeft ;
            label9.font = [UIFont systemFontOfSize:14];
            [self.view addSubview:label9];
            UILabel *cardPsdLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label9.frame),yPos+11,150, 14)];
            cardPsdLb.backgroundColor = [UIColor clearColor];
            cardPsdLb.text = @"";
            cardPsdLb.textColor = [UIColor blackColor];
            cardPsdLb.textAlignment = UITextAlignmentLeft ;
            cardPsdLb.font = [UIFont systemFontOfSize:14];
            
            self.cardPsdLabel = cardPsdLb;
            [self.view addSubview:cardPsdLb];
            
            UIImage *img = [UIImage imageNamed:@"recharge_commit_btn.png"];
            UIImage *image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2,
                                                                               img.size.width/2,
                                                                               img.size.height/2,
                                                                               img.size.width/2)];
            
            UIImageView *chargeView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(cardPsdLb.frame)+5,cardPsdLb.frame.origin.y - 5  , 50, 30)];
            chargeView.backgroundColor = [UIColor clearColor];
            chargeView.image = image ;
            [chargeView dwMakeRoundCornerWithRadius:5];
            chargeView.userInteractionEnabled = YES ;
            self.rechargeView = chargeView;
            [self.view addSubview:chargeView];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"充 值" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.frame = CGRectMake(0, 0, 50, 30);
            [button addTarget:self action:@selector(rechageAciton) forControlEvents:UIControlEventTouchUpInside];
            self.rechargeBtn = button;
            [chargeView addSubview:button];
            
            
            yPos = CGRectGetMaxY(cardPsdLb.frame) ;
        }
        

        UIImageView *line1 = [[UIImageView alloc]initWithFrame:CGRectMake(22, yPos + 16, self.view.frame.size.width-44, 1)];
        line1.autoresizingMask = UIViewContentModeScaleToFill ;
        line1.image = image ;
        [self.view addSubview:line1];
        
        //边缘
        UIImageView *briImgeView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line1.frame)+8, 6, 28)];
        briImgeView1.backgroundColor = [UIColor colorWithRed:0x6f/255. green:0xc5/255. blue:0x37/255. alpha:1];//[UIColor colorWithRed:46/255. green:205/255. blue:46/255. alpha:1];    // modified by zy
        [self.view addSubview:briImgeView1];
        
        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(22,CGRectGetMaxY(line1.frame)+8,100,28)];
        label3.backgroundColor = [UIColor clearColor];
        if (self.pageType == 1 || self.pageType == 4) {
            label3.text = @"购卡金额";
        }else{
            label3.text = @"充值金额"; 
        }
        
        label3.textColor = [UIColor blackColor];
        label3.textAlignment = UITextAlignmentLeft ;
        label3.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:label3];
        
        UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(22,CGRectGetMaxY(briImgeView1.frame)+10,70,14)];
        label4.backgroundColor = [UIColor clearColor];
        if (self.pageType == 1 || self.pageType == 4) {
            label4.text = @"购卡金额 : ";
        }else{
            label4.text = @"充值金额 : ";
        }
        label4.textColor = [UIColor blackColor];
        label4.textAlignment = UITextAlignmentLeft ;
        label4.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:label4];
        
        UILabel *moneyLb= [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label4.frame),CGRectGetMaxY(briImgeView1.frame)+/*10*/7,/*30*/60,12)];
        moneyLb.backgroundColor = [UIColor clearColor];
        moneyLb.text = @"";
        moneyLb.textColor = [UIColor colorWithRed:255/255. green:93/255. blue:62/255. alpha:1];
        moneyLb.textAlignment = UITextAlignmentLeft ;
        moneyLb.font = [UIFont systemFontOfSize:/*14*/18];
        [self.view addSubview:moneyLb];
        self.orderPriceLb = moneyLb ;
        
        UILabel *label6 = [[UILabel alloc]initWithFrame:CGRectMake(22, CGRectGetMaxY(moneyLb.frame)+11, 70, 14)];
        label6.text = @"实付金额 : ";
        label6.backgroundColor = [UIColor clearColor];
        label6.textColor = [UIColor blackColor];
        label6.font = [UIFont systemFontOfSize:14];
        label6.textAlignment = UITextAlignmentLeft ;
        [self.view addSubview:label6];
        
        UILabel *realPayLb= [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label6.frame),CGRectGetMaxY(moneyLb.frame)+/*11*/7,/*30*/60,14)];
        realPayLb.backgroundColor = [UIColor clearColor];
        realPayLb.text = @"";
        realPayLb.textColor = [UIColor colorWithRed:255/255. green:93/255. blue:62/255. alpha:1];
        realPayLb.textAlignment = UITextAlignmentLeft ;
        realPayLb.font = [UIFont systemFontOfSize:/*14*/18];
        [self.view addSubview:realPayLb];
        self.realPriceLb = realPayLb ;
        
    }
    //横线
    {
        UIImageView *line1 = [[UIImageView alloc]initWithFrame:CGRectMake(22, CGRectGetMaxY(self.realPriceLb.frame)+16, self.view.frame.size.width-44, 1)];
        line1.autoresizingMask = UIViewContentModeScaleToFill ;
        line1.image = image ;
        [self.view addSubview:line1];
    }
    
    {
        {
            UIImage *image = [UIImage imageNamed:@"recharge_commit_icon.png"];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 0, image.size.width, image.size.height)];
            imageView.image = image ;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn_hl.png"] forState:UIControlStateHighlighted];
            [button setTitle:@"确 定" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.frame = CGRectMake(22, CGRectGetMaxY(self.realPriceLb.frame)+33 , self.view.frame.size.width-44, 37);
//            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
            [button addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
            
            imageView.frame =CGRectMake(22, CGRectGetMaxY(self.realPriceLb.frame)+33 , self.view.frame.size.width-44, 37);
            [button addSubview:imageView];
            [self.view addSubview:button];
        }
    }
}
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
- (void) setInfo {
    
    NSMutableDictionary * dictionary = self.orderInfo ;
    
    if (self.pageType == 2 || self.pageType == 3) {
    
        //充值只有2种结果  一是充值成功 二是 充值结果
        NSString *OrderStatusCode = [self.orderInfo objectForKey:@"OrderStatusCode"];
        
        if ([OrderStatusCode isEqualToString:@"11105"]) {  //充值成功
            self.orderStatusLabel.text = @"充值成功";
            //支付时间
            self.orderPayedDateLb.text = [self.orderInfo objectForKey:@"OrderPayedDate"];
        }else{
            self.orderStatusLabel.text = [self.orderInfo objectForKey:@"OrderStatusDescription"];
            self.orderPayedDateLb.text = [self.orderInfo objectForKey:@"OrderCreatedDate"];
        }
        //电话号码
        self.phoneNumLb.text = [dictionary objectForKey:@"PhoneNumber"];
        
    }
    
    if (self.pageType == 4) {
        //卡密
        NSString *OrderStatusCode = [self.orderInfo objectForKey:@"OrderStatusCode"];
        NSString *cardType = [dictionary objectForKey:@"CardType"];
        
        if ([cardType integerValue] == 0) {
            self.phoneNumLb.text = @"话费卡";
        }else{
            self.phoneNumLb.text = @"流量卡";
        }
        if ([OrderStatusCode isEqualToString:@"11108"]) {
            self.orderResultLabel.text = @"购买成功";
            self.cardPsdLabel.text = @"";           //设置卡密  请求成功后才设置
            self.orderPayedDateLb.text = [self.orderInfo objectForKey:@"OrderPayedDate"];
            //网络请求查询卡密 并显示充值按钮
            [self qryCardPsd];
            
        }else{
            self.orderStatusLabel.text = [self.orderInfo objectForKey:@"OrderStatusDescription"];
            self.orderPayedDateLb.text = [self.orderInfo objectForKey:@"OrderCreatedDate"];
            self.rechargeView.hidden = YES;
        }
    }
    
    //必须填写的信息
    NSString *orderPrice = [self.orderInfo objectForKey:@"OrderPrice"];           //购买的充值卡金额
    if (self.pageType <2) {
         NSString *OrderPayedDate = [self.orderInfo objectForKey:@"OrderCreatedDate"]; //订单生成时间
         self.orderPayedDateLb.text = OrderPayedDate ;
    }
   
    NSString *realPrice = [dictionary objectForKey:@"RealPrice"];                        //实际付款金额
    self.orderPriceLb.text = orderPrice ;
    self.realPriceLb.text = realPrice ;
    
    //可变的长度充值金额
    [self.orderPriceLb setNumberOfLines:0];
    self.orderPriceLb.lineBreakMode = UILineBreakModeWordWrap;
    NSString *s = orderPrice;
    [self.orderPriceLb sizeToFit];
    if (!self.realPriceUnitLb) {
        UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.orderPriceLb.frame)+2,self.orderPriceLb.frame.origin.y+4,14,14)];
        label5.backgroundColor = [UIColor clearColor];
        label5.text = @"元";
        label5.textColor = [UIColor blackColor];
        label5.font = [UIFont systemFontOfSize:14];
        self.realPriceUnitLb = label5 ;
        [self.view addSubview:label5];
    }else{
    }
    
    //可变的长度真实金额
    [self.realPriceLb setNumberOfLines:0];
    self.realPriceLb.lineBreakMode = UILineBreakModeWordWrap;
    s = realPrice;
    [self.realPriceLb sizeToFit];
    if (!self.orderPriceUnitLb) {
        UILabel *label7 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.realPriceLb.frame)+2,   self.realPriceLb.frame.origin.y+4,14,14)];
        label7.text = @"元";
        label7.backgroundColor = [UIColor clearColor];
        label7.textColor = [UIColor blackColor];
        label7.font = [UIFont systemFontOfSize:14];
        label7.textAlignment = UITextAlignmentLeft ;
        self.orderPriceUnitLb = label7 ;
        [self.view addSubview:label7];
    }else{
    }
    
    //[self.orderIdLabel setNumberOfLines:0];
    self.orderIdLabel.lineBreakMode = UILineBreakModeWordWrap;
    s = [self.orderInfo objectForKey:@"OrderId"];    //订单号
    self.orderIdLabel.text = [self.orderInfo objectForKey:@"OrderId"];
    [self.orderIdLabel sizeToFit];

    //modified by huangfq 2014-5-27

    //电话号码
    if (self.pageType == 0) {
        self.phoneNumLb.text = [self.orderInfo objectForKey:@"PhoneNumber"];
    }
    else if(self.pageType == 1)
    {
        NSString *cardType = [dictionary objectForKey:@"CardType"];
        if ([cardType integerValue] == 0) {
            self.phoneNumLb.text = @"话费卡";
        }else{
            self.phoneNumLb.text = @"流量卡";
        }
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void) commitAction
{
    //  pagetpe  0 确认页  1 银行卡充值话费、流量的成功和失败的跳转页  2 购买充值卡的成功和失败的跳转页
    if (self.pageType == 0) {
        NSString *payUrl = [NSString stringWithFormat:@"http://wapzt.189.cn/pay/onlinePay.do?method=getOrder&userid=%@&id=%@", [self.orderInfo objectForKey:@"UserId"], [self.orderInfo objectForKey:@"OrderId"]];
        
        CTOrderRechargeVCtler *vctler = [CTOrderRechargeVCtler new];
        vctler.jumpUrl = payUrl;
        vctler.title = @"订单支付";
        vctler.fullScreen = YES;
        vctler.rechargeType = 0;
        vctler.rechargeChannel = 0;  //银行卡充话费  //或者充流量
        vctler.orderInfo = self.orderInfo ;
        vctler.comeType  = 2;
        
        [self.navigationController pushViewController:vctler animated:YES];
    }
    else if (self.pageType == 1)
    {
        NSString *payUrl = [NSString stringWithFormat:@"http://wapzt.189.cn/pay/onlinePay.do?method=getOrder&userid=%@&id=%@", [self.orderInfo objectForKey:@"UserId"], [self.orderInfo objectForKey:@"OrderId"]];
        [self.orderInfo setObject:@"4" forKey:@"PageType"];
        CTOrderRechargeVCtler *vctler = [CTOrderRechargeVCtler new];
        vctler.jumpUrl = payUrl;
        vctler.title = @"订单支付";
        vctler.fullScreen = YES;
        vctler.rechargeType = 0;
        vctler.rechargeChannel = 0;  //银行卡充话费
        vctler.comeType  = 2;
        vctler.orderInfo = self.orderInfo ;
        
        [self.navigationController pushViewController:vctler animated:YES];
    }
    else if(self.pageType == 4)                         //充值卡跳转到话费充值页面
    {
        NSArray *VCArray =  self.navigationController.viewControllers;
        for (CTBaseViewController *vc in VCArray) {
            if ([vc isKindOfClass:[CTRechargeVCtler class]]) {
                CTRechargeVCtler *rechargeVC = (CTRechargeVCtler *)vc ;
                rechargeVC.orderInfo = self.orderInfo ;
                [rechargeVC setRechargeCardInfo];                                 //设置充值卡信息
                [self.navigationController popToViewController:vc animated:YES];  //可以跳转
            }
        }
    }else if (self.pageType == 2  || self.pageType == 3){                       //失败页面  跳转到充值页面 ？
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma  mark - netWork reflesh the orderInfo

//查询卡密
- (void) qryCardPsd
{
    NSString *OrderId = @"";
    OrderId =[self.orderInfo objectForKey:@"OrderId"];
    NSString *UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"bank888";
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            OrderId, @"OrderId",
                            UserId, @"UserId",nil];
    
    __block CTOrderConfirmVCtler *weakSelf = self;
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    self.qryCardPsdOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"CardBuyInfo"
                                                                params:params
                                                           onSucceeded:^(NSDictionary *dict)
                          {
                              DDLogInfo(@"查询订单状态 %s--%@", __func__, dict.description);
                              
                              NSDictionary *data = [dict objectForKey:@"Data"];
                              if (data && [data respondsToSelector:@selector(objectForKey:)]) {

                                  NSString *CardNo = [data objectForKey:@"CardNo"];
                                  NSString *CardPwd = [data objectForKey:@"CardPwd"];
                                  //获取卡密
                                  [weakSelf.orderInfo setObject:CardNo forKey:@"CardNo"];
                                  [weakSelf.orderInfo setObject:CardPwd forKey:@"CardPwd"];
                                  
                                  weakSelf.cardPsdLabel.text = CardPwd;
                                  weakSelf.rechargeView.hidden = NO;
                              }
                              [SVProgressHUD dismiss];
                          } onError:^(NSError *engineError) {
                              DDLogInfo(@"%s--%@", __func__, engineError);
                              weakSelf.rechargeView.hidden = YES;
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
//返回信息   返回和充值相同功能
- (void) onLeftBtnAction:(id)sender
{
    if (self.qryCardPsdOpt) {
        [self.qryCardPsdOpt cancel];
        self.qryCardPsdOpt = nil;
    }
    if (self.qryOrderStatusOpt) {
        [self.qryOrderStatusOpt cancel];
        self.qryOrderStatusOpt = nil;
    }
    
    if (self.pageType<4) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{
        NSArray *VCArray =  self.navigationController.viewControllers;
        for (CTBaseViewController *vc in VCArray) {
            if ([vc isKindOfClass:[CTRechargeVCtler class]]) {
                CTRechargeVCtler *rechargeVC = (CTRechargeVCtler *)vc ;
                rechargeVC.orderInfo = self.orderInfo ;
                [rechargeVC setRechargeCardInfo];                                 //设置充值卡信息
                [self.navigationController popToViewController:vc animated:YES];  //可以跳转
            }
        }
    }

}

//刷新数据
- (void) onRightBtnAction:(id)sender
{
    NSString *OrderId = @"";
    OrderId =[self.orderInfo objectForKey:@"OrderId"];
    NSString *UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"bank888";
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            OrderId, @"OrderId",
                            UserId, @"UserId",nil];
    
    __block CTOrderConfirmVCtler *weakSelf = self;
    self.qryOrderStatusOpt =  [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrderInfo"
                                                                     params:params
                                                                onSucceeded:^(NSDictionary *dict)
   {
       DDLogInfo(@"查询订单状态 %s--%@", __func__, dict.description);
       
       NSDictionary *data = [dict objectForKey:@"Data"];
       if (data && [data respondsToSelector:@selector(objectForKey:)]) {
           //更新orderInfo
           NSString *OrderStatusCode = [data objectForKey:@"OrderStatusCode"];
           NSString *OrderPayedDate = [data objectForKey:@"OrderPayedDate"];
           NSString *OrderStatusDescription = [data objectForKey:@"OrderStatusDescription"];
           
           if ([OrderStatusCode isEqualToString:@"11108"] || [OrderStatusCode isEqualToString:@"11105"]) {
               if ([OrderPayedDate isEqualToString:@"null"]) {
                   OrderPayedDate = @""; //刷新付款时间
               }else{
                   OrderPayedDate = [data objectForKey:@"OrderPayedDate"];
               }
               
               //刷新数据
               [weakSelf.orderInfo setObject:OrderStatusCode forKey:@"OrderStatusCode"];
               [weakSelf.orderInfo setObject:OrderPayedDate forKey:@"OrderPayedDate"];
               [weakSelf.orderInfo setObject:OrderStatusDescription forKey:@"OrderStatusDescription"];
               
               [weakSelf setInfo];
           }
       }
     [SVProgressHUD dismiss];
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
       else{
           [SVProgressHUD dismiss];
           ToastAlertView *alert = [ToastAlertView new];
           [alert showAlertMsg:@"系统繁忙，请稍后再试"];
       }
   }];
}
//购买充值卡成功后点击充值跳转到充值首页
- (void) rechageAciton
{
    NSArray *VCArray =  self.navigationController.viewControllers;
    for (CTBaseViewController *vc in VCArray) {
        if ([vc isKindOfClass:[CTRechargeVCtler class]]) {
            CTRechargeVCtler *rechargeVC = (CTRechargeVCtler *)vc ;
            rechargeVC.orderInfo = self.orderInfo ;
            [rechargeVC setRechargeCardInfo];                                 //设置充值卡信息
            [self.navigationController popToViewController:vc animated:YES];  //可以跳转
            
        }
    }
}


@end
