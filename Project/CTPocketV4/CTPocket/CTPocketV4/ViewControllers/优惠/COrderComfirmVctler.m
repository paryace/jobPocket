//
//  COrderComfirmVctler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 14-1-17.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

// 订单确认：

#import "COrderComfirmVctler.h"
#import "CPayDoneVctler.h"
#import "CRecipientSelectVctler.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"
#import "CTNumPayVCtler.h"
#import "CserviceOperation.h"

//add by liuruxian 2014-03-04
#import "CTPrettyNumberVCtler.h"
#import "CTCity.h"

//added by huangfq 2014-5-30
#import "CTOrderRechargeVCtler.h"
#import "Utils.h"

#define kTagRootScrollview 100

#define kTagInfoViewStartIdx  8910
#define kTagInfoViewInfoView2 8911
#define kTagInfoViewInfoView3 8912
#define kTagInfoViewInfoView4 8913
#define kTagInfoViewInfoView5 8914

#define kTagImageViewFrame   8940
#define kTagInfoViewPrice    8950

@interface COrderComfirmVctler ()
@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSString *comboName;
@property (nonatomic, strong) NSDictionary *salesProInfo;
@property (nonatomic, strong) CserviceOperation *createOrderUniOpt;
//
-(UIView*)getLayoutViewWithTitle:(NSString*)title;
-(UIView*)getLayoutTotalPrice;
-(void)setOrderPayInfo;
//actions
-(void)onPayAction:(id)sender;
-(void)onCardTypeModify:(id)sender;  // 套卡修改
-(void)onRecipientModify:(id)sender; // 配送修改
-(void)onPayCheckModify:(id)sender;  // 发票修改
//notify
-(void)onSelectRecipientNotify:(NSNotification*)notify;
@end

@implementation COrderComfirmVctler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"订单确认";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSelectRecipientNotify:)
                                                     name:CTP_MSG_SELECT_RECIPIENT
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    self.view.backgroundColor= [UIColor colorWithRed:235/255.0
                                               green:235/255.0
                                                blue:235/255.0
                                               alpha:1.0];
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
    NSArray* titleList = [NSArray arrayWithObjects:@"入网号码：",@"套餐类型：",@"手  机 卡\r类      型：",
                          @"配送信息：",/*@"发票信息：",*/@"支付方式：", nil];
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
    
    if (_selRecipientDict) {
        [self setOrderPayInfo];
    }
    
    // 生成订单（靓号通用）
    [self createOrderUni];
}

- (void) dealloc{
    NSLog(@"%s",__func__);
}

-(UIView*)getLayoutViewWithTitle:(NSString*)title{
    UIView* tv = [[UIView alloc] init];
    tv.frame = CGRectMake(0, 0, self.view.frame.size.width, 42);

    CGFloat xval = 15;
    UILabel* labKeyName = [[UILabel alloc] init];
    labKeyName.text = title;
    labKeyName.numberOfLines = 2;
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
    rframeView.tag   = kTagImageViewFrame;
    if ([title isEqualToString:@"入网号码："])
    {
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame), 0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetHeight(tv.frame));
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
        tbgview.image = tImage;

        //
        UILabel* labPhone = [[UILabel alloc] init];
        labPhone.text = self.info[@"item"][@"PhoneNumber"];
        labPhone.numberOfLines = 2;
        labPhone.tag  = 100;
        labPhone.font = [UIFont systemFontOfSize:14];
        labPhone.frame= CGRectMake(5,0,CGRectGetWidth(tv.frame)-10,CGRectGetHeight(tv.frame));
        labPhone.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:labPhone];

    }else if([title isEqualToString:@"套餐类型："])
    {
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame), 0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetHeight(tv.frame));
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
        tbgview.image = tImage;

        UILabel* labProduct = [[UILabel alloc] init];
        {
            NSUInteger inx = [self.info[@"index"] integerValue];
            // 根据ComboType来显示套餐名
            if ([self.info[@"combo"][@"ComboType"] isEqualToString:@"883"]) {
                // 纯流量
                labProduct.text = self.info[@"combo"][@"ComboName"];
            }
            else if ([self.info[@"combo"][@"ComboType"] isEqualToString:@"881"]) {
                // 云卡
                if ([self.info[@"package"][@"PackageItem"] isKindOfClass:[NSDictionary class]]) {
                    labProduct.text = self.info[@"package"][@"PackageItem"][@"Name"];
                }
                else if ([self.info[@"package"][@"PackageItem"] isKindOfClass:[NSArray class]]) {
                    labProduct.text = self.info[@"package"][@"PackageItem"][inx][@"Name"];
                }
            }
            else if ([self.info[@"combo"][@"ComboType"] isEqualToString:@"884"]) {
                // 乐享3G上网版
                if ([self.info[@"package"][@"PackageItem"] isKindOfClass:[NSDictionary class]]) {
                    labProduct.text = [NSString stringWithFormat:@"%@%@元", self.info[@"combo"][@"ComboName"], self.info[@"package"][@"PackageItem"][@"Name"]];
                }
                else if ([self.info[@"package"][@"PackageItem"] isKindOfClass:[NSArray class]]) {
                    labProduct.text = [NSString stringWithFormat:@"%@%@元", self.info[@"combo"][@"ComboName"], self.info[@"package"][@"PackageItem"][inx][@"Name"]];
                }
            }
            self.comboName = labProduct.text;
        }
        labProduct.numberOfLines = 2;
        labProduct.tag    = 100;
        labProduct.font = [UIFont systemFontOfSize:14];
        labProduct.frame= CGRectMake(5,0,CGRectGetWidth(tv.frame)-10,CGRectGetHeight(tv.frame));
        labProduct.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:labProduct];
    }else if([title isEqualToString:@"手  机 卡\r类      型："])
    {
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame), 0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetHeight(tv.frame));
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
        tbgview.image = tImage;
        
        UILabel* labProduct = [[UILabel alloc] init];
        labProduct.text = self.info[@"UimName"];
        labProduct.tag    = 100;
        labProduct.font = [UIFont systemFontOfSize:14];
        labProduct.frame= CGRectMake(5,0,CGRectGetWidth(rframeView.frame)-50,CGRectGetHeight(rframeView.frame));
        labProduct.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:labProduct];
    }else if([title isEqualToString:@"配送信息："])
    {
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame),
                                      0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      85);
        //rframeView.backgroundColor = [UIColor greenColor];
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
        tbgview.image = tImage;
        
        UILabel* labUname = [[UILabel alloc] init];
        labUname.text = @"王海   020-38095910";
        labUname.tag    = 100;
        labUname.font = [UIFont systemFontOfSize:14];
        labUname.frame= CGRectMake(5,10,CGRectGetWidth(tv.frame)-50,20);
        labUname.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:labUname];
        
        UILabel* labaddress = [[UILabel alloc] init];
        labaddress.numberOfLines = 2;
        labaddress.tag    = 101;
        labaddress.text = @"推荐个100M的路由给我要5口的要小巧大牌子便宜.";
        labaddress.font = [UIFont systemFontOfSize:14];
        labaddress.frame= CGRectMake(5,CGRectGetMaxY(labUname.frame),
                                     CGRectGetWidth(rframeView.frame)-50,
                                     CGRectGetHeight(rframeView.frame)-CGRectGetMaxY(labUname.frame));
        labaddress.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:labaddress];

        UIButton* modifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [modifyBtn setTitle: @"修改" forState:UIControlStateNormal];
        [modifyBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        modifyBtn.frame= CGRectMake(CGRectGetMaxX(labaddress.frame),
                                    CGRectGetHeight(rframeView.frame)-40,
                                    40,
                                    40);
        [modifyBtn setTitleColor:[UIColor colorWithRed:103/255.0 green:194/255.0 blue:54/255.0 alpha:1.0]
                        forState:UIControlStateNormal];
        [modifyBtn addTarget:self
                      action:@selector(onRecipientModify:)
            forControlEvents:UIControlEventTouchUpInside];
        [rframeView addSubview:modifyBtn];

    }
    else if([title isEqualToString:@"支付方式："])
    {
        rframeView.frame = CGRectMake(CGRectGetMaxX(labKeyName.frame), 0,
                                      CGRectGetWidth(tv.frame)-CGRectGetMaxX(labKeyName.frame)-xval,
                                      CGRectGetHeight(tv.frame));
        UIImageView* tbgview = (UIImageView*)[rframeView viewWithTag:99];
        tbgview.frame = CGRectMake(0,0,
                                   CGRectGetWidth(rframeView.frame),
                                   CGRectGetHeight(rframeView.frame));
        tbgview.image = tImage;
        [tbgview setNeedsLayout];

        UILabel* labProduct = [[UILabel alloc] init];
        labProduct.text = @"在线支付";
        labProduct.numberOfLines = 2;
        labProduct.tag    = 100;
        labProduct.font = [UIFont systemFontOfSize:14];
        labProduct.frame= CGRectMake(5,0,CGRectGetWidth(rframeView.frame)-10,CGRectGetHeight(rframeView.frame));
        labProduct.backgroundColor = [UIColor clearColor];
        [rframeView addSubview:labProduct];
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
        //tv.backgroundColor = [UIColor greenColor];
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
            UILabel* labLine1 = (UILabel*)[imgframev viewWithTag:100];
            labLine1.text = [NSString stringWithFormat:@"%@  %@",
                             [_selRecipientDict objectForKey:@"UserName"],
                             [_selRecipientDict objectForKey:@"CusMobile"]
                             ];
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
}

// 生成订单
- (void)createOrderUni
{
    [SVProgressHUD showWithStatus:@"生成订单中..." maskType:SVProgressHUDMaskTypeGradient];
    
    // 创建请求数据字典
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // OptPackages
    if (self.info[@"OptPackages"]) {
        if ([self.info[@"OptPackages"][@"OptProdId"] count] > 0) {
            NSMutableString *OptProdIdStr = [[NSMutableString alloc] init];
            for (NSDictionary *dict in self.info[@"OptPackages"][@"OptProdId"]) {
                [OptProdIdStr appendString:[NSString stringWithFormat:@"<Id>%@</Id>", dict[@"Id"]]];
            }
            [params setObject:@{@"OptSalesProdId": self.info[@"OptPackages"][@"OptSalesProdId"],
                                @"OptProdId": OptProdIdStr}
                       forKey:@"OptPackages"];
        }
    }
    // ShopId
    [params setObject:BUSSINESS_SHOPID forKey:@"ShopId"];
    // GpFlag
    [params setObject:@"0" forKey:@"GpFlag"];
    // ChildType
    [params setObject:self.info[@"combo"][@"ComboType"] forKey:@"ChildType"];
    // UimCode
    [params setObject:self.info[@"UimCode"] forKey:@"UimCode"];
    // UserId
    NSDictionary *custInfoDict = [Global sharedInstance].custInfoDict;
    [params setObject:(custInfoDict[@"UserId"] ? custInfoDict[@"UserId"] : @"bank888") forKey:@"UserId"];
    // NewPhoneNumber
    [params setObject:@"true" forKey:@"NewPhoneNumber"];
    // PhoneNumber
    [params setObject:self.info[@"item"][@"PhoneNumber"] forKey:@"PhoneNumber"];
    // ComboId 根据ComboType来显示套餐名
    NSUInteger inx = [self.info[@"index"] integerValue];
    if ([self.info[@"combo"][@"ComboType"] isEqualToString:@"883"]) {
        // 纯流量
        [params setObject:@"5000001401100001" forKey:@"ComboId"];
    }
    else if ([self.info[@"combo"][@"ComboType"] isEqualToString:@"881"]) {
        // 云卡
        if ([self.info[@"package"][@"PackageItem"] isKindOfClass:[NSDictionary class]]) {
            [params setObject:self.info[@"package"][@"PackageItem"][@"Id"] forKey:@"ComboId"];
        }
        else if ([self.info[@"package"][@"PackageItem"] isKindOfClass:[NSArray class]]) {
            [params setObject:self.info[@"package"][@"PackageItem"][inx][@"Id"] forKey:@"ComboId"];
        }
    }
    else if ([self.info[@"combo"][@"ComboType"] isEqualToString:@"884"]) {
        // 乐享3G上网版
        if ([self.info[@"package"][@"PackageItem"] isKindOfClass:[NSDictionary class]]) {
            [params setObject:self.info[@"package"][@"PackageItem"][@"Id"] forKey:@"ComboId"];
        }
        else if ([self.info[@"package"][@"PackageItem"] isKindOfClass:[NSArray class]]) {
            [params setObject:self.info[@"package"][@"PackageItem"][inx][@"Id"] forKey:@"ComboId"];
        }
    }
    // CashSalesProdId
    [params setObject:self.info[@"CashSalesProdId"] forKey:@"CashSalesProdId"];
    // SalesProdId
    [params setObject:self.info[@"item"][@"SalesProdId"] forKey:@"SalesProdId"];
    // BlockInfo
    if (self.info[@"blockInfo"]) {
        [params setObject:self.info[@"blockInfo"] forKey:@"BlockInfo"];
    }
        
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"createOrderUni"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          [SVProgressHUD dismiss];
                                          //TODO:保存生成订单
                                          self.orderId = dict[@"Data"][@"OrderId"];
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
                                          
                                          [SVProgressHUD showErrorWithStatus:engineError.localizedDescription];
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
    
    // 收货地址信息
    NSDictionary *deliveryInfo = @{@"CusMobile":self.selRecipientDict[@"CusMobile"],
                                   @"PostCode": (self.selRecipientDict[@"PostCode"] ? self.selRecipientDict[@"PostCode"] : @""),
                                   @"City": self.selRecipientDict[@"City"],
                                   @"CusEmail": (self.selRecipientDict[@"CusEmail"] ? self.selRecipientDict[@"CusEmail"] : @""),
                                   @"County": self.selRecipientDict[@"County"],
                                   @"Address": self.selRecipientDict[@"Address"],
                                   @"Province": self.selRecipientDict[@"Province"],
                                   @"UserName": self.selRecipientDict[@"UserName"]};
    
    // 用户入网信息
    NSDictionary *customerInfo = @{@"Idcard_Postcode": @""/*(self.uPostCode ? self.uPostCode : @"_")*/,//add by liuruxian 2014-03-06
                                   @"Cust_Name": self.uName,
                                   @"Cust_Affress": self.uAddress,
                                   @"Phone_Number": self.info[@"item"][@"PhoneNumber"],
                                   @"Order_Id": (self.orderId == nil ?  @"":self.orderId),
                                   @"Idcardno": self.uID};
    
    NSDictionary *params = @{@"Remark": @"",
                             @"DeliveryTime": @"3",
                             @"UserId": ([[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] ? [[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] : @"bank888"),
                             @"OrderId": (self.orderId == nil ?  @"":self.orderId),
                             @"PayMethod": @"0",
                             @"Type": @"1",
                             @"DeliveryInfo": deliveryInfo,
                             @"CustomerInfo": customerInfo};
    
    self.createOrderUniOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"submitOrderUni"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          [SVProgressHUD dismiss];
                                          // 构造支付页面URL
                                          NSString *myOrderId = dict[@"Data"][@"OrderId"];
                                          NSString *userId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"bank888";
                                          
                                          NSString *payUrl = [NSString stringWithFormat:@"http://wapzt.189.cn/pay/onlinePay.do?method=getOrder&userid=%@&id=%@", userId, myOrderId];
                                          
#if 0
                                          CTNumPayVCtler *vc = [[CTNumPayVCtler alloc] init];
                                          vc.orderId = myOrderId;
                                          vc.payUrl = payUrl;
                                          vc.comboName = self.comboName ? self.comboName : @"";
                                          vc.info = self.info;
                                          vc.salesProInfo = self.salesProInfo ;
                                          [self.navigationController pushViewController:vc animated:YES];
#else
                                          
//                                          //added by huangfq 2014-5-30  不管什么类型传5
                                          [Utils saveOrderType:5];
                                          
                                          CTOrderRechargeVCtler *vc = [[CTOrderRechargeVCtler alloc] init];
                                          vc.orderId = myOrderId;
                                          vc.comboName = self.comboName ? self.comboName : @"";
                                          vc.info = self.info;
                                          vc.salesProInfo = self.salesProInfo ;
                                          vc.comeType = 3;
                                          vc.jumpUrl  = payUrl;
                                          [self.navigationController pushViewController:vc animated:YES];
                                          
#endif
                                          
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
                                                                                if ([vc isKindOfClass:[CTPrettyNumberVCtler class]]) {
                                                                                    isFound = YES ;
                                                                                    [self.navigationController popToViewController:vc animated:YES];
                                                                                    break ;
                                                                                }
                                                                            }
                                                                            if (!isFound) {
                                                                                CTPrettyNumberVCtler *vc = [CTPrettyNumberVCtler new];
                                                                                vc.isTop = YES ;
                                                                                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                                                NSDictionary *dict = [defaults objectForKey:CITYINFO];
                                                                                vc.locateData = [CTCity modelObjectWithDictionary:dict];
                                                                                [self.navigationController pushViewController:vc animated:YES];
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
                                          }
                                      }];
}



@end
