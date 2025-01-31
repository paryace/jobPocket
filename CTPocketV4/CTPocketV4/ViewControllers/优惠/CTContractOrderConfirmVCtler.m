//
//  CTContractOrderConfirmVCtler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 14-3-26.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTContractOrderConfirmVCtler.h"
#import "CserviceOperation.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
//#import "CTNumPayVCtler.h"
#import "CTContractProductPayVCterl.h"
#import "CTPrettyNumberVCtler.h"
#import "CTNumberSelectedVCtler.h"

#define kTagRootScrollview 100

#define kTagInfoViewStartIdx  8910
#define kTagInfoViewInfoView2 8911
#define kTagInfoViewInfoView3 8912
#define kTagInfoViewInfoView4 8913
#define kTagInfoViewInfoView5 8914

#define kTagImageViewFrame   8940
#define kTagInfoViewPrice    8950

@interface CTContractOrderConfirmVCtler ()

@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSString *comboName;
@property (nonatomic, strong) NSDictionary *salesProInfo;
@property (nonatomic, strong) CserviceOperation *createOrderUniOpt;

@end

@implementation CTContractOrderConfirmVCtler

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
    self.title = @"订单确认";
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    self.view.backgroundColor= [UIColor colorWithRed:235/255.0
                                               green:235/255.0
                                                blue:235/255.0
                                               alpha:1.0];
    
    if (_selRecipientDict) {
        [self setOrderPayInfo];
    }
    
    // 生成订单（靓号通用）
    [self createOrderUni];
}

- (void) dealloc{
    NSLog(@"%s",__func__);
}

- (void)setLayoutView
{
    UIScrollView* rootSbview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              CGRectGetWidth(self.view.frame),
                                                                              CGRectGetHeight(self.view.frame))];
    rootSbview.tag =kTagRootScrollview;
    rootSbview.backgroundColor = [UIColor colorWithRed:235/255.0
                                                 green:235/255.0
                                                  blue:235/255.0
                                                 alpha:1.0];
    rootSbview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:rootSbview];
    
    CGFloat xoffset = 15;
    CGFloat yoffset = 15;
    CGRect  trect   = CGRectMake(xoffset, yoffset, self.view.frame.size.width-xoffset*2,30);
    {
        UILabel* labTip = [[UILabel alloc] initWithFrame:trect];
        labTip.backgroundColor = [UIColor clearColor];
        labTip.text = @"您的订单内容如下：";
        labTip.font = [UIFont boldSystemFontOfSize:15];
        [rootSbview addSubview:labTip];
        yoffset += CGRectGetHeight(labTip.frame);
    }
    yoffset += 10;
    //    NSArray* titleList = [NSArray arrayWithObjects:@"订单商品：",@"入网号码：",@"套餐类型：",@"合约内容：", @"套餐类型：",@"配送信息：",@"发票信息：",nil];
    self.BareMetal = [[NSUserDefaults standardUserDefaults] boolForKey:@"BareMetal"]; //是否是裸机
    NSArray* titleList;
    if (self.BareMetal) {
        
        titleList = [NSArray arrayWithObjects:
                     @"订单商品：",
                     @"配送信息：",
                     @"发票信息：",nil];
    }
    else
    {
        if (self.PrestoreNames) {
            
            titleList = [NSArray arrayWithObjects:@"订单商品：",@"入网号码：",
                         @"合约内容：",@"套餐类型：",
                         @"现金预存：",@"配送信息：",
                         @"发票信息：",nil];
        }
        else
        {
            
            titleList = [NSArray arrayWithObjects:@"订单商品：",@"入网号码：",
                         @"合约内容：",@"套餐类型：",
                         @"配送信息：",@"发票信息：",nil];
        }
    }
    
    int tvTag = kTagInfoViewStartIdx;
    for (NSString* title in titleList){
        UIView* tv = [self getLayoutViewWithTitle:title];
        tv.tag = tvTag;
        tv.frame =CGRectMake(tv.frame.origin.x,
                             yoffset,
                             CGRectGetWidth(tv.frame),
                             CGRectGetHeight(tv.frame));
        [rootSbview addSubview:tv];
        yoffset += CGRectGetHeight(tv.frame) + 16;
        tvTag ++;
    }
    
    yoffset -= 10;
    UIView* VtotolPrice = [self getLayoutTotalPrice];
    VtotolPrice.tag   = kTagInfoViewPrice;
    VtotolPrice.frame =CGRectMake(VtotolPrice.frame.origin.x,
                                  yoffset,
                                  CGRectGetWidth(VtotolPrice.frame),
                                  CGRectGetHeight(VtotolPrice.frame));
    [rootSbview addSubview:VtotolPrice];
    yoffset += CGRectGetHeight(VtotolPrice.frame) - 10;
    
    UIButton* btnNextStp = [UIButton buttonWithType:UIButtonTypeSystem];
    btnNextStp.frame = CGRectMake(25, yoffset, self.view.frame.size.width-25*2,35);
    [btnNextStp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNextStp setTitle:@"下一步，支付" forState:UIControlStateNormal];
    UIImage* bgImg =
    [[UIImage imageNamed:@"myOrderBtn.png"] stretchableImageWithLeftCapWidth:20
                                                                topCapHeight:20];
    [btnNextStp setBackgroundImage:bgImg forState:UIControlStateNormal];
    [btnNextStp addTarget:self
                   action:@selector(onPayAction:)
         forControlEvents:UIControlEventTouchUpInside];
    [rootSbview addSubview:btnNextStp];
    yoffset += CGRectGetHeight(btnNextStp.frame)+10;
    // 总数 + 按钮
    rootSbview.contentSize= CGSizeMake(CGRectGetWidth(rootSbview.frame), yoffset);
}

-(UIView*)getLayoutViewWithTitle:(NSString*)title{
    UIView* tv = [[UIView alloc] init];
    tv.frame = CGRectMake(0, 0, self.view.frame.size.width, 42);
    
    CGFloat xval = 15;
    UILabel* labKeyName = [[UILabel alloc] init];
    labKeyName.text = title;
    labKeyName.numberOfLines = 0;
    labKeyName.font = [UIFont systemFontOfSize:14];
    labKeyName.frame= CGRectMake(xval, 0,70,CGRectGetHeight(tv.frame));
    labKeyName.backgroundColor = [UIColor clearColor];
    [tv addSubview:labKeyName];
    
    UIImage * tImage = [[UIImage  imageNamed:@"per_content_bg.png"] stretchableImageWithLeftCapWidth:10
                                                                                        topCapHeight:10];
    
    UIView* rframeView = [[UIView alloc] init];
    rframeView.tag   = kTagImageViewFrame;
    {
        UIImageView* tbgview = [[UIImageView alloc] init];
        tbgview.tag = 99;
        tbgview.userInteractionEnabled  = NO;
        [rframeView addSubview:tbgview];
    }
    
    if ([title isEqualToString:@"订单商品："])
    {
        //外框
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.image = tImage;
        //内容
        UILabel* labSalesName = [[UILabel alloc] init];
        labSalesName.text = self.SalesName;
        labSalesName.numberOfLines = 0;
        labSalesName.lineBreakMode = UILineBreakModeWordWrap;
        labSalesName.tag  = 100;
        labSalesName.font = [UIFont systemFontOfSize:14];
        labSalesName.frame= CGRectMake(10,15,CGRectGetWidth(tv.frame)-70-45,CGRectGetHeight(labSalesName.frame));
        [labSalesName sizeToFit];
        labSalesName.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:labSalesName];
        
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame), 0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetMaxY(labSalesName.frame)+15);
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
        
    }
    else if ([title isEqualToString:@"现金预存："])
    {
        //外框
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.image = tImage;
        //内容
        UILabel* cashName = [[UILabel alloc] init];
        cashName.text = self.PrestoreNames;
//        cashName.text = @"100元";
        cashName.numberOfLines = 1;
        cashName.tag  = 100;
        cashName.font = [UIFont systemFontOfSize:14];
        cashName.frame= CGRectMake(10,15,CGRectGetWidth(tv.frame)-70-45,CGRectGetHeight(cashName.frame));
        [cashName sizeToFit];
        cashName.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:cashName];
        
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame), 0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetMaxY(cashName.frame)+15);
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
    }
    else if([title isEqualToString:@"入网号码："])
    {
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.image = tImage;
        
        UILabel* labPhone = [[UILabel alloc] init];
        labPhone.tag    = 100;
        labPhone.text = self.Phone;
        labPhone.font = [UIFont systemFontOfSize:14];
        labPhone.frame= CGRectMake(10,15,CGRectGetWidth(tv.frame)-70-45,CGRectGetHeight(labPhone.frame));
        labPhone.backgroundColor = [UIColor clearColor];
        [labPhone sizeToFit];
        [rframeView addSubview:labPhone];
        
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame), 0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetMaxY(labPhone.frame)+15);
        
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
        
    }else if([title isEqualToString:@"合约内容："])
    {
        
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.image = tImage;
        
        UILabel* labContract = [[UILabel alloc] init];
        labContract.text = [NSString stringWithFormat:@"%@\n%@",self.ContractDescription, self.MinAmount];
        labContract.tag    = 100;
        labContract.numberOfLines = 2;
        labContract.font = [UIFont systemFontOfSize:14];
        labContract.frame= CGRectMake(10,15,CGRectGetWidth(tv.frame)-70-45,CGRectGetHeight(rframeView.frame));
        labContract.backgroundColor = [UIColor clearColor];
        [labContract sizeToFit];
        [rframeView addSubview:labContract];
        
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame), 0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetMaxY(labContract.frame)+15);
        
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
        
    }else if([title isEqualToString:@"套餐类型："])
    {
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.image = tImage;
        [tbgview setNeedsLayout];
        
        UILabel* labProduct = [[UILabel alloc] init];
        labProduct.text = self.ComboDescription;
        labProduct.numberOfLines = 2;
        labProduct.tag    = 100;
        labProduct.font = [UIFont systemFontOfSize:14];
        labProduct.frame= CGRectMake(10,15,CGRectGetWidth(tv.frame)-70-45,CGRectGetHeight(labProduct.frame));
        labProduct.backgroundColor = [UIColor clearColor];
        [labProduct sizeToFit];
        [rframeView addSubview:labProduct];
        self.comboName = labProduct.text;
        
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame), 0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetMaxY(labProduct.frame)+15);
        
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
        
    }else if([title isEqualToString:@"配送信息："])
    {
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.image = tImage;
        
        UILabel* labUname = [[UILabel alloc] init];
//        labUname.text = @"王海   020-38095910";
        labUname.text = [NSString stringWithFormat:@"%@   %@", [self.selRecipientDict objectForKey:@"UserName"], [self.selRecipientDict objectForKey:@"CusMobile"]];
        labUname.tag    = 100;
        labUname.font = [UIFont systemFontOfSize:14];
        labUname.frame= CGRectMake(10,15,CGRectGetWidth(tv.frame)-130,20);
        labUname.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:labUname];
        
        UILabel* labaddress = [[UILabel alloc] init];
        labaddress.numberOfLines = 2;
        labaddress.tag    = 101;
//        labaddress.text = @"北京市海淀区杏石路99号3栋西山赢府D座100093";
        labaddress.text = [NSString stringWithFormat:@"%@", [self.selRecipientDict objectForKey:@"Address"]];
        labaddress.font = [UIFont systemFontOfSize:14];
        labaddress.frame= CGRectMake(10,CGRectGetMaxY(labUname.frame),
                                     CGRectGetWidth(tv.frame)-130,
                                     CGRectGetHeight(labaddress.frame));
        labaddress.backgroundColor = [UIColor clearColor];
        [labaddress sizeToFit];
        [rframeView addSubview:labaddress];
        
        UIButton* modifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [modifyBtn setTitle: @"修改" forState:UIControlStateNormal];
        [modifyBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [modifyBtn setTitleColor:[UIColor colorWithRed:103/255.0 green:194/255.0 blue:54/255.0 alpha:1.0]
                        forState:UIControlStateNormal];
        [modifyBtn addTarget:self
                      action:@selector(onRecipientModify:)
            forControlEvents:UIControlEventTouchUpInside];
        [rframeView addSubview:modifyBtn];
        
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame),
                                      0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetMaxY(labaddress.frame)+15);
        
        modifyBtn.frame= CGRectMake(CGRectGetWidth(tv.frame)-150,
                                    CGRectGetHeight(rframeView.frame)-40,
                                    40,
                                    40);
        
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
    }
    else if([title isEqualToString:@"发票信息："])
    {
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.image = tImage;
        
        UILabel* labPerson = [[UILabel alloc] init];
//        labPerson.text = @"抬头：个人"; 个人
        labPerson.text = [NSString stringWithFormat:@"抬头：%@", [self.selRecipientDict objectForKey:@"InvoiceInfoType"]];
        labPerson.numberOfLines = 2;
        labPerson.tag    = 100;
        labPerson.font = [UIFont systemFontOfSize:14];
        labPerson.frame= CGRectMake(10,15,CGRectGetWidth(tv.frame) - 130,CGRectGetHeight(labPerson.frame));
        [labPerson sizeToFit];
        labPerson.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:labPerson];
        
        UILabel* labContent = [[UILabel alloc] init];
//        labContent.text = @"抬头：个人"; 内容
        labContent.text = [NSString stringWithFormat:@"内容：%@", [self.selRecipientDict objectForKey:@"InvoiceContentType"]];
        labContent.tag    = 100;
        labContent.numberOfLines = 0;
        labContent.font = [UIFont systemFontOfSize:14];
        labContent.frame= CGRectMake(10,
                                     CGRectGetMaxY(labPerson.frame),
                                     CGRectGetWidth(tv.frame)-130,
                                     CGRectGetHeight(labContent.frame));
        [labContent sizeToFit];
        labContent.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:labContent];
        
        UIButton* modifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [modifyBtn setTitle: @"修改" forState:UIControlStateNormal];
        [modifyBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [modifyBtn setTitleColor:[UIColor colorWithRed:103/255.0 green:194/255.0 blue:54/255.0 alpha:1.0]
                        forState:UIControlStateNormal];
        [modifyBtn addTarget:self
                      action:@selector(onPayCheckModify:)
            forControlEvents:UIControlEventTouchUpInside];
        [rframeView addSubview:modifyBtn];
        
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame), 0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetMaxY(labContent.frame)+15);
        
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
        
        modifyBtn.frame= CGRectMake(CGRectGetWidth(tv.frame)-150,
                                    CGRectGetHeight(rframeView.frame)-40,
                                    40,
                                    40);
        
        // 测试发票接口
        // NSLog(@"InvoiceType is %@,\nInvoiceContentType is %@, \nInvoiceInfo is %@, \nInvoiceInfoType is %@" ,self.InvoiceType, self.InvoiceContentType, self.InvoiceInfo, self.InvoiceInfoType);
        
    }
    
    if (CGRectGetHeight(tv.frame) < CGRectGetHeight(rframeView.frame))
    {
        labKeyName.frame = CGRectMake(labKeyName.frame.origin.x,
                                      labKeyName.frame.origin.y,
                                      CGRectGetWidth(labKeyName.frame),
                                      CGRectGetHeight(rframeView.frame));
        
        tv.frame = CGRectMake(tv.frame.origin.x, 0,
                              CGRectGetWidth(tv.frame),
                              CGRectGetHeight(rframeView.frame));
    }
    [tv addSubview:rframeView];
    DLog(@"*rframeView***%@",NSStringFromCGRect(rframeView.frame));
    return tv;
}

-(UIView*)getLayoutTotalPrice{
    UIView* tv = [[UIView alloc] init];
    tv.frame = CGRectMake(0, 0, self.view.frame.size.width, 42);
    
    CGFloat leftval =15;
    UILabel* labKeyYuan = [[UILabel alloc] init];
    labKeyYuan.text = @"元";
    labKeyYuan.tag  = 100;
    labKeyYuan.font = [UIFont systemFontOfSize:14];
    labKeyYuan.frame= CGRectMake(CGRectGetWidth(tv.frame)-20-leftval,0,20,20);
    labKeyYuan.backgroundColor = [UIColor clearColor];
    [tv addSubview:labKeyYuan];
    
    UILabel* labKeyValue = [[UILabel alloc] init];
    labKeyValue.text = @"查询中...";
    labKeyValue.tag  = 101;
    labKeyValue.font = [UIFont systemFontOfSize:14];
    labKeyValue.textColor = [UIColor colorWithRed:233/255.0
                                            green:80/255.0
                                             blue:63/255.0
                                            alpha:1.0];
    labKeyValue.frame= CGRectMake(CGRectGetMinX(labKeyYuan.frame),0,200,20);
    labKeyValue.backgroundColor = [UIColor clearColor];
    CGSize fitSize = [labKeyValue sizeThatFits:labKeyValue.frame.size];
    DLog(@"fitsize=%@",NSStringFromCGSize(fitSize));
    labKeyValue.frame = CGRectMake(CGRectGetMinX(labKeyYuan.frame)-fitSize.width,
                                   labKeyValue.frame.origin.y,
                                   fitSize.width, 20);
    [tv addSubview:labKeyValue];
    
    UILabel* labKey = [[UILabel alloc] init];
    labKey.text = @"实付金额：";//@"订单金额：";
    labKey.font = [UIFont systemFontOfSize:14];
    labKey.tag  = 102;
    labKey.frame= CGRectMake(CGRectGetMinX(labKeyValue.frame),0,100,20);
    labKey.backgroundColor = [UIColor clearColor];
    fitSize = [labKey sizeThatFits:labKeyValue.frame.size];
    DLog(@"fitsize=%@",NSStringFromCGSize(fitSize));
    labKey.frame = CGRectMake(CGRectGetMinX(labKeyValue.frame)-fitSize.width,
                              labKey.frame.origin.y,
                              fitSize.width, 20);
    [tv addSubview:labKey];
    
    
    return tv;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.createOrderUniOpt) {
        [self.createOrderUniOpt cancel];
        self.createOrderUniOpt = nil;
    }
}

-(void)setOrderPayInfo{
    UIScrollView* rootSbview = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
    if (!rootSbview) {
        return;
    }
    
    // @"入网号码："
    int tag = kTagInfoViewStartIdx;
    {
        UIView* tv = [rootSbview viewWithTag:tag];
        UIImageView* imgframev = (UIImageView*)[tv viewWithTag:kTagImageViewFrame];
        if (imgframev) {
            //            UILabel* labValue = (UILabel*)[imgframev viewWithTag:100];
            //labValue.text = [_selRecipientDict objectForKey:@"UserName"];
        }
    }
    tag++;
    // @"套餐类型："
    {
        UIView* tv = [rootSbview viewWithTag:tag];
        UIImageView* imgframev = (UIImageView*)[tv viewWithTag:kTagImageViewFrame];
        if (imgframev) {
            //            UILabel* labValue = (UILabel*)[imgframev viewWithTag:100];
            //labValue.text = @""; the value u what to set
        }
    }
    tag++;
    // @"手  机 卡\r类      型："
    {
        UIView* tv = [rootSbview viewWithTag:tag];
        // TODO:
        UIImageView* imgframev = (UIImageView*)[tv viewWithTag:kTagImageViewFrame];
        if (imgframev) {
            //            UILabel* labValue = (UILabel*)[imgframev viewWithTag:100];
            //labValue.text = @""; the value u what to set
        }
    }
    tag++;
    // @"配送信息："
    {
        UIView* tv = [rootSbview viewWithTag:tag];
        UIImageView* imgframev = (UIImageView*)[tv viewWithTag:kTagImageViewFrame];
        if (imgframev) {
            /*
             Auther         :gongxt
             Description    :多余的label
             */
//            UILabel* labLine1 = (UILabel*)[imgframev viewWithTag:100];
//            labLine1.text = [NSString stringWithFormat:@"%@  %@",
//                             [_selRecipientDict objectForKey:@"UserName"],
//                             [_selRecipientDict objectForKey:@"CusMobile"]
//                             ];
            UILabel* labLine2 = (UILabel*)[imgframev viewWithTag:101];
            labLine2.text = [_selRecipientDict objectForKey:@"Address"];
        }
    }
    tag++;
    // @"支付方式："
    {
        UIView* tv = [rootSbview viewWithTag:tag];
        UIImageView* imgframev = (UIImageView*)[tv viewWithTag:kTagImageViewFrame];
        if (imgframev) {
            //            UILabel* labLine1 = (UILabel*)[imgframev viewWithTag:100];
            //labValue.text = @""; the value u what to set
        }
    }
    // @总价格
    {
        UIView* tv = [rootSbview viewWithTag:kTagInfoViewPrice];
        UILabel* lab01 = (UILabel*)[tv viewWithTag:100];
        UILabel* lab02 = (UILabel*)[tv viewWithTag:101];
        UILabel* lab03 = (UILabel*)[tv viewWithTag:102];
        //lab02.text = @""; value set here
        CGSize fitSize = [lab02 sizeThatFits:lab02.frame.size];
        
        DLog(@"fitsize=%@",NSStringFromCGSize(fitSize));
        lab02.frame = CGRectMake(CGRectGetMinX(lab01.frame)-fitSize.width,
                                 lab02.frame.origin.y,
                                 fitSize.width,
                                 lab02.frame.size.height);
        lab03.frame = CGRectMake(CGRectGetMinX(lab02.frame)-lab03.frame.size.width,
                                 lab03.frame.origin.y,
                                 lab03.frame.size.width,
                                 lab03.frame.size.height);
    }
}

#pragma mark -actions
-(void)onSelectRecipientNotify:(NSNotification*)notify
{
    NSDictionary* dict   = [notify userInfo];
    self.selRecipientDict= [NSDictionary dictionaryWithDictionary:dict];
    [self setOrderPayInfo];
}

-(void)onPayAction:(id)sender
{
    //    CPayDoneVctler * vc = [[CPayDoneVctler alloc] init];
    //    [self.navigationController pushViewController:vc animated:YES];
    [self submitOrderUni];
}

// 套卡修改
-(void)onCardTypeModify:(id)sender{
    // TODO:
}
// 配送修改
-(void)onRecipientModify:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
// 发票修改
-(void)onPayCheckModify:(id)sender{
    // TODO:
    [self.navigationController popViewControllerAnimated:YES];
}

// 生成订单
- (void)createOrderUni
{
    [SVProgressHUD showWithStatus:@"生成订单中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *ShopId = ESHORE_ShopId ;
    NSString *UserId = [[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"]?[[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"]:@"bank888";
    NSString *PhoneNumber = self.PhoneNumber;
    NSString *SalesProdId = self.SalesProdId;
//    NSString *SalesProdId = @"00000000F632DB0C012610ADE043433210AC7EBD";
    NSString *AbType = [NSString stringWithFormat:@"%d", self.AbType];
    NSString *SalesType = [NSString stringWithFormat:@"%d", self.SalesProdType];
    
    // 创建请求数据字典
    self.BareMetal = [[NSUserDefaults standardUserDefaults] boolForKey:@"BareMetal"];
    NSDictionary *params;
    if (self.BareMetal) {
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  ShopId,@"ShopId",
                  UserId,@"UserId",
                  SalesProdId,@"SalesProdId",
                  AbType, @"AbType",
                  SalesType, @"SalesType",
                  nil];
    }
    else
    {
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  ShopId,@"ShopId",
                  UserId,@"UserId",
                  SalesProdId,@"SalesProdId",
                  AbType, @"AbType",
                  SalesType, @"SalesType",
                  PhoneNumber,@"PhoneNumber",
                  nil];
    }
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"createOrderBd"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          [SVProgressHUD dismiss];
                                          //TODO:保存生成订单
                                          self.orderId = dict[@"Data"][@"OrderId"];
                                          //NSLog(@"dic is %@", dict);
                                          NSDictionary *dic = dict[@"Data"][@"Items"];
                                          self.ComboDescription = dic[@"Item"][@"ComboDescription"]; // 套餐类型
                                          self.ContractDescription = dic[@"Item"][@"ContractDescription"]; //合约内容
                                          self.PrestoreNames = dic[@"Item"][@"PrestoreNames"][@"Item"]; //销售品关联号码预存款金额
                                          [self setLayoutView]; //设置订单View  modified by shallow
                                          {
                                              UIScrollView* rootSbview = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
                                              UIView* tv = [rootSbview viewWithTag:kTagInfoViewPrice];
                                              UILabel* labKeyValue = (UILabel*)[tv viewWithTag:101];
#if 0                                           // modified by zy, 2014-02-19
                                              labKeyValue.text = dict[@"Data"][@"TotalPrice"];
#else
                                              if (dict[@"Data"][@"RealPrice"] != [NSNull null] &&
                                                  dict[@"Data"][@"RealPrice"] != nil)
                                              {
                                                  labKeyValue.text = dict[@"Data"][@"RealPrice"];
                                              }
#endif
                                              self.salesProInfo = dict[@"Data"][@"Items"][@"Item"];
                                          }
                                      } onError:^(NSError *engineError) {
                                          
//                                          [SVProgressHUD showErrorWithStatus:engineError.localizedDescription];
                                          [SVProgressHUD showErrorWithStatus:@"创建订单失败，请返回检查。"];
                                          
                                          //                                          [self.navigationController popViewControllerAnimated:YES];
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

// 提交订单
- (void)submitOrderUni
{
    
    if (!self.orderId) {
        return ;
    }
    
    [SVProgressHUD showWithStatus:@"提交订单中..." maskType:SVProgressHUDMaskTypeGradient];
    
    if (self.createOrderUniOpt) {
        [self.createOrderUniOpt cancel];
        self.createOrderUniOpt = nil;
    }
    
    // 收货地址信息  DeliveryInfo接口
    NSDictionary *deliveryInfo = @{@"CusMobile":self.selRecipientDict[@"CusMobile"],
                                   @"PostCode": (self.selRecipientDict[@"PostCode"] ? self.selRecipientDict[@"PostCode"] : @""),
                                   @"City": self.selRecipientDict[@"City"],
                                   @"CusEmail": (self.selRecipientDict[@"CusEmail"] ? self.selRecipientDict[@"CusEmail"] : @""),
                                   @"County": self.selRecipientDict[@"County"],
                                   @"Address": self.selRecipientDict[@"Address"],
                                   @"Province": self.selRecipientDict[@"Province"],
                                   @"UserName": self.selRecipientDict[@"UserName"]};
    
    // 发票信息 InvoiceInfo接口
    NSDictionary *InvoiceInfo = @{@"InvoiceType":self.InvoiceType,
                                  @"InvoiceContentType":self.InvoiceContentType,
                                  @"InvoiceInfo":self.InvoiceInfo,
                                  @"InvoiceInfoType":self.InvoiceInfoType
                                  };// 发票抬头和内容
    
    // 用户入网信息 CustomerInfo接口
    self.BareMetal = [[NSUserDefaults standardUserDefaults] boolForKey:@"BareMetal"];
    NSDictionary *customerInfo;
    NSDictionary *params;
    if (self.BareMetal)
    {
        params = @{@"Remark": @"",
                   @"DeliveryTime": @"1",
                   @"UserId": ([[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] ? [[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] : @"bank888"),
                   @"OrderId": (self.orderId == nil ?  @"":self.orderId),
                   @"PayMethod": @"0",
                   @"Type": @"1",
                   @"DeliveryInfo": deliveryInfo,
                   @"InvoiceInfo" : InvoiceInfo};
    }
    else
    {
        customerInfo = @{@"Idcard_Postcode": @""/*(self.uPostCode ? self.uPostCode : @"_")*/,//add by liuruxian 2014-03-06
                                       @"Cust_Name": self.uName?self.uName:@"",
                                       @"Cust_Affress": self.uAddress?self.uAddress:@"",
                                       @"Phone_Number": self.salesProInfo[@"PhoneNumber"],// motified by liuruxian 2014-03-28
                                       @"Order_Id": (self.orderId == nil ?  @"":self.orderId),
                                       @"Idcardno": self.uID?self.uID:@""};
        
        params = @{@"Remark": @"",
                   @"DeliveryTime": @"1",
                   @"UserId": ([[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] ? [[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] : @"bank888"),
                   @"OrderId": (self.orderId == nil ?  @"":self.orderId),
                   @"PayMethod": @"0",
                   @"Type": @"1",
                   @"DeliveryInfo": deliveryInfo,
                   @"InvoiceInfo" : InvoiceInfo,
                   @"CustomerInfo": customerInfo};
    }
    
    
    self.createOrderUniOpt = [MyAppDelegate.cserviceEngine
                               postXMLWithCode:@"submitOrderBd"
                                        params:params
                                   onSucceeded:^(NSDictionary *dict) {
                                       [SVProgressHUD dismiss];
                                       // 构造支付页面URL
                                       NSString *myOrderId = dict[@"Data"][@"OrderId"];
                                       NSString *userId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"bank888";
                                       NSString *payUrl = [NSString stringWithFormat:@"http://wapzt.189.cn/pay/onlinePay.do?method=getOrder&userid=%@&id=%@", userId, myOrderId];
                                       CTContractProductPayVCterl *vc = [[CTContractProductPayVCterl alloc] init];
                                       vc.orderId = myOrderId;
                                       vc.payUrl = payUrl;
                                       vc.comboName = self.comboName ? self.comboName : @"";
                                       vc.info = self.info;
                                       vc.salesProInfo = self.salesProInfo ;
                                       [self.navigationController pushViewController:vc animated:YES];
                                       
                                   } onError:^(NSError *engineError) {
                                       [SVProgressHUD dismiss];
                                       if (engineError.userInfo[@"ResultCode"])
                                       {
                                           if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"192"]) {
                                               SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                                andMessage:@"您选的号码必定人人喜爱，已被人抢先一步，请重新选择一个号码。"];
                                               [alertView addButtonWithTitle:@"换个号码"
                                                                        type:SIAlertViewButtonTypeDefault
                                                                     handler:^(SIAlertView *alertView) {
                                                                         //add by liuruxian 2014-03-04
                                                                         NSArray *VCtlerArary =  self.navigationController.viewControllers ;
                                                                         BOOL isFound = NO;
                                                                         for (id vc in VCtlerArary) {
                                                                             if ([vc isKindOfClass:[CTNumberSelectedVCtler class]]) {
                                                                                 isFound = YES ;
                                                                                 [self.navigationController popToViewController:vc animated:YES];
                                                                                 break ;
                                                                             }
                                                                         }
                                                                         if (!isFound) {
                                                                             CTNumberSelectedVCtler *vc = [CTNumberSelectedVCtler new];
                                                                             vc.isCreate = YES;
                                                                             [self.navigationController pushViewController:vc animated:YES];
                                                                             
                                                                             [[NSNotificationCenter defaultCenter] postNotificationName:CTNumberSelectedNotification object:nil];
                                                                         }
                                                                     }];
                                               alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                               [alertView show];
                                           }
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
                                           else
                                           {
                                               SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                                andMessage:engineError.userInfo[@"NSLocalizedDescription"]];
                                               
                                               [alertView addButtonWithTitle:@"确定"
                                                                        type:SIAlertViewButtonTypeDefault
                                                                     handler:^(SIAlertView *alertView){
                                                                     }];
                                               alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                               [alertView show];
                                           }
                                       }
                                   }];
}

@end
