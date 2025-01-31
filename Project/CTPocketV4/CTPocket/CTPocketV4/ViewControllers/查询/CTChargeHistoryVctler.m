//
//  CTChargeHistoryVctler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 13-11-13.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//  交费记录

#import "CTChargeHistoryVctler.h"
#import "UIView+RoundRect.h"
#import "AppDelegate.h"
#import "CserviceEngine.h"
#import "SIAlertView.h"
#import "NSDate+Extensions.h"
#import "SVProgressHUD.h"
#import "CTRechargeVCtler.h"

#define kTagcntView      8976
#define kTagBtnPreMonth  8977
#define kTagLabCurMonth  8988
#define kTagBtnNxtMonth  8999

#define kTagScrollview   89761


@implementation PayhisItem
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat xval = 20;
        CGFloat yval  = 5;
        CGRect  vrc  = CGRectMake(xval, yval, 100, 22);
        UILabel* keyDate        = [[UILabel alloc] initWithFrame:vrc];
        keyDate.backgroundColor  = [UIColor clearColor];
        keyDate.font             = [UIFont systemFontOfSize:14];
        keyDate.textColor        = [UIColor blackColor];
        keyDate.text             = @"交费时间：";
        keyDate.textAlignment    = UITextAlignmentCenter;
        [self addSubview:keyDate];
        
        xval += 120;
        vrc   = CGRectMake(xval, yval, 140, 22);
        labDate        = [[UILabel alloc] initWithFrame:vrc];
        labDate.backgroundColor  = [UIColor clearColor];
        labDate.font             = [UIFont systemFontOfSize:14];
        labDate.textColor        = [UIColor blackColor];
        labDate.textAlignment    = UITextAlignmentLeft;
        [self addSubview:labDate];
        
        xval  = 20;
        yval += 22;
        vrc   = CGRectMake(xval, yval, 100, 22);
        UILabel* keyMoney        = [[UILabel alloc] initWithFrame:vrc];
        keyMoney.backgroundColor  = [UIColor clearColor];
        keyMoney.font             = [UIFont systemFontOfSize:14];
        keyMoney.textColor        = [UIColor blackColor];
        keyMoney.text             = @"交费金额：";
        keyMoney.textAlignment    = UITextAlignmentCenter;
        [self addSubview:keyMoney];

        xval += 120;
        vrc   = CGRectMake(xval, yval, 140, 22);
        labMoney      = [[UILabel alloc] initWithFrame:vrc];
        labMoney.tag             = 2;
        labMoney.backgroundColor = [UIColor clearColor];
        labMoney.font            = [UIFont systemFontOfSize:14];
        labMoney.text            = @"";
        labMoney.textAlignment   = UITextAlignmentLeft;
        labMoney.textColor       = [UIColor blackColor];/*[UIColor colorWithRed:233/255.0
                                                   green:90/255.0
                                                    blue:76/255.0
                                                   alpha:1];*///(106, 106, 106, 1);
        [self addSubview:labMoney];
        
        xval  = 20;
        yval += 22;
        vrc   = CGRectMake(xval, yval, 100, 22);
        UILabel* keyMethod        = [[UILabel alloc] initWithFrame:vrc];
        keyMethod.backgroundColor  = [UIColor clearColor];
        keyMethod.font             = [UIFont systemFontOfSize:14];
        keyMethod.textColor        = [UIColor blackColor];
        keyMethod.text             = @"交费方式：";
        keyMethod.textAlignment    = UITextAlignmentCenter;
        [self addSubview:keyMethod];

        xval += 120;
        vrc   = CGRectMake(xval, yval, 140, 22);
        labMethod      = [[UILabel alloc] initWithFrame:vrc];
        labMethod.tag              = 3;
        labMethod.backgroundColor  = [UIColor clearColor];
        labMethod.font             = [UIFont systemFontOfSize:14];
        labMethod.textAlignment   = UITextAlignmentLeft;
        labMethod.textColor        = [UIColor blackColor];/*[UIColor colorWithRed:106/255.0
                                                   green:106/255.0
                                                    blue:106/255.0
                                                   alpha:1];*///(106, 106, 106, 1);
        [self addSubview:labMethod];
        
        // div line
        UIImageView* divLine0 = [[UIImageView alloc] initWithFrame:CGRectMake(0,frame.size.height-1,frame.size.width,1)];
        divLine0.image = [UIImage imageNamed:@"recharge_horline_bg.png"];
        [self addSubview:divLine0];
    }
    return self;
}

-(void)setDataInfoDict:(NSDictionary*)dict
{
    labDate.text   = [dict objectForKey:@"PaidTime"];
    labMoney.text  = [NSString stringWithFormat:@"%@元",[dict objectForKey:@"PaymentAmount"]];
    //labMethod.text = [dict objectForKey:@"PaymentMethod"];
    //缴费方式付款方式 11：现金12：支票13：信用卡缴费14：代缴15：充值
    id mdstr = [dict objectForKey:@"PaymentMethod"];
    if (mdstr) {
        int val = [(NSNumber*)mdstr intValue];
        if (val==11)
        {
            labMethod.text = @"现金支付";
        }else if(val == 12){
            labMethod.text = @"支票支付";
        }else if(val == 13){
            labMethod.text = @"信用卡缴费";
        }else if(val == 14){
            labMethod.text = @"银行代缴";
        }else if(val == 15){
            labMethod.text = @"充值";
        }
    }
}

@end



@interface CTChargeHistoryVctler ()
@property (strong, nonatomic)CserviceOperation *_QryOperation01;
-(void)onRechargeBution:(id)button;
-(void)onPayListDataError:(NSError*)error;
@end

@implementation CTChargeHistoryVctler

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
    self.title = @"缴费记录";
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    {
        UILabel* mtitle = [[UILabel alloc] initWithFrame:CGRectMake(10,15,300,22)];
        mtitle.backgroundColor = [UIColor clearColor];
        mtitle.font     = [UIFont systemFontOfSize:14];
        mtitle.textColor= [UIColor blackColor];
        {
            NSDictionary* logindict= [Global sharedInstance].loginInfoDict;
            NSString *PhoneNum = logindict[@"UserLoginName"] ? logindict[@"UserLoginName"] : @"";
            mtitle.text = [NSString stringWithFormat:@"查询号码：%@",PhoneNum];
        }
        [self.view addSubview:mtitle];

        // div line
        UIImageView* divLine = [[UIImageView alloc] initWithFrame:CGRectMake(0,48, 320, 1)];
        divLine.image = [UIImage imageNamed:@"recharge_horline_bg.png"];
        [self.view addSubview:divLine];
    }
    
    {
        float yval = 58;
        CGRect cntRce   = CGRectMake(0,yval,320, CGRectGetHeight(self.view.frame)-62*2-92);
        UIView* cntView = [[UIView alloc] initWithFrame:cntRce];
        cntView.tag     = kTagcntView;
        cntView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:cntView];
        
        CGRect scView   = CGRectMake(0,46,320,cntView.frame.size.height-46);
        UIScrollView* scrolView = [[UIScrollView alloc] initWithFrame:scView];
        scrolView.tag           = kTagScrollview;
        scrolView.backgroundColor = [UIColor clearColor];
        [cntView addSubview:scrolView];

        // 覆盖的月份浮标：左月
        UIButton *firstMonth = [UIButton buttonWithType:UIButtonTypeCustom];
        firstMonth.tag   = kTagBtnPreMonth;
        firstMonth.frame = CGRectMake(0,yval+5,80,36);
        [firstMonth setBackgroundImage:[UIImage imageNamed:@"his_mth_01.png"]
                              forState:UIControlStateNormal];
        [firstMonth setTitle:@"" forState:UIControlStateNormal];
        [firstMonth setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
        [firstMonth.titleLabel setFont:[UIFont boldSystemFontOfSize:22]];
        [firstMonth addTarget:self
                       action:@selector(OnPreMonthAction:)
             forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:firstMonth];
        
        // 覆盖的月份浮标：中间月
        UILabel* centerMonth = [[UILabel alloc] initWithFrame:CGRectMake(80,yval+12,160,22)];
        centerMonth.tag      = kTagLabCurMonth;
        centerMonth.backgroundColor = [UIColor clearColor];
        centerMonth.font     = [UIFont boldSystemFontOfSize:/*22*/18];
        centerMonth.textColor= [UIColor colorWithRed:127/255. green:204/255. blue:71/255. alpha:1];//[UIColor colorWithRed:111.0/255 green:197.0/255 blue:55.0/255 alpha:1];    // modified by zy, 2014-02-19
        centerMonth.textAlignment = UITextAlignmentCenter;
        centerMonth.text = @"";
        [self.view addSubview:centerMonth];
        
        // 覆盖的月份浮标：右边月
        UIButton *lastMonth = [UIButton buttonWithType:UIButtonTypeCustom];
        lastMonth.tag   = kTagBtnNxtMonth;
        lastMonth.frame = CGRectMake(240,yval+5,80,36);
        [lastMonth setBackgroundImage:[UIImage imageNamed:@"his_mth_02.png"]
                             forState:UIControlStateNormal];
        [lastMonth setTitle:@"" forState:UIControlStateNormal];
        [lastMonth addTarget:self
                      action:@selector(OnNxtMonthAction:)
            forControlEvents:UIControlEventTouchUpInside];
        [lastMonth setTitleColor:[UIColor whiteColor]
                        forState:UIControlStateNormal];
        [lastMonth.titleLabel setFont:[UIFont boldSystemFontOfSize:22]];
        [self.view addSubview:lastMonth];
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20,CGRectGetHeight(self.view.frame)-50-92,280,36);
        [button setBackgroundImage:[[UIImage imageNamed:@"common_alert_button.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:12]
                          forState:UIControlStateNormal];
        {
            UIImageView* cenicon = [[UIImageView alloc] initWithFrame:CGRectMake(104,9,26,18)];
            cenicon.image = [UIImage imageNamed:@"qry_icon_money.png"];
            cenicon.userInteractionEnabled = NO;
            [button addSubview:cenicon];
        }
        [button dwMakeRoundCornerWithRadius:3];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 28, 0, 0)];
        [button setTitle:@"充值" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onRechargeBution:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        // added by zy, 2014-02-14，适配ios7
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.)
        {
            button.frame = CGRectMake(CGRectGetMinX(button.frame),
                                      CGRectGetMinY(button.frame) - 10,
                                      CGRectGetWidth(button.frame),
                                      CGRectGetHeight(button.frame));
        }
    }
    
    [self setMonthLabs:nil];
    {
        NSCalendar * calendar    = [NSCalendar currentCalendar];
        NSDateComponents * comps = [[NSDateComponents alloc] init];
        NSDate * newDate         = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
        NSDateFormatter * df     = [NSDateFormatter new];
        [df setDateFormat:@"yyyyMM"];
        NSString * month  = [df stringFromDate:newDate];
        [self queryPayHistory:month];
    }
    
    // 左右滑动手势
    {
        UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRecognizer:)];
        [recognizer1 setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.view addGestureRecognizer:recognizer1];
        UISwipeGestureRecognizer *recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRecognizer:)];
        [recognizer2 setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.view addGestureRecognizer:recognizer2];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onRechargeBution:(id)button{
    NSArray *array = self.navigationController.viewControllers;
    BOOL isFound = NO;
    for (id vc in array) {
        if ([vc isKindOfClass:[CTRechargeVCtler class]]) {
            isFound = YES;
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
    if (!isFound) {
    UINavigationController *nar =  MyAppDelegate.tabBarController.viewControllers[2] ;
    CTRechargeVCtler *vc =  (CTRechargeVCtler *)nar.viewControllers[0] ;
    [vc pageIndex:0];
    MyAppDelegate.tabBarController.selectedIndex = 2;
    }
}

-(void)setMonthLabs:(id)sender
{
    UIButton* btn_pre = (UIButton*)[self.view viewWithTag:kTagBtnPreMonth];
    UILabel*  lab_cur =  (UILabel*)[self.view viewWithTag:kTagLabCurMonth];
    UIButton* btn_nxt = (UIButton*)[self.view viewWithTag:kTagBtnNxtMonth];
    
    NSCalendar * calendar    = [NSCalendar currentCalendar];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    if (sender == NULL)
    {
        // 右边
        [comps setMonth:+1];
        NSDate * newDate     = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
        NSDateFormatter * df = [NSDateFormatter new];
        [df setDateFormat:@"MM月"];
        [btn_nxt setTitle:[df stringFromDate:newDate]
                 forState:UIControlStateNormal];
        [btn_nxt setEnabled:NO];
        
        // 中间
        [comps setMonth:0];
        newDate           = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
        [df setDateFormat:@"yyyy年MM月"];
        lab_cur.text      = [df stringFromDate:newDate];
        // 左边
        [comps setMonth:-1];
        [df setDateFormat:@"MM月"];
        newDate           = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
        [btn_pre setTitle:[df stringFromDate:newDate]
                 forState:UIControlStateNormal];
    }else
    {
        // 右边
        NSDate*  date     = (NSDate*)sender;
        [comps setMonth:+1];
        NSDate * newDate  = [calendar dateByAddingComponents:comps toDate:date options:0];
        NSDateFormatter * df= [NSDateFormatter new];
        [df setDateFormat:@"MM月"];
        [btn_nxt setTitle:[df stringFromDate:newDate]
                 forState:UIControlStateNormal];
        if (NO == [self checkMonth:newDate])
        {
            [btn_nxt setEnabled:NO];
        }else
        {
            [btn_nxt setEnabled:YES];
        }
        
        // 中间
        [comps setMonth:0];
        newDate           = [calendar dateByAddingComponents:comps toDate:date options:0];
        [df setDateFormat:@"yyyy年MM月"];
        lab_cur.text      = [df stringFromDate:newDate];
        // 左边
        [comps setMonth:-1];
        [df setDateFormat:@"MM月"];
        newDate           = [calendar dateByAddingComponents:comps toDate:date options:0];
        [btn_pre setTitle:[df stringFromDate:newDate]
                 forState:UIControlStateNormal];
        if (NO == [self checkMonth:newDate])
        {
            [btn_pre setEnabled:NO];
        }else
        {
            [btn_pre setEnabled:YES];
        }
    }
}

-(void)OnPreMonthAction:(id)sender
{
    UILabel*  lab_cur = (UILabel*)[self.view viewWithTag:kTagLabCurMonth];
    NSString* strmont = lab_cur.text;

    
    NSDateFormatter * df= [NSDateFormatter new];
    [df setDateFormat:@"yyyy年MM月"];
    NSDate*   date = [df dateFromString:strmont];

    NSCalendar * calendar    = [NSCalendar currentCalendar];
    NSDateComponents * comps = [[NSDateComponents alloc] init];

    // 计算将要请求的月份
    NSString* month = @"";
    [df setDateFormat:@"yyyyMM"];
    [comps setMonth:-1];
    NSDate* lastMonth = [calendar dateByAddingComponents:comps toDate:date options:0];
    month = [df stringFromDate:lastMonth];

    [self setMonthLabs:lastMonth];
    [self queryPayHistory:month];
}


-(void)OnNxtMonthAction:(id)sender
{
    UILabel*  lab_cur = (UILabel*)[self.view viewWithTag:kTagLabCurMonth];
    NSString* strmont = lab_cur.text;
    
    NSCalendar * calendar    = [NSCalendar currentCalendar];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    NSDateFormatter * df= [NSDateFormatter new];
    {
        [df setDateFormat:@"yyyy年MM月"];
        NSDate*   date = [df dateFromString:strmont];
        
        [comps setMonth:1];
        date = [calendar dateByAddingComponents:comps toDate:date options:0];
        [self setMonthLabs:date];

        // 计算将要请求的月份
        NSString* month = @"";
        [df setDateFormat:@"yyyyMM"];
        month  = [df stringFromDate:date];
        [self queryPayHistory:month];
    }
}

-(BOOL)checkMonth:(NSDate*)month
{
    NSDate* today = [NSDate date];
    
    unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar * calendar  = [NSCalendar currentCalendar];
    
    if ([today isEarlierThanDate:month])
    {
        // 如果大于或者等于当前月
        return  NO;
    }else
    {
        // 如果小于前6个月，则提示智能查前6个月
        NSDateComponents *comps  = [calendar components:unitFlags fromDate:month  toDate:today  options:0];
        int months = [comps month];
        if (months > 6)
        {
            return  NO;
        }
    }
    return YES;
}

-(void)queryPayHistory:(NSString*)month
{
    NSDictionary* logindict= [Global sharedInstance].loginInfoDict;
    NSString *PhoneNum = logindict[@"UserLoginName"] ? logindict[@"UserLoginName"] : @"";
    
    NSDictionary *params   = [NSDictionary dictionaryWithObjectsAndKeys:
                              PhoneNum,@"PhoneNum",
                              month,@"Month",
                              nil];
    {
        [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
        
        self._QryOperation01   =
        [MyAppDelegate.cserviceEngine postXMLWithCode:@"queryPaymentRecord"
                                               params:params
                                          onSucceeded:^(NSDictionary *dict)
        {
            //格式化数据(将指定的数据格式化成数组)
            dict = [Utils objFormatArray:dict path:@"Data/Items/Item"];
            
            [self onPayListDataBack:dict];
            [SVProgressHUD dismiss];
        } onError:^(NSError *engineError){
              DDLogInfo(@"%s--%@", __func__, engineError);
              [self onPayListDataError:engineError];
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
          }];
    }
}

-(void)onPayListDataError:(NSError*)error
{
    UIView* cntv   = (UIView*)[self.view viewWithTag:kTagcntView];
    UIScrollView* scv = (UIScrollView*)[cntv viewWithTag:kTagScrollview];
    
    for (UIView* tv in [scv subviews]) {
        if ([tv isKindOfClass:[PayhisItem class]] ||
            [tv isKindOfClass:[UILabel class]])
        {
            [tv removeFromSuperview];
        }
    }
    scv.contentSize = CGSizeMake(320, scv.frame.size.height);
    
    {
        UILabel* mtitle = [[UILabel alloc] initWithFrame:CGRectMake(10, (scv.frame.size.height-30)/2,
                                                                    scv.frame.size.width-20,
                                                                    30)];
        mtitle.backgroundColor = [UIColor clearColor];
        mtitle.font     = [UIFont systemFontOfSize:14];
        mtitle.textColor= [UIColor darkGrayColor];
        mtitle.textAlignment = UITextAlignmentCenter;
        mtitle.text     = @"查询失败，请稍后重试。";
        [scv addSubview:mtitle];
    }
}


-(void)onPayListDataBack:(NSDictionary*)dict
{
    UIView* cntv   = (UIView*)[self.view viewWithTag:kTagcntView];
    UIScrollView* scv = (UIScrollView*)[cntv viewWithTag:kTagScrollview];
    
    for (UIView* tv in [scv subviews]) {
        if ([tv isKindOfClass:[PayhisItem class]] ||
            [tv isKindOfClass:[UILabel class]])
        {
            [tv removeFromSuperview];
        }
    }
    scv.contentSize = CGSizeMake(320, scv.frame.size.height);

    NSArray * aryItems = nil;
    if ([[[[dict objectForKey:@"Data"] objectForKey:@"Items"] objectForKey:@"Item"] isKindOfClass:[NSArray class]])
    {
        aryItems = [[[dict objectForKey:@"Data"] objectForKey:@"Items"] objectForKey:@"Item"];
    }
    else if ([[[[dict objectForKey:@"Data"] objectForKey:@"Items"] objectForKey:@"Item"] isKindOfClass:[NSDictionary class]])
    {
        aryItems = [NSArray arrayWithObject:[[[dict objectForKey:@"Data"] objectForKey:@"Items"] objectForKey:@"Item"]];
    }
    
    CGFloat yval = 0;
    for (NSDictionary* item in aryItems)
    {
        CGRect trc = CGRectMake(0, yval, scv.frame.size.width, 70+6);
        PayhisItem * pitemv = [[PayhisItem alloc] initWithFrame:trc];
        [pitemv setDataInfoDict:item];
        [scv addSubview:pitemv];
        yval += pitemv.frame.size.height;
    }
    scv.contentSize = CGSizeMake(320, yval);
    
    if ([aryItems count] <= 0)
    {
        UILabel* mtitle = [[UILabel alloc] initWithFrame:CGRectMake(10, (scv.frame.size.height-30)/2,
                                                                    scv.frame.size.width-20,
                                                                    30)];
        mtitle.backgroundColor = [UIColor clearColor];
        mtitle.font     = [UIFont systemFontOfSize:14];
        mtitle.textColor= [UIColor darkGrayColor];
        mtitle.textAlignment = UITextAlignmentCenter;
        mtitle.text     = @"当月您没有充值缴费记录。";
        [scv addSubview:mtitle];
    }
}

- (void)handleRecognizer:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        UIButton* btn_nxt = (UIButton*)[self.view viewWithTag:kTagBtnNxtMonth];
        if (btn_nxt.enabled)
        {
            [self OnNxtMonthAction:nil];
        }
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        UIButton* btn_pre = (UIButton*)[self.view viewWithTag:kTagBtnPreMonth];
        if (btn_pre.enabled)
        {
            [self OnPreMonthAction:nil];
        }
    }
}

@end
