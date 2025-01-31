//
//  CTPQryAttributionVCtler.m
//  CTPocketv3
//
//  Created by lyh on 13-4-17.
//
//

#import "CTPQryAttributionVCtler.h"
#import "UIView+RoundRect.h"
#import "CserviceEngine.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "ToastAlertView.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"

#define  QATagTfPhoneNumber  1000


@interface CTPQryAttributionVCtler ()
@property (strong, nonatomic)CserviceOperation *QryOperation;
@end

@implementation CTPQryAttributionVCtler

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setTitle:@"号码归属地查询"];
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];

    int yOffset = 20;
    
    {
        UIImageView* divLine = [[UIImageView alloc] initWithFrame:CGRectMake(10,yOffset,self.view.bounds.size.width - 2 * 10,2)];
        divLine.image = [UIImage imageNamed:@"div_line.png"];
//        [self.view addSubview:divLine];
        yOffset += 2;
    }
    
    {
        if (_tfPhoneNum) {
            _tfPhoneNum = nil;
        }
        _tfPhoneNum = [[UITextField alloc] initWithFrame:CGRectMake(30,yOffset,self.view.bounds.size.width - 60,36)];
        _tfPhoneNum.placeholder  = @"";
        _tfPhoneNum.tag          = QATagTfPhoneNumber;
        _tfPhoneNum.textColor    = [UIColor darkTextColor];
        _tfPhoneNum.font         = [UIFont systemFontOfSize:15];
        _tfPhoneNum.keyboardType = UIKeyboardTypeNumberPad;
        _tfPhoneNum.placeholder  = @"请输入您要查询的电信手机号码";
        [_tfPhoneNum dwMakeRoundCornerWithRadius:5];
        _tfPhoneNum.backgroundColor = [UIColor whiteColor];
        _tfPhoneNum.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _tfPhoneNum.returnKeyType = UIReturnKeyNext;
        _tfPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        {
            UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
            mView.backgroundColor = [UIColor clearColor];
            _tfPhoneNum.leftView = mView;
            _tfPhoneNum.leftViewMode = UITextFieldViewModeAlways;
        }
        [self.view addSubview:_tfPhoneNum];
        yOffset += _tfPhoneNum.frame.size.height;

    }
    
    {
        yOffset += 16;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(30, yOffset, self.view.bounds.size.width - 60, 36);
        button.backgroundColor = [UIColor colorWithRed:111/255. green:197/255. blue:55/255. alpha:1.00f];
        [button dwMakeRoundCornerWithRadius:3];
        [button setTitle:@"查询" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onQryAttribution:) forControlEvents:UIControlEventTouchUpInside];
        yOffset += button.frame.size.height;
        [self.view addSubview:button];
    }
    
    {
        int xOffset = 10;
        yOffset += 10;
        if (_resultView)
        {
            _resultView = nil;
        }
        
        _resultView = [[UIView alloc] initWithFrame:CGRectMake(10, yOffset, self.view.bounds.size.width - 2 * 10, 150)];
        _resultView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_resultView];
        _resultView.hidden = YES;
        
        {
            yOffset = 0;
            UILabel*  labTip = [[UILabel alloc] initWithFrame:CGRectMake(30, yOffset, _resultView.frame.size.width - 60, 24)];
            labTip.backgroundColor = [UIColor clearColor];
            labTip.font     = [UIFont  systemFontOfSize:16];
            labTip.textColor= [UIColor darkTextColor];
            labTip.textAlignment = UITextAlignmentLeft;
            labTip.text = @"查询结果";
            [_resultView addSubview:labTip];
            yOffset += labTip.frame.size.height;
        }
        
        {
            yOffset += 10;
            UIImageView * imgResultBackground = [[UIImageView alloc] initWithFrame:CGRectMake(30, yOffset, _resultView.frame.size.width - 60, 80)];
            [imgResultBackground dwMakeRoundCornerWithRadius:5];
            imgResultBackground.backgroundColor = [UIColor whiteColor];
            [_resultView addSubview:imgResultBackground];
        }
        
        {
            xOffset = 35;
            yOffset += 5;
            UILabel*  labResultPhoneTip = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 74, 24)];
            labResultPhoneTip.backgroundColor = [UIColor clearColor];
            labResultPhoneTip.font     = [UIFont  systemFontOfSize:14];
            labResultPhoneTip.textColor= [UIColor darkTextColor];
            labResultPhoneTip.textAlignment = UITextAlignmentLeft;
            labResultPhoneTip.text = @"手机号码:";
            [_resultView addSubview:labResultPhoneTip];
            xOffset += labResultPhoneTip.frame.size.width;
        }
        
        {
            xOffset += 5;
            if (_labResultPhoneNum) {
                _labResultPhoneNum = nil;
            }
            _labResultPhoneNum = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 140, 24)];
            _labResultPhoneNum.backgroundColor = [UIColor clearColor];
            _labResultPhoneNum.font     = [UIFont  systemFontOfSize:14];
            _labResultPhoneNum.textColor= [UIColor darkTextColor];
            _labResultPhoneNum.textAlignment = UITextAlignmentLeft;
            _labResultPhoneNum.text = @"";
            [_resultView addSubview:_labResultPhoneNum];
            yOffset += _labResultPhoneNum.frame.size.height;
        }
        
        {
            xOffset = 35;
            UILabel*  labResultAttributionTip = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 74, 24)];
            labResultAttributionTip.backgroundColor = [UIColor clearColor];
            labResultAttributionTip.font     = [UIFont  systemFontOfSize:14];
            labResultAttributionTip.textColor= [UIColor darkTextColor];
            labResultAttributionTip.textAlignment = UITextAlignmentLeft;
            labResultAttributionTip.text = @"所属省份:";
            [_resultView addSubview:labResultAttributionTip];
            xOffset += labResultAttributionTip.frame.size.width;

            xOffset += 5;
            if (_labAttribution) {
                _labAttribution = nil;
            }
            _labAttribution = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 140, 24)];
            _labAttribution.backgroundColor = [UIColor clearColor];
            _labAttribution.font     = [UIFont  systemFontOfSize:14];
            _labAttribution.textColor= [UIColor darkTextColor];
            _labAttribution.textAlignment = UITextAlignmentLeft;
            _labAttribution.text = @"";
            [_resultView addSubview:_labAttribution];
            yOffset += _labAttribution.frame.size.height;
        }
        
        {
            xOffset = 35;
            UILabel*  labResultAreaCodeTip = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 74, 24)];
            labResultAreaCodeTip.backgroundColor = [UIColor clearColor];
            labResultAreaCodeTip.font     = [UIFont  systemFontOfSize:14];
            labResultAreaCodeTip.textColor= [UIColor darkTextColor];
            labResultAreaCodeTip.textAlignment = UITextAlignmentLeft;
            labResultAreaCodeTip.text = @"所属城市:";
            [_resultView addSubview:labResultAreaCodeTip];
            xOffset += labResultAreaCodeTip.frame.size.width;

            xOffset += 5;
            if (_labAreaCode) {
                _labAreaCode = nil;
            }
            _labAreaCode = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 140, 24)];
            _labAreaCode.backgroundColor = [UIColor clearColor];
            _labAreaCode.font     = [UIFont  systemFontOfSize:14];
            _labAreaCode.textColor= [UIColor darkTextColor];
            _labAreaCode.textAlignment = UITextAlignmentLeft;
            _labAreaCode.text = @"";
            [_resultView addSubview:_labAreaCode];
            
        }
    }
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - NetRequest
- (void)getAttribution
{
    NSString * PhoneNum  = [NSString stringWithString:_tfPhoneNum.text];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            BUSSINESS_SHOPID, @"ShopId",
                            PhoneNum,@"PhoneNbr",
                            nil];
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    self.QryOperation = [MyAppDelegate.cserviceEngine postXMLWithCode:@"getLocationByphoneNbrInfo"
                                                                params:params
                                                           onSucceeded:^(NSDictionary *dict) {
                                                               DDLogInfo(@"%s--%@", __func__, dict.description);
                                                               _resultView.hidden = NO;
                                                               
                                                               _labResultPhoneNum.text = _tfPhoneNum.text;
                                                               _labAttribution.text = [[dict objectForKey:@"Data"] objectForKey:@"Province"];
                                                               _labAreaCode.text = [[dict objectForKey:@"Data"] objectForKey:@"City"];
                                                               [SVProgressHUD dismiss];
                                                           } onError:^(NSError *engineError) {
                                                               [SVProgressHUD showErrorWithStatus:engineError.localizedDescription];
                                                               DDLogInfo(@"%s--%@", __func__, engineError);
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
                                                                   } else
                                                                   {
                                                                       ToastAlertView *toast = [ToastAlertView new];
                                                                       [toast showAlertMsg:@"网络异常,请查看网络"];
                                                                   }
                                                               }
                                                           }];
}

#pragma mark - IBAction
- (void)onQryAttribution:(id)sender
{
    [self onHideKeyboard];
    
//    NSDictionary * logindict = [Global sharedSingleton].loginInfoDict;
//    NSString* str_loginname = [logindict objectForKey:@"UserLoginName"] ? [logindict objectForKey:@"UserLoginName"] : @"";
//    if (str_loginname.length > 0)
    {
        if (_tfPhoneNum.text.length == 0)
        {
            ToastAlertView *alert = [ToastAlertView new];
            [alert showAlertMsg:@"亲，别忘记填写手机号码"];
        }
        else if (_tfPhoneNum.text.length != 11)
        {
            ToastAlertView *alert = [ToastAlertView new];
            [alert showAlertMsg:@"手机号码是11位哦，请检查"];
        }
        else if (NO == [Utils isMobileNumber:_tfPhoneNum.text])
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示！"
                                                            message:@"请输入正确的手机号码"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];            
            return;
        }
        else
        {
            CGRect rect = CGRectMake(10, 20 + 2, self.view.bounds.size.width - 2 * 10, 270);
            _bgView.frame = rect;
            _bgView.backgroundColor =  [UIColor colorWithRed:230/255.0
                                                       green:230/255.0
                                                        blue:230/255.0 alpha:1];
            [_bgView dwMakeBottomRoundCornerWithRadius:5];
            [self getAttribution];
        }
    }
    /*else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示！"
                                                        message:@"亲爱的用户，请登录后再查询。"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }*/
}

- (void)onHideKeyboard
{
    // 关闭键盘
    [_tfPhoneNum resignFirstResponder];
}
@end
