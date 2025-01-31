//
//  CPayDoneVctler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 14-1-17.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CPayDoneVctler.h"
#import "CTMyOrderListVCtler.h"
#import "CTPrettyNumberVCtler.h"
#import "COQueryVctler.h"

#define kTagRootScrollview 100
#define kTagImageViewFrame 150
@interface CPayDoneVctler ()

@property (nonatomic, strong) UILabel *phoneLab;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIScrollView *scrollView;

-(void)onOkBtnAction:(id)sender;
@end

@implementation CPayDoneVctler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"订单确认";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    self.view.backgroundColor= [UIColor colorWithRed:235/255.0
                                               green:235/255.0
                                                blue:235/255.0
                                               alpha:1.0];
    UIScrollView* rootSbview = [[UIScrollView alloc] initWithFrame:self.view.frame];
    rootSbview.tag =kTagRootScrollview;
    rootSbview.backgroundColor = [UIColor colorWithRed:235/255.0
                                                 green:235/255.0
                                                  blue:235/255.0
                                                 alpha:1.0];
    rootSbview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:rootSbview];
    self.scrollView = rootSbview ;
    
    CGFloat xoffset = 15;
    CGFloat yoffset = 15;
    CGRect  trect   = CGRectMake(xoffset, yoffset, self.view.frame.size.width-xoffset*2,44);
    {
        UILabel* labTip = [[UILabel alloc] initWithFrame:trect];
        labTip.numberOfLines   = 2;
        labTip.backgroundColor = [UIColor clearColor];
        labTip.text = [NSString stringWithFormat:@"您的订单(订单编号%@)\r\n%@。", self.pOrderId, self.pOrderStatusDescription];
        labTip.font = [UIFont boldSystemFontOfSize:15];
        labTip.numberOfLines = 0;
        [labTip sizeToFit];
        [rootSbview addSubview:labTip];
        yoffset += CGRectGetHeight(labTip.frame);
    }
    
    {
        trect   = CGRectMake(xoffset, yoffset, self.view.frame.size.width-xoffset*2,30);
        UILabel* labTip = [[UILabel alloc] initWithFrame:trect];
        labTip.backgroundColor = [UIColor clearColor];
        labTip.text = @"您订购的商品是：";
        labTip.font = [UIFont systemFontOfSize:15];
        [rootSbview addSubview:labTip];
        yoffset += CGRectGetHeight(labTip.frame)+10;
    }

    {
        trect   = CGRectMake(xoffset, yoffset, self.view.frame.size.width-xoffset*2,43);
        UIImageView* rframeView = [[UIImageView alloc] init];
        rframeView.userInteractionEnabled = YES;
        rframeView.tag   = kTagImageViewFrame;
        UIImage * tImage = [[UIImage  imageNamed:@"per_content_bg.png"] stretchableImageWithLeftCapWidth:10
                                                                                            topCapHeight:10];
        rframeView.image = tImage;
        self.bgImageView = rframeView;
        rframeView.frame = trect;
        //
        UILabel* labPhone = [[UILabel alloc] init];
        labPhone.text = self.pComboName;
        labPhone.numberOfLines = 2;
        labPhone.tag  = 100;
        labPhone.font = [UIFont systemFontOfSize:14];
        labPhone.frame= CGRectMake(5,0,CGRectGetWidth(rframeView.frame)-10,CGRectGetHeight(rframeView.frame));
        labPhone.backgroundColor = [UIColor clearColor];
        self.phoneLab = labPhone ;
        [rframeView addSubview:labPhone];
        [rootSbview addSubview:rframeView];
        yoffset += CGRectGetHeight(rframeView.frame)+10;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = rframeView.bounds ;
        [btn addTarget:self action:@selector(onOkBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [rframeView addSubview:btn];
        self.button = btn;
    }
    
//    {
//        trect   = CGRectMake(xoffset, yoffset, self.view.frame.size.width-xoffset*2,44);
//        UILabel* labTip = [[UILabel alloc] initWithFrame:trect];
//        labTip.backgroundColor = [UIColor clearColor];
//        labTip.numberOfLines = 2;
//        labTip.text = @"本订单为快速购买订单，\r\n可以通过以下路径查询订单情况：";
//        labTip.font = [UIFont systemFontOfSize:15];
//        [rootSbview addSubview:labTip];
//        yoffset += CGRectGetHeight(labTip.frame);
//    }
//    
//    {
//        trect   = CGRectMake(xoffset, yoffset, self.view.frame.size.width-xoffset*2,30);
//        UILabel* labTip = [[UILabel alloc] initWithFrame:trect];
//        labTip.backgroundColor = [UIColor clearColor];
//        labTip.text = @"查询-->订单查询-->快速订单";
//        labTip.font = [UIFont systemFontOfSize:15];
//        labTip.textColor = [UIColor colorWithRed:112/255.0
//                                           green:195/255.0
//                                            blue:56/255.0
//                                           alpha:1.0];
//        [rootSbview addSubview:labTip];
//        yoffset += CGRectGetHeight(labTip.frame) + 10;
//    }
//    
//    {
//        trect = CGRectMake(20, yoffset, self.view.frame.size.width-20*2,35);
//        UIButton* btnNextStp = [UIButton buttonWithType:UIButtonTypeSystem];
//        btnNextStp.frame = trect;
//        [btnNextStp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [btnNextStp setTitle:@"确定" forState:UIControlStateNormal];
//        UIImage* bgImg =
//        [[UIImage imageNamed:@"myOrderBtn.png"] stretchableImageWithLeftCapWidth:20
//                                                                    topCapHeight:20];
//        [btnNextStp setBackgroundImage:bgImg forState:UIControlStateNormal];
//        [btnNextStp addTarget:self
//                       action:@selector(onOkBtnAction:)
//             forControlEvents:UIControlEventTouchUpInside];
//        [rootSbview addSubview:btnNextStp];
//        yoffset += CGRectGetHeight(btnNextStp.frame) + 10;
//        // 总数 + 按钮
//        rootSbview.contentSize= CGSizeMake(CGRectGetWidth(rootSbview.frame), yoffset);
//    }
    [self setPhoneInfo];
}

- (void) setPhoneInfo
{
    if (self.info&& self.info[@"item"]) {
        if (self.info[@"item"][@"PhoneNumber"]) {
            
            NSString *str = [NSString stringWithFormat:@"%@\n%@  %@",self.salesProInfo[@"SalesProName"],self.info[@"item"][@"PhoneNumber"],self.pComboName];
            self.phoneLab.numberOfLines = 0;
            self.phoneLab.text = str;
            [self.phoneLab sizeToFit];
            self.phoneLab.frame = CGRectMake(5, 5, self.phoneLab.frame.size.width, self.phoneLab.frame.size.height);
            
            self.bgImageView.frame = CGRectMake(self.bgImageView.frame.origin.x, self.bgImageView.frame.origin.y, self.bgImageView.frame.size.width, self.phoneLab.frame.size.height + 10);
            self.button.frame = self.bgImageView.bounds ;
            
            //初始化
            CGFloat xoffset = 15;
            CGFloat yoffset = 15;
            CGRect  trect;
            yoffset = CGRectGetMaxY(self.bgImageView.frame) + 10;
            {
                trect   = CGRectMake(xoffset, yoffset, self.view.frame.size.width-xoffset*2,44);
                UILabel* labTip = [[UILabel alloc] initWithFrame:trect];
                labTip.backgroundColor = [UIColor clearColor];
                labTip.numberOfLines = 2;
                labTip.text = @"本订单为快速购买订单，\r\n可以通过以下路径查询订单情况：";
                labTip.font = [UIFont systemFontOfSize:15];
                [self.scrollView addSubview:labTip];
                yoffset = CGRectGetMaxY(labTip.frame)+10;
            }
            
            {
                trect   = CGRectMake(xoffset, yoffset, self.view.frame.size.width-xoffset*2,30);
                UILabel* labTip = [[UILabel alloc] initWithFrame:trect];
                labTip.backgroundColor = [UIColor clearColor];
                labTip.text = @"查询-->订单查询-->快速订单";
                labTip.font = [UIFont systemFontOfSize:15];
                labTip.textColor = [UIColor colorWithRed:112/255.0
                                                   green:195/255.0
                                                    blue:56/255.0
                                                   alpha:1.0];
                [self.scrollView addSubview:labTip];
                yoffset = CGRectGetMaxY(labTip.frame) + 10;
            }
            
            {
                trect = CGRectMake(20, yoffset, self.view.frame.size.width-20*2,35);
                UIButton* btnNextStp = [UIButton buttonWithType:UIButtonTypeSystem];
                btnNextStp.frame = trect;
                [btnNextStp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btnNextStp setTitle:@"确定" forState:UIControlStateNormal];
                UIImage* bgImg =
                [[UIImage imageNamed:@"myOrderBtn.png"] stretchableImageWithLeftCapWidth:20
                                                                            topCapHeight:20];
                [btnNextStp setBackgroundImage:bgImg forState:UIControlStateNormal];
                [btnNextStp addTarget:self
                               action:@selector(onOkBtnAction:)
                     forControlEvents:UIControlEventTouchUpInside];
                [self.scrollView addSubview:btnNextStp];
                yoffset += CGRectGetHeight(btnNextStp.frame) + 10;
                // 总数 + 按钮
                self.scrollView.contentSize= CGSizeMake(CGRectGetWidth(self.scrollView.frame), yoffset);
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onLeftBtnAction:(id)sender
{
//    NSArray *array =  self.navigationController.viewControllers;
//    for (id vc in array) {
//        if ([vc isKindOfClass:[CTPrettyNumberVCtler class]]) {
//            [self.navigationController popToViewController:vc animated:YES];
//            break ;
//        }
//    }
//    [self.navigationController popToViewController:array[1] animated:YES];
    
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
}

-(void)onOkBtnAction:(id)sender{
    
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

@end
