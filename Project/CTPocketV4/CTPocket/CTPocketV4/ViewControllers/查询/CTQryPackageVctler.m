//
//  CTQryPackageVctler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 13-11-5.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//  套餐查询

#import "CTQryPackageVctler.h"
#import "UIView+RoundRect.h"
#import "CTPackageItem.h"
#import "AppDelegate.h"
#import "CserviceEngine.h"
#import "CTRechargeVCtler.h"
#import "SVProgressHUD.h"
#import "SIAlertView.h"

#define kTagScrollview   9018
#define kTagLab_step02   90181
#define kTagLab_step01   90182
#define kTagLab_step03   90183
#define kTagLab_tipLabel 90184
#define kTagBtn          90185
@interface CTQryPackageVctler ()
@property (strong, nonatomic)CserviceOperation *_QryOperation01;

-(void)getSNEDate:(NSString**)stdate end:(NSString**)enddate;
-(void)qryPackageInfo;

-(void)onStreamPackageBution:(id)sender;
-(void)onQryFlowInfoError:(NSError*)error;
@end

@implementation CTQryPackageVctler

-(void)onStreamPackageBution:(id)sender{
    
    UINavigationController *nar =  MyAppDelegate.tabBarController.viewControllers[2] ;
    CTRechargeVCtler *vc =  (CTRechargeVCtler *)nar.viewControllers[0] ;
    [vc pageIndex:1];
    MyAppDelegate.tabBarController.selectedIndex = 2;
    [[NSNotificationCenter defaultCenter] postNotificationName:MineShowHome object:nil];
 
}

-(void)getSNEDate:(NSString**)stdate end:(NSString**)enddate
{
    NSDate * today      = [NSDate date];
    NSDateFormatter * df= [NSDateFormatter new];
    [df setDateFormat:@"yyyy年MM月"];
    *stdate             = [NSString stringWithFormat:@"%@1日", [df stringFromDate:today]];
    [df setDateFormat:@"MM月dd日"];
    *enddate            = [df stringFromDate:today];
}

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
    self.title = @"套餐查询";
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    {
        UILabel* numlab = [[UILabel alloc] initWithFrame:CGRectMake(10,15,300,22)];
        numlab.backgroundColor = [UIColor clearColor];
        numlab.font     = [UIFont systemFontOfSize:14];
        numlab.textColor= [UIColor blackColor];
        {
            //numlab.text     = @"查询号码:18925032998";
            NSDictionary *logindict = [Global sharedInstance].loginInfoDict;
            NSString *PhoneNum = logindict[@"UserLoginName"] ? logindict[@"UserLoginName"] : @"";
            numlab.text = [NSString stringWithFormat:@"查询号码：%@",PhoneNum];
        }
        [self.view addSubview:numlab];
        
        UILabel* datelab = [[UILabel alloc] initWithFrame:CGRectMake(10,37,300,22)];
        datelab.backgroundColor = [UIColor clearColor];
        datelab.font     = [UIFont systemFontOfSize:14];
        datelab.textColor= [UIColor blackColor];
        {
        
            NSString* startDate    = @"";
            NSString* endsDate     = @"";
            [self getSNEDate:&startDate end:&endsDate];
            //NSLog(@"start=%@,end=%@",startDate,endsDate);
            datelab.text     = [NSString stringWithFormat:@"查询周期：%@-%@", startDate, endsDate];//@"计费起始日期：2013年10月1日-10月10日";
        }
        [self.view addSubview:datelab];
        
        // div line
        UIImageView* divLine0 = [[UIImageView alloc] initWithFrame:CGRectMake(0,65, 320, 1)];
        divLine0.image = [UIImage imageNamed:@"recharge_horline_bg.png"];
        [self.view addSubview:divLine0];
    }
    
    {
        UIScrollView* scrolView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,65,320,self.view.frame.size.height-65)];
        scrolView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        scrolView.tag           = kTagScrollview;
        scrolView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scrolView];
    }
    
    [self qryPackageInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)qryPackageInfo{
    NSDictionary* logindict= [Global sharedInstance].loginInfoDict;
    NSString *PhoneNum = logindict[@"UserLoginName"] ? logindict[@"UserLoginName"] : @"";
    NSDictionary *params   = [NSDictionary dictionaryWithObjectsAndKeys:
                              PhoneNum,@"PhoneNum",
                              nil];
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    self._QryOperation01   = [MyAppDelegate.cserviceEngine postXMLWithCode:@"ppaccuFlowInfo"
                                                                    params:params
                                                               onSucceeded:^(NSDictionary *dict)
    {
       [self onQryFlowInfoBack:dict];
       [SVProgressHUD dismiss];
   } onError:^(NSError *engineError) {
       DDLogInfo(@"%s--%@", __func__, engineError);
       [self onQryFlowInfoError:engineError];
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

-(void)onQryFlowInfoBack:(NSDictionary*)dict
{
    UIScrollView* scrolView = (UIScrollView*)[self.view viewWithTag:kTagScrollview];
    {
        UILabel* mtitle = [[UILabel alloc] initWithFrame:CGRectMake(10,10,220,44)];
        mtitle.backgroundColor = [UIColor clearColor];
        mtitle.font     = [UIFont systemFontOfSize:13];
        mtitle.numberOfLines = 2;
        mtitle.textColor= [UIColor blackColor];
        mtitle.tag      = kTagLab_tipLabel;
        mtitle.text     = @"套餐内'-'使用量排名第一，建议订购流量包，每M流量最多节省50%";
        [scrolView addSubview:mtitle];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(230,14,74,30);
        [button dwMakeRoundCornerWithRadius:3];
        [button setBackgroundImage:[UIImage imageNamed:@"qry_btn_bg.png"]
                          forState:UIControlStateNormal];
        button.tag = kTagBtn;
        [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [button setTitleColor:[UIColor colorWithRed:61/255.0
                                              green:61/255.0
                                               blue:61/255.0
                                              alpha:1]
                     forState:UIControlStateNormal];
        [button setTitle:@"订购流量包" forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(onQryAttribution:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self
                   action:@selector(onStreamPackageBution:)
         forControlEvents:UIControlEventTouchUpInside];
        [scrolView addSubview:button];
        
        // 图片：
        {
            UIImageView* stepimg = [[UIImageView alloc] initWithFrame:CGRectMake(45,130,77,38)];
            [stepimg setImage:[UIImage imageNamed:@"qry_step_01.png"]];
            [stepimg setBackgroundColor:[UIColor clearColor]];
            [scrolView addSubview:stepimg];
            
            UIImageView* stepimg1 = [[UIImageView alloc] initWithFrame:CGRectMake(121,110,78,58)];
            [stepimg1 setImage:[UIImage imageNamed:@"qry_step_02.png"]];
            [stepimg1 setBackgroundColor:[UIColor clearColor]];
            [scrolView addSubview:stepimg1];
            
            UIImageView* stepimg2 = [[UIImageView alloc] initWithFrame:CGRectMake(199,135,77,33)];
            [stepimg2 setImage:[UIImage imageNamed:@"qry_step_03.png"]];
            [stepimg2 setBackgroundColor:[UIColor clearColor]];
            [scrolView addSubview:stepimg2];
            
            UIImageView* divLine0 = [[UIImageView alloc] initWithFrame:CGRectMake(0,168, 320, 1)];
            divLine0.image = [UIImage imageNamed:@"recharge_horline_bg.png"];
            [scrolView addSubview:divLine0];
        }
        
        {
            {// 台阶2
                UILabel* mtitle = [[UILabel alloc] initWithFrame:CGRectMake(45,86,77,44)];
                mtitle.tag = kTagLab_step02;
                mtitle.backgroundColor = [UIColor clearColor];
                mtitle.numberOfLines   = 2;
                mtitle.font     = [UIFont boldSystemFontOfSize:13];
                mtitle.textColor= [UIColor blackColor];
                mtitle.textAlignment = UITextAlignmentCenter;
                //mtitle.text     = @"语音\r已使用30%";
                [scrolView addSubview:mtitle];
            }
            {// 台阶1
                UILabel* mtitle = [[UILabel alloc] initWithFrame:CGRectMake(121,70,78,44)];
                mtitle.tag = kTagLab_step01;
                mtitle.backgroundColor = [UIColor clearColor];
                mtitle.numberOfLines   = 2;
                mtitle.font     = [UIFont boldSystemFontOfSize:13];
                mtitle.textColor= [UIColor blackColor];
                mtitle.textAlignment = UITextAlignmentCenter;
                //mtitle.text     = @"流量\r已使用30%";
                [scrolView addSubview:mtitle];
            }
            {// 台阶3
                UILabel* mtitle = [[UILabel alloc] initWithFrame:CGRectMake(199,92,77,44)];
                mtitle.tag = kTagLab_step03;
                mtitle.backgroundColor = [UIColor clearColor];
                mtitle.numberOfLines   = 2;
                mtitle.font     = [UIFont boldSystemFontOfSize:13];
                mtitle.textAlignment = UITextAlignmentCenter;
                mtitle.textColor= [UIColor blackColor];
                //mtitle.text     = @"短信\r已使用30%";
                [scrolView addSubview:mtitle];
            }
        }
    }

    NSDictionary* data = [dict objectForKey:@"Data"];
    NSDictionary* CallAccDict = [data objectForKey:@"CallAccList"];
    NSDictionary* FlowAccDict = [data objectForKey:@"FlowAccList"];
    NSDictionary* pSMSAccDict = [data objectForKey:@"SmsAccList"];
    
    CGFloat callPercent=0.0,flowPercent=0.0,smsPercent=0.0;
    
    callPercent = [self getUsedPercent:CallAccDict];
    flowPercent = [self getUsedPercent:FlowAccDict];
    smsPercent  = [self getUsedPercent:pSMSAccDict];
    
    NSLog(@"call flow sms %f, %f, %f", callPercent, flowPercent, smsPercent);
    
    NSMutableArray* ary     = [NSMutableArray new];
    // 话费
    NSDictionary* calldict  = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"语音",@"name",
                                           [NSNumber numberWithFloat:callPercent],@"percent",nil];
    [ary addObject:calldict];
    // 流量
    NSDictionary* flowdict  = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"流量",@"name",
                                           [NSNumber numberWithFloat:flowPercent],@"percent",nil];
    [ary addObject:flowdict];

    // 短信
    NSDictionary* smsdict  = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"短信",@"name",
                                           [NSNumber numberWithFloat:smsPercent],@"percent",nil];
    [ary addObject:smsdict];
    // 排序
    [self sortArray:ary orderWithKey:@"percent" ascending:NO];
    
    UIScrollView* scview = (UIScrollView*)[self.view viewWithTag:kTagScrollview];
    
    UILabel* labstab2 = (UILabel*)[scview viewWithTag:kTagLab_step02];
    UILabel* labstab1 = (UILabel*)[scview viewWithTag:kTagLab_step01];
    UILabel* labstab3 = (UILabel*)[scview viewWithTag:kTagLab_step03];
    UILabel* labstip  = (UILabel*)[scview viewWithTag:kTagLab_tipLabel];
    UIButton* btn = (UIButton *)[scview viewWithTag:kTagBtn];
    {
        NSString* name= [[ary objectAtIndex:0] objectForKey:@"name"];
        if ([name isEqualToString:@"流量"]) {
            labstip.text  = @"您是流量达人，建议购买流量卡可节省高达200%的费用，还可跨月使用哟";
            [btn setTitle:@"充流量" forState:UIControlStateNormal];
        }else if([name isEqualToString:@"语音"]){
            labstip.text  = [NSString stringWithFormat:@"您是电话达人"];
            labstip.hidden = YES;
            btn.hidden = YES;
        }else if([name isEqualToString:@"短信"]){
            labstip.text  = [NSString stringWithFormat:@"您是短信达人"];
            labstip.hidden = YES;
            btn.hidden = YES;
        }
    }

    {
        NSString* name= [[ary objectAtIndex:0] objectForKey:@"name"];
        NSNumber* val = [[ary objectAtIndex:0] objectForKey:@"percent"];
        CGFloat  pval = [val floatValue]*100;
        labstab1.text = [NSString stringWithFormat:@"%@\r已用%0.1f%@",name,pval,@"%"];
    }

    {
        NSString* name= [[ary objectAtIndex:1] objectForKey:@"name"];
        NSNumber* val = [[ary objectAtIndex:1] objectForKey:@"percent"];
        CGFloat  pval = [val floatValue]*100;
        labstab2.text = [NSString stringWithFormat:@"%@\r已用%0.1f%@",name,pval,@"%"];
    }

    {
        NSString* name= [[ary objectAtIndex:2] objectForKey:@"name"];
        NSNumber* val = [[ary objectAtIndex:2] objectForKey:@"percent"];
        CGFloat  pval = [val floatValue]*100;
        labstab3.text = [NSString stringWithFormat:@"%@\r已用%0.1f%@",name,pval,@"%"];
    }
    
    // 下面处理套餐项
    NSArray* PpaccuAccList = [NSArray array];
    if ([[[data objectForKey:@"PpaccuAccList"] objectForKey:@"ListItem"] isKindOfClass:[NSDictionary class]])
    {
        PpaccuAccList = [NSArray arrayWithObject:[[data objectForKey:@"PpaccuAccList"] objectForKey:@"ListItem"]];
    }
    else if ([[[data objectForKey:@"PpaccuAccList"] objectForKey:@"ListItem"] isKindOfClass:[NSArray class]])
    {
        PpaccuAccList = [NSArray arrayWithArray:[[data objectForKey:@"PpaccuAccList"] objectForKey:@"ListItem"]];
    }
    NSMutableArray* itemsAry    = [self getPPaccItemsAryBydict:PpaccuAccList];
    CGFloat xval=10, yval = 180;
    for (int i = 0; i < [itemsAry count]; i ++)
    {
        CTPackageItem* item = [[CTPackageItem alloc] initWithFrame:CGRectMake(xval, yval, 300, 40)];
        [item setData:[itemsAry objectAtIndex:i]];
        [scview addSubview:item];
        yval += 50;
    }
    scview.contentSize = CGSizeMake(320, yval);
}

- (void) showPackageUsrInfo : (NSArray *) array
{
   
}

-(void)onQryFlowInfoError:(NSError*)error
{
    UIScrollView* scrolView = (UIScrollView*)[self.view viewWithTag:kTagScrollview];
    UILabel* mtitle = [[UILabel alloc] initWithFrame:CGRectMake(10,(scrolView.frame.size.height-60)/2,
                                                                300,60)];
    mtitle.backgroundColor = [UIColor clearColor];
    mtitle.font     = [UIFont systemFontOfSize:13];
    mtitle.numberOfLines = 3;
    mtitle.textColor= [UIColor darkGrayColor];
    mtitle.textAlignment = UITextAlignmentCenter;
    mtitle.text     = [NSString stringWithFormat:@"抱歉，套餐查询失败，原因如下:\r\n%@。",[error localizedDescription]];
    [scrolView addSubview:mtitle];
}

-(CGFloat)getUsedPercent:(NSDictionary*)dict{
    NSDictionary* items = [[[dict objectForKey:@"ListItem"] objectForKey:@"AccList"] objectForKey:@"Items"];
    //NSLog(@"items=%@",[items description]);
    NSNumber* AccAmount     = [items objectForKey:@"AccAmount"];
    NSNumber* BalanceAmount = [items objectForKey:@"BalanceAmount"];
    CGFloat per;
    if ([AccAmount intValue] == 0)
    {
        per = 0.0f;
    }
    else if ([BalanceAmount intValue] == 0)
    {
        per = 1.0f;
    }
    else
    {
        per = ([AccAmount intValue]-[BalanceAmount intValue])*1.0/[AccAmount intValue];
    }
    
    return per;
}

-(void)sortArray:(NSMutableArray*)dicArray
    orderWithKey:(NSString *)key
       ascending:(BOOL)yesOrNo
{
    NSSortDescriptor *distanceDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:yesOrNo];
    NSArray *descriptors = [NSArray arrayWithObjects:distanceDescriptor,nil];
    [dicArray sortUsingDescriptors:descriptors];
}

-(NSMutableArray*)getPPaccItemsAryBydict:(NSArray*)dict
{
    NSMutableArray* retArray = [[NSMutableArray alloc] initWithCapacity:20];
    for (id acclist in dict )
    {
        NSLog(@"acclist=%@",[acclist description]);
        if ([acclist isKindOfClass:[NSDictionary class]])
        {
            id titem = [[(NSDictionary*)acclist objectForKey:@"AccList"] objectForKey:@"Items"];
            if ([titem isKindOfClass:[NSDictionary class]])
            {
                [retArray addObject:titem];
            }else if([titem isKindOfClass:[NSArray class]])
            {
                [retArray addObjectsFromArray:titem];
            }
        }
    }
    
    return retArray;
}



@end
