//
//  COrderFillVctler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 14-1-17.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "COrderFillVctler.h"
#import "UIView+RoundRect.h"
#import "CRecipientEditView.h"
#import "CInvoiceEditView.h"
#import "CRecipientSelectVctler.h"
#import "CserviceEngine.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "COrderComfirmVctler.h"
#import "Utils.h"
#import "CTServiceAgreementVCtler.h"
#import "SVProgressHUD.h"

#define kTagRootScrollview 100

#define kTagTfUserName 89011
#define kTagTfUserCode 89012
#define kTagTfAddress  89013
#define kTagTfPostCode 89014

#define kTagBtnAgreeMent 89015

#define kTagEditView   89020
#define kTagRecipientView   89021
#define kTagInvoiceView   89022


#define keyBoardHeight 184


@interface COrderFillVctler ()
{
//    NSMutableArray* _recipienList;
//    NSDictionary*   _defaultRecipDict;
    
    // 城市选择相关：
    BOOL          _showingPicker;
//    NSMutableArray* _areaList;  // 省份列表
    UIPickerView* _areaPicker;  // pickerview
    
    UITextField*  _activTfView;
    
    // 合作条款是否同意
    BOOL          _ifAgreetoRule;
    BOOL          _isFirst;  //add by liuruxian,2014-02-24
    UIButton*       _licenseCheckBtn;   // added by zy, 2014-02-18
    UIView*        _pickerStatusView;
}
@property (strong, nonatomic)CserviceOperation *_QryOperation;  // 查询：是否有默认的配送地址
@property (strong, nonatomic)CserviceOperation *_QryProvinceOp; // 查询：省份
@property (strong, nonatomic)CserviceOperation *_QryCityOp;     // 查询：成市
@property (strong, nonatomic)CserviceOperation *_QryDistOp;     // 查询：地区
@property (strong, nonatomic)CserviceOperation *_AddRecipientpOp;   // 增加配送地址
//add by liuruxian 2013-03-01
@property (strong, nonatomic) NSMutableArray *areaList;
@property (nonatomic, strong) NSMutableArray *recipienList;
@property (nonatomic, strong) NSDictionary   *defaultRecipDict;

-(void)onSeleOthers:(id)sender;         // 选择其他配送地址
-(void)onKeyboardHidden:(id)sender;     // 隐藏弹出界面：keyboard等
-(void)onSubmintAction:(id)sender;      // 下一步按钮
-(void)onAgreeMentBtn:(id)sender;
-(void)resetRecipientView;              // 切换配送时，更新配件信息视图

// networks
-(void)getRecipienList;                 // 查询：是否有默认的配送地址
-(void)doAddRecipient;                  // 查询：没有配送地址下，自动添加一个配送地址
-(void)onSelectRecipientNotify:(NSNotification*)notify;
-(void)onAgreenMentNotify:(NSNotification*)notify;
@end

@implementation COrderFillVctler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"填写订单信息";
        _ifAgreetoRule= YES;
        _isFirst = NO;
        _recipienList = [NSMutableArray new];
        _areaList     = [NSMutableArray new];
        _defaultRecipDict = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSelectRecipientNotify:)
                                                     name:CTP_MSG_SELECT_RECIPIENT
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAgreenMentNotify:)
                                                     name:@"CTP_MSG_SELECT_AGREEMENT"
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    
    UIScrollView* rootSbview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              CGRectGetWidth(self.view.frame),
                                                                              CGRectGetHeight(self.view.frame))];
    rootSbview.tag =kTagRootScrollview;
    rootSbview.backgroundColor = [UIColor colorWithRed:235/255.0
                                                 green:235/255.0
                                                  blue:235/255.0
                                                 alpha:1.0];
    rootSbview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    {
        UIButton* btnHidden = [UIButton buttonWithType:UIButtonTypeCustom];
        btnHidden.frame = CGRectMake(0, 0, CGRectGetWidth(rootSbview.frame),
                                     CGRectGetHeight(rootSbview.frame));
        btnHidden.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [btnHidden addTarget:self
                      action:@selector(onKeyboardHidden:)
            forControlEvents:UIControlEventTouchUpInside];
        [rootSbview addSubview:btnHidden];
    }
    
    [self.view addSubview:rootSbview];
    [self getRecipienList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CTP_MSG_SELECT_AGREEMENT" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTP_MSG_SELECT_RECIPIENT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hiddenPicker];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
}

- (void) dealloc{
    
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
    
    if (_areaPicker && [_areaPicker isDescendantOfView:MyAppDelegate.window]) {
        [_areaPicker removeFromSuperview];
        [_pickerStatusView removeFromSuperview];
        _areaPicker = nil;
        _pickerStatusView = nil;
    } else {
        _areaPicker = nil;
        _pickerStatusView = nil;
    }
}

-(void)LayoutScollview{
    UIScrollView* rootSbview = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
    {
        // 右半边
        CGFloat xoffset = 30;
        CGFloat yoffset = 10;
        CGFloat grepv   = 5;
        CGRect  trect   = CGRectMake(xoffset, yoffset, self.view.frame.size.width-xoffset-grepv, 30);
        {
            UILabel* labTip = [[UILabel alloc] initWithFrame:trect];
            labTip.backgroundColor = [UIColor clearColor];
            labTip.text = @"填写入网信息";
            labTip.font = [UIFont boldSystemFontOfSize:15];
            [rootSbview addSubview:labTip];
        }
        
        yoffset += CGRectGetHeight(trect)+5;
        trect   = CGRectMake(xoffset+10, yoffset, 110, 35);
        NSArray* ary = @[@"机主姓名:",@"机主身份证号:",@"地址:"/*,@"邮政编码:"*/];
        int counter = 0;
        for (NSString* title in ary) {
            UILabel* startLab = [[UILabel alloc] initWithFrame:CGRectMake(xoffset, yoffset, 10, 35)];
            startLab.backgroundColor = [UIColor clearColor];
            startLab.text = @"*";
            startLab.textColor = [UIColor colorWithRed:233/255.0
                                                 green:80/255.0
                                                  blue:65/255.0
                                                 alpha:1];
            startLab.font = [UIFont systemFontOfSize:15];
            [rootSbview addSubview:startLab];
            
            UILabel* labTip = [[UILabel alloc] initWithFrame:trect];
            labTip.backgroundColor = [UIColor clearColor];
            labTip.text = title;
            labTip.font = [UIFont systemFontOfSize:15];
            [rootSbview addSubview:labTip];
            
            CGRect rightRc = CGRectMake(CGRectGetWidth(trect)+xoffset,
                                        yoffset, 165, 35);
            UITextField *txtFeild = [[UITextField alloc]initWithFrame:rightRc];
            txtFeild.tag = kTagTfUserName + counter;
            txtFeild.backgroundColor =  [UIColor whiteColor];
            txtFeild.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter ;
            txtFeild.returnKeyType = UIReturnKeyDone ;
            txtFeild.clearButtonMode = UITextFieldViewModeWhileEditing ; //点击清除
            if (counter == 3) {
                txtFeild.keyboardType = UIKeyboardTypeNumberPad ;
            }
            else if (counter == 1)      // added by zy, 2014-02-19
            {
                txtFeild.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            } else if(counter == 0)
            {
                //                txtFeild.keyboardType = UIKeyboardTypeNumbersAndPunctuation ;
            }
            else{
                txtFeild.keyboardType = UIKeyboardTypeDefault ;
            }
            txtFeild.delegate = self;
            txtFeild.font = [UIFont systemFontOfSize:14];
            [rootSbview addSubview:txtFeild];
            
            yoffset += CGRectGetHeight(trect)+5;
            trect   = CGRectMake(xoffset+10, yoffset, 110, 35);
            counter ++;
        }
        
        trect   = CGRectMake(xoffset, yoffset+25,255, 35);
#if 0   // modified by zy, 2014-02-18
        {
            UIButton* btnRead = [UIButton buttonWithType:UIButtonTypeSystem];
            btnRead.tag   = kTagBtnAgreeMent;
            btnRead.frame = trect;
            [btnRead setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnRead setTitle:@"阅读并同意服务协议" forState:UIControlStateNormal];
            [btnRead setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0,90)];
            //btnRead.enabled = NO;
            UIImage* bgImg =
            [[UIImage imageNamed:@"FeiYoung_Btn2_Selected.png"] stretchableImageWithLeftCapWidth:20
                                                                                    topCapHeight:20];
            // 默认选中
            //            UIImage * bgImg = [[UIImage  imageNamed:@"per_content_bg.png"] stretchableImageWithLeftCapWidth:10
            //                                                                                                topCapHeight:10];
            
            [btnRead setBackgroundImage:bgImg forState:UIControlStateNormal];
            [btnRead addTarget:self
                        action:@selector(onAgreeMentBtn:) forControlEvents:UIControlEventTouchUpInside];
            [rootSbview addSubview:btnRead];
        }
#else
        {
            UIImage* img = [UIImage imageNamed:@"login_button1"];
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(trect.origin.x, trect.origin.y, 40, 40);
            [btn setImage:img forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"login_button1_selected"] forState:UIControlStateSelected];
            [btn setImageEdgeInsets:UIEdgeInsetsMake((CGRectGetHeight(btn.frame) - img.size.height)/2,
                                                     (CGRectGetWidth(btn.frame) - img.size.width)/2,
                                                     (CGRectGetHeight(btn.frame) - img.size.height)/2,
                                                     (CGRectGetWidth(btn.frame) - img.size.width)/2)];
            btn.selected = YES;
            [btn addTarget:self action:@selector(onServiceLienceCheckBtn:) forControlEvents:UIControlEventTouchUpInside];
            [rootSbview addSubview:btn];
            _licenseCheckBtn = btn;
        }
        {
            UIButton* btnRead = [UIButton buttonWithType:UIButtonTypeCustom];
            btnRead.tag   = kTagBtnAgreeMent;
            btnRead.frame = CGRectInset(trect, 40, 0);
            [btnRead setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnRead setTitle:@"阅读并同意服务协议 >>" forState:UIControlStateNormal];
            [btnRead.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [btnRead setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [btnRead setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [btnRead setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
            [btnRead addTarget:self action:@selector(onAgreeMentBtn:) forControlEvents:UIControlEventTouchUpInside];
            [rootSbview addSubview:btnRead];
        }
#endif
      
        
        yoffset = CGRectGetMaxY(trect) +24;
        UIImage *image = [UIImage imageNamed:@"prettyNum_dividingLine_ver.png"];
        UIImageView *dividing = [[UIImageView alloc] initWithFrame:CGRectMake(0, yoffset, CGRectGetWidth(rootSbview.frame), 1)];
        dividing.image = image;
        [rootSbview addSubview:dividing];
        
        // 下一步，提交订单
        if (_defaultRecipDict == nil)
            //if (1)
        {
            yoffset += 20;
            trect = CGRectMake(xoffset-10, yoffset,CGRectGetWidth(rootSbview.frame)-xoffset, 260);
            CRecipientEditView* editView = [[CRecipientEditView alloc] initWithFrame:trect];
            editView.tag = kTagEditView;
            editView.delegate = self;
            [rootSbview addSubview:editView];
            editView.reciper.delegate  = self;
            editView.address.delegate  = self;
            editView.postcode.delegate = self;
            editView.phone.delegate    = self;
            
            
            //选项栏
            UIView *pickerSelView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(MyAppDelegate.window.frame), CGRectGetWidth(self.view.frame), 40)];
            pickerSelView.backgroundColor = [UIColor colorWithRed:(9*16+7)/255. green:(9*16+7)/255. blue:(9*16+7)/255. alpha:1];
           
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                 [MyAppDelegate.window addSubview:pickerSelView];
                 _pickerStatusView = pickerSelView ;
            }
            {
                
                UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
                cancelBtn.frame = CGRectMake(0, 0, 80, 40);
                [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
                [pickerSelView addSubview:cancelBtn] ;
                
                
                UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [okBtn setTitle:@"完成" forState:UIControlStateNormal];
                [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                okBtn.titleLabel.font = [UIFont systemFontOfSize:18];
                okBtn.frame = CGRectMake(320-80, 0, 80, 40);
                [okBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
                [pickerSelView addSubview:okBtn] ;
            }
            
            // picker
            UIPickerView * picker = [[UIPickerView alloc] init];
            picker.dataSource     = (id<UIPickerViewDataSource>)self;
            picker.delegate       = (id<UIPickerViewDelegate>)self;
            [picker setBackgroundColor:[UIColor whiteColor]];
            picker.showsSelectionIndicator = YES;
            _areaPicker           = picker;
            [self getProvinceList];
            
        }else
        {
            yoffset += 10;
            trect = CGRectMake(xoffset,yoffset,CGRectGetWidth(rootSbview.frame)-xoffset-15,100);
            UIView* recipSelView = [[UIView alloc] init];
            recipSelView.tag     = kTagRecipientView;
            recipSelView.frame   = trect;
            recipSelView.backgroundColor = [UIColor clearColor];
            [rootSbview addSubview:recipSelView];
            [self resetRecipientView];
        }
        
        yoffset += CGRectGetHeight(trect) + 5;
        trect = CGRectMake(xoffset, yoffset,CGRectGetWidth(rootSbview.frame)-2*xoffset,35);
        //下一步
        {
            UIButton* btnRead = [UIButton buttonWithType:UIButtonTypeSystem];
            btnRead.frame = trect;
            [btnRead setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnRead setTitle:@"下一步" forState:UIControlStateNormal];
            UIImage* bgImg =
            [[UIImage imageNamed:@"myOrderBtn.png"] stretchableImageWithLeftCapWidth:20
                                                                        topCapHeight:20];
            [btnRead setBackgroundImage:bgImg forState:UIControlStateNormal];
            [btnRead addTarget:self
                        action:@selector(onSubmintAction:)
              forControlEvents:UIControlEventTouchUpInside];
            [rootSbview addSubview:btnRead];
        }
        
        //底部
        yoffset += CGRectGetHeight(trect) + 10;
        rootSbview.contentSize = CGSizeMake(CGRectGetWidth(rootSbview.frame), yoffset);
    }
    
    {// 左半边
        UIView* leftbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 314)];
        leftbg.backgroundColor = [UIColor colorWithRed:121/255.0
                                                 green:198/255.0
                                                  blue:74/255.0
                                                 alpha:1.0];
//        [rootSbview addSubview:leftbg];
        
        CGFloat xof = -5;
        CGFloat yof = 25;
        CGRect  labRce = CGRectMake(xof, yof, 48, 40);
        NSArray* ary = @[@"号码",@"套餐",@"订单",@"支付"];
        for (NSString * title in ary) {
            UIButton* labTip = [UIButton buttonWithType:UIButtonTypeCustom];
            labTip.frame = labRce;
            labTip.layer.cornerRadius = 5.0;
            labTip.titleLabel.font = [UIFont systemFontOfSize:14];
            labTip.userInteractionEnabled= NO;
            labTip.backgroundColor = [UIColor colorWithRed:187/255.0
                                                     green:187/255.0
                                                      blue:187/255.0
                                                     alpha:1.0];
            if ([title isEqualToString:@"订单"]) {
                labTip.backgroundColor = [UIColor colorWithRed:121/255.0
                                                         green:198/255.0
                                                          blue:74/255.0
                                                         alpha:1.0];
            }
            [labTip setTitle:title forState:UIControlStateNormal] ;//@"号码";
//            [rootSbview addSubview:labTip];
            yof = CGRectGetMaxY(labRce) + 43;
            labRce = CGRectMake(xof, yof, 48, 40);
        }
    }
}

- (void)onServiceLienceCheckBtn:(UIButton* )btn
{
    btn.selected = !btn.selected;
    _ifAgreetoRule = btn.selected;
}

-(void)resetRecipientView
{
    UIScrollView* rootSbview = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
    UIView* recipientview = [rootSbview viewWithTag:kTagRecipientView];
    if (!recipientview) {
        return;
    }
    
    for (UIView* tv in [recipientview subviews]) {
        [tv removeFromSuperview];
    }
    
    CGFloat txval = 10,tyval = 0;
    UILabel* labTip = [[UILabel alloc] initWithFrame:CGRectMake(txval, tyval, 140, 30)];
    labTip.backgroundColor = [UIColor clearColor];
    labTip.text = @"选择收件人信息";
    labTip.font = [UIFont systemFontOfSize:15];
    [recipientview addSubview:labTip];
    
    UIButton* selBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selBtn.frame = CGRectMake(CGRectGetWidth(recipientview.frame)-100,tyval,100, 30);
    [selBtn setTitleColor:[UIColor colorWithRed:70/255.0
                                          green:136/255.0
                                           blue:31/255.0
                                          alpha:1]
                 forState:UIControlStateNormal];
    [selBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    selBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [selBtn setTitle:@"其他收件人" forState:UIControlStateNormal];
    [selBtn addTarget:self action:@selector(onSeleOthers:) forControlEvents:UIControlEventTouchUpInside];
    [recipientview addSubview:selBtn];
    
    tyval += CGRectGetHeight(labTip.frame);
    
    UIButton* btnRead = [UIButton buttonWithType:UIButtonTypeSystem];
    btnRead.frame = CGRectMake(txval,tyval,
                               CGRectGetWidth(recipientview.frame)-2*txval,
                               CGRectGetHeight(recipientview.frame) - tyval);
    btnRead.enabled = NO;
    [btnRead setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIImage* bgImg  =
    [[UIImage imageNamed:@"FeiYoung_Btn2_Selected.png"] stretchableImageWithLeftCapWidth:20
                                                                            topCapHeight:20];
    [btnRead setBackgroundImage:bgImg forState:UIControlStateNormal];
    [recipientview addSubview:btnRead];
    
    UILabel* labLine1 = [[UILabel alloc] init];
    labLine1.backgroundColor = [UIColor clearColor];
    labLine1.text  = [NSString stringWithFormat:@"%@  %@",
                      [_defaultRecipDict objectForKey:@"UserName"],
                      [_defaultRecipDict objectForKey:@"CusMobile"]
                      ];
    labLine1.font  = [UIFont systemFontOfSize:13];
    labLine1.frame = CGRectMake(10,5,CGRectGetWidth(btnRead.frame)-20,18);
    [btnRead addSubview:labLine1];
    
    UILabel* labLine2 = [[UILabel alloc] init];
    labLine2.backgroundColor = [UIColor clearColor];
    labLine2.numberOfLines = 2;
    labLine2.font  = [UIFont systemFontOfSize:13];
    labLine2.text  = [_defaultRecipDict objectForKey:@"Address"];
    labLine2.frame = CGRectMake(10,28,CGRectGetWidth(btnRead.frame)-20,36);
    [btnRead addSubview:labLine2];
}

-(void)onAgreeMentBtn:(id)sender{
    CTServiceAgreementVCtler* tvc = [[CTServiceAgreementVCtler alloc] init];
    [self.navigationController pushViewController:tvc animated:YES];
    [self hiddenPicker];
}

-(void)onKeyboardHidden:(id)sender
{
    UIScrollView* rootSbview = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
    for (UIView* tv in [rootSbview subviews]) {
        if ([tv isKindOfClass:[UITextField class]]) {
            [tv resignFirstResponder];
        }
    }
    CRecipientEditView* creView = (CRecipientEditView*)[self.view viewWithTag:kTagEditView];
    if (creView) {
        [creView hiddenKeyBord];
    }
    [self hiddenPicker];
}
#pragma mark -
#pragma mark Notifications
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue*  aValue   = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSString* duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSString* Curve    = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int keyboadHeight = keyboardRect.size.height;
    
    UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
    CGRect rc       = sbView.frame;
    rc.size.height  = [[UIScreen mainScreen] bounds].size.height - keyboadHeight - 64;
    
    [UIView animateWithDuration:[duration floatValue]
                          delay:0.0
                        options:[Curve integerValue]
                     animations:^
     {
         sbView.frame = rc;
         if (_activTfView){
             CGRect trc = _activTfView.frame;
             UIView* parentv = [_activTfView superview];
             if ([parentv isKindOfClass:[UIView class]]) {
                 trc.origin.y += parentv.frame.origin.y;
             }
             [sbView scrollRectToVisible:CGRectInset(trc, 0,-16) animated:YES];
         }
     }completion:^(BOOL finished) {
         
     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
    CGRect rc       = sbView.frame;
    rc.size.height  = [[UIScreen mainScreen] bounds].size.height - 113;
    sbView.frame    = rc;
    if (_activTfView){
        [sbView scrollRectToVisible:_activTfView.frame animated:YES];
    }
}

-(void)onSelectRecipientNotify:(NSNotification*)notify
{
    NSDictionary* dict = [notify userInfo];
    _defaultRecipDict  = [NSDictionary dictionaryWithDictionary:dict];
    
    [self resetRecipientView];
}

-(void)onAgreenMentNotify:(NSNotification*)notify{
    _ifAgreetoRule = YES;
#if 0   // modified by zy, 2014-02-18
    UIScrollView* rootSbview = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
    UIButton* btn = (UIButton*)[rootSbview viewWithTag:kTagBtnAgreeMent];
    if (btn) {
        UIImage* bgImg =
        [[UIImage imageNamed:@"FeiYoung_Btn2_Selected.png"] stretchableImageWithLeftCapWidth:20
                                                                                topCapHeight:20];
        [btn setBackgroundImage:bgImg forState:UIControlStateNormal];
    }
#else
    {
        _licenseCheckBtn.selected = YES;
    }
#endif
}

#pragma mark UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _activTfView = textField;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (_activTfView == textField){
        _activTfView = nil;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hiddenPicker];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

#pragma mark - actions

- (void) onLeftBtnAction:(id)sender{
    [super onLeftBtnAction:sender];
    [self hiddenPicker];
}


-(void)cancelAction
{
    [self hiddenPicker];
}

-(void)doneAction
{
    CRecipientEditView* creView = (CRecipientEditView*)[self.view viewWithTag:kTagEditView];
    if (creView) {
        NSDictionary* dict = [self getSeledProvince];        // 获取选中的城市
        [creView setProvince:[dict objectForKey:@"province"]
                        city:[dict objectForKey:@"city"]
                        dist:[dict objectForKey:@"district"]];
    }
    
    [self hiddenPicker];
}

-(void)onSeleOthers:(id)sender{
    CRecipientSelectVctler * vc = [[CRecipientSelectVctler alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)onSubmintAction:(id)sender
{
    // 隐藏键盘
    [self onKeyboardHidden:nil];
    
    int TfCtltagstart = kTagTfUserName;
    UITextField* tfUname = (UITextField*)[self.view viewWithTag:TfCtltagstart];
    TfCtltagstart ++;
    UITextField* tfUcode = (UITextField*)[self.view viewWithTag:TfCtltagstart];
    TfCtltagstart ++;
    UITextField* tfUAddress  = (UITextField*)[self.view viewWithTag:TfCtltagstart];
//    TfCtltagstart ++;
//    UITextField* tfUPostcode = (UITextField*)[self.view viewWithTag:TfCtltagstart];
    
    NSString* errMsg = @"";
    do
    {
        if ([tfUname.text length] <= 0 || [[tfUname.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
            errMsg = @"请输入机主姓名";
            break;
        }
        if ([tfUcode.text length] <= 0 || [[tfUcode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
            errMsg = @"请输入机主身份证号";
            break;
        }else if(tfUcode.text && [tfUcode.text length] > 0 ){
            if ([Utils isIDNumberValid:tfUcode.text]==NO) {
                errMsg = @"请输入正确的身份证号";
                break;
            }
        }
        if ([tfUAddress.text length] <= 0 || [[tfUAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
            errMsg = @"请输入机主地址";
            break;
        }
        //add by liuruxian 2014-03-06
        /*
         if ([tfUPostcode.text length] <= 0 || [[tfUPostcode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
         errMsg = @"请输入机主邮政编码";
         break;
         }
         if ([tfUPostcode.text length] <= 5) {
         errMsg = @"请输入正确的邮政编码";
         break;
         }
         */
    } while (NO);
    
    if (errMsg && [errMsg length] > 0) {
        SIAlertView *alertView =
        [[SIAlertView alloc] initWithTitle:nil
                                andMessage:errMsg];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView){
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
        return;
    }
    
    if (_ifAgreetoRule == NO) {
        SIAlertView *alertView =
        [[SIAlertView alloc] initWithTitle:nil
                                andMessage:@"请先阅读并同意服务协议。"];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView){
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
        return;
    }
    
    if (_defaultRecipDict)
    {
        //1 提交订单
        COrderComfirmVctler* vc = [[COrderComfirmVctler alloc] init];
        vc.selRecipientDict = _defaultRecipDict;
        vc.uName     = tfUname.text;
        vc.uID       = tfUcode.text;
        vc.uAddress  = tfUAddress.text;
        vc.uPostCode = @"-"/*tfUPostcode.text*/;// add by liuruxian 2014-03-06
        vc.info = self.info;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else
    {
        CRecipientEditView* creView = (CRecipientEditView*)[self.view viewWithTag:kTagEditView];
        if (!creView) {
            return;
        }
        //2 读取CREVIEW的字段，并判断
        NSError* error = [creView checkInputValues];
        if (error) {
            SIAlertView *alertView =
            [[SIAlertView alloc] initWithTitle:nil
                                    andMessage:[error domain]];
            [alertView addButtonWithTitle:@"确定"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView){
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            [alertView show];
            return;
        }
        //1.先提交默认的配送地址
        [self doAddRecipient];
        //2.提交订单
        NSDictionary* pickerdict = [self getSeledProvince];
        NSMutableDictionary* selDict = [[NSMutableDictionary alloc] init];
        [selDict setObject:creView.address.text
                    forKey:@"Address"];
        [selDict setObject:[pickerdict objectForKey:@"citycode"] forKey:@"City"];
        [selDict setObject:[pickerdict objectForKey:@"city"] forKey:@"CityName"];
        [selDict setObject:[pickerdict objectForKey:@"provincecode"] forKey:@"Province"];
        [selDict setObject:[pickerdict objectForKey:@"province"] forKey:@"ProvinceName"];
        [selDict setObject:[pickerdict objectForKey:@"districtcode"] forKey:@"County"];
        [selDict setObject:[pickerdict objectForKey:@"district"] forKey:@"CountyName"];
        [selDict setObject:creView.phone.text
                    forKey:@"CusMobile"];
        [selDict setObject:tfUname.text
                    forKey:@"CusName"];
        [selDict setObject:creView.reciper.text  //add by liuruxian 2014-02-23  tfUname.text
                    forKey:@"UserName"];
        
        [selDict setObject:@"" forKey:@"AddressId"];
        [selDict setObject:@"" forKey:@"CertificateNumber"];
        [selDict setObject:@"" forKey:@"CertificateType"];
        [selDict setObject:@"" forKey:@"CusEmail"];
        [selDict setObject:@"" forKey:@"CusTelnum"];
        [selDict setObject:@"" forKey:@"IfDefault"];
        [selDict setObject:@"" forKey:@"PostCode"];
        [selDict setObject:@"" forKey:@"UserId"];
        [selDict setObject:@"" forKey:@"UserType"];
        
        COrderComfirmVctler* vc = [[COrderComfirmVctler alloc] init];
        vc.selRecipientDict = selDict;
        
        vc.uName     = tfUname.text;
        vc.uID       = tfUcode.text;
        vc.uAddress  = tfUAddress.text;
        vc.uPostCode = @""/*tfUPostcode.text*/;// add by liuruxian 2014-03-06
        vc.info = self.info;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - NetWorks
-(void)getRecipienList
{
    // 未登录情况，不用请求
    NSString *UserId = ([[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] ? [[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] : @"");
    if ([UserId length] <=0) {
        [self LayoutScollview];
        return;
    }
    
    __weak typeof (self)weakSelf = self;
    NSDictionary *params= [NSDictionary dictionaryWithObjectsAndKeys:
                           UserId,@"UserId",nil];
    self._QryOperation   =
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"getConsigneeAddress"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          DLog(@"***getConsigneeAddress\r\n%@",dict);
                                          [weakSelf.recipienList removeAllObjects];
                                          
                                          id  dataList = dict[@"Data"][@"Items"][@"Item"];
                                          if ([dataList isKindOfClass:[NSDictionary class]])
                                          {
                                              [weakSelf.recipienList addObject:dataList];
                                          }else if([dataList isKindOfClass:[NSArray class]]){
                                              [weakSelf.recipienList addObjectsFromArray:dataList];
                                          }
                                          
                                          if ([weakSelf.recipienList count] > 0)
                                          {
                                              weakSelf.defaultRecipDict
                                              = [NSDictionary dictionaryWithDictionary:[weakSelf.recipienList objectAtIndex:0]];
                                              for (NSDictionary* ttd in weakSelf.recipienList){
                                                  if ([ttd[@"IfDefault"] integerValue] == 1)
                                                  {
                                                      weakSelf.defaultRecipDict = [NSDictionary dictionaryWithDictionary:ttd];
                                                      break;
                                                  }
                                              }
                                          }
                                          [weakSelf LayoutScollview];
                                      } onError:^(NSError *engineError) {
                                          DDLogInfo(@"%s--%@", __func__, engineError);
                                          [weakSelf LayoutScollview];
                                      }];
}

#pragma mark - CRecipientEditViewDelegate
-(void)onPikerAction:(id)sender
{
    if ([_areaList count] <= 0)
    {
        return;
    }
    
    _isFirst = YES ;
    [self onKeyboardHidden:nil];

    CRecipientEditView* creView = (CRecipientEditView*)sender;
    if (creView) {
        [creView hiddenKeyBord];
    }
    // add by liuruxian 2014-03-04
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = NO;
    
    if ([_areaPicker isDescendantOfView:MyAppDelegate.window])
    {
//        [UIView animateWithDuration:0.25 animations:^{
//            
//            _areaPicker.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(_areaPicker.frame));
//            
//            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//            {
//                CGRect rect ;
//                rect = _pickerStatusView.frame ;
//                rect.origin.y = CGRectGetHeight(MyAppDelegate.window.frame)-CGRectGetHeight(_areaPicker.frame) - 30 ;
//                _pickerStatusView.frame = rect ;
//            }
//            UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
//            CGRect rc       = sbView.frame;
//            rc.size.height  = [[UIScreen mainScreen] bounds].size.height - CGRectGetHeight(_areaPicker.frame) - 64;
//            
//            sbView.frame = rc;
//            if (creView.address)
//            {
//                CGRect trc = creView.address.frame;
//                UIView* parentv = [creView.address superview];
//                if ([parentv isKindOfClass:[UIView class]]) {
//                    trc.origin.y += parentv.frame.origin.y;
//                }
//                [sbView scrollRectToVisible:CGRectInset(trc, 0,-16) animated:YES];
//            }
//
//        } completion:^(BOOL finished) {
//        }];
        return;
        
    }else{
        _areaPicker.frame = CGRectMake(0, CGRectGetHeight(MyAppDelegate.window.frame), CGRectGetWidth(_areaPicker.frame), CGRectGetHeight(_areaPicker.frame));
        _pickerStatusView.frame = CGRectMake(0, CGRectGetHeight(MyAppDelegate.window.frame), CGRectGetWidth(_areaPicker.frame), 40);
        
        [MyAppDelegate.window addSubview:_areaPicker];
        [MyAppDelegate.window addSubview:_pickerStatusView];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            _areaPicker.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(_areaPicker.frame));
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                CGRect rect ;
                rect = _pickerStatusView.frame ;
                rect.origin.y = CGRectGetHeight(MyAppDelegate.window.frame)-CGRectGetHeight(_areaPicker.frame) - 40 ;
                _pickerStatusView.frame = rect ;
            }
            
            UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
            CGRect rc       = sbView.frame;
            rc.size.height  = [[UIScreen mainScreen] bounds].size.height - CGRectGetHeight(_areaPicker.frame) - 64;
            sbView.frame = rc;
            if (creView.address)
            {
                CGRect trc = creView.address.frame;
                UIView* parentv = [creView.address superview];
                if ([parentv isKindOfClass:[UIView class]]) {
                    trc.origin.y += parentv.frame.origin.y;
                }
                [sbView scrollRectToVisible:CGRectInset(trc, 0,-8) animated:YES];
            }

        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)onHiddenPopView:(id)sender
{
    [self onKeyboardHidden:nil];
}

#pragma mark - hiddenPicker
-(void)hiddenPicker{
    if (![_areaPicker isDescendantOfView:MyAppDelegate.window]){
        return;
    }
    
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        _areaPicker.transform = CGAffineTransformIdentity;//;CGAffineTransformMakeTranslation(0, CGRectGetHeight(MyAppDelegate.window.frame));
        
        CGRect rect ;
        rect = _pickerStatusView.frame ;
        rect.origin.y = CGRectGetHeight(MyAppDelegate.window.frame);
        _pickerStatusView.frame = rect ;
        
        // add by liuruxian 2014-02-26
        UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagRootScrollview];
        CGRect rc       = sbView.frame;
        rc.size.height  = [[UIScreen mainScreen] bounds].size.height - 113;
        sbView.frame    = rc;
    } completion:^(BOOL finished) {
        [_areaPicker removeFromSuperview];
        [_pickerStatusView removeFromSuperview];
    }];
}

#pragma mark - picker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
        {
            int cnt = [_areaList count];
            return cnt;
        }break;
        case 1:
        {
            int selprovice = [pickerView selectedRowInComponent:0];
            if (selprovice < [_areaList count] && selprovice >= 0){
                NSDictionary * province = [_areaList objectAtIndex:selprovice];
                int cnt = [[province objectForKey:@"citylist"] count];
                if (cnt <= 0) {
                    cnt = 1;
                }
                return cnt;
            }
        }break;
        case 2:
        {
            int selprovice = [pickerView selectedRowInComponent:0];
            if (selprovice < [_areaList count] && selprovice >= 0)
            {
                NSDictionary * province = [_areaList objectAtIndex:selprovice];
                NSArray * citylist = [province objectForKey:@"citylist"];
                int selcity = [pickerView selectedRowInComponent:1];
                if (selcity < [citylist count] && selcity >= 0){
                    NSDictionary * city = [citylist objectAtIndex:selcity];
                    int cnt = [[city objectForKey:@"districtlist"] count];
                    if (cnt <= 0) {
                        cnt = 1;
                    }
                    return cnt;
                }
            }
        }break;
        default:
            break;
    }
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
        {
            if (row >= 0 && row < [_areaList count]){
                NSDictionary * province = [_areaList objectAtIndex:row];
                return [province objectForKey:@"Freight_Area_Name"];
            }
        }break;
        case 1:
        {
            int selprovice = [pickerView selectedRowInComponent:0];
            if (selprovice < [_areaList count] && selprovice >= 0){
                NSDictionary * province = [_areaList objectAtIndex:selprovice];
                NSArray * citylist = [province objectForKey:@"citylist"];
                if ([citylist isKindOfClass:[NSArray class]]
                    && row >= 0
                    && row < [citylist count])
                {
                    NSDictionary * city = [citylist objectAtIndex:row];
                    return [city objectForKey:@"Freight_Area_Name"];
                }
            }
        }break;
        case 2:
        {
            int selprovice = [pickerView selectedRowInComponent:0];
            if (selprovice < [_areaList count] && selprovice >= 0)
            {
                NSDictionary * province = [_areaList objectAtIndex:selprovice];
                NSArray * citylist = [province objectForKey:@"citylist"];
                int selcity = [pickerView selectedRowInComponent:1];
                if ([citylist isKindOfClass:[NSArray class]] && selcity < [citylist count] && selcity >= 0)
                {
                    NSArray * districtlist = [[citylist objectAtIndex:selcity] objectForKey:@"districtlist"];
                    if ([districtlist isKindOfClass:[NSArray class]] && row >= 0 && row < [districtlist count])
                    {
                        NSDictionary * district = [districtlist objectAtIndex:row];
                        return [district objectForKey:@"Freight_Area_Name"];
                    }
                }
            }
        }break;
        default:
            break;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView reloadAllComponents];
    switch (component)
    {
        case 0:
        {
            if (row < [_areaList count] && row >= 0){
                NSDictionary * province = [_areaList objectAtIndex:row];
                NSArray * citylist = [province objectForKey:@"citylist"];
                if (![citylist count])
                {
                    [self qryCity:[province objectForKey:@"Freight_Area_Code"]];
                }
                else
                {
                    [self pickerView:pickerView didSelectRow:0 inComponent:1];
                }
            }
        }break;
        case 1:
        {
            int selprovice = [pickerView selectedRowInComponent:0];
            if (selprovice < [_areaList count] && selprovice >= 0)
            {
                NSDictionary * province = [_areaList objectAtIndex:selprovice];
                NSArray * citylist = [province objectForKey:@"citylist"];
                if ([citylist isKindOfClass:[NSArray class]]
                    && row < [citylist count]
                    && row >= 0)
                {
                    NSDictionary * city = [citylist objectAtIndex:row];
                    NSArray * districtlist = [city objectForKey:@"districtlist"];
                    if (![districtlist count])
                    {
                        [self qryDistrict:[province objectForKey:@"Freight_Area_Code"]
                                     city:[city objectForKey:@"Freight_Area_Code"]];
                    }
                }else{
                    [self pickerView:pickerView didSelectRow:0 inComponent:2];
                }
            }
        }break;
        default:
            break;
    }

        // 设置piker的值给lab
    CRecipientEditView* creView = (CRecipientEditView*)[self.view viewWithTag:kTagEditView];
    if (creView) {
        NSDictionary* dict = [self getSeledProvince];        // 获取选中的城市
        [creView setProvince:[dict objectForKey:@"province"]
                        city:[dict objectForKey:@"city"]
                        dist:[dict objectForKey:@"district"]];
    }
}


-(NSDictionary*)getSeledProvince{
    NSString* proviceStr = nil;
    NSString* cityStr    = nil;
    NSString* distStr    = nil;
    NSString* proviceCode = nil;
    NSString* cityCode    = nil;
    NSString* distCode    = nil;
    
    
    int selRow0 = [_areaPicker selectedRowInComponent:0];
    int selRow1 = [_areaPicker selectedRowInComponent:1];
    int selRow2 = [_areaPicker selectedRowInComponent:2];
    
    if (selRow0 < [_areaList count] && selRow0 >= 0)
    {
        NSDictionary * province = [_areaList objectAtIndex:selRow0];
        proviceStr  = [province objectForKey:@"Freight_Area_Name"];
        proviceCode = [province objectForKey:@"Freight_Area_Code"];
        
        if (selRow1 != -1) {
            NSArray * citylist = [province objectForKey:@"citylist"];
            if (citylist && [citylist count] > selRow1) {
                NSDictionary * city = [citylist objectAtIndex:selRow1];
                cityStr = [city objectForKey:@"Freight_Area_Name"];
                cityCode= [city objectForKey:@"Freight_Area_Code"];
                if (selRow2 != -1) {
                    NSArray * districtlist = [city objectForKey:@"districtlist"];
                    if (districtlist && [districtlist count] > selRow2) {
                        NSDictionary * district = [districtlist objectAtIndex:selRow2];
                        distStr = [district objectForKey:@"Freight_Area_Name"];
                        distCode= [district objectForKey:@"Freight_Area_Code"];
                    }
                }
            }
        }
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            proviceStr==nil?@"":proviceStr,@"province",
            cityStr==nil?@"":cityStr,@"city",
            distStr==nil?@"":distStr,@"district",
            proviceCode==nil?@"":proviceCode,@"provincecode",
            cityCode==nil?@"":cityCode,@"citycode",
            distCode==nil?@"":distCode,@"districtcode",
            nil];
}

#pragma mark - getDatas
-(void)getProvinceList{
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"2", @"Type",
                               @"", @"ProvinceCode",
                               @"", @"CityCode",
                               nil];
    __weak typeof (self)weakSelf = self;
    __weak typeof (_areaPicker)pick = _areaPicker;
    self._QryProvinceOp =
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrganization"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          DLog(@"***qryOrganization\r\n%@",dict);
                                          id itemAry = dict[@"Data"][@"Items"];
                                          if (itemAry    == nil
                                              || itemAry == [NSNull null]){
                                              return ;
                                          }
                                          
                                          if ([itemAry isKindOfClass:[NSDictionary class]])
                                          {
                                              [weakSelf.areaList addObject:itemAry];
                                          }else if([itemAry isKindOfClass:[NSArray class]])
                                          {
                                              [weakSelf.areaList addObjectsFromArray:itemAry];
                                          }
//                                          for (NSDictionary *dict in weakSelf.areaList) {
//                                              
//                                          }
                                          
                                          [pick reloadComponent:0];
                                          [pick selectRow:1
                                                     inComponent:0
                                                        animated:NO];
                                          
                                          [weakSelf pickerView:pick
                                              didSelectRow:1
                                               inComponent:0];

                                      } onError:^(NSError *engineError) {
                                          // 取消掉全部请求和回调，避免出现多个弹框
                                          [MyAppDelegate.cserviceEngine cancelAllOperations];
                                          // 提示重新登录
                                          SIAlertView *alertView =
                                          [[SIAlertView alloc] initWithTitle:nil
                                                                  andMessage:[engineError localizedDescription]];
                                          
                                          [alertView addButtonWithTitle:@"确定"
                                                                   type:SIAlertViewButtonTypeDefault
                                                                handler:^(SIAlertView *alertView){
                                                                }];
                                          alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                          [alertView show];
                                      }];
}

-(void)qryCity:(NSString*)provincecode
{
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"2", @"Type",
                               provincecode, @"ProvinceCode",
                               @"", @"CityCode",
                               nil];
    __weak NSString* procode = provincecode;
    [self._QryCityOp cancel];
    
    
    __weak typeof (self)weakSelf = self;
    __weak typeof (_areaPicker)pick = _areaPicker;
    self._QryCityOp =
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrganization"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          DLog(@"***qryCity\r\n%@",dict);
                                          id Items = dict[@"Data"][@"Items"];
                                          NSArray * arr = nil;
                                          if ([Items isKindOfClass:[NSArray class]])
                                          {
                                              arr = Items;
                                          }
                                          else if ([Items isKindOfClass:[NSDictionary class]])
                                          {
                                              arr = [NSArray arrayWithObject:Items];
                                          }
                                          else
                                          {
                                              arr = [NSArray array];
                                          }
                                          
                                          for (NSDictionary * tdict in weakSelf.areaList)
                                          {
                                              NSString * FreightAreaCode = [tdict objectForKey:@"Freight_Area_Code"];
                                              if ([FreightAreaCode isEqualToString:procode]){
                                                  NSMutableDictionary * mutaDict = [NSMutableDictionary dictionaryWithDictionary:tdict];
                                                  [mutaDict setObject:arr
                                                               forKey:@"citylist"];
                                                  [weakSelf.areaList replaceObjectAtIndex:[weakSelf.areaList indexOfObject:tdict]
                                                                       withObject:mutaDict];
                                                  break;
                                              }
                                          }
                                          
                                          [pick reloadComponent:1];
                                          [pick selectRow:arr.count/2
                                                     inComponent:1
                                                        animated:NO];
                                          
                                          [weakSelf pickerView:pick
                                              didSelectRow:arr.count/2
                                               inComponent:1];
                                      } onError:^(NSError *engineError) {
                                          // 取消掉全部请求和回调，避免出现多个弹框
                                          [SVProgressHUD dismiss];
                                          [MyAppDelegate.cserviceEngine cancelAllOperations];
                                          // 提示重新登录
                                          SIAlertView *alertView =
                                          [[SIAlertView alloc] initWithTitle:nil
                                                                  andMessage:[engineError localizedDescription]];
                                          
                                          [alertView addButtonWithTitle:@"确定"
                                                                   type:SIAlertViewButtonTypeDefault
                                                                handler:^(SIAlertView *alertView){
                                                                }];
                                          alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                          [alertView show];
                                      }];
}

- (void)qryDistrict:(NSString *)province city:(NSString *)city
{
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"2", @"Type",
                               province, @"ProvinceCode",
                               city, @"CityCode",
                               nil];
    __weak NSString* procode = province;
    __weak NSString* procity = city;
    [self._QryDistOp cancel];
    __weak typeof (self)weakSelf = self;
    __weak typeof (_areaPicker)pick = _areaPicker;
    self._QryDistOp =
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrganization"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          DLog(@"***qryDist\r\n%@",dict);
                                          id Items = dict[@"Data"][@"Items"];
                                          NSArray * arr = nil;
                                          if ([Items isKindOfClass:[NSArray class]]){
                                              arr = Items;
                                          }else if ([Items isKindOfClass:[NSDictionary class]]){
                                              arr = [NSArray arrayWithObject:Items];
                                          }else{
                                              arr = [NSArray array];
                                          }
                                          
                                          for (NSDictionary * provincedict in weakSelf.areaList)
                                          {
                                              NSString * FreightAreaCode = [provincedict objectForKey:@"Freight_Area_Code"];
                                              if (![FreightAreaCode isEqualToString:procode])
                                              {
                                                  continue;
                                              }
                                              NSMutableArray * citylist = [NSMutableArray arrayWithArray:[provincedict objectForKey:@"citylist"]];
                                              for (NSDictionary * citydict in citylist)
                                              {
                                                  NSString * tmpcode = [citydict objectForKey:@"Freight_Area_Code"];
                                                  if (![tmpcode isEqualToString:procity])
                                                  {
                                                      continue;
                                                  }
                                                  NSMutableDictionary * mutaCitydict = [NSMutableDictionary dictionaryWithDictionary:citydict];
                                                  [mutaCitydict setObject:arr forKey:@"districtlist"];
                                                  [citylist replaceObjectAtIndex:[citylist indexOfObject:citydict] withObject:mutaCitydict];
                                                  
                                                  NSMutableDictionary * mutaProvincedict = [NSMutableDictionary dictionaryWithDictionary:provincedict];
                                                  [mutaProvincedict setObject:citylist forKey:@"citylist"];
                                                  [weakSelf.areaList replaceObjectAtIndex:[weakSelf.areaList indexOfObject:provincedict] withObject:mutaProvincedict];
                                                  break;
                                              }
                                              break;
                                          }
                                          
                                          [pick reloadComponent:2];
                                          [weakSelf pickerView:pick
                                              didSelectRow:0
                                               inComponent:2];
                                          [SVProgressHUD dismiss];
                                      } onError:^(NSError *engineError) {
                                          // 取消掉全部请求和回调，避免出现多个弹框
                                          [SVProgressHUD dismiss];
                                          [MyAppDelegate.cserviceEngine cancelAllOperations];
                                          // 提示重新登录
                                          SIAlertView *alertView =
                                          [[SIAlertView alloc] initWithTitle:nil
                                                                  andMessage:[engineError localizedDescription]];
                                          
                                          [alertView addButtonWithTitle:@"确定"
                                                                   type:SIAlertViewButtonTypeDefault
                                                                handler:^(SIAlertView *alertView){
                                                                }];
                                          alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                          [alertView show];
                                      }];
}

-(void)doAddRecipient
{
    {
        // 未登录情况，不用添加
        NSString *UserId = ([[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] ? [[[Global sharedInstance] custInfoDict] objectForKey:@"UserId"] : @"");
        if ([UserId length] <=0) {
            return;
        }
    }
    
    CRecipientEditView* creView = (CRecipientEditView*)[self.view viewWithTag:kTagEditView];
    if (!creView) {
        return;
    }
    
    NSString *UserId    = [Global sharedInstance].custInfoDict[@"UserId"];
    NSString* UserName  = creView.reciper.text;
    NSString* Address   = creView.address.text;
    NSString* PostCode  = creView.postcode.text;
    NSString* CusMobile = creView.phone.text;
    NSNumber* ifDefalut = [NSNumber numberWithBool:YES];
    NSString* CusTelnum = @"-";
    NSString* CusEmail  = @"-";
    NSDictionary* seldict = [self getSeledProvince];
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             UserId, @"UserId",
                             CusMobile, @"CusMobile",
                             PostCode, @"PostCode",
                             [seldict objectForKey:@"citycode"], @"City",
                             [seldict objectForKey:@"districtcode"], @"County",
                             Address, @"Address",
                             [seldict objectForKey:@"provincecode"], @"Province",
                             UserName, @"UserName",
                             CusEmail,@"CusEmail",
                             CusTelnum,@"CusTelnum",
                             ifDefalut,@"IfDefault",
                             nil];
    self._AddRecipientpOp =
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"addComConsigneeAddress"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                      } onError:^(NSError *engineError) {
                                          
                                      }];
    
}

@end
