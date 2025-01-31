//
//  CTOrderDetailVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-11-26.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//  订单详情

#import "CTOrderDetailVCtler.h"
#import "SVProgressHUD.h"
#import "ToastAlertView.h"
#import "CserviceOperation.h"
#import "AppDelegate.h"
#import "UIView+RoundRect.h"
#import "CTDeliverStatusVCtler.h"
#import "SIAlertView.h"
#import "CTRechargeVCtler.h"
#import "CTPPointExchangeVCtler.h"

#define kHeight 200

@interface CTOrderDetailVCtler ()


@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSDictionary *orderInfo;
@property (nonatomic, strong) CserviceOperation *orderOpt;
@property (nonatomic, strong) CserviceOperation *rechargeOpt;
@property (nonatomic, strong) UIButton *rechargeForSelfBtn;
@property (nonatomic, strong) UIButton *rechargeForOtherBtn;

@property (nonatomic, assign) int  showType ;
@property (nonatomic, assign) int  cardType ;
@property (nonatomic, strong) NSString *psdWord;
@end

@implementation CTOrderDetailVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // 标题
        self.title = @"订单详情";
        // 左按钮
        [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
        self.showType = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView ;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
//    self.scrollView.contentSize = self.view.frame.size ;
    [self qryOrderInfo];
}

#pragma mark - fun

//设置外框内容
- (void) create : (NSDictionary *)dictionary
{
    if (!dictionary) {
        return;
    }
    
    NSString *str = @"";
    
    float yOringal = 14;
    {
//        str = [NSString stringWithFormat:@"您的订单(编号 : %@)内容如下 : ",self.ordrId];
        str = @"您的订单内容如下 : ";
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(15, yOringal, self.view.frame.size.width-30, 43)];
        lab.backgroundColor = [UIColor clearColor];
        [lab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        lab.textAlignment = UITextAlignmentLeft ;
        lab.textColor = [UIColor blackColor];
        lab.numberOfLines = 0;
        [self.scrollView addSubview:lab];
        CGSize size = [str sizeWithFont:lab.font constrainedToSize:CGSizeMake(self.view.frame.size.width-30, kHeight) lineBreakMode:NSLineBreakByWordWrapping];
        [lab setFrame:CGRectMake(lab.frame.origin.x, lab.frame.origin.y, size.width, size.height)];
        lab.text = str;
        
        yOringal += CGRectGetMaxY(lab.frame);
    }
    //订单编号
    {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(15, yOringal+8, 70, 14)];
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize:14];
        lab.textAlignment = UITextAlignmentLeft ;
        lab.textColor = [UIColor blackColor];
        lab.text = @"订单编号 : ";
        [self.scrollView addSubview:lab];
        
        UIImage *image = [UIImage imageNamed:@"per_content_bg.png"];
        UIImage *img = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2)];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lab.frame), yOringal, self.view.frame.size.width - CGRectGetMaxX(lab.frame)-15,46)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = img;
        [self.scrollView addSubview:imageView];
        {
            UILabel *label = [[UILabel alloc]init];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentLeft ;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            CGSize size = [self.ordrId sizeWithFont:label.font constrainedToSize:CGSizeMake(imageView.frame.size.width-16, kHeight) lineBreakMode:NSLineBreakByWordWrapping];
            [label setFrame:CGRectMake(8, 8, size.width, size.height)];
            label.text = self.ordrId;
            [imageView addSubview:label];
            
        }
        yOringal = CGRectGetMaxY(imageView.frame) + 8;
    }
    //订单商品
    {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(15, yOringal+8, 70, 14)];
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize:14];
        lab.textAlignment = UITextAlignmentLeft ;
        lab.textColor = [UIColor blackColor];
        lab.text = @"订单商品 : ";
        [self.scrollView addSubview:lab];
    
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lab.frame), yOringal, self.view.frame.size.width - CGRectGetMaxX(lab.frame)-15,0)];
        imageView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:imageView];
        
        id Item = [dictionary objectForKey:@"Item"];
//        self.orderImageView = imageView ;
        {
//            str = @"三星配送信息阿对方就卡地方纠结啊但是分开啦啦大煞风景阿大煞风景卡家大煞风景啊大哭饭";
//            id item = [dictionary objectForKey:@"Item"];
            id salesProNames  ;
            if([Item isKindOfClass:[NSArray class]])
            {
                NSArray *array = [NSArray arrayWithArray:Item];
                
                salesProNames = [[array objectAtIndex:0]objectForKey:@"SalesProName"];
             
            }else if([Item isKindOfClass:[NSDictionary class]]){
//                NSDictionary *dict = [NSDictionary dictionaryWithDictionary:Item];
                salesProNames = [[dictionary objectForKey:@"Item"]objectForKey:@"SalesProName"];
            }
            
            
//            salesProNames = [[dictionary objectForKey:@"Item"]objectForKey:@"SalesProName"];
            if ([salesProNames isKindOfClass:[NSArray class]]) {
                str = salesProNames[0];
            }else if([salesProNames isKindOfClass:[NSString class]])
            {
                str = salesProNames;
            }
            
            UILabel *label = [[UILabel alloc]init];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentLeft ;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            CGSize size = [str sizeWithFont:label.font constrainedToSize:CGSizeMake(imageView.frame.size.width-16, kHeight) lineBreakMode:NSLineBreakByWordWrapping];
            [label setFrame:CGRectMake(8, 8, size.width, size.height)];
            label.text = str ;
            [imageView addSubview:label];
            
            float height = size.height+16 > 46.0f ? size.height+16 : 46.0f;
            //修改外框高度
            UIImage *image = [UIImage imageNamed:@"per_content_bg.png"];
            UIImage *img = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2)];
            [imageView setFrame:CGRectMake(CGRectGetMaxX(lab.frame), yOringal, imageView.frame.size.width, height)];
            imageView.image = img ;
        }
        
        yOringal = CGRectGetMaxY(imageView.frame) + 8;
    }
    
    //配送信息
    {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(15, yOringal+8, 70, 14)];
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize:14];
        lab.textAlignment = UITextAlignmentLeft ;
        lab.textColor = [UIColor blackColor];
        lab.text = @"配送信息 : ";
        [self.scrollView addSubview:lab];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lab.frame), yOringal, self.view.frame.size.width - CGRectGetMaxX(lab.frame)-15,0)];
        imageView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:imageView];
//        self.orderImageView = imageView ;
        {
//            str = @"王海  010-58507321\n北京市海淀区杏石口路99号3棟西山赢俯D座100093";
            id Consignee = [dictionary objectForKey:@"Consignee"];
            if (!Consignee) {
                str = @"";
            }
            else{
                NSString *UserName = [Consignee objectForKey:@"UserName"];
                NSString *CusMobile = [Consignee objectForKey:@"CusMobile"];
                NSString *Address = [Consignee objectForKey:@"Address"];
                
                str = [NSString stringWithFormat:@"%@  %@\n%@",UserName,CusMobile,Address];
            }
            UILabel *label = [[UILabel alloc]init];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentLeft ;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            CGSize size = [str sizeWithFont:label.font constrainedToSize:CGSizeMake(imageView.frame.size.width-16, kHeight) lineBreakMode:NSLineBreakByWordWrapping];
            [label setFrame:CGRectMake(8, 8, size.width, size.height)];
            label.text = str ;
            [imageView addSubview:label];
            
            float height = size.height+16 > 46.0f ? size.height+16 : 46.0f;
            //修改外框高度
            UIImage *image = [UIImage imageNamed:@"per_content_bg.png"];
            UIImage *img = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2)];
            [imageView setFrame:CGRectMake(CGRectGetMaxX(lab.frame), yOringal, imageView.frame.size.width, height)];
            imageView.image = img ;
        }
        
        yOringal = CGRectGetMaxY(imageView.frame) + 8;
    }
    
    //发票信息
    {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(15, yOringal+8, 70, 14)];
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize:14];
        lab.textAlignment = UITextAlignmentLeft ;
        lab.textColor = [UIColor blackColor];
        lab.text = @"发票信息 : ";
        [self.scrollView addSubview:lab];
        
        UIImage *image = [UIImage imageNamed:@"per_content_bg.png"];
        UIImage *img = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2)];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lab.frame), yOringal, self.view.frame.size.width - CGRectGetMaxX(lab.frame)-15,46)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = img;
        [self.scrollView addSubview:imageView];
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(8, 8, 40, 14)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:14];
            label.text = @"抬头 : ";
            [imageView addSubview:label];
            
            UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 8, imageView.frame.size.width - 16, 14)];
            label2.backgroundColor = [UIColor clearColor];
            label2.textAlignment = UITextAlignmentLeft;
            label2.textColor = [UIColor blackColor];
            label2.font = [UIFont systemFontOfSize:14];
            
            CGSize size = [str sizeWithFont:label.font constrainedToSize:CGSizeMake(label2.frame.size.width, kHeight) lineBreakMode:NSLineBreakByWordWrapping];
            [label2 setFrame:CGRectMake(label2.frame.origin.x,label2.frame.origin.y,size.width,14)];
            label2.text = str ;
            
            [imageView addSubview:label2];
            
            str = @"通信器材";
            UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(8, CGRectGetMaxY(label.frame)+1, 40, 14)];
            label1.backgroundColor = [UIColor clearColor];
            label1.textAlignment = UITextAlignmentLeft;
            label1.textColor = [UIColor blackColor];
            label1.font = [UIFont systemFontOfSize:14];
            label1.text = @"内容 : ";
            [imageView addSubview:label1];
            
            UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame), CGRectGetMaxY(label.frame)+1, imageView.frame.size.width - 16, 14)];
            label3.backgroundColor = [UIColor clearColor];
            label3.textAlignment = UITextAlignmentLeft;
            label3.textColor = [UIColor blackColor];
            label3.font = [UIFont systemFontOfSize:14];
            
            size = [str sizeWithFont:label.font constrainedToSize:CGSizeMake(label3.frame.size.width, kHeight) lineBreakMode:NSLineBreakByWordWrapping];
            [label3 setFrame:CGRectMake(label3.frame.origin.x,label3.frame.origin.y-2,size.width,size.height)];
            label3.text = str ;
            
            [imageView addSubview:label3];
            
            
            id InvoiceInfo = [dictionary objectForKey:@"InvoiceInfo"];
            if (!InvoiceInfo) {
                str = @"";
                label.hidden = YES ;
                label1.hidden = YES ;
                label2.hidden = YES ;
                label3.hidden = YES ;
            }else{
                int InvoiceInfoType = [[InvoiceInfo objectForKey:@"InvoiceInfoType"]intValue];
                NSString *name = InvoiceInfoType > 0? @"公司":@"个人";
                int InvoiceContentType = [[InvoiceInfo objectForKey:@"InvoiceContentType"]intValue];
                NSString *content = InvoiceContentType > 0?@"商品明细":@"通信器材";
                label2.text = name ;
                label3.text = content;
            }
        }
        
         yOringal = CGRectGetMaxY(imageView.frame) + 8;
    }
    //支付方式
    {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(15, yOringal+8, 70, 14)];
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize:14];
        lab.textAlignment = UITextAlignmentLeft ;
        lab.textColor = [UIColor blackColor];
        lab.text = @"支付方式 : ";
        [self.scrollView addSubview:lab];
        
        UIImage *image = [UIImage imageNamed:@"per_content_bg.png"];
        UIImage *img = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2)];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lab.frame), yOringal, self.view.frame.size.width - CGRectGetMaxX(lab.frame)-15,46)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = img;
        [self.scrollView addSubview:imageView];
        {
            NSString *str = @"在线支付";
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, 70, imageView.frame.size.height)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:14];
            label.text = str;
            [imageView addSubview:label];
            
            int PayMethod = [[dictionary objectForKey:@"PayMethod"]intValue];
            NSString *pay = @"";
            
            if (PayMethod==0) {
                pay = @"网上支付";
            }else if(PayMethod==1)
            {
                pay = @"货到付款";
            }else if(PayMethod==2)
            {
                pay = @"分期支付";
            }else{
                pay = @"上门自提";
            }
            label.text = pay;
            
        }
        yOringal = CGRectGetMaxY(imageView.frame) + 8;
    }
    //订单金额
    {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(170, yOringal+8, 70, 14)];
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize:14];
        lab.textAlignment = UITextAlignmentLeft ;
        lab.textColor = [UIColor blackColor];
        lab.text = @"订单金额 : ";
        [self.scrollView addSubview:lab];
    
        NSString *money = [dictionary objectForKey:@"OrderPrice"];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lab.frame), yOringal+2, 50, 18)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:20];
        label.textAlignment = UITextAlignmentLeft ;
        label.textColor = [UIColor colorWithRed:255/255. green:93/255. blue:63/255. alpha:1];
        label.text = money;
        
        CGSize size = [money sizeWithFont:label.font constrainedToSize:CGSizeMake(100, kHeight) lineBreakMode:NSLineBreakByWordWrapping];
        [label setFrame:CGRectMake(label.frame.origin.x,label.frame.origin.y,size.width,size.height)];
        label.text = money ;
  
        [self.scrollView addSubview:label];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), yOringal+8, 20, 14)];
        label1.backgroundColor = [UIColor clearColor];
        label1.font = [UIFont systemFontOfSize:14];
        label1.textAlignment = UITextAlignmentLeft ;
        label1.textColor = [UIColor blackColor];
        label1.text = @"元";
        [self.scrollView addSubview:label1];
    
         yOringal = CGRectGetMaxY(lab.frame) + 18;
    }
    
    if (self.showType == 0) {  //卡密充值按钮
    
        UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitle:@"为本机充值" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(rechargeAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn_highLight.png"] forState:UIControlStateHighlighted];
        button.frame = CGRectMake(20, yOringal , 130, 30);
        [self.scrollView addSubview:button];
        self.rechargeForSelfBtn = button ;
        
        UIButton *button1  = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.titleLabel.font = [UIFont systemFontOfSize:14];
        [button1 setTitle:@"为他机充值" forState:UIControlStateNormal];
        [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button1 setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn.png"] forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(rechargeAction:) forControlEvents:UIControlEventTouchUpInside];
        [button1 setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn_highLight.png"] forState:UIControlStateHighlighted];
        button1.frame = CGRectMake(CGRectGetMaxX(button.frame)+20, yOringal , 130, 30);
        [self.scrollView addSubview:button1 ];
        self.rechargeForOtherBtn = button1 ;
        yOringal = CGRectGetMaxY(button.frame) + 10;
    }
    else{
        if (([dictionary[@"OrderStatusCode"] intValue] == 10100) ||
            ([dictionary[@"OrderStatusCode"] intValue] == 10702) ||
            ([dictionary[@"OrderStatusCode"] intValue] == 10703) ||
            ([dictionary[@"OrderStatusCode"] intValue] == 11106) ||
            ([dictionary[@"OrderStatusCode"] intValue] == 11109))
        {
            // 状态为 待支付 订单，需要支付
            UIImage *img = [UIImage imageNamed:@"recharge_commit_btn.png"];
            UIImage *image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2,
                                                                               img.size.width/2,
                                                                               img.size.height/2,
                                                                               img.size.width/2)];
            
            UIImageView *chargeView = [[UIImageView alloc]initWithFrame:CGRectMake(20, yOringal , (self.scrollView.frame.size.width-14)/2-20, 42)];
            chargeView.backgroundColor = [UIColor clearColor];
            [chargeView dwMakeRoundCornerWithRadius:5];
            chargeView.image = image ;
            [self.scrollView addSubview:chargeView];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"取消订单" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setFrame:chargeView.frame];
            [button addTarget:self action:@selector(onCancelAction) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:button];
            
            UIImageView *chargeView1 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(button.frame)+20, yOringal,(self.scrollView.frame.size.width-14)/2-20 , 42)];
            chargeView1.backgroundColor = [UIColor clearColor];
            [chargeView1 dwMakeRoundCornerWithRadius:5];
            chargeView1.image = image ;
            [self.scrollView addSubview:chargeView1];
            
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [cancelButton setTitle:@"立即支付" forState:UIControlStateNormal];
            cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            cancelButton.frame = chargeView1.frame ;
            [cancelButton addTarget:self action:@selector(onPayAction) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:cancelButton];
            
            yOringal = CGRectGetMaxY(button.frame) + 10;
        }
        else {
            UIImage *img = [UIImage imageNamed:@"recharge_commit_btn.png"];
            UIImage *image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2,
                                                                               img.size.width/2,
                                                                               img.size.height/2,
                                                                               img.size.width/2)];
            
            UIImageView *chargeView = [[UIImageView alloc]initWithFrame:CGRectMake(7, yOringal , self.scrollView.frame.size.width-14, 42)];
            chargeView.backgroundColor = [UIColor clearColor];
            [chargeView dwMakeRoundCornerWithRadius:5];
            chargeView.image = image ;
            [self.scrollView addSubview:chargeView];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"查看物流状态" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setFrame:chargeView.frame];
            [button addTarget:self action:@selector(qryLogisticsAction) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:button];
            
            yOringal = CGRectGetMaxY(button.frame) + 10;
        }
    }

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                             yOringal);
}

#pragma mark - net work

- (void) qryOrderInfo
{
    NSString *OrderId = @"";
    OrderId = self.ordrId;
    NSString *userId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"FSD88888";
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            OrderId, @"OrderId",
                            userId, @"UserId",nil];
    
    __block CTOrderDetailVCtler *weakSelf = self;
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    self.orderOpt =  [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrderInfo"
                                                                     params:params
                                                                onSucceeded:^(NSDictionary *dict)
                               {
                                   DDLogInfo(@"查询订单状态 %s--%@", __func__, dict.description);
                                   
                                   NSDictionary *data = [dict objectForKey:@"Data"];
                                   if (data && [data respondsToSelector:@selector(objectForKey:)]) {
                                       //更新orderInfo
                                       [weakSelf create:data];
                                       [SVProgressHUD dismiss];
                                   }
                               } onError:^(NSError *engineError) {
                                   DDLogInfo(@"%s--%@", __func__, engineError);
                                   [SVProgressHUD dismiss];
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
                                                                     if (self.navigationController != nil)
                                                                     {
                                                                         [self.navigationController popViewControllerAnimated:NO];
                                                                     }
                                                                 }];
                                           alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                           [alertView show];
                                       }
                                   }
                                   else
                                   {
                                       ToastAlertView *alert = [ToastAlertView new];
                                       [alert showAlertMsg:@"获取订单信息失败"];
                                   }
                               }];

}

- (void) qryCardPsd
{
    
}

#pragma mark - action
- (void) qryLogisticsAction
{
    CTDeliverStatusVCtler *vc = [[CTDeliverStatusVCtler alloc] init];
    vc.orderId = self.ordrId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) setcardInfo: (int) showType cardType : (int) cardType
{
    self.showType = showType ;
    self.cardType = cardType;
}

- (void) rechargeAction : (id) sender
{
    [SVProgressHUD showWithStatus:@"查询卡密中..." maskType:SVProgressHUDMaskTypeBlack];
    
    UIButton *btn = (UIButton *)sender;
    NSString *orderId = self.ordrId;
    NSString *userId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"FSD88888";
    
    // 查询卡密
    NSDictionary *params = @{@"UserId": userId,
                             @"OrderId": orderId};
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"CardBuyInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          [SVProgressHUD dismiss];
                                          CTRechargeVCtler *vc = [[CTRechargeVCtler alloc] init];
                                          if (self.cardType == 4)
                                          {
                                              // 话费卡
                                              if (self.rechargeForSelfBtn == btn)
                                              {
                                                  [vc recharge:0 cardPsdWord:dict[@"Data"][@"CardPwd"] rechageNum:YES];
                                              }
                                              else
                                              {
                                                  [vc recharge:0 cardPsdWord:dict[@"Data"][@"CardPwd"] rechageNum:NO];
                                              }
                                          }
                                          else if (self.cardType == 42)
                                          {
                                              // 流量卡
                                              if (self.rechargeForSelfBtn == btn)
                                              {
                                                  [vc recharge:1 cardPsdWord:dict[@"Data"][@"CardPwd"] rechageNum:YES];
                                              }
                                              else
                                              {
                                                  [vc recharge:1 cardPsdWord:dict[@"Data"][@"CardPwd"] rechageNum:NO];
                                              }
                                          }
                                          else
                                          {
                                              [vc recharge:0 cardPsdWord:@"" rechageNum:NO];
                                          }
                                          [vc setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
                                          [self.navigationController pushViewController:vc animated:YES];
                                          
                                      } onError:^(NSError *engineError) {
                                          
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
                                              else
                                              {
                                                  [SVProgressHUD showErrorWithStatus:@"卡密查询失败！"];
                                              }
                                          }
                                          
                                      }];
}

- (void)onPayAction
{
    NSString *orderId = self.ordrId;
    NSString *userId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"FSD88888";
    
    NSString *payUrl = [NSString stringWithFormat:@"http://wapzt.189.cn/pay/onlinePay.do?method=getOrder&userid=%@&id=%@", userId, orderId];
    CTPPointExchangeVCtler *vctler = [CTPPointExchangeVCtler new];
    vctler.jumpUrl = payUrl;
    vctler.title = @"订单支付";
    vctler.fullScreen = YES;
    vctler.needBack2Rootview = NO;
    [self.navigationController pushViewController:vctler animated:YES];
}


// add by liuruxian 2014-04-15

- (void)onCancelAction
{
    NSString *orderId = self.ordrId ;
    NSString *userId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"FSD88888";
    
    NSDictionary *params = @{@"UserId": userId,
                             @"OrderId": orderId};
    
    __weak CTOrderDetailVCtler *weakSelf = self;
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"cancelOrder"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          [SVProgressHUD dismiss];
                                          
                                          ToastAlertView *alertView = [ToastAlertView new];
                                          [alertView showAlertMsg:@"已成功取消订单"];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"onCancelAction" object:nil];
                                          [weakSelf.navigationController popViewControllerAnimated:YES];
                                          
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
                                              else
                                              {
                                                  ToastAlertView *alertView = [ToastAlertView new];
                                                  [alertView showAlertMsg:@"取消订单失败"];
                                                  [weakSelf.navigationController popViewControllerAnimated:YES];
                                              }
                                          }
                                          
                                      }];
}

@end
