//
//  CTRechargeSucessVCtler.m
//  CTPocketV4
//
//  Created by apple on 13-11-1.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTRechargeSucessVCtler.h"
#import "AppDelegate.h"
#import "CTContractPhoneVCtler.h"
#import "UIView+RoundRect.h"
#import "CTChargeHistoryVctler.h"
#import "CTMessageCenterVCtler.h" 
#import "CTLoginVCtler.h"
#import "CTContractPhoneListViewController.h"

#define kButtonTag 1000
@interface CTRechargeSucessVCtler ()
{
    UILabel *_usrLb;
}

@property (nonatomic, strong) UIView *rechargeView;
@property (nonatomic, strong) UILabel *phoneNumLb;
@property (nonatomic, strong) UILabel *rechargeTypeLb;
@property (nonatomic, strong) UILabel *flowsLb;
@property (nonatomic, strong) UILabel *buyCardTypeLb;  //购买的卡的类型
@property (nonatomic, strong) UILabel *errorDiscriptionLb;
@property (nonatomic, strong) NSString *cardPsd;
@property (nonatomic, strong) UILabel  *usrNameLb;
@property (nonatomic, strong) UILabel *failedLb;


@property (nonatomic, assign) int rechargeStatus;
@property (nonatomic, assign) int rechargeType;     //充值方式  充花费  流量

@end

@implementation CTRechargeSucessVCtler

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
    [self setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
    
    self.rechargeStatus = [[self.rechargeInfoDict objectForKey:@"OrderStatus"]intValue];
    
    
    if (self.rechargeStatus==0) {
        self.title = @"充值成功";
    }else{
        self.title = @"充值失败";
    }
    [self.view setBackgroundColor:PAGEVIEW_BG_COLOR];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    self.rechargeView = view ;
    float yPos ;
    
    //成功状态
    NSString *OrderStatus = [self.rechargeInfoDict objectForKey:@"OrderStatus"];
    NSString *rechargeType = [self.rechargeInfoDict objectForKey:@"rechargeType"];
    self.rechargeType = [rechargeType intValue];
    self.rechargeStatus = [OrderStatus intValue] ;
    
    if (self.rechargeStatus == 0) {                         //充值成功
        [view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 103)];
        {
            UILabel *label = [self createLb:[UIFont systemFontOfSize:14]
                                      color:[UIColor blackColor]
                                       text:@"尊敬的用户 : " rect:CGRectMake(48,26,82,14)];
            [view addSubview:label];
            UILabel *usrLb = [self createLb:[UIFont systemFontOfSize:14]
                                      color:[UIColor blackColor]
                                       text:@""
                                       rect:CGRectMake(CGRectGetMaxX(label.frame),26 , 200, 14)];
            self.usrNameLb = usrLb ;
//            [view addSubview:usrLb];
            
            UILabel *label1 = [self createLb:[UIFont systemFontOfSize:14]
                                       color:[UIColor blackColor]
                                        text:@"你在电信手机营业厅"
                                        rect:CGRectMake(48,26+25, 200, 14)];
            [view addSubview:label1];
            
            UILabel *label2 = [self createLb:[UIFont systemFontOfSize:14]
                                       color:[UIColor blackColor]
                                        text:@"为"
                                        rect:CGRectMake(48,46+30, 100, 14)];
            [view addSubview:label2];
            
            UILabel *phoneLb = [self createLb:[UIFont systemFontOfSize:20]
                                        color:[UIColor blackColor]
                                         text:@"18101119023"
                                         rect:CGRectMake(61,46+27, 124, 16)];
            phoneLb.textAlignment = UITextAlignmentCenter;
            [view addSubview:phoneLb];
            self.phoneNumLb = phoneLb;
            //255,98,74
            UILabel *label3 = [self createLb:[UIFont systemFontOfSize:14]
                                       color:[UIColor blackColor]
                                        text:@"充值"
                                        rect:CGRectMake(CGRectGetMaxX(phoneLb.frame),46+30, 28, 14)];
            [view addSubview:label3];
            
            //可以改写成M
            UILabel *moneyLb = [self createLb:[UIFont systemFontOfSize:20]
                                        color:[UIColor colorWithRed:255/255 green:98/255 blue:74/255 alpha:1]
                                         text:@"100"
                                         rect:CGRectMake(CGRectGetMaxX(label3.frame)+1,46+24, 0, 0)];
            moneyLb.textAlignment = UITextAlignmentCenter;
            self.rechargeTypeLb = moneyLb ;
            [view addSubview:moneyLb];
            
             
        }
        yPos = CGRectGetMaxY(view.frame) ;
    }else{
        [view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
        {
            UILabel *label = [self createLb:[UIFont systemFontOfSize:14]
                                      color:[UIColor blackColor]
                                       text:@"尊敬的用户 : " rect:CGRectMake(48,26,82,14)];
            [view addSubview:label];
            UILabel *usrLb = [self createLb:[UIFont systemFontOfSize:14]
                                      color:[UIColor blackColor]
                                       text:@"刘小贱"
                                       rect:CGRectMake(CGRectGetMaxX(label.frame),26, 200, 14)];
            self.usrNameLb = usrLb ;
//            [view addSubview:usrLb];
            
            UILabel *label1 = [self createLb:[UIFont systemFontOfSize:14]
                                       color:[UIColor blackColor]
                                        text:@"您为"
                                        rect:CGRectMake(48,26+25, 28, 14)];
            [view addSubview:label1];
            
            UILabel *phoneLb = [self createLb:[UIFont systemFontOfSize:20]
                                        color:[UIColor blackColor]
                                         text:@"18101119023"
                                         rect:CGRectMake(CGRectGetMaxX(label1.frame),26+23, 124, 16)];
            phoneLb.textAlignment = UITextAlignmentCenter;
            self.phoneNumLb = phoneLb;
            [view addSubview:phoneLb];
           
//            //255,98,74
//            UILabel *label3 = [self createLb:[UIFont systemFontOfSize:14]
//                                       color:[UIColor blackColor]
//                                        text:@"充值"
//                                        rect:CGRectMake(CGRectGetMaxX(phoneLb.frame),26+25, 28, 14)];
//            [view addSubview:label3];
//            
//            //可以改写成M
//            UILabel *flowLb = [self createLb:[UIFont systemFontOfSize:20]
//                                        color:[UIColor colorWithRed:255/255 green:98/255 blue:74/255 alpha:1]
//                                         text:@"100"
//                                         rect:CGRectMake(CGRectGetMaxX(label3.frame)+1,26+23, 34, 16)];
//            self.rechargeTypeLb = flowLb ;
//            [view addSubview:flowLb];
            
            UILabel *label4 = [self createLb:[UIFont systemFontOfSize:14]
                                       color:[UIColor blackColor]
                                        text:@"充值失败。"
                                        rect:CGRectMake(CGRectGetMaxX(phoneLb.frame),26+25, 100, 14)];
            [view addSubview:label4];
            
            UILabel *label5 = [self createLb:[UIFont systemFontOfSize:14]
                                       color:[UIColor blackColor]
                                        text:@"请确认您的"
                                        rect:CGRectMake(48,46+25, 220, 30)];
            label5.numberOfLines = 2;
            label5.textAlignment = UITextAlignmentLeft ;
            
            [view addSubview:label5];
            self.failedLb = label5 ;
            self.failedLb.text = [self.rechargeInfoDict objectForKey:@"disctription"];
            self.failedLb.text = [NSString stringWithFormat:@"%@",self.failedLb.text];

            label5.numberOfLines = 0;
            [self.failedLb sizeToFit];
            
            
            [view addSubview:label5];
            
           
        }
         yPos = CGRectGetMaxY(view.frame) ;
    }
    
    //外框
    UIImage *image1 = [UIImage imageNamed:@"recharge_verLine_bg.png"]; //竖线
    UIImage *image2 = [UIImage imageNamed:@"recharge_horline_bg.png"]; //横线

    NSArray *infoAry = [NSArray arrayWithObjects:@"充值记录查询",@"继续充值",@"优惠活动",@"0元购机", nil];
    NSArray *iconAry = [NSArray arrayWithObjects:@"recharge_record_icon.png",@"recharge_keeprecharge_icon.png",@"recharge_preference_icon.png",@"recharge_buyphone_icon.png", nil];
    for (int i=0; i<5; i++) {
        //横线
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:
                                  CGRectMake(31,
                                             yPos,
                                             self.view.frame.size.width-62,
                                             1)];
        imageView.autoresizingMask = UIViewContentModeScaleToFill ;
        imageView.image = image2 ;
        [self.view addSubview:imageView];
        if (i<4) {
            UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:
                                        CGRectMake(31,
                                                   yPos,
                                                   self.view.frame.size.width-62,
                                                   48)];
            
            bgImageView.backgroundColor = [UIColor clearColor];
            bgImageView.userInteractionEnabled = YES ;
            [self.view addSubview:bgImageView];
            
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = bgImageView.frame ;
            btn.tag = kButtonTag + i;
            [btn addTarget:self action:@selector(operateAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:btn];
            
            {
                UIImage *markImage = [UIImage imageNamed:[iconAry objectAtIndex:i]];
                //竖直线
                UIImageView *line = [[UIImageView alloc]initWithFrame:
                                     CGRectMake(32,
                                                0,
                                                1,
                                                bgImageView.frame.size.height)];
                line.autoresizingMask = UIViewContentModeScaleToFill ;
                line.image = image1;
                [bgImageView addSubview:line];
                //图标
                UIImageView *markImageView = [[UIImageView alloc]initWithFrame:
                                              CGRectMake(18,
                                                         (bgImageView.frame.size.height - 28)/2,
                                                         28,
                                                         28)];
                
                markImageView.userInteractionEnabled = YES;
                markImageView.autoresizingMask = UIViewContentModeScaleAspectFit ;
                markImageView.image = markImage ;
                [bgImageView addSubview:markImageView];
                //提示
                UILabel *label = [self createLb:[UIFont systemFontOfSize:14]
                                          color:[UIColor blackColor]
                                           text:[infoAry objectAtIndex:i]
                                           rect:CGRectMake(65,0,100,bgImageView.frame.size.height)];
                [bgImageView addSubview:label];
                
                //箭头
                
                UIImage *arrImage = [UIImage imageNamed:@"recharge_arrow_icon.png"];
                UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(230, (bgImageView.frame.size.height-arrImage.size.height)/2, arrImage.size.width, arrImage.size.height)];
                arrow.image = arrImage ;
                [bgImageView addSubview:arrow];
                
            }
        }
        
        yPos = CGRectGetMaxY(imageView.frame) + 48;
    }
    
    float xPos = 31;
    
    switch (self.rechargeType) {
        case 0:
            yPos = CGRectGetMaxY(view.frame) ;
            break;
        case 1:
            yPos = CGRectGetMaxY(view.frame)  ;
            break;
        case 2:
            yPos = CGRectGetMaxY(view.frame) +40 ;
            break;

    }
    for (int i=0; i<3; i++) {
        UIImageView *verLineimageView = [[UIImageView alloc]initWithFrame:
                                         CGRectMake(xPos,
                                                    yPos ,
                                                    1,
                                                    48*4+5)];
        verLineimageView.image =  image1 ;
        [self.view addSubview:verLineimageView];
        xPos += self.view.frame.size.width-62 ;
    }
}

- (UILabel *) createLb : (UIFont *)font color : (UIColor *)color text: (NSString *)text rect : (CGRect)rect
{
    UILabel *label = [[UILabel alloc]initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.text = text;
    label.textColor = color ;
    label.textAlignment = UITextAlignmentLeft ;
    label.font = font ;
    
    return label ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    self.phoneNumLb.text = [self.rechargeInfoDict objectForKey:@"phoneNumber"];
    NSString *str = @"";
//    self.rechargeType = 0;
    if (self.rechargeStatus == 0) {     //充值成功
        if (self.rechargeType == 0) {
            self.rechargeTypeLb.text = [self.rechargeInfoDict objectForKey:@"OrderPrice"];
            [self.rechargeTypeLb setNumberOfLines:0];
            [self.rechargeTypeLb sizeToFit];
            
            
            UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.rechargeTypeLb.frame),self.rechargeTypeLb.frame.origin.y+5,14,14)];
            label5.backgroundColor = [UIColor clearColor];
            label5.text = @"元";
            label5.textColor = [UIColor blackColor];
            label5.textAlignment = UITextAlignmentLeft ;
            label5.font = [UIFont systemFontOfSize:14];
            [self.rechargeView addSubview:label5];
            
        }else{
            str = [self.rechargeInfoDict objectForKey: @"Flow"]; //流量
            self.rechargeTypeLb.numberOfLines = 0;
            self.rechargeTypeLb.text = str;
            [self.rechargeTypeLb sizeToFit];
        }
    }else{              //充值失败
        
    }
}

- (void) onLeftBtnAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


//@"充值记录查询",@"继续充值",@"优惠活动",@"0元购机",
#pragma mark operaton Action
- (void) operateAction : (id) sender
{
    int index = [(UIButton *)sender tag] - kButtonTag;
    
    switch (index) {
        case 0:  //充值记录查询
        {
            if ([Global sharedInstance].isLogin == YES) {
                CTChargeHistoryVctler *vc = [CTChargeHistoryVctler new];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
                }];
                return;
            }
           
        }
            break;
        case 1: //继续充值
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        case 2: // 公告
        {
            CTMessageCenterVCtler *vc = [CTMessageCenterVCtler new];
            [vc rechargeType:0];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3: //0元购机
        {
            CTContractPhoneListViewController *vc = [CTContractPhoneListViewController new];
//            CTContractPhoneVCtler *vc = [CTContractPhoneVCtler new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            
            break;
    }
}

- (void) checkCardPsdAction
{
    
}

@end
