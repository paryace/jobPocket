//
//  CRecipientUpdateVctler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 14-1-17.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CRecipientUpdateVctler.h"
#import "CRecipientEditView.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"

#define kTagScrollview 100
#define kTagEditView 10101
#define kTagBtnCheck 10102

@interface CRecipientUpdateVctler ()
{
//    BOOL          _hadPreSetCity;       // 用在第一次请求时，如果是修改的情况下，预设选中piker项：城市
    BOOL          _hadPreSetCounty;     // 用在第一次请求时，如果是修改的情况下，预设选中piker项：地区
    
    BOOL          _saveAsDefault;
    BOOL          _showingPicker;
    UIPickerView* _areaPicker;
    UITextField*  _activTfView;
    
//    NSMutableArray* _areaList;  // 省份列表
    UIView*        _pickerStatusView; //add by liuruxian
    BOOL          _isFirst;
    UIView *_bgview;
}

@property (strong, nonatomic)CserviceOperation *_QryProvinceOp;
@property (strong, nonatomic)CserviceOperation *_QryCityOp;
@property (strong, nonatomic)CserviceOperation *_QryDistOp;
@property (strong, nonatomic)CserviceOperation *_DoModifyOp;

@property (strong, nonatomic) NSMutableArray *areaList;
@property (nonatomic,assign) BOOL          hadPreSetCity;
@property (nonatomic,assign) BOOL          hadPreSetCounty;

@property (nonatomic, assign) BOOL isFirst;

-(void)onBtnHidden:(id)sender;
-(void)onCheckBtn:(id)sender;
@end

@implementation CRecipientUpdateVctler

-(id)initWithViewForType:(NSInteger)type address:(NSDictionary*)dict{
    self = [super init];
    if (self) {
        _viewForType = type;
        _addessDict  = dict;
        _hadPreSetCity   = NO;
        _hadPreSetCounty = NO;
        _activTfView     = nil;
        _isFirst         = NO ;
        // Custom initialization

    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _viewForType = 1;
        self.title = @"填写收件人信息";
        _areaList = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 左按钮
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0
                                                green:235/255.0
                                                 blue:235/255.0
                                                alpha:1.0];
    
    UIScrollView* rootSbview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              CGRectGetWidth(self.view.frame),
                                                                              CGRectGetHeight(self.view.frame))];
    rootSbview.backgroundColor = [UIColor colorWithRed:235/255.0
                                                 green:235/255.0
                                                  blue:235/255.0
                                                 alpha:1.0];
    rootSbview.tag = kTagScrollview;
    rootSbview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    {
        UIButton* btnHidden = [UIButton buttonWithType:UIButtonTypeCustom];
        btnHidden.frame = self.view.frame;
        btnHidden.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [btnHidden addTarget:self
                      action:@selector(onBtnHidden:)
            forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnHidden];
    }
    [self.view addSubview:rootSbview];


	// Do any additional setup after loading the view.
    CGRect trect = CGRectMake(10,10,CGRectGetWidth(self.view.frame)-30,260);
    CRecipientEditView* editView = [[CRecipientEditView alloc] initWithFrame:trect];
    editView.tag = kTagEditView;
    editView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    editView.delegate = self;
    [rootSbview addSubview:editView];
    editView.reciper.delegate  = self;
    editView.address.delegate  = self;
    editView.postcode.delegate = self;
    editView.phone.delegate    = self;
    if (_viewForType==2 && _addessDict)
    {
        [editView setAdressDict:_addessDict];
        _saveAsDefault = [[_addessDict objectForKey:@"IfDefault"] boolValue];
    }
    else {
        // 默认为选中状态
        _saveAsDefault = YES;
    }
    
    CGFloat tyval = CGRectGetMaxY(editView.frame);
    {
        UIButton* btncheck = [UIButton buttonWithType:UIButtonTypeCustom];
        btncheck.tag       = kTagBtnCheck;
        btncheck.frame     = CGRectMake(20,tyval,160,30);
        if (_saveAsDefault) {
            [btncheck setImage:[UIImage imageNamed:@"btn_check_y.png"]
                 forState:UIControlStateNormal];
        }else{
            [btncheck setImage:[UIImage imageNamed:@"btn_check_n.png"]
                 forState:UIControlStateNormal];
        }
        UIEdgeInsets imgInset = UIEdgeInsetsMake(4,10,4,130);
        [btncheck setImageEdgeInsets:imgInset];
        [btncheck addTarget:self action:@selector(onCheckBtn:) forControlEvents:UIControlEventTouchUpInside];
        [rootSbview addSubview:btncheck];
        
        UILabel* labContent = [[UILabel alloc] initWithFrame:CGRectMake(30,2,130,24)];
        labContent.backgroundColor = [UIColor clearColor];
        labContent.font     = [UIFont  systemFontOfSize:14];
        labContent.textColor= [UIColor darkTextColor];
        labContent.textAlignment = UITextAlignmentLeft;
        labContent.text      = @"设置为默认地址";
        [btncheck addSubview:labContent];
    }
    tyval += 40;
    {
        UIButton* btnRead = [UIButton buttonWithType:UIButtonTypeSystem];
        btnRead.frame = CGRectMake(20, tyval,CGRectGetWidth(self.view.frame)-40,35);;
        [btnRead setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnRead setTitle:@"保存" forState:UIControlStateNormal];
        UIImage* bgImg =
        [[UIImage imageNamed:@"myOrderBtn.png"] stretchableImageWithLeftCapWidth:20
                                                                    topCapHeight:20];
        [btnRead setBackgroundImage:bgImg forState:UIControlStateNormal];
        [btnRead addTarget:self
                    action:@selector(onButtonSave:)
          forControlEvents:UIControlEventTouchUpInside];
        [rootSbview addSubview:btnRead];
    }
    tyval += 55;
    rootSbview.contentSize = CGSizeMake(CGRectGetWidth(rootSbview.frame), tyval);
    
    //add by liuruxian 2014-02-28
     _bgview = [[UIView alloc] init];
    
    UIView *pickerSelView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(MyAppDelegate.window.frame), CGRectGetWidth(MyAppDelegate.window.frame), 40)];
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
    
    {
        // picker
        UIPickerView * picker = [[UIPickerView alloc] init];
        picker.showsSelectionIndicator = YES;
        picker.dataSource     = (id<UIPickerViewDataSource>)self;
        picker.delegate       = (id<UIPickerViewDelegate>)self;
        [picker setBackgroundColor:[UIColor whiteColor]];
        picker.showsSelectionIndicator = YES;
        _areaPicker           = picker;
    }
    
    // 请求数据
    [self getProvinceList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidUnload{
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];         
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue*  aValue   = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSString* duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSString* Curve    = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int keyboadHeight = keyboardRect.size.height;

    UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagScrollview];
    CGRect rc       = sbView.frame;
    rc.size.height  = [[UIScreen mainScreen] bounds].size.height - keyboadHeight - 64;

    [UIView animateWithDuration:[duration floatValue]
                          delay:0.0
                        options:[Curve integerValue]
                     animations:^
    {
        sbView.frame = rc;
        if (_activTfView){
            [sbView scrollRectToVisible:CGRectInset(_activTfView.frame, 0, -8) animated:YES];
        }
    }completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagScrollview];
    CGRect rc       = sbView.frame;
    rc.size.height  = [[UIScreen mainScreen] bounds].size.height - 64;
    sbView.frame    = rc;
    if (_activTfView){
        [sbView scrollRectToVisible:_activTfView.frame animated:YES];
    }
}


#pragma mark - btnActions

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

-(void)onBtnHidden:(id)sender{
    [self hiddenPicker];
    CRecipientEditView* creView = (CRecipientEditView*)[self.view viewWithTag:kTagEditView];
    if (creView) {
        [creView hiddenKeyBord];
    }
}

-(void)onCheckBtn:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    _saveAsDefault = !_saveAsDefault;
    if (_saveAsDefault) {
        [btn setImage:[UIImage imageNamed:@"btn_check_y.png"]
             forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"btn_check_n.png"]
             forState:UIControlStateNormal];
    }
}

- (void) dealloc{
    _areaPicker.delegate = nil;
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
    if (_areaPicker && [_areaPicker isDescendantOfView:MyAppDelegate.window]) {
        [_areaPicker removeFromSuperview];
        [_pickerStatusView removeFromSuperview];
        [_bgview removeFromSuperview];
        _bgview = nil ;
        _areaPicker = nil;
        _pickerStatusView = nil;
    } else {
        _areaPicker = nil;
        _pickerStatusView = nil;
    }
}

- (void) onLeftBtnAction:(id)sender
{
    [super onLeftBtnAction:sender];
    if (_areaPicker && [_areaPicker isDescendantOfView:MyAppDelegate.window]) {
        [_areaPicker removeFromSuperview];
        [_pickerStatusView removeFromSuperview];
        [_bgview removeFromSuperview];
        _bgview = nil;
        _areaPicker = nil;
        _pickerStatusView = nil;
    } else {
        _areaPicker = nil;
        _pickerStatusView = nil;
    }
}

-(void)onButtonSave:(id)sender
{
    CRecipientEditView* creView = (CRecipientEditView*)[self.view viewWithTag:kTagEditView];
    if (!creView) {
        return;
    }
    [creView hiddenKeyBord];
    [self hiddenPicker];
    
    // 检查参数输入完整性
    NSError * error = [creView checkInputValues];
    if (error != nil)
    {
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
    }else
    {
        NSString *UserId = [Global sharedInstance].custInfoDict[@"UserId"];
        NSString* UserName = creView.reciper.text;
        NSString* Address  = [creView.address.text length] > 0? creView.address.text:@"";
        NSString* PostCode = [creView.postcode.text length]> 0? creView.postcode.text:@"";
        NSString* CusMobile= creView.phone.text;
        NSNumber* ifDefalut= [NSNumber numberWithBool:_saveAsDefault];
        NSString* CusTelnum= @"-";
        NSString* CusEmail = @"-";
         __weak typeof (self)weakSelf = self;
        if (_viewForType == 1) {
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
            
           
            self._DoModifyOp =
            [MyAppDelegate.cserviceEngine postXMLWithCode:@"addComConsigneeAddress"
                                                   params:params
                                              onSucceeded:^(NSDictionary *dict) {
                                                  SIAlertView *alertView =
                                                  [[SIAlertView alloc] initWithTitle:nil
                                                                          andMessage:@"收件人地址添加成功。"];
                                                  [alertView addButtonWithTitle:@"确定"
                                                                           type:SIAlertViewButtonTypeDefault
                                                                        handler:^(SIAlertView *alertView){
                                                                            [self.navigationController popViewControllerAnimated:YES];
                                                                        }];
                                                  alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                  [alertView show];
                                                  
                                                  // added by zy, 2014-02-14
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateAddressSuccess" object:nil];
                                                  
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
        }else if(_viewForType == 2)
        {
            NSDictionary* seldict = [self getSeledProvince];
            NSString* AddressId   = [_addessDict objectForKey:@"AddressId"];
            NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                                     AddressId,@"AddressId",
                                     UserId, @"UserId",
                                     CusMobile, @"CusMobile",
                                     PostCode, @"PostCode",
                                     [seldict objectForKey:@"citycode"], @"City",
                                     [seldict objectForKey:@"districtcode"], @"County",
                                     [seldict objectForKey:@"provincecode"], @"Province",
                                     Address, @"Address",
                                     UserName, @"UserName",
                                     CusTelnum,@"CusTelnum",
                                     ifDefalut,@"IfDefault",
                                     nil];
            self._DoModifyOp =
            [MyAppDelegate.cserviceEngine postXMLWithCode:@"modifyComConsigneeAddress"
                                                   params:params
                                              onSucceeded:^(NSDictionary *dict) {
                                                  SIAlertView *alertView =
                                                  [[SIAlertView alloc] initWithTitle:nil
                                                                          andMessage:@"收件人地址修改成功。"];
                                                  [alertView addButtonWithTitle:@"确定"
                                                                           type:SIAlertViewButtonTypeDefault
                                                                        handler:^(SIAlertView *alertView){
                                                                            [weakSelf.navigationController popViewControllerAnimated:YES];
                                                                        }];
                                                  alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                  [alertView show];
                                                  
                                                  // added by zy, 2014-02-14
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateAddressSuccess" object:nil];

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
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGPoint buttonPoint = [_areaPicker convertPoint:point fromView:MyAppDelegate.window];
    if ([_areaPicker pointInside:buttonPoint withEvent:event]) {
        return _areaPicker;
    }
    return nil;
}


#pragma mark - CRecipientEditViewDelegate
-(void)onPikerAction:(id)sender
{
    if ([_areaList count] <= 0) {
        [self getProvinceList];
        return;
    }

    CRecipientEditView* creView = (CRecipientEditView*)sender;
    if (creView) {
        [creView hiddenKeyBord];
    }

    //add by liuruxian 2014-03-04
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = NO;

    if ([_areaPicker isDescendantOfView:MyAppDelegate.window])
    {
//        [UIView animateWithDuration:0.25 animations:^{
//            _areaPicker.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(_areaPicker.frame));
//            //add by liuruxian 2014-02-28
//            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//            {
//                CGRect rect ;
//                rect = _pickerStatusView.frame ;
//                rect.origin.y = CGRectGetHeight(MyAppDelegate.window.frame)-CGRectGetHeight(_areaPicker.frame) - 30 ;
//                _pickerStatusView.frame = rect ;
//            }
//        } completion:^(BOOL finished) {
//        }];
        return;
    }else{
        _bgview.frame = CGRectMake(0, CGRectGetHeight(MyAppDelegate.window.frame), CGRectGetWidth(_areaPicker.frame), CGRectGetHeight(_areaPicker.frame));
        _bgview.backgroundColor = [UIColor clearColor];
        [MyAppDelegate.window addSubview:_bgview];
        
        _areaPicker.frame = CGRectMake(0, CGRectGetHeight(MyAppDelegate.window.frame), CGRectGetWidth(_areaPicker.frame), CGRectGetHeight(_areaPicker.frame));
        _pickerStatusView.frame = CGRectMake(0, CGRectGetHeight(MyAppDelegate.window.frame), CGRectGetWidth(_areaPicker.frame), 40);
        
        [MyAppDelegate.window addSubview:_areaPicker];
        [MyAppDelegate.window addSubview:_pickerStatusView];
        
        [UIView animateWithDuration:0.25 animations:^{
            _areaPicker.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(_areaPicker.frame));
            _bgview.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(_areaPicker.frame));
            //add by liuruxian 2014-02-28
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                CGRect rect ;
                rect = _pickerStatusView.frame ;
                rect.origin.y = CGRectGetHeight(MyAppDelegate.window.frame)-CGRectGetHeight(_areaPicker.frame) - 40 ;
                _pickerStatusView.frame = rect ;
            }
        } completion:^(BOOL finished) {
        }];
    }
}

-(void)onHiddenPopView:(id)sender
{
    [self onBtnHidden:nil];
}

#pragma mark - hiddenPicker
-(void)hiddenPicker{
    AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (![_areaPicker isDescendantOfView:app.window]){
        return;
    }
    
    //add by liuruxian 2014-03-04
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        _areaPicker.transform = CGAffineTransformIdentity;//CGAffineTransformMakeTranslation(0, CGRectGetHeight(MyAppDelegate.window.frame));
        _bgview.transform = CGAffineTransformIdentity ;
        CGRect rect ;
        rect = _pickerStatusView.frame ;
        rect.origin.y = CGRectGetHeight(MyAppDelegate.window.frame);
        _pickerStatusView.frame = rect ;
        
        // add by liuruxian 2014-02-26
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagScrollview];
            CGRect rc       = sbView.frame;
            rc.size.height  = [[UIScreen mainScreen] bounds].size.height - 113;
            sbView.frame    = rc;
        }
    } completion:^(BOOL finished) {
        [_bgview removeFromSuperview];
        [_areaPicker removeFromSuperview];
        [_pickerStatusView removeFromSuperview];
    }];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hiddenPicker];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (_activTfView == textField){
        _activTfView = nil;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
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
    
//    if (!_isFirst) {
//        UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagScrollview];
//        CRecipientEditView* creView = (CRecipientEditView*)[sbView viewWithTag:kTagEditView];
//        if (creView)
//        {
//            NSDictionary* dict = [self getSeledProvince];        // 获取选中的城市
//            [creView setProvince:[dict objectForKey:@"province"]
//                            city:[dict objectForKey:@"city"]
//                            dist:[dict objectForKey:@"district"]];
//        }
//        _isFirst = YES ;
//    }

    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<=7.0f) {
        
    }
    switch (_viewForType) {
        case 2:
        {
            UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagScrollview];
            CRecipientEditView* creView = (CRecipientEditView*)[sbView viewWithTag:kTagEditView];
            if (creView) {
                NSDictionary* dict = [self getSeledProvince];        // 获取选中的城市
                [creView setProvince:[dict objectForKey:@"province"]
                                city:[dict objectForKey:@"city"]
                                dist:[dict objectForKey:@"district"]];
            }
        }
            
            break;
        case 1:
        {
                UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagScrollview];
                CRecipientEditView* creView = (CRecipientEditView*)[sbView viewWithTag:kTagEditView];
                if (creView) {
                    NSDictionary* dict = [self getSeledProvince];        // 获取选中的城市
                    [creView setProvince:[dict objectForKey:@"province"]
                                    city:[dict objectForKey:@"city"]
                                    dist:[dict objectForKey:@"district"]];
                }
        }
            break;
            
        default:
            break;
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
                                          [pick reloadComponent:0];

                                          if (weakSelf.viewForType ==2 && weakSelf.addessDict) {
                                              // 处理预选中
                                              NSString* selProvinceCode = [weakSelf.addessDict objectForKey:@"Province"];
                                              for (int i = 0; i < [weakSelf.areaList count]; i++)
                                              {
                                                  NSDictionary* prodict = [weakSelf.areaList objectAtIndex:i];
                                                  NSString* prodcode = prodict[@"Freight_Area_Code"];
                                                  if(NO ==[selProvinceCode isEqualToString:prodcode]){
                                                      continue;
                                                  };
                                                  DLog("selProvince=%@,prodcode=%@",selProvinceCode,prodcode);
                                                  [pick selectRow:i
                                                             inComponent:0
                                                                animated:NO];
                                                  [weakSelf pickerView:pick
                                                      didSelectRow:i
                                                       inComponent:0];
                                                  break;
                                              }
                                          }else{
                                              [pick selectRow:1 inComponent:0 animated:NO];
                                              [weakSelf pickerView:pick
                                                  didSelectRow:1
                                                   inComponent:0];
                                          }
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
    __weak typeof (_areaPicker)pick = _areaPicker ;
    
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
                                          if (weakSelf.viewForType ==2 && weakSelf.addessDict && weakSelf.hadPreSetCity==NO)
                                          {
                                              // 处理预选中
                                              NSString* selProvinceCode = [weakSelf.addessDict objectForKey:@"Province"];
                                              NSString* selCityCode = [weakSelf.addessDict objectForKey:@"City"];
                                              BOOL hadFound = NO;
                                              for (NSDictionary * tdict in weakSelf.areaList)
                                              {
                                                  NSString * FreightAreaCode = [tdict objectForKey:@"Freight_Area_Code"];
                                                  if ([FreightAreaCode isEqualToString:selProvinceCode])
                                                  {
                                                      NSArray* cityList = [tdict objectForKey:@"citylist"];
                                                      for (int i =0; i < [cityList count]; i++) {
                                                          NSDictionary* citydict = [cityList objectAtIndex:i];
                                                          if ([selCityCode isEqualToString:[citydict objectForKey:@"Freight_Area_Code"]])
                                                          {
                                                              [pick selectRow:i
                                                                         inComponent:1
                                                                            animated:NO];
                                                              [weakSelf pickerView:pick
                                                                  didSelectRow:i
                                                                   inComponent:1];
                                                              hadFound = YES;
                                                              weakSelf.hadPreSetCity = YES;
                                                              break;
                                                          }
                                                      }
                                                      break;
                                                  }
                                                  if (hadFound) {
                                                      break;
                                                  }
                                              }
                                              if (!hadFound) {
                                                  [SVProgressHUD dismiss];
                                              }
                                          }else{
                                              [pick selectRow:0 inComponent:1 animated:NO];
                                              [weakSelf pickerView:pick
                                                  didSelectRow:0
                                                   inComponent:1];
                                              DDLogInfo(@"****** qry cityInfo success !!");
                                          }
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
    __weak typeof (_areaPicker)pick = _areaPicker ;
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
                                          if (weakSelf.viewForType ==2 && weakSelf.addessDict && weakSelf.hadPreSetCounty==NO)
                                          {
                                              // 处理预选中
                                              NSString* selProvinceCode = [weakSelf.addessDict objectForKey:@"Province"];
                                              NSString* selCityCode   = [weakSelf.addessDict objectForKey:@"City"];
                                              NSString* selCountyCode = [weakSelf.addessDict objectForKey:@"County"];
                                              for (NSDictionary * tdict in weakSelf.areaList)
                                              {
                                                  NSString * FreightAreaCode = [tdict objectForKey:@"Freight_Area_Code"];
                                                  BOOL hadCityFound = NO;
                                                  if (NO == [FreightAreaCode isEqualToString:selProvinceCode])
                                                  {
                                                      continue;
                                                  }
                                                  NSArray* cityList = [tdict objectForKey:@"citylist"];
                                                  for (NSDictionary* citydict in cityList)
                                                  {
                                                      BOOL hadFound = NO;
                                                      if (NO ==[selCityCode isEqualToString:[citydict objectForKey:@"Freight_Area_Code"]]){
                                                          continue;
                                                      }
                                                      hadCityFound = YES;
                                                      NSArray* countyList = [citydict objectForKey:@"districtlist"];
                                                      for (int i =0; i < [countyList count]; i++) {
                                                          NSDictionary*countyDt = [countyList objectAtIndex:i];
                                                          if (NO ==[selCountyCode isEqualToString:[countyDt objectForKey:@"Freight_Area_Code"]]){
                                                              continue;
                                                          }
                                                          hadFound = YES;
                                                          
                                                          // modified by zy, 2014-02-13
                                                          [pick selectRow:i
                                                                     inComponent:2
                                                                        animated:NO];
                                                          [weakSelf pickerView:pick
                                                              didSelectRow:i
                                                               inComponent:2];
                                                          [pick selectRow:i
                                                                     inComponent:2
                                                                        animated:NO];
                                                          weakSelf.hadPreSetCounty = YES;
                                                          break;
                                                      }
                                                      break;
                                                  }
                                                  if (hadCityFound == YES) {
                                                      break;
                                                  }
                                              }
                                          }else
                                          {
                                              [weakSelf pickerView:pick
                                                  didSelectRow:0
                                                   inComponent:2];
                                          }
                                          
                                          if (!weakSelf.isFirst) {
                                              UIScrollView* sbView = (UIScrollView*)[self.view viewWithTag:kTagScrollview];
                                              CRecipientEditView* creView = (CRecipientEditView*)[sbView viewWithTag:kTagEditView];
                                              if (creView)
                                              {
                                                  NSDictionary* dict = [weakSelf getSeledProvince];        // 获取选中的城市
                                                  [creView setProvince:[dict objectForKey:@"province"]
                                                                  city:[dict objectForKey:@"city"]
                                                                  dist:[dict objectForKey:@"district"]];
                                              }
                                              weakSelf.isFirst = YES ;
                                          }
                                          
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
@end
