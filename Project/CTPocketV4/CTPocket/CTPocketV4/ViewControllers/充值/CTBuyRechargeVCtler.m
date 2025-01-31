//
//  CTBuyRechargeVCtler.m
//  CTPocketV4
//
//  Created by apple on 13-10-31.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTBuyRechargeVCtler.h"
#import "UIView+RoundRect.h"
#import "CTRechargeVCtler.h"
#import "CTRechargeSucessVCtler.h"
#import "CserviceOperation.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "CTLoginVCtler.h"
#import "ToastAlertView.h"
#import "SIAlertView.h"
#import "Utils.h"

#define kcashBtnTag 1000
#define kflowBtnTag 1200
#define kReachargeTypeBtn 2000
#define kRechargeViewTag 3000

@interface CTBuyRechargeVCtler ()
{
    NSDictionary *_cashdict;
    UILabel *_bankCashLabel;
}

@property (nonatomic, strong) NSDictionary *cashdict;
@property (nonatomic, strong) UILabel *cashLabel;
@property (nonatomic, strong) UILabel *flowLabel;

@property (nonatomic, assign) int buyCardType;
@property (nonatomic, assign) int cashType ;
@property (nonatomic, assign) int flowType ;

@property (nonatomic, strong) NSDictionary *flowdict;
@property (nonatomic, strong) UIView *callsView;
@property (nonatomic, strong) UIView *flowsView;
@property (nonatomic, strong) NSString *UserId;

@property (nonatomic, strong) CserviceOperation *buyCardOpt;
@property (nonatomic, strong) CserviceOperation *qrySalesProIdOpt;

@property (nonatomic, strong) NSMutableArray *callsdArray;
@property (nonatomic, strong) NSMutableArray *flowsArray;

@property (nonatomic, strong) NSString *phoneNum;

@end



@implementation CTBuyRechargeVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.flowType = 2;
        self.cashType = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = PAGEVIEW_BG_COLOR;  // added by zy
    
    self.callsdArray = [NSMutableArray new];
    self.flowsArray = [NSMutableArray new];
    
    self.cashdict = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"20元充值卡",@"0",
                     @"30元充值卡",@"1",
                     @"50元充值卡",@"2",
                     @"100元充值卡",@"3",
                     @"200元充值卡",@"4",
                     @"500元充值卡",@"5",nil];
    
    self.flowdict = [NSDictionary dictionaryWithObjectsAndKeys:  @"10元流量卡",@"0",
                                                                 @"20元流量卡",@"1",
                                                                 @"30元流量卡",@"2",
                                                                 nil];
    
    
	// Do any additional setup after loading the view.
    //充值卡类型
    UIImageView *briage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 5, 28)];
    briage.backgroundColor = [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1];
    [self.view addSubview:briage];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(22,10,100,28)];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"充值卡类型";
    label1.textColor = [UIColor blackColor];
    label1.textAlignment = UITextAlignmentLeft ;
    label1.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label1];
    
    UIImage *image1 = [UIImage imageNamed:@"recharge_selectedRechargeType_btn.png"];
    UIImage *image2 = [UIImage imageNamed:@"recharge_unselectedRechargeType_btn.png"];
    
    UIButton *callsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    callsBtn.frame = CGRectMake(22, CGRectGetMaxY(briage.frame)+4,120,33);
    callsBtn.selected = YES ;
    callsBtn.tag = kReachargeTypeBtn;
    [callsBtn setTitle:@"买话费卡密" forState:UIControlStateNormal];
    callsBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [callsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [callsBtn setTitleColor:[UIColor colorWithRed:0/255. green:160/255. blue:26/255. alpha:1] forState:UIControlStateSelected];
    [callsBtn setBackgroundImage:image2 forState:UIControlStateNormal];
    [callsBtn setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn_highLight.png"] forState:UIControlStateHighlighted];
    [callsBtn setBackgroundImage:image1 forState:UIControlStateSelected];
    [callsBtn addTarget:self action:@selector(buyCardTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callsBtn];
    
    UIButton *flowsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    flowsBtn.frame = CGRectMake( 37+CGRectGetMaxX(callsBtn.frame),CGRectGetMaxY(briage.frame)+4, 120,33);
    [flowsBtn setTitle:@"买流量卡密" forState:UIControlStateNormal];
    flowsBtn.selected = NO;
    flowsBtn.tag = kReachargeTypeBtn + 1;
    flowsBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [flowsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [flowsBtn setTitleColor:[UIColor colorWithRed:0/255. green:160/255. blue:26/255. alpha:1] forState:UIControlStateSelected];
    [flowsBtn setBackgroundImage:image2 forState:UIControlStateNormal];
    [flowsBtn setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn_highLight.png"] forState:UIControlStateHighlighted];
    [flowsBtn addTarget:self action:@selector(buyCardTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    [flowsBtn setBackgroundImage:image1 forState:UIControlStateSelected];
    [self.view addSubview:flowsBtn];

    
    
    
    //分成 流量卡充值  和 话费卡充值
    UIView *callsView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(flowsBtn.frame)+20, self.view.frame.size.width, 275)];
    callsView.backgroundColor = [UIColor clearColor];
    callsView.tag = kRechargeViewTag;
    [self.view addSubview:callsView];
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, 5, 28)];
        imageView.backgroundColor = [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1];
        [callsView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(22,0,100,28)];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"选择金额";
        label.textColor = [UIColor blackColor];
        label.textAlignment = UITextAlignmentLeft ;
        label.font = [UIFont systemFontOfSize:14];
        [callsView addSubview:label];
        
        float x=22,x1=22, yOriginal = 0;
        {
            UIImage *selImg = [UIImage imageNamed:@"recharge_selectedRechargeType_btn2.png"];
            UIImage *norImg = [UIImage imageNamed:@"recharge_byother_btn.png"];
            
            NSArray *array = [NSArray arrayWithObjects:@"20元",@"30元",@"50元",@"100元",@"200元",@"500元", nil];
            
            for (int i=0; i<6; i++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithRed:0/255. green:160/255. blue:26/255. alpha:1] forState:UIControlStateSelected];
                [btn setBackgroundImage:norImg forState:UIControlStateNormal];
                [btn setBackgroundImage:selImg forState:UIControlStateSelected];
                [btn setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn_highLight.png"] forState:UIControlStateHighlighted];
                btn.titleLabel.font = [UIFont systemFontOfSize:14];
                btn.tag = kcashBtnTag + i ;
                [btn addTarget:self action:@selector(cashTypeAction:) forControlEvents:UIControlEventTouchUpInside];
                if (i<3) {
                    btn.frame = CGRectMake(x, CGRectGetMaxY(label.frame) + 10, 73, 32);
                    x = CGRectGetMaxX(btn.frame) + 28.5;
                }else{
                    btn.frame = CGRectMake(x1, CGRectGetMaxY(label.frame)+34+20, 73, 32);
                    x1 = CGRectGetMaxX(btn.frame) + 28.5;
                    yOriginal = CGRectGetMaxY(btn.frame) ;
                }
                if (i==0) {
                    btn.selected = YES;
                    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
                }
                [callsView addSubview:btn];
            }
            
            
        }
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(22, yOriginal+20,39,12)] ;
        label2.textColor =  [UIColor blackColor];
        label2.text = @"已选择";
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont systemFontOfSize:13];
        [callsView addSubview:label2];
        
        UILabel *cashLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label2.frame)+1,yOriginal+20,100,12)] ;
        cashLb.textColor = [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1];
        cashLb.text = [self.cashdict objectForKey:@"0"];
        cashLb.backgroundColor = [UIColor clearColor];
        cashLb.font = [UIFont systemFontOfSize:13];
        [callsView addSubview:cashLb];
        self.cashLabel = cashLb;
        
        UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(22, yOriginal+35,275,30)] ;
        tipLb.textColor =  [UIColor blackColor];
        tipLb.numberOfLines = 0;
        tipLb.text = @"充值卡密请前往查询->订单查询->已完成订单查找卡密";
        tipLb.backgroundColor = [UIColor clearColor];
        tipLb.font = [UIFont systemFontOfSize:12];
        [callsView addSubview:tipLb];    }
    /*
        流量充值卡  view
    */
    UIView *flowsView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(flowsBtn.frame)+20, self.view.frame.size.width, 275)];
    flowsView.backgroundColor = [UIColor clearColor];
    flowsView.hidden = YES;
    flowsView.tag = kRechargeViewTag + 1;
    [self.view addSubview:flowsView];
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, 5, 28)];
        imageView.backgroundColor = [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1];
        [flowsView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(22,0,100,28)];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"选择金额";
        label.textColor = [UIColor blackColor];
        label.textAlignment = UITextAlignmentLeft ;
        label.font = [UIFont systemFontOfSize:14];
        [flowsView addSubview:label];
        
        float x=22,yOriginal = 0;
        {
            UIImage *selImg = [UIImage imageNamed:@"recharge_selectedRechargeType_btn2.png"];
            UIImage *norImg = [UIImage imageNamed:@"recharge_byother_btn.png"];
            
            NSArray *array = [NSArray arrayWithObjects:@"60M/10元",@"150M/20元",@"300M/30元", nil];
            
            for (int i=0; i<3; i++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithRed:0/255. green:160/255. blue:26/255. alpha:1] forState:UIControlStateSelected];
                [btn setBackgroundImage:norImg forState:UIControlStateNormal];
                [btn setBackgroundImage:selImg forState:UIControlStateSelected];
                [btn setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn_highLight.png"] forState:UIControlStateHighlighted];
                btn.titleLabel.font = [UIFont systemFontOfSize:12];
                btn.tag = kflowBtnTag + i ;
                [btn addTarget:self action:@selector(flowTypeAction:) forControlEvents:UIControlEventTouchUpInside];
                if (i<3) {
                    btn.frame = CGRectMake(x, CGRectGetMaxY(label.frame) + 10, 73, 32);
                    x = CGRectGetMaxX(btn.frame) + 28.5;
                }
//                else{
//                    btn.frame = CGRectMake(x1, CGRectGetMaxY(label.frame)+34+20, 73, 32);
//                    x1 = CGRectGetMaxX(btn.frame) + 26;
//                    yOriginal = CGRectGetMaxY(btn.frame) ;
//                }
                if (i==2) {
                    btn.selected = YES;
                    btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
                }
                [flowsView addSubview:btn];
            }
        }
        
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(22, yOriginal+92,39,12)] ;
        label2.textColor =  [UIColor blackColor];
        label2.text = @"已选择";
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont systemFontOfSize:13];
        [flowsView addSubview:label2];
        
        UILabel *cashLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label2.frame)+1, yOriginal+92,100,12)] ;
        cashLb.textColor = [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1];
        cashLb.text = [self.flowdict objectForKey:@"2"];
        cashLb.backgroundColor = [UIColor clearColor];
        cashLb.font = [UIFont systemFontOfSize:12];
        [flowsView addSubview:cashLb];
        self.flowLabel = cashLb;
        yOriginal = CGRectGetMaxY(cashLb.frame);
        
        UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(22, yOriginal+2,275,30)] ;
        tipLb.textColor =  [UIColor blackColor];
        tipLb.numberOfLines = 0;
        tipLb.text = @"充值卡密请前往查询->订单查询->已完成订单查找卡密";
        tipLb.backgroundColor = [UIColor clearColor];
        tipLb.font = [UIFont systemFontOfSize:12];
        [flowsView addSubview:tipLb];
       
    }
    
    {
        CGSize mainSize = [UIScreen mainScreen].bounds.size;
        CGFloat footH = 50;
        CGFloat yPos = mainSize.height-64-footH-91;
        UIView *footV = [[UIView alloc]init];
        //footV.layer.borderWidth = 1;
        footV.backgroundColor = RGB(240, 240, 240, 1);
        footV.frame = CGRectMake(0, yPos, mainSize.width, footH);
        [self.view addSubview:footV];
        
        UIImage *image = [UIImage imageNamed:@"recharge_commit_icon.png"];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 0, image.size.width, image.size.height)];
        imageView.image = image ;
        
        CGFloat btnw = mainSize.width-44,btnH = 37;
        CGFloat cx = (mainSize.width - btnw)/2;
        CGFloat cy = (footH-btnH)/2;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn_hl.png"] forState:UIControlStateHighlighted];
        [button setTitle:@"充  值" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.frame = CGRectMake(cx, cy, btnw, btnH);
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
        [button addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
        
        imageView.frame = CGRectMake( 100,(button.frame.size.height-imageView.frame.size.height)/2, imageView.frame.size.width, imageView.frame.size.height);
        [button addSubview:imageView];
        [footV addSubview:button];
        
    }
    NSDictionary *loginDict = [Global sharedInstance].loginInfoDict;
    self.phoneNum  = [loginDict objectForKey:@"UserLoginName"] ? [loginDict objectForKey:@"UserLoginName"] : @"";
    
}


- (void) buyCardTypeAction : (id) sender
{
    UIButton *btn = (UIButton *)sender;
    int index = btn.tag - kReachargeTypeBtn ;
    self.buyCardType = index;
    
    //added by huangfq 2014-5-30
    //保存选择的订单类型 //self.buyCardType   0代表 购话费卡 1代表 购流量卡
    self.buyCardType?[Utils saveOrderType:3]:[Utils saveOrderType:4];//3：购话费卡4：购流量卡
    
    if (btn.selected==YES) {
        return;
    }else{
        btn.selected = !btn.selected ;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        for (int i=0; i<2; i++) {
            UIView *view = [self.view viewWithTag:i+kRechargeViewTag];
            if (i!=index) {
                UIButton *button = (UIButton *) [self.view viewWithTag:i+kReachargeTypeBtn];
                button.selected = NO;
                button.titleLabel.font = [UIFont systemFontOfSize:14];
                view.hidden = YES;
            }else{
                view.hidden = NO;
            }
        }
    }
}

//话费卡选择
- (void) cashTypeAction : (id) sender
{
    UIButton *btn = (UIButton *)sender ;
    int index = btn.tag - kcashBtnTag ;
    self.cashType = index;
    if (btn.selected == YES) {
        return;
    }else{
        btn.selected = !btn.selected ;
        NSString *str =[self.cashdict objectForKey:[NSString stringWithFormat:@"%d",index]];

        self.cashLabel.text = str;
        
        for (int i=0;i<6; i++) {
            if (i!=index) {
                UIButton *button = (UIButton *)[self.view viewWithTag:i+kcashBtnTag];
                button.titleLabel.font = [UIFont systemFontOfSize:14];
                button.selected = NO;
            } else{
                UIButton *button = (UIButton *)[self.view viewWithTag:i+kcashBtnTag];
                button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
                button.selected = YES;
            }
        }
    }
}

//流量卡选择

- (void) flowTypeAction : (id) sender
{
    UIButton *btn = (UIButton *)sender ;
    int index = btn.tag - kflowBtnTag ;
    self.flowType = index;
    if (btn.selected == YES) {
        return;
    }else{
        btn.selected = !btn.selected ;
        NSString *str =[self.flowdict objectForKey:[NSString stringWithFormat:@"%d",index]];
        self.flowLabel.text = str;
        
        for (int i=0;i<3; i++) {
            if (i!=index) {
                UIButton *button = (UIButton *)[self.view viewWithTag:i+kflowBtnTag];
                button.titleLabel.font = [UIFont systemFontOfSize:12];
                button.selected = NO;
            } else {
                UIButton *button = (UIButton *)[self.view viewWithTag:i+kflowBtnTag];
                button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
                button.selected = YES;
            }
        }
    }
}

//- (void) showView : (int) tag
//{
//    UIButton *btn = (UIButton *)[self.view viewWithTag:tag+kReachargeTypeBtn];
//    btn.selected = NO;
////    [self chargeTypeAction:btn]; //选择显示的view
//}

- (void) showToastView : (NSString*)message
{
    ToastAlertView *alert = [ToastAlertView new];
    [alert showAlertMsg:message];
}

#pragma mark - new Work
//查询充值卡的销售品ID
- (void) qrySalesProId
{
    
    if (self.qrySalesProIdOpt) {
        [self.qrySalesProIdOpt cancel];
        self.qrySalesProIdOpt = nil;
    }
    
    if (![Global sharedInstance].isLogin) {
        [MyAppDelegate showReloginVC];
        if (self.navigationController != nil)
        {
            [self.navigationController popViewControllerAnimated:NO];
            
        }
        return;
    }
    
    //查询充值卡
    NSString *PageIndex = @"0";
    NSString *PageSize = @"0";
    NSString *Type = @"";
    NSString *Keyword = @"";

    if (self.buyCardType == 0) {
        Type = @"4";
    }else{
        Type = @"42";   
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            PageIndex, @"PageIndex",
                            PageSize, @"PageSize",
                            Type, @"Type",
                            BUSSINESS_SHOPID, @"ShopId",
                            Keyword , @"Keyword",
                            nil];
    
    __block CTBuyRechargeVCtler *weakSelf = self ;
    self.qrySalesProIdOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"qrySalesProductList"
                                                                   params:params
                                                              onSucceeded:^(NSDictionary *dict)
   {
       //格式化数据(将指定的数据格式化成数组)
       dict = [Utils objFormatArray:dict path:@"Data/DataList/List"];
       
       DDLogInfo(@"获取商品的 SalesProdId %s--%@", __func__, dict.description);
       NSDictionary *Data = [dict objectForKey:@"Data"];
       if (Data && [Data respondsToSelector:@selector(objectForKey:)]) {
           NSDictionary *DataList = [Data objectForKey:@"DataList"];
           NSArray *array1 = [NSArray arrayWithArray:[DataList objectForKey:@"List"]];

           if(array1)
           {
               NSString *SalesProdId = @"";
               if (weakSelf.buyCardType == 0) {
                   SalesProdId = [weakSelf matchSalesId:weakSelf.cashType DataList:array1];
               }else{
                   SalesProdId = [weakSelf matchSalesId:weakSelf.flowType DataList:array1];
               }
               
               //生成订单
               [self buyCard:SalesProdId];
           }
       }
       
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
           [self showToastView:@"系统繁忙，请稍后再试"];
       }
   }];
}

//
- (NSString *) matchSalesId  : (int) cardIndex DataList : (NSArray *) rechargeAry
{
    //选中的金额
    NSString *money = @"";
    if (self.buyCardType == 0) {
        NSString *temp = [self.cashdict objectForKey:[NSString stringWithFormat:@"%d",cardIndex]];
        NSArray *array = [temp componentsSeparatedByString:@"元"];
        money = [array objectAtIndex:0];
    }else{
        NSString *temp = [self.flowdict objectForKey:[NSString stringWithFormat:@"%d",cardIndex]];
        NSArray *array = [temp componentsSeparatedByString:@"元"];
        money = [array objectAtIndex:0];
    }
 
    
    for (NSDictionary *dict in rechargeAry) {
        NSString *Price = [dict objectForKey:@"Price"];
        if ([money isEqualToString:Price]) {
            return [dict objectForKey:@"SalesProdId"];
        }
    }
    
    return nil ;
}
// 生成订单
- (void) buyCard : (NSString *) salesProdId
{
    if (self.buyCardOpt) {
        [self.buyCardOpt cancel];
        self.buyCardOpt = nil;
    }

    NSString *UserId = [Global sharedInstance].custInfoDict[@"UserId"]?[Global sharedInstance].custInfoDict[@"UserId"]:@"bank888";
    
    self.UserId = UserId;
    NSString *ChannelId = @"3001";
    NSString *SalesProId = salesProdId;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            ChannelId, @"ChannelId",
                            SalesProId, @"SalesProId",
                            UserId, @"UserId",
                            BUSSINESS_SHOPID, @"ShopId",
                            nil];
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    __block CTBuyRechargeVCtler *weakSelf = self ;
    __block NSDictionary *par = params;
    
    self.buyCardOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"BuyCard"
                                                             params:params
                                                        onSucceeded:^(NSDictionary *dict)
                       {
                           DDLogInfo(@"获取第一步的订单id成功 %s--%@", __func__, dict.description);
                           id OrderId = [[dict objectForKey:@"Data"]objectForKey:@"OrderId"];
                           if (OrderId) {
                               NSString *payUrl = [NSString stringWithFormat:@"http://wapzt.189.cn/pay/onlinePay.do?method=getOrder&userid=%@&id=%@", self.UserId, OrderId];
                               NSLog(@"%@",payUrl) ;
                               
                               NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithDictionary:par];
                               [dictionary setObject:payUrl forKey:@"payUrl"];  //跳转web
                               [dictionary setObject:@"1" forKey:@"PageType"];
                               
                               [dictionary setObject:weakSelf.phoneNum forKey:@"phoneNumber"];
                               [dictionary setObject:@"1" forKey:@"PageType"];
                               [dictionary setObject:OrderId forKey:@"OrderId"];
                               NSString *realPrice = [[dict objectForKey:@"Data"]objectForKey:@"OrderPrice"];// 选择充值金额
                               [dictionary setObject:realPrice forKey:@"RealPrice"];   //实际付款金额  当前金额假如有折扣的话 没有则和实际相同
                               [dictionary setObject:[[dict objectForKey:@"Data"]objectForKey:@"OrderPrice"] forKey:@"OrderPrice"];
                               NSString * flow = @"";
                               flow = [flow stringByAppendingString:@"M"];
                               [dictionary setObject:flow forKey:@"Flow"];
                               [dictionary setObject:[[dict objectForKey:@"Data"]objectForKey:@"Flow"] forKey:@"Flow"];
                               
                               [dictionary setObject:[[dict objectForKey:@"Data"]objectForKey:@"OrderCreatedDate"] forKey:@"OrderCreatedDate"];
                               [dictionary setObject:@"" forKey:@"OrderPayedDate"];
                               
                               [dictionary setObject:@"未支付" forKey:@"OrderStatusDescription"];
                               [dictionary setObject:@"10010" forKey:@"OrderStatusCode"];
                               [dictionary setObject:weakSelf.UserId forKey:@"UserId"];
                               
                               //充值卡所需的参数 充值卡类型  
                               if (weakSelf.buyCardType == 0) {
                            
                                   [dictionary setObject:@"0" forKey:@"CardType"];    // 话费卡
                                   [dictionary setObject:[NSString stringWithFormat:@"%d",weakSelf.cashType] forKey:@"AmountOpts"];  //选择充值的金额
                                   
                                   //added by huangfq 2014-5-26
                                   [dictionary setObject:@"3" forKey:@"Type"];
                                   
                               }else{
                
                                   [dictionary setObject:@"1" forKey:@"CardType"];    // 流量卡
                                   [dictionary setObject:[NSString stringWithFormat:@"%d",weakSelf.flowType] forKey:@"AmountOpts"];
                                   
                                   //added by huangfq 2014-5-26
                                   [dictionary setObject:@"4" forKey:@"Type"];
                               }
      
                               
                               [[NSNotificationCenter defaultCenter]postNotificationName:CTP_MSG_RECHARGE_BANK object:dictionary];
                               
                           } else {
                               
                           }
                           [SVProgressHUD dismiss];
                       } onError:^(NSError *engineError) {
                           DDLogInfo(@"%s--%@", __func__, engineError);
                           [SVProgressHUD showWithStatus:engineError.userInfo[@"NSLocalizedDescription"]];
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
                               [self showToastView:@"系统繁忙，请稍后再试"];
                           }
                       }];

}

//购卡
- (void) commitAction
{
//    if ([Global sharedInstance].isLogin == NO) {
//        CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//        [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
//        }];
//        return;
//    }
    
    //添加userid得判断
   NSString *UserId =[Global sharedInstance].custInfoDict[@"UserId"] ?[Global sharedInstance].custInfoDict[@"UserId"]: @"bank888";
    
    if(!UserId && UserId.length==0)
    {
        NSDictionary *loginDict = [Global sharedInstance].loginInfoDict;
        NSString *Account = [loginDict objectForKey:@"UserLoginName"] ? [loginDict objectForKey:@"UserLoginName"] : @"";
        
        NSDictionary *params1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 Account, @"Account",
                                 @"201", @"AccountType",
                                 BUSSINESS_SHOPID, @"ShopId", nil];
        
        __block CTBuyRechargeVCtler *weakSelf = self;
        [MyAppDelegate.cserviceEngine postXMLWithCode:@"custIdInfo"
                                               params:params1
                                          onSucceeded:^(NSDictionary *dict) {
                                              //获取用户id
                                              id Data = [dict objectForKey:@"Data"];
                                              if (Data && [Data respondsToSelector:@selector(objectForKey:)]) {
                                                  [Global sharedInstance].custInfoDict = dict[@"Data"];
                                                  [weakSelf qrySalesProId];
                                              }
                                              
                                          } onError:^(NSError *engineError) {
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
                                                  ToastAlertView *alert = [ToastAlertView new];
                                                  [alert showAlertMsg:@"系统繁忙,请重新提交"];
                                              }
                                          }];
    }else {
        [self qrySalesProId];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
