//
//  CTCallsRechargeVCtler.m
//  CTPocketV4
//
//  Created by apple on 13-10-31.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTCallsRechargeVCtler.h"
#import "UIView+RoundRect.h"
#import "PublicFile.h"
#import "CTRechargeSucessVCtler.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "SIAlertView.h"
#import "Utils.h"
#import "FlowCardValidata.h"
#import "CserviceOperation.h"
#import "AppDelegate.h"
#import "Global.h"
#import "CTOrderRechargeVCtler.h"
#import "CTOrderConfirmVCtler.h"
#import "SVProgressHUD.h"
#import "CTLoginVCtler.h"
#import "ToastAlertView.h"
#import <QuartzCore/QuartzCore.h>

#define kcashBtnTag 1000
#define kReachargeTypeBtn 1100
#define kRechargeViewTag 1200
#define kDiscountTag  1300
#define kLoginPhoneNum    @"loginPhoneNum"

#define kDiscountValue 1400
@interface CTCallsRechargeVCtler () <UITextFieldDelegate,ABPeoplePickerNavigationControllerDelegate >

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *bankRechargeView;
@property (nonatomic, strong) UILabel *chargeTypeLabel;
@property (nonatomic, strong) UILabel *bankCashLabel;
@property (nonatomic, strong) UIView *rechargeCardView;
@property (nonatomic, strong) UIView *clickView;
@property (nonatomic, strong) NSDictionary *cashdict;
@property (nonatomic, assign) int rechargeTye;
@property (nonatomic, assign) int cashType ;
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSDictionary *selectedInfo;
@property (nonatomic, strong) ABPeoplePickerNavigationController *picker;
@property (nonatomic, strong) NSString *selectedPhone;
@property (nonatomic, strong) CserviceOperation *callsByCardOpt;
@property (nonatomic, strong) CserviceOperation *callsByBankOpt;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSDictionary *dateDict;
//@property (nonatomic,s)

@end


@implementation CTCallsRechargeVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //注册键盘消失和出现的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//        self.dateArary = [NSMutableArray new];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.rechargeTye = 1;
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:230/255. green:230/255. blue:230/255. alpha:1]; // modified by zy
    self.scrollView = scrollView ;
    [self.view addSubview:scrollView];
    
    UIButton *keyBoardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    keyBoardBtn.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [keyBoardBtn addTarget:self action:@selector(onHideKeyboardBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:keyBoardBtn];
    [self.scrollView sendSubviewToBack:keyBoardBtn];
    
    self.cashdict = [NSDictionary dictionaryWithObjectsAndKeys:@"20",@"0",@"30",@"1",@"50",@"2",@"100",@"3",@"200",@"4",@"500",@"5",nil];
    
    float yPos = 0;
    //手机号码
    {
        UITextField *phoneTextField = [[UITextField alloc]initWithFrame:CGRectMake(22, 17, 203, 38)];
        phoneTextField.backgroundColor = kUIColorWhiteColor ;
        phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter ;
        phoneTextField.returnKeyType = UIReturnKeyDone ;
        phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing ; //点击清除
        phoneTextField.keyboardType = UIKeyboardTypeNumberPad ;
        phoneTextField.placeholder = @"请输入需要充值的电信手机号码";
        phoneTextField.font = [UIFont systemFontOfSize:14];
        {
            UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 10)];
            mView.backgroundColor = [UIColor clearColor];
            phoneTextField.leftView = mView;
            phoneTextField.leftViewMode = UITextFieldViewModeAlways;
        }
        
        phoneTextField.delegate = self ;
        self.phoneNumTextField = phoneTextField ;
        [self.scrollView addSubview:phoneTextField];
        
        
        UIToolbar *toolBar=[self textFieldInputAccessoryView];
        phoneTextField.inputAccessoryView=toolBar;
        /**
        NSArray* inputChain = @[self.phoneNumTextField];
        self.keyboardControls = [[APLKeyboardControls alloc] initWithInputFields:inputChain];
        self.keyboardControls.hasPreviousNext = NO;*/
       
        
        //为他充值按钮
//        UIImage *otherImage = [UIImage imageNamed:@"recharge_byother_btn.png"];
//        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoneTextField.frame), 17, 70, 38)];
//        imageView2.backgroundColor = [UIColor clearColor];
//        imageView2.image = otherImage;
//        imageView2.userInteractionEnabled = YES;
//        [self.scrollView addSubview:imageView2];
//        
//        //logo
//        otherImage = [UIImage imageNamed:@"recharge_byother_icon.png"];
//        UIImageView *chargeLogo = [[UIImageView alloc]initWithFrame:CGRectMake((imageView2.frame.size.width - otherImage.size.width)/2, (imageView2.frame.size.height - otherImage.size.height)/2, otherImage.size.width, otherImage.size.height)];
//        chargeLogo.backgroundColor = [UIColor clearColor];
//        chargeLogo.image = otherImage ;
//        [imageView2 addSubview:chargeLogo];
        UIImage *otherImage = [UIImage imageNamed:@"recharge_byother_icon.png"];
        UIImageView *chargeLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, otherImage.size.width, otherImage.size.height)];
        chargeLogo.image = otherImage ;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        [button setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn_highLight.png"] forState:UIControlStateHighlighted];
        button.frame = CGRectMake(CGRectGetMaxX(phoneTextField.frame), 17, 70, 38);
        [button addTarget:self action:@selector(contracterAction) forControlEvents:UIControlEventTouchUpInside];
        
        chargeLogo.frame = CGRectMake(25, (button.frame.size.height-chargeLogo.frame.size.height)/2, chargeLogo.frame.size.width, chargeLogo.frame.size.height);
        [button addSubview:chargeLogo];
        [self.scrollView addSubview:button];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(phoneTextField.frame),
                                                                  CGRectGetMaxY(button.frame)+4,
                                                                  button.frame.size.width,
                                                                  12)];
        label.textAlignment = UITextAlignmentCenter ;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = kUIColorLightGray ;
        label.text = @"为Ta充值";
        [self.scrollView addSubview:label];
        
        //箭头
        UIImage *image = [UIImage imageNamed:@"recharge_forOther_icon.png"];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.scrollView.frame.size.width - 25,
                                                                              CGRectGetMaxY(button.frame)-5,
                                                                              image.size.width,
                                                                              image.size.height)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = image ;
        [self.scrollView addSubview:imageView];
        
        yPos = CGRectGetMaxY(label.frame);
    }
    //选择方式
    {
        //绿色图片
        //        UIImage *image = [UIImage imageNamed:@""];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, yPos, 5, 28)];
        imageView.backgroundColor = [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1];
        [self.scrollView addSubview:imageView];
        
        //选择方式
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(22, yPos, 100, 28)];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"选择方式";
        label.textColor = [UIColor blackColor];
        label.textAlignment = UITextAlignmentLeft ;
        label.font = [UIFont systemFontOfSize:14];
        [self.scrollView addSubview:label];
        
        yPos = CGRectGetMaxY(imageView.frame) ;
    }
    //选择按钮(银行卡充值，充值卡充值)
    {
        UIImage *image1 = [UIImage imageNamed:@"recharge_selectedRechargeType_btn.png"];
        UIImage *image2 = [UIImage imageNamed:@"recharge_unselectedRechargeType_btn@2x"];
        
//        UIImage *selectedImg =[image1 resizableImageWithCapInsets:UIEdgeInsetsMake(image1.size.width/2, image1.size.height/2, image1.size.width/2, image1.size.height/2)];
//        UIImage *unSelectedImg = [image2 resizableImageWithCapInsets:UIEdgeInsetsMake(image2.size.width/2, image2.size.height/2, image2.size.width/2, image2.size.height/2)];
        UIButton *bankBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        _bankChargeBtn = bankBtn;
        bankBtn.backgroundColor = [UIColor clearColor];
        bankBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        bankBtn.frame = CGRectMake(22, yPos, 120, 32);
        bankBtn.selected = YES;
        [bankBtn setTitle:@"银行卡充值" forState:UIControlStateNormal];
        [bankBtn addTarget:self action:@selector(chargeTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        [bankBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [bankBtn setBackgroundImage:image2 forState:UIControlStateNormal];
        [bankBtn setBackgroundImage:image1 forState:UIControlStateSelected];
        [bankBtn setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn_highLight.png"] forState:UIControlStateHighlighted];
        bankBtn.tag = kReachargeTypeBtn ;
        [self.scrollView addSubview:bankBtn];
        
        UIButton *rechargeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        _rechargeCardBtn = rechargeBtn ;
        rechargeBtn.backgroundColor = [UIColor clearColor];
        rechargeBtn.frame = CGRectMake(178, yPos, 120, 32);
        rechargeBtn.selected = NO;
        rechargeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [rechargeBtn setTitle:@"充值卡充值" forState:UIControlStateNormal];
        [rechargeBtn addTarget:self action:@selector(chargeTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        [rechargeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [rechargeBtn setBackgroundImage:image2 forState:UIControlStateNormal];
        [rechargeBtn setBackgroundImage:image1 forState:UIControlStateSelected];
        [rechargeBtn setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn_highLight.png"] forState:UIControlStateHighlighted];
        rechargeBtn.tag = kReachargeTypeBtn +1;
        [self.scrollView addSubview:rechargeBtn];
        
        yPos = CGRectGetMaxY(bankBtn.frame);
    }
    
    // 银行卡充值view 和 充值卡充值view
    UIView *bankView = [[UIView alloc]initWithFrame:CGRectMake(0, yPos+9, self.view.frame.size.width, 141)];
    bankView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:bankView];
    bankView.tag = kRechargeViewTag;
    self.bankRechargeView = bankView ;
    
    UIButton *bankKeyBoardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bankKeyBoardBtn.frame = CGRectMake(0, 0, _bankRechargeView.frame.size.width, _bankRechargeView.frame.size.height);
    [bankKeyBoardBtn addTarget:self action:@selector(onHideKeyboardBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.bankRechargeView addSubview:bankKeyBoardBtn];
    [self.bankRechargeView sendSubviewToBack:bankKeyBoardBtn];
    
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 5, 28)];
        imageView.backgroundColor = [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1];
        [bankView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(22,0,100,28)];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"选择金额";
        label.textColor = [UIColor blackColor];
        label.textAlignment = UITextAlignmentLeft ;
        label.font = [UIFont systemFontOfSize:14];
        [bankView addSubview:label];
        
        float x=22,x1=22, yOriginal = 0;
        {
            UIImage *selImg = [UIImage imageNamed:@"recharge_selectedRechargeType_btn.png"];
            UIImage *norImg = [UIImage imageNamed:@"recharge_byother_btn.png"];
            
            NSArray *array = [NSArray arrayWithObjects:@"20元",@"30元",@"50元",@"100元",@"200元",@"500元", nil];
            
            for (int i=0; i<6; i++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1] forState:UIControlStateSelected];
                [btn setBackgroundImage:norImg forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"recharge_byother_btn_highLight.png"] forState:UIControlStateHighlighted];
                [btn setBackgroundImage:selImg forState:UIControlStateSelected];
                btn.titleLabel.font = [UIFont systemFontOfSize:14];
                btn.tag = kcashBtnTag + i ;
                [btn addTarget:self action:@selector(cashTypeAction:) forControlEvents:UIControlEventTouchUpInside];
                if (i<3) {
                    btn.frame = CGRectMake(x, CGRectGetMaxY(label.frame), 73, 32);
                    x = CGRectGetMaxX(btn.frame) + 26;
                }else{
                    btn.frame = CGRectMake(x1, CGRectGetMaxY(label.frame)+34+10, 73, 32);
                    x1 = CGRectGetMaxX(btn.frame) + 26;
                    yOriginal = CGRectGetMaxY(btn.frame) ;
                }
                if (i==3) {
                    btn.selected = YES;
                    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
                }
                
                [bankView addSubview:btn];
                
                // 折扣图片
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(btn.frame.origin.x-10, btn.frame.origin.y-5, 20, 20)];
                imageView.backgroundColor = [UIColor clearColor];
                //                imageView.image = img ;
                imageView.tag = kDiscountTag+i;
                imageView.backgroundColor = [UIColor colorWithRed:255/255. green:91/255. blue:67/255. alpha:1];
                imageView.hidden = YES;
                imageView.layer.masksToBounds = YES;
                imageView.layer.cornerRadius = 10;
                
                [bankView addSubview:imageView];
                {
                    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(3, 3 , imageView.frame.size.width, imageView.frame.size.height/2)];
                    lab.text = @"9.8";
                    lab.backgroundColor = [UIColor clearColor];
                    lab.textAlignment = UITextAlignmentLeft;
                    lab.textColor = [UIColor whiteColor];
                    [lab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
                
                    lab.tag = 0;
                    [imageView addSubview:lab];
                    
                    UILabel *lab1 = [[UILabel alloc]initWithFrame:CGRectMake(2, CGRectGetMaxY(lab.frame)-2, imageView.frame.size.width-4, imageView.frame.size.height/2)];
                    lab1.text = @"折";
                    lab1.backgroundColor = [UIColor clearColor];
                    lab1.textAlignment = UITextAlignmentCenter;
                    lab1.textColor = [UIColor whiteColor];
                    lab1.font = [UIFont systemFontOfSize:8];
                    [imageView addSubview:lab1];
                }
            }
        }
        //提示信息
        {
            UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(22, yOriginal,39,38)] ;
            label1.textColor =  [UIColor blackColor];
            label1.text = @"已选择";
            label1.backgroundColor = [UIColor clearColor];
            label1.font = [UIFont systemFontOfSize:13];
            [bankView addSubview:label1];
            
            UILabel *bankCardLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame)+1,yOriginal, 67, 38)];
            bankCardLb.textColor = [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1];
            bankCardLb.text = @"银行卡充值";
            bankCardLb.backgroundColor = [UIColor clearColor];
            bankCardLb.font = [UIFont systemFontOfSize:13];
            [bankView addSubview:bankCardLb];
            
            UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(bankCardLb.frame), yOriginal,26,38)] ;
            label2.textColor =  [UIColor blackColor];
            label2.text = @"共计";
            label2.backgroundColor = [UIColor clearColor];
            label2.font = [UIFont systemFontOfSize:13];
            [bankView addSubview:label2];
            
            UILabel *cashLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label2.frame),yOriginal,24,38)] ;
            cashLb.textColor =  [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1];
            cashLb.text = @"100";
            cashLb.backgroundColor = [UIColor clearColor];
            cashLb.font = [UIFont systemFontOfSize:13];
            [bankView addSubview:cashLb];
            self.bankCashLabel = cashLb;
            
            UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(cashLb.frame),yOriginal,150,38)] ;
            label3.textColor =  [UIColor blackColor];
            label3.text = @"元( 0-24小时内到账 )";
            label3.backgroundColor = [UIColor clearColor];
            label3.font = [UIFont systemFontOfSize:13];
            [bankView addSubview:label3];
        }
    }
    //充值卡view
    {
        UIView *rechargeCardView = [[UIView alloc]initWithFrame:CGRectMake(0, yPos+9,self.view.frame.size.width, 141)];
        rechargeCardView.backgroundColor = [UIColor clearColor];
        rechargeCardView.hidden = YES;
        rechargeCardView.tag = kRechargeViewTag + 1;
        [self.scrollView addSubview:rechargeCardView];
        self.rechargeCardView = rechargeCardView ;
        
        UIButton *rechargeKeyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rechargeKeyBtn.frame = CGRectMake(0, 0, _rechargeCardView.frame.size.width, _rechargeCardView.frame.size.height);
        [rechargeKeyBtn addTarget:self action:@selector(onHideKeyboardBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.rechargeCardView addSubview:rechargeKeyBtn];
        [self.rechargeCardView sendSubviewToBack:rechargeKeyBtn];
        
        {
            UITextField *cardPasswrdTextField = [[UITextField alloc]initWithFrame:CGRectMake(22, 9, 203+38*2, 38)];
            cardPasswrdTextField.backgroundColor =  kUIColorWhiteColor ;
            cardPasswrdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter ;
            cardPasswrdTextField.returnKeyType = UIReturnKeyDone ;
            cardPasswrdTextField.clearButtonMode = UITextFieldViewModeWhileEditing ; //点击清除
            cardPasswrdTextField.keyboardType = UIKeyboardTypeNumberPad ;
            cardPasswrdTextField.placeholder = @"请输入您的充值卡密码";
            cardPasswrdTextField.font = [UIFont systemFontOfSize:14];
            [rechargeCardView addSubview:cardPasswrdTextField];
            {
                UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 10)];
                mView.backgroundColor = [UIColor clearColor];
                cardPasswrdTextField.leftView = mView;
                cardPasswrdTextField.leftViewMode = UITextFieldViewModeAlways;
            }
            self.carPassWrdTextField = cardPasswrdTextField ;
            cardPasswrdTextField.delegate = self ;
            
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor colorWithRed:230/255. green:230/255. blue:230/255. alpha:1];
        button.frame = CGRectMake(CGRectGetMaxX(self.carPassWrdTextField.frame), 9, 70, 38);
        [button addTarget:self action:@selector(scanningAciton) forControlEvents:UIControlEventTouchUpInside];
        [rechargeCardView addSubview:button];
        button.hidden = YES ;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.carPassWrdTextField.frame),
                                                                  CGRectGetMaxY(button.frame)+4,
                                                                  button.frame.size.width,
                                                                  12)];
        label.textAlignment = UITextAlignmentCenter ;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = kUIColorLightGray ;
        label.text = @"扫描卡密";
        label.hidden = YES;
        [rechargeCardView addSubview:label];
        
        //箭头
        UIImage *image = [UIImage imageNamed:@""];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxY(button.frame),
                                                                              CGRectGetMaxY(button.frame)-5,
                                                                              image.size.width,
                                                                              image.size.height)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = image ;
        [rechargeCardView addSubview:imageView];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(22,CGRectGetMaxY(label.frame)+10,39,12)] ;
        label1.textColor =  [UIColor blackColor];
        label1.text = @"已选择";
        label1.backgroundColor = [UIColor clearColor];
        label1.font = [UIFont systemFontOfSize:13];
        [rechargeCardView addSubview:label1];
        
        UILabel *rechargeCardLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame)+1,CGRectGetMaxY(label.frame)+10, 68, 12)];
        rechargeCardLb.textColor = [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1];
        rechargeCardLb.text = @"充值卡充值";
        rechargeCardLb.backgroundColor = [UIColor clearColor];
        rechargeCardLb.font = [UIFont systemFontOfSize:13];
        [rechargeCardView addSubview:rechargeCardLb];
        
        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake( CGRectGetMaxX(rechargeCardLb.frame),CGRectGetMaxY(label.frame)+10,150,12)] ;
        label3.textColor =  [UIColor blackColor];
        label3.text = @"( 0-24小时内到账 )";
        label3.backgroundColor = [UIColor clearColor];
        label3.font = [UIFont systemFontOfSize:13];
        [rechargeCardView addSubview:label3];
    }
    //充值按钮
    yPos = CGRectGetMaxY(bankView.frame);
    {
        UIImage *image = [UIImage imageNamed:@"recharge_commit_icon.png"];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 0, image.size.width, image.size.height)];
        imageView.image = image ;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn_hl.png"] forState:UIControlStateHighlighted];
        [button setTitle:@"充  值" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.frame = CGRectMake(22, yPos , self.view.frame.size.width-44, 37);
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
        [button addTarget:self action:@selector(rechargeAction) forControlEvents:UIControlEventTouchUpInside];
        
        imageView.frame = CGRectMake( 100,(button.frame.size.height-imageView.frame.size.height)/2, imageView.frame.size.width, imageView.frame.size.height);
        [button addSubview:imageView];
        [self.scrollView addSubview:button];
    
    }

    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    self.phoneNumTextField.text = loginInfoDict[@"UserLoginName"] ? loginInfoDict[@"UserLoginName"] : @"";
    NSUserDefaults *defults = [NSUserDefaults standardUserDefaults];
    [defults setObject:self.phoneNumTextField.text forKey:kLoginPhoneNum];
    
    [defults synchronize];
    self.cashType = 3;
    [self showDiscount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setPhoneNum)
                                                 name:@"ReloadMsg" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.phoneNumTextField resignFirstResponder];
}
#pragma mark - NSNotification

- (void) setPhoneNum
{
    self.phoneNumTextField.text = [Global sharedInstance].loginInfoDict[@"UserLoginName"];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.dateDict && [self.dateDict respondsToSelector:@selector(objectForKey:)])
    {
        NSDate *curDate = [NSDate date];//获取当前日期
        NSString *EndTime =  [self.dateDict objectForKey:@"EndTime"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate *destDate= [dateFormatter dateFromString:EndTime];
        //失效
        if ([[destDate laterDate:curDate]isEqual:curDate])
        {
            [self showDiscountImage:NO discountRate:[self.dateDict objectForKey:@"DiscountRate"]];
            // 隐藏Tabbar的折扣Icon
            [MyAppDelegate.tabBarController hiddenZheIcon:YES];
        }else{  //有效
            [self showDiscountImage:YES discountRate:[self.dateDict objectForKey:@"DiscountRate"]];
            // 显示Tabbar的折扣Icon
            [MyAppDelegate.tabBarController hiddenZheIcon:NO];
        }
    }
    else{
        [self showDiscount];
    }
}

#pragma  mark - fun

//显示折扣图片
- (void) showDiscount
{
    [self qryDiscount];
}

- (void) pay
{
    
}

#pragma mark - Action

- (void) chargeTypeAction : (id) sender
{
    UIButton *btn = (UIButton *)sender ;
    int index = btn.tag - kReachargeTypeBtn ;
    self.rechargeTye = index + 1 ;
    if (btn.selected==YES) {
        return;
    }else{
        btn.selected = !btn.selected ;
        for (int i=0; i<2; i++) {
            UIView *view = [self.scrollView viewWithTag:i+kRechargeViewTag];
            if (i!=index) {
                UIButton *button = (UIButton *) [self.scrollView viewWithTag:i+kReachargeTypeBtn];
                button.selected = NO;
                view.hidden = YES;
            }else{
                view.hidden = NO;
            }
        }
    }
    [self.clickView resignFirstResponder];
}

- (void) cashTypeAction : (id) sender
{
    UIButton *btn = (UIButton *)sender ;
    int index = btn.tag - kcashBtnTag ;
    self.cashType = index;
    if (btn.selected == YES) {
//        [self qryDiscount:sender];
        return;
    }else{
        btn.selected = !btn.selected ;
        NSString *str =[self.cashdict objectForKey:[NSString stringWithFormat:@"%d",index]];
        if(index<3)
        {
            str = [@" " stringByAppendingString:str];
        }
        self.bankCashLabel.text = str;
//        [self qryDiscount:sender];
        for (int i=0;i<6; i++) {
            if (i!=index) {
                UIButton *button = (UIButton *)[_bankRechargeView viewWithTag:i+kcashBtnTag];
                button.selected = NO;
                button.titleLabel.font = [UIFont systemFontOfSize:14];
            } else{
                UIButton *button = (UIButton *)[_bankRechargeView viewWithTag:i+kcashBtnTag];
                button.selected = YES;
                button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            }
        }
    }
   
}

//显示view
- (void) showView : (int) tag
{
    UIButton *btn = (UIButton *)[self.view viewWithTag:tag+kReachargeTypeBtn];
    btn.selected = NO;
    [self chargeTypeAction:btn]; //选择显示的view
}

//显示支付金额

//键盘隐藏
- (void) onHideKeyboardBtn : (id)sender
{
    if (_clickView) {
        [_clickView resignFirstResponder];
    }
}

//充值
- (void) rechargeAction
{
    [self.phoneNumTextField resignFirstResponder];
    [self.carPassWrdTextField resignFirstResponder];
    
//    // 判断用户是否已经登陆
//    if ([Global sharedInstance].isLogin == NO) {
//        CTLoginVCtler *vc = [[CTLoginVCtler alloc] init];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//        [MyAppDelegate.tabBarController presentViewController:nav animated:YES completion:^(void){
//        }];
//        return;
//    }
    
    NSString *phone =  [self.phoneNumTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *psd = @"";
    
    if (!phone || phone.length< 11 || ![Utils isNumber:phone]) {
        [self showToastView:@"亲,别忘记填写正确的电信手机号码"];
        return;
    }
    if (![Utils isCTMobileNumber:phone]) {
        [self showToastView:@"亲,只能对电信手机号码充值哦~"];
        return ;
    }
    if (self.rechargeTye == 1) {    //银行卡充值
        
        
        NSString *UserId =[Global sharedInstance].custInfoDict[@"UserId"] ?[Global sharedInstance].custInfoDict[@"UserId"]: @"bank888";
        if(!UserId && UserId.length==0)
        {
            NSDictionary *loginDict = [Global sharedInstance].loginInfoDict;
            NSString *Account = [loginDict objectForKey:@"UserLoginName"] ? [loginDict objectForKey:@"UserLoginName"] : @"";
            
            NSDictionary *params1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     Account, @"Account",
                                     @"201", @"AccountType",
                                     ESHORE_ShopId, @"ShopId", nil];
            
            __block CTCallsRechargeVCtler *weakSelf = self;
            [MyAppDelegate.cserviceEngine postXMLWithCode:@"custIdInfo"
                                                   params:params1
                                              onSucceeded:^(NSDictionary *dict) {
                                                  
                                                  //获取用户id
                                                  id Data = [dict objectForKey:@"Data"];
                                                  if (Data && [Data respondsToSelector:@selector(objectForKey:)]) {
                                                      [Global sharedInstance].custInfoDict = dict[@"Data"];
                                                      [weakSelf bankCardInfo];
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
            [self bankCardInfo];
        }
    }
    else{                           //充值卡充值
        psd = [self.carPassWrdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (!psd || psd.length == 0) {
            [self showToastView:@"亲，别忘了填写充值密码"];
            return ;
        } else if(psd.length != 18)
        {
            [self showToastView:@"充值卡密码是18位哦,请检查"];
            return ;
        }
        
        NSString *message = @"";
        message = [NSString stringWithFormat:@"充值确认\n\n充值号码 : %@ \n充值卡密码 : %@",self.phoneNumTextField.text,psd];
        message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:message];
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {

                              }];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [self FCInfo];
                              }];
        [alertView show];
        
    }
}

#pragma mark - network
//充值卡充话费
- (void)FCInfo
{
    NSString *phoneNumber = self.phoneNumTextField.text;
    NSString *password = self.carPassWrdTextField.text ;
    //1 充花费  
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:phoneNumber, @"phoneNbr", password, @"cardPwd", ESHORE_ShopId, @"ShopId",@"1", @"Type", nil];
    
    if (self.callsByCardOpt) {
        [self.callsByCardOpt cancel];
        self.callsByCardOpt = nil;
    }
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    __block NSString *phone = phoneNumber ;
    __block CTCallsRechargeVCtler *weakSelf = self;
    self.callsByCardOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"FCInfo"
                                                                    params:params
                           onSucceeded:^(NSDictionary *dict) {
                               DDLogInfo(@"%s--%@", __func__, dict.description);
                               //填写充值信息
                               NSMutableDictionary *dictionary = [NSMutableDictionary new];
                               NSString *message = @"";
                               id Data = [dict objectForKey:@"Data"];
                               if (Data && [Data respondsToSelector:@selector(objectForKey:)]) {
                                   message = [message stringByAppendingFormat:@"%.2f", [[Data objectForKey:@"VoucherValue"] floatValue]/100.0];
                                   [dictionary setObject:message forKey:@"OrderPrice"];
                                   [dictionary setObject:phone forKey:@"phoneNumber"];
                                   [dictionary setObject:@"0" forKey:@"OrderStatus"];
                                   [dictionary setObject:@"0" forKey:@"rechargeType"];  //充值话费
                               }
                               [SVProgressHUD dismiss];
                               //跳转
                              [[NSNotificationCenter defaultCenter]postNotificationName:CTP_MSG_RECHARGE_CARD object:dictionary]; 
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
                                       //                                        [alertView release];
                                   }
                                   else{
                                       NSMutableDictionary *dictionary = [NSMutableDictionary new];
                                       [dictionary setObject:@"1" forKey:@"OrderStatus"];        //返回值用的是flg表示成功和失败
                                       [dictionary setObject:@"0" forKey:@"rechargeType"];       //充值话费
                                       [dictionary setObject:[weakSelf.cashdict objectForKey:[NSString stringWithFormat:@"%d", weakSelf.cashType]] forKey:@"OrderPrice"];
                                       [dictionary setObject:phone forKey:@"phoneNumber"];
                                       [dictionary setObject:[engineError.userInfo objectForKey:@"NSLocalizedDescription"]forKey:@"disctription"];
//                                       [SVProgressHUD dismiss];
                                       
                                       [[NSNotificationCenter defaultCenter]postNotificationName:CTP_MSG_RECHARGE_CARD object:dictionary];
                                   }
                               }
                               else{
                                   //充值失败
                                   NSMutableDictionary *dictionary = [NSMutableDictionary new];
                                   [dictionary setObject:@"1" forKey:@"OrderStatus"];
                                   [dictionary setObject:@"0" forKey:@"rechargeType"];       //充值话费
                                   [dictionary setObject:[weakSelf.cashdict objectForKey:[NSString stringWithFormat:@"%d", weakSelf.cashType]] forKey:@"OrderPrice"];
                                   [dictionary setObject:phone forKey:@"phoneNumber"];
                                   //跳转
                                   [[NSNotificationCenter defaultCenter]postNotificationName:CTP_MSG_RECHARGE_CARD object:dictionary];
                               }
                           }];
}
//银行卡充花费
- (void)bankCardInfo
{
    if (self.callsByBankOpt) {
        [self.callsByBankOpt cancel];
        self.callsByBankOpt = nil;
    }
    
    NSString *phoneNumber = self.phoneNumTextField.text ;
    
    NSString *money = [self.cashdict objectForKey:[NSString stringWithFormat:@"%d",self.cashType]];
    
    NSString *UserId = [Global sharedInstance].custInfoDict[@"UserId"] ? [Global sharedInstance].custInfoDict[@"UserId"] : @"bank888";
    
    self.UserId = UserId;

    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:phoneNumber, @"PhoneNumber",
                            money, @"PayAmount",
                            UserId, @"UserId",
                            ESHORE_ShopId, @"ShopId",
                            @"1", @"Type", nil];
    
    __block CTCallsRechargeVCtler *weakSelf = self ;
    __block NSDictionary *par = params;
    self.callsByBankOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"bankCardInfo"
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
                                    [dictionary setObject:@"0" forKey:@"PageType"];
                                    
                                    [dictionary setObject:OrderId forKey:@"OrderId"];       
                                    NSString *realPrice = [[dict objectForKey:@"Data"]objectForKey:@"OrderPrice"];// 选择充值金额
                                    [dictionary setObject:realPrice forKey:@"RealPrice"];   //实际付款金额  当前金额假如有折扣的话 没有则和实际相同
                                    [dictionary setObject:[par objectForKey:@"PayAmount"] forKey:@"OrderPrice"];
                                    NSString * flow = @"";
                                    flow = [flow stringByAppendingString:@"M"];
                                    [dictionary setObject:flow forKey:@"Flow"];
                                    [dictionary setObject:[[dict objectForKey:@"Data"]objectForKey:@"Flow"] forKey:@"Flow"];
                                    
                                    [dictionary setObject:[[dict objectForKey:@"Data"]objectForKey:@"OrderCreatedDate"] forKey:@"OrderCreatedDate"];
                                    [dictionary setObject:@"" forKey:@"OrderPayedDate"];
                                    
                                    [dictionary setObject:@"未支付" forKey:@"OrderStatusDescription"];
                                    [dictionary setObject:@"10010" forKey:@"OrderStatusCode"];
                                    [dictionary setObject:weakSelf.UserId forKey:@"UserId"];
                                    
                                    //充值卡所需的参数
                                    [dictionary setObject:@"-1" forKey:@"CardType"];    //充值卡类型  话费卡  流量卡
                                    [dictionary setObject:@"-1" forKey:@"AmountOpts"];  //选择充值的金额
                                    [[NSNotificationCenter defaultCenter]postNotificationName:CTP_MSG_RECHARGE_BANK object:dictionary];
                                  
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
                                    ToastAlertView *alert = [ToastAlertView new];
                                    [alert showAlertMsg:@"系统繁忙,请重新提交"];
                                }
                            }];
    
}

- (void) qryDiscount
{
//    获取当前时间
    NSDate *curDate = [NSDate date];//获取当前日期
    
    NSString *Amount = @"10";//[self.cashdict objectForKey:[NSString stringWithFormat:@"%d",index]];
    NSString *Type = @"1" ;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:  Type, @"Type",
                                                                        Amount, @"Amount",
                                                                    ESHORE_ShopId, @"ShopId",nil];
    
//    __block CTCallsRechargeVCtler *weakSelf = self ;
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryDiscount"
                                             params:params
            onSucceeded:^(NSDictionary *dict)
                   {
                       DDLogInfo(@"获取第一步的订单id成功 %s--%@", __func__, dict.description);
                       id Data = [dict objectForKey:@"Data"];
                       if (Data) {
                           self.dateDict = Data ;
                           NSString *DiscountRate = [Data objectForKey:@"DiscountRate"];
                           NSString *EndTime = [Data objectForKey:@"EndTime"];
                           
                           NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                           [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                           NSDate *destDate= [dateFormatter dateFromString:EndTime];
                           
                           //没有过期 图片显示
                           if ([[destDate earlierDate:curDate]isEqual:curDate]) {
                               [self showDiscountImage:YES discountRate:DiscountRate];
                           }else{
                               [self showDiscountImage:NO discountRate:@""];
                           }
//                           self.date = EndTime;
                       }else{
                           
                       }
                   } onError:^(NSError *engineError) {
                       
//                       /*
//                            test
//                       */
//                       NSString *EndTime = @"2014-01-01";
//                       NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                       [dateFormatter setDateFormat: @"yyyy-MM-dd"];
//                       NSDate *destDate= [dateFormatter dateFromString:EndTime];
//                      
//                       NSString *disctount = @"0.98";
//                       NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:EndTime,@"EndTime" ,disctount,@"DiscountRate" , nil];
//                       self.dateDict = dict ;
//                       
//                       if ([[destDate earlierDate:curDate]isEqual:curDate]) //有效
//                       {
//                           [self showDiscountImage:YES discountRate:disctount];
//                       }else{
//                           [self showDiscountImage:NO discountRate:disctount];
//                       }
                       
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
                           [self showDiscountImage:NO discountRate:@""];
                       }
                   }];
}

- (void) showDiscountImage : (BOOL) isShow discountRate : (NSString *)DiscountRate
{
    for (int i=0; i<6; i++) {
        UIImageView *imageView = (UIImageView *)[ self.bankRechargeView viewWithTag:kDiscountTag+i];
        imageView.hidden = NO;
        if (isShow) {
            UILabel *lab = (UILabel *)[imageView viewWithTag:0];
            lab.text = [NSString stringWithFormat:@"%0.1f",[DiscountRate floatValue]*10] ;
        }else{
            imageView.hidden = YES ;
        }
    }
  
}

- (void) showToastView : (NSString*)message
{
    ToastAlertView *alert = [ToastAlertView new];
    [alert showAlertMsg:message];
}

- (void)alert:(NSString *)message  leftbutton : (NSString *)left rightbutton :(NSString *) right
{
    message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:message];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    if (left && left.length > 0) {
        [alertView addButtonWithTitle:left
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  
                                  NSLog(@"重试");
                              }];
    }
    if (right && right.length > 0) {
        [alertView addButtonWithTitle:right
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  
                                  NSLog(@"取消");
                              }];
    }

    [alertView show];
}

//联系人
- (void) contracterAction {
    
    if (!self.picker) {
        self.picker = [[ABPeoplePickerNavigationController alloc] init];
        self.picker.peoplePickerDelegate = self;
        [MyAppDelegate.tabBarController presentViewController:self.picker animated:YES completion:nil];

    }else{
        [MyAppDelegate.tabBarController presentViewController:self.picker animated:YES completion:nil];
    }
}

//扫描
- (void) scanningAciton {
    
}

#pragma mark -
#pragma mark - ABPeoplePickerNavigationController delegate
//取消
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if(property ==kABPersonPhoneProperty)
    {
        ABMultiValueRef phoneProperty = ABRecordCopyValue(person,kABPersonPhoneProperty);
        int idx = ABMultiValueGetIndexForIdentifier (phoneProperty, identifier);
        NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneProperty,idx);
        CFBridgingRelease(phoneProperty);
        NSString *phoneNum =[phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@")"  withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" "  withString:@""];
        
        self.selectedPhone = phoneNum ;
        self.phoneNumTextField.text = phoneNum ;
        [peoplePicker dismissModalViewControllerAnimated:YES];
    }
    
    return NO;
}
#pragma mark Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 animations:^{
        if (self.clickView == self.carPassWrdTextField) {
            self.scrollView.frame = CGRectMake(0, -40, self.view.frame.size.width, self.view.frame.size.height);
            if (self.view.superview) {
                [self.view.superview bringSubviewToFront:self.rechargeView];
            }
        }
    } completion:^(BOOL finished) {
        
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.clickView == self.carPassWrdTextField)
    {
        self.scrollView.frame = self.view.bounds ;
    }
}

#pragma mark UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext)
    {
        UITextField * next = (UITextField *)[_scrollView viewWithTag:textField.tag+1];
        [next becomeFirstResponder];
        return YES;
    }
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.clickView = textField;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"input_bg_highlight.png"];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{

    textField.background = nil;
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 手机输入框的完成按钮
- (UIBarButtonItem *)doneButton {
    UIBarButtonItem *_doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(closeInput:)];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        _doneButton.tintColor = [UIColor whiteColor];
    }
    return _doneButton;
}

- (UIBarButtonItem *)flexSpace {
    UIBarButtonItem *_flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return _flexSpace;
}
- (UIToolbar *)textFieldInputAccessoryView {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    UIToolbar *_inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0., 0., CGRectGetWidth(appFrame), 44.)];
    _inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        _inputAccessoryView.barTintColor = [UIColor colorWithRed:(9*16+7)/255. green:(9*16+7)/255. blue:(9*16+7)/255. alpha:1];
    }
    UIBarButtonItem *flexItem=[self flexSpace];
    UIBarButtonItem *doneItem=[self doneButton];
    _inputAccessoryView.items=@[flexItem,doneItem];
    return _inputAccessoryView;
}
-(void)closeInput:(UIBarButtonItem*)item
{
    [self.phoneNumTextField resignFirstResponder];
}
@end
