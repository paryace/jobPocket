//
//  CTPNewAddrVCtler.m
//  CTPocketv3
//
//  Created by apple on 13-4-26.
//
//

#import "CTPNewAddrVCtler.h"

#import "UIView+RoundRect.h"
#import "AppDelegate.h"
#import "UIView+BounceAnimation.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "CTPInvoiceInfoVCtler.h"
#import "AppDelegate.h"
#import "CserviceOperation.h"
#import "CTLoginVCtler.h"
#import "SVProgressHUD.h"
#import "ToastAlertView.h"
#import "SIAlertView.h"


#define kCacheAddress   @"cacheaddress"
#define kBarHeight 49 

@interface CTPNewAddrVCtler ()

@property (nonatomic, retain) NSDictionary * deliverInfoDict;
@property (nonatomic, strong) CserviceOperation* addComConsigneeAddressOpt;
@property (nonatomic, strong) CserviceOperation* qryProvinceOpt;
@property (nonatomic, strong) CserviceOperation* qryCityOpt;
@property (nonatomic, strong) CserviceOperation* qryDistrictOpt;

- (void)onConfirmBtn:(id)sender;
- (void)onBgBtn:(id)sender;
- (void)onNavigationBarPrevBtn:(id)sender;
- (void)onNavigationBarNextBtn:(id)sender;
- (void)onNavigationBarConfirmBtn:(id)sender;
- (void)onAreaBtn:(id)sender;
- (void)showPickerView;
- (void)hidePickerView;
- (void)showNavigationBar;
- (void)hideNavigationBar;
- (void)setAreaBtnTitle;

- (void)addComConsigneeAddress;
- (void)qryProvince;
- (void)qryCity:(NSString *)province;
- (void)qryDistrict:(NSString *)province city:(NSString *)city;
- (void)loadCacheArea;
- (void)saveCacheArea;

- (void)setInitAddrinfo;

- (void)checkBaritemButtonEnable;

@end

@implementation CTPNewAddrVCtler

@synthesize userInfoDict;
@synthesize isSalesproduct;
@synthesize salesProductInfoDict;
@synthesize orderInfoDict;
@synthesize CustomerInfo;
@synthesize ContractInfo;
@synthesize PackageInfoDict;
@synthesize isModifyAddrinfo;
@synthesize addrInfo;
@synthesize deliverInfoDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [self loadCacheArea];
        if (![_areaList count])
        {
            [self qryProvince];
        }
        //获取登录用户名称
        NSDictionary *loginDict = [Global sharedInstance].loginInfoDict;
        NSString *Account = [loginDict objectForKey:@"UserLoginName"] ? [loginDict objectForKey:@"UserLoginName"] : @"";
        
        NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
        NSString * key = [NSString stringWithFormat:@"%@_%@", Account, kCacheAddress];
        self.deliverInfoDict = [def objectForKey:key];
    }
    return self;
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //add by liuruxian 2014-03-04
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
    
    //add by liuruxian 2014-03-04
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    self.userInfoDict = nil;
    if (self.addComConsigneeAddressOpt) {
        [self.addComConsigneeAddressOpt cancel];
        self.addComConsigneeAddressOpt = nil;
    }
    if (self.qryProvinceOpt) {
        [self.qryProvinceOpt cancel];
        self.qryProvinceOpt = nil;
    }
    if (self.qryCityOpt) {
        [self.qryCityOpt cancel];
        self.qryCityOpt = nil;
    }
    if (self.qryDistrictOpt) {
        [self.qryDistrictOpt cancel];
        self.qryDistrictOpt = nil;
    }
    
    [_netCitys release];
    [_netDistricts release];
    [_areaList release];
    [_textfieldNaviBar release];
    
    if ([_areaPicker isDescendantOfView:MyAppDelegate.window]) {
        [_areaPicker removeFromSuperview];
    }
    [_areaPicker release]; _areaPicker = nil ;
    
    self.salesProductInfoDict = nil;
    self.orderInfoDict = nil;
    self.CustomerInfo = nil;
    self.ContractInfo = nil;
    self.PackageInfoDict = nil;
    
    self.addrInfo = nil;

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"新建收货地址";
    [self setLeftButton:[UIImage imageNamed:@"btn_back_recharge.png"]];
    self.view.backgroundColor = [UIColor whiteColor];
    {
        UIImage * img = [UIImage imageNamed:@"huidi.png"];
        UIImageView * bgview = [[UIImageView alloc] initWithImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)]];
        bgview.frame = CGRectMake(10, 0, CGRectGetWidth(self.view.frame) - 20, CGRectGetHeight(self.view.frame) -15-89);

        [self.view addSubview:bgview];
        _greyBgView     = bgview;
        
        UIScrollView * scrollview = [[UIScrollView alloc] initWithFrame:CGRectInset(bgview.frame, 5, 5)];
        scrollview.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scrollview];
        _contentScroll = scrollview;
        
        [bgview release];
        [scrollview release];
    }
    {
#define kTextfieldTag   10
        int tftag    = kTextfieldTag;
        int interval = 10;
        int originX = interval;
        int originY = 10;
        int height  = 38;
        
        {
            originX             = interval;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX - 10, originY, 78, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1];
            lab.textAlignment   = UITextAlignmentRight;
            lab.text            = @"收货人姓名: ";
            [_contentScroll addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
            
            UITextField* textfield = [[UITextField alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - interval, height)];
            textfield.tag          = tftag++;
            textfield.placeholder  = @"请输入收货人姓名";
            textfield.textColor    = [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1];
            textfield.font         = [UIFont systemFontOfSize:14];
            [textfield dwMakeRoundCornerWithRadius:5];
            textfield.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
            textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfield.returnKeyType = UIReturnKeyNext;
            textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
            textfield.delegate      = (id<UITextFieldDelegate>)self;
            {
                UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
                mView.backgroundColor = [UIColor clearColor];
                textfield.leftView = mView;
                textfield.leftViewMode = UITextFieldViewModeAlways;
                [mView release];
            }
            [_contentScroll addSubview:textfield];
            originY                 = CGRectGetMaxY(textfield.frame) + 10;
            _nameTf                 = textfield;
            [textfield release];
            
            if ([self.CustomerInfo objectForKey:@"Cust_Name"] && [[self.CustomerInfo objectForKey:@"Cust_Name"] length])
            {
                _nameTf.text        = [self.CustomerInfo objectForKey:@"Cust_Name"];
            }
            if ([self.deliverInfoDict objectForKey:@"UserName"] && [[self.deliverInfoDict objectForKey:@"UserName"] length])
            {
                _nameTf.text        = [self.deliverInfoDict objectForKey:@"UserName"];
            }
        }
        {
            originX             = interval;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, 68, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1];
            lab.textAlignment   = UITextAlignmentRight;
            lab.text            = @"手机号码: ";
            [_contentScroll addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
            
            UITextField* textfield = [[UITextField alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - interval, height)];
            textfield.placeholder  = @"请输入手机号码";
            textfield.textColor    = [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1];
            textfield.font         = [UIFont systemFontOfSize:14];
            textfield.keyboardType = UIKeyboardTypeNumberPad;
            [textfield dwMakeRoundCornerWithRadius:5];
            textfield.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
            textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfield.returnKeyType = UIReturnKeyNext;
            textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
            textfield.delegate      = (id<UITextFieldDelegate>)self;
            textfield.tag           = tftag++;
            {
                UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
                mView.backgroundColor = [UIColor clearColor];
                textfield.leftView = mView;
                textfield.leftViewMode = UITextFieldViewModeAlways;
                [mView release];
            }
            [_contentScroll addSubview:textfield];
            originY                 = CGRectGetMaxY(textfield.frame) + 10;
            _phonenumTf             = textfield;
            [textfield release];
            
            {
                NSDictionary *loginDict = [Global sharedInstance].loginInfoDict;
                NSString *Account = [loginDict objectForKey:@"UserLoginName"] ? [loginDict objectForKey:@"UserLoginName"] : @"";
                _phonenumTf.text        = Account;
            }
            
            if ([self.deliverInfoDict objectForKey:@"CusMobile"] && [[self.deliverInfoDict objectForKey:@"CusMobile"] length])
            {
                _phonenumTf.text        = [self.deliverInfoDict objectForKey:@"CusMobile"];
            }
        }
        {
            originX             = interval;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, 68, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = [UIColor colorWithRed:36/255. green:36/255. blue:36/255 alpha:1];
            lab.textAlignment   = UITextAlignmentRight;
            lab.text            = @"邮政编码: ";
            [_contentScroll addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
            
            UITextField* textfield = [[UITextField alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - interval, height)];
            textfield.placeholder  = @"请输入邮政编码";
            textfield.textColor    = [UIColor colorWithRed:36/255. green:36/255. blue:36/255 alpha:1];
            textfield.font         = [UIFont systemFontOfSize:14];
            textfield.keyboardType = UIKeyboardTypeNumberPad;
            [textfield dwMakeRoundCornerWithRadius:5];
            textfield.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255 alpha:1];
            textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfield.returnKeyType = UIReturnKeyNext;
            textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
            textfield.delegate      = (id<UITextFieldDelegate>)self;
            textfield.tag           = tftag++;
            {
                UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
                mView.backgroundColor = [UIColor clearColor];
                textfield.leftView = mView;
                textfield.leftViewMode = UITextFieldViewModeAlways;
                [mView release];
            }
            [_contentScroll addSubview:textfield];
            originY                 = CGRectGetMaxY(textfield.frame) + 10;
            _postcodeTf             = textfield;
            [textfield release];
            
            if ([self.CustomerInfo objectForKey:@"Idcard_Postcode"] && [[self.CustomerInfo objectForKey:@"Idcard_Postcode"] length])
            {
                _postcodeTf.text        = [self.CustomerInfo objectForKey:@"Idcard_Postcode"];
            }
            if ([self.deliverInfoDict objectForKey:@"PostCode"] && [[self.deliverInfoDict objectForKey:@"PostCode"] length])
            {
                _postcodeTf.text        = [self.deliverInfoDict objectForKey:@"PostCode"];
            }
        }
        {
            originX             = interval;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, 68, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = [UIColor colorWithRed:36/255. green:36/255. blue:36/255 alpha:1];
            lab.textAlignment   = UITextAlignmentRight;
            lab.text            = @"所在地区: ";
            [_contentScroll addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
            
            UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame           = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - interval, height);
            [btn dwMakeRoundCornerWithRadius:5];
            [btn setTitleColor:[UIColor colorWithRed:36/255. green:36/255. blue:36/255 alpha:1] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.titleLabel.textAlignment = UITextAlignmentLeft;
            btn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
            btn.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255 alpha:1];
            btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.tag           = tftag++;
            [btn addTarget:self action:@selector(onAreaBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_contentScroll addSubview:btn];
            originY                 = CGRectGetMaxY(btn.frame) + 10;
            _countyBtn              = btn;
            
            UIImage * img     = [UIImage imageNamed:@"query_btn_s.png"];
            [btn setBackgroundImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)] forState:UIControlStateSelected];
            {
                UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_arrow_s.png"]];
                arrow.frame         = CGRectMake(CGRectGetWidth(btn.frame) - 18, (CGRectGetHeight(btn.frame) - 13)/2, 13, 13);
                [btn addSubview:arrow];
                [arrow release];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 23)];
            }
            
            {
                UIPickerView * picker = [[UIPickerView alloc] init];
                picker.dataSource     = (id<UIPickerViewDataSource>)self;
                picker.delegate       = (id<UIPickerViewDelegate>)self;
                picker.showsSelectionIndicator = YES;
                _areaPicker           = picker;
            }
            
            NSString * Province = [self.deliverInfoDict objectForKey:@"Province"];
            NSString * City     = [self.deliverInfoDict objectForKey:@"City"];
            NSString * County   = [self.deliverInfoDict objectForKey:@"County"];
            [_areaList enumerateObjectsUsingBlock:^(id proviceobj, NSUInteger provinceidx, BOOL *provincestop) {
                if (![[proviceobj objectForKey:@"Freight_Area_Code"] isEqualToString:Province])
                {
                    return ;
                }
                
                [_areaPicker selectRow:provinceidx inComponent:0 animated:NO];
                *provincestop = YES;
                
                NSArray * citylist = [proviceobj objectForKey:@"citylist"];
                [citylist enumerateObjectsUsingBlock:^(id cityobj, NSUInteger cityidx, BOOL *citystop) {
                    if (![[cityobj objectForKey:@"Freight_Area_Code"] isEqualToString:City])
                    {
                        return ;
                    }
                    
                    [_areaPicker selectRow:cityidx inComponent:1 animated:NO];
                    *citystop = YES;
                    
                    NSArray * districtlist = [cityobj objectForKey:@"districtlist"];
                    [districtlist enumerateObjectsUsingBlock:^(id districtobj, NSUInteger districtidx, BOOL *districtstop) {
                        if (![[districtobj objectForKey:@"Freight_Area_Code"] isEqualToString:County])
                        {
                            return ;
                        }
                        
                        [_areaPicker selectRow:districtidx inComponent:2 animated:NO];
                        *districtstop = YES;
                    }];
                }];
            }];
            
            [self setAreaBtnTitle];
        }
        {
            originX             = interval;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, 68, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = [UIColor colorWithRed:36/255. green:36/255. blue:36/255 alpha:1];
            lab.textAlignment   = UITextAlignmentRight;
            lab.text            = @"详细地址: ";
            [_contentScroll addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
            
            UITextView * textview  = [[UITextView alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - interval, height * 2)];
            textview.textColor     = [UIColor colorWithRed:36/255. green:36/255. blue:36/255 alpha:1];
            textview.font          = [UIFont systemFontOfSize:14];
            [textview dwMakeRoundCornerWithRadius:5];
            textview.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255 alpha:1];
            textview.returnKeyType = UIReturnKeyDone;
            textview.delegate      = (id<UITextViewDelegate>)self;
            textview.tag           = tftag++;
            [_contentScroll addSubview:textview];
            originY                = CGRectGetMaxY(textview.frame) + 10;
            _addrTf                = textview;
            [textview release];
            /*UITextField* textfield = [[UITextField alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - interval, height)];
            textfield.placeholder  = @"请输入详细地址";
            textfield.textColor    = kUIColorDarkBlack;
            textfield.font         = [UIFont systemFontOfSize:14];
            [textfield dwMakeRoundCornerWithRadius:5];
            textfield.backgroundColor = kUIColorWhiteColor;
            textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfield.returnKeyType = UIReturnKeyDone;
            textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
            textfield.delegate      = (id<UITextFieldDelegate>)self;
            textfield.tag           = tftag++;
            {
                UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
                mView.backgroundColor = [UIColor clearColor];
                textfield.leftView = mView;
                textfield.leftViewMode = UITextFieldViewModeAlways;
                [mView release];
            }
            [_contentScroll addSubview:textfield];
            originY                 = CGRectGetMaxY(textfield.frame) + 10;
            _addrTf               = textfield;
            [textfield release];*/
            
            if ([self.CustomerInfo objectForKey:@"Cust_Affress"] && [[self.CustomerInfo objectForKey:@"Cust_Affress"] length])
            {
                _addrTf.text        = [self.CustomerInfo objectForKey:@"Cust_Affress"];
            }
            if ([self.deliverInfoDict objectForKey:@"Address"] && [[self.deliverInfoDict objectForKey:@"Address"] length])
            {
                _addrTf.text        = [self.deliverInfoDict objectForKey:@"Address"];
            }
        }
        {
            originY             += 5;
            UIImage * img       = [UIImage imageNamed:@"query_btn.png"];
            UIImage * himg      = [UIImage imageNamed:@"query_btn_highlight.png"];
            UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame           = CGRectMake(30, originY, CGRectGetWidth(_contentScroll.frame) - 60, 44);
            [btn setBackgroundImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)] forState:UIControlStateNormal];
            [btn setBackgroundImage:[himg resizableImageWithCapInsets:UIEdgeInsetsMake(himg.size.height/2, himg.size.width/2, himg.size.height/2, himg.size.width/2)] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[himg resizableImageWithCapInsets:UIEdgeInsetsMake(himg.size.height/2, himg.size.width/2, himg.size.height/2, himg.size.width/2)] forState:UIControlStateDisabled];
            [btn setTitle:@"储存地址" forState:UIControlStateNormal];
            [btn setTitle:@"" forState:UIControlStateDisabled];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [btn addTarget:self action:@selector(onConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_contentScroll addSubview:btn];
            originY             = CGRectGetMaxY(btn.frame) + 15;
            _saveBtn         = btn;
        }
        {
            UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame           = CGRectMake(0, 0, CGRectGetWidth(_contentScroll.frame), MAX(CGRectGetHeight(_contentScroll.frame), originY));
            [btn addTarget:self action:@selector(onBgBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_contentScroll addSubview:btn];
            [_contentScroll sendSubviewToBack:btn];
        }
        
        {
            UINavigationBar * navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            navbar.barStyle = UIBarStyleBlackTranslucent;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                navbar.barTintColor = [UIColor colorWithRed:(9*16+7)/255. green:(9*16+7)/255. blue:(9*16+7)/255. alpha:1];
            }
            _textfieldNaviBar = navbar;
            
#define kBarItemTag     100
            int bartag = kBarItemTag;
            UINavigationItem * navitems = [[UINavigationItem alloc] init];
            UIBarButtonItem * prevbtn = [[UIBarButtonItem alloc] initWithTitle:@"上一项" style:UIBarButtonItemStyleBordered target:self action:@selector(onNavigationBarPrevBtn:)];
            prevbtn.tag               = bartag++;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                prevbtn.tintColor = [UIColor whiteColor];
            }
            
            
            UIBarButtonItem * nextbtn = [[UIBarButtonItem alloc] initWithTitle:@"下一项" style:UIBarButtonItemStyleBordered target:self action:@selector(onNavigationBarNextBtn:)];
            nextbtn.tag               = bartag++;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                nextbtn.tintColor = [UIColor whiteColor];
            }
            UIBarButtonItem * confirmbtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(onNavigationBarConfirmBtn:)];
            confirmbtn.tag            = bartag++;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                confirmbtn.tintColor = [UIColor whiteColor];
            }
            
            [navitems setLeftBarButtonItems:[NSArray arrayWithObjects:prevbtn, nextbtn, nil]];
            [navitems setRightBarButtonItems:[NSArray arrayWithObjects:confirmbtn, nil]];
            [navbar pushNavigationItem:navitems animated:NO];
            
            [navitems release];
            [confirmbtn release];
            [prevbtn release];
            [nextbtn release];
        }
        
        {
            UIActivityIndicatorView * activityview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityview.frame = CGRectMake(0, 0, 14, 14);
            activityview.hidesWhenStopped = YES;
            [_contentScroll addSubview:activityview];
            _activityviewInfo = activityview;
            _activityviewInfo.center = _saveBtn.center;
            [activityview release];
        }
        
        _contentScroll.contentSize  = CGSizeMake(CGRectGetWidth(_contentScroll.frame), originY);
    }
    
    [self pickerView:_areaPicker didSelectRow:0 inComponent:0];
    [self setAreaBtnTitle];
    [self setInitAddrinfo];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _contentScroll = nil;
    _nameTf = nil;
    _phonenumTf = nil;
    _postcodeTf = nil;
    _countyBtn = nil;
    _saveBtn = nil;
    _activityviewInfo = nil;
    _clickView = nil;
    _greyBgView = nil;
    _addrTf = nil;
    [_areaPicker release], _areaPicker = nil;
    [_textfieldNaviBar release], _textfieldNaviBar = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark - CTPNavBarDelegate
-(void)onleftBtnAction:(id)sender
{
    //网络取消 返回
    if (self.addComConsigneeAddressOpt) {
        [self.addComConsigneeAddressOpt cancel];
        self.addComConsigneeAddressOpt = nil;
    }
    if (self.qryProvinceOpt) {
        [self.qryProvinceOpt cancel];
        self.qryProvinceOpt = nil;
    }
    if (self.qryCityOpt) {
        [self.qryCityOpt cancel];
        self.qryCityOpt = nil;
    }
    if (self.qryDistrictOpt) {
        [self.qryDistrictOpt cancel];
        self.qryDistrictOpt = nil;
    }
    
    [self onNavigationBarConfirmBtn:sender];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark private
- (void)onConfirmBtn:(id)sender
{
    [self onBgBtn:nil];
    [self addComConsigneeAddress];
}

- (void)onBgBtn:(id)sender
{
    [_clickView resignFirstResponder];
    [self hidePickerView];
}

- (void)onNavigationBarPrevBtn:(id)sender
{
    int tag = _clickView.tag;
    if (tag <= kTextfieldTag)
    {
        return;
    }
    UIView * nview = [_contentScroll viewWithTag:tag-1];
    if (nview == _countyBtn)
    {
        [self onAreaBtn:nil];
        [_clickView resignFirstResponder];
    }
    else
    {
        if (tag == _countyBtn.tag)
        {
            [self hidePickerView];
            [self setAreaBtnTitle];
        }
        [nview becomeFirstResponder];
    }
}

- (void)onNavigationBarNextBtn:(id)sender
{
    int tag = _clickView.tag;
    UIView * nview = [_contentScroll viewWithTag:1+tag];
    if (nview == _countyBtn)
    {
        [self onAreaBtn:nil];
        [_clickView resignFirstResponder];
    }
    else
    {
        if (tag == _countyBtn.tag)
        {
            [self hidePickerView];
            [self setAreaBtnTitle];
        }
        [nview becomeFirstResponder];
    }
}

- (void)onNavigationBarConfirmBtn:(id)sender
{
    if (_clickView == _countyBtn)
    {
        [self setAreaBtnTitle];
    }
    [self onBgBtn:sender];
}

- (void)onAreaBtn:(id)sender
{
    [self showPickerView];
}
//弹出输入框时可能要移动整个view
- (void)showPickerView
{
    if (_clickView != _countyBtn)
    {
        [_clickView resignFirstResponder];
    }
    _clickView = _countyBtn;
    _countyBtn.selected = YES;
    
    //add by liuruxian 2014-03-04
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = NO;
    
    AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([_areaPicker isDescendantOfView:app.window])
    {
        return;
    }
    
    _areaPicker.frame = CGRectMake(0, CGRectGetHeight(app.window.frame), CGRectGetWidth(_areaPicker.frame), CGRectGetHeight(_areaPicker.frame));
    _areaPicker.backgroundColor = [UIColor whiteColor];
    [app.window addSubview:_areaPicker];
    
    [UIView animateWithDuration:0.25 animations:^{
        _areaPicker.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(_areaPicker.frame));
        
        int tabbarH = 0;
        //********************
//        if (!((AppDelegate *)[UIApplication sharedApplication].delegate).mainVctler.isTabbarHidden)
//        {
////            tabbarH = kCTPTabbarHeight;
//            tabbarH = 49;
//        }
        CGRect rc = _contentScroll.frame;
        rc.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(_contentScroll.frame) - CGRectGetHeight(_areaPicker.frame) + tabbarH - CGRectGetHeight(_textfieldNaviBar.frame) + kBarHeight;
        _contentScroll.frame = rc;
    } completion:^(BOOL finished) {
        [self showNavigationBar];
        if (_clickView)
        {
            [_contentScroll scrollRectToVisible:CGRectInset(_clickView.frame, 0, -8) animated:YES];
        }
    }];
}

- (void)hidePickerView
{
    if (![_areaPicker isDescendantOfView:((AppDelegate *)[UIApplication sharedApplication].delegate).window])
    {
        return;
    }
    //add by liuruxian 2014-03-04
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.25 animations:^{
        _areaPicker.transform = CGAffineTransformIdentity;
        
        CGRect rc = _contentScroll.frame;
        rc.size.height = CGRectGetMaxY(_greyBgView.frame) - CGRectGetMinY(_contentScroll.frame);
        _contentScroll.frame = rc;
        if (_clickView == _countyBtn)
        {
            _countyBtn.selected = NO;
            _clickView = nil;
            [self hideNavigationBar];
        }
    } completion:^(BOOL finished) {
        [_areaPicker removeFromSuperview];
    }];
}

- (void)showNavigationBar
{
    if (![_textfieldNaviBar isDescendantOfView:self.view])
    {
        [self.view addSubview:_textfieldNaviBar];
    }
    _textfieldNaviBar.frame = CGRectMake(0, CGRectGetMaxY(_contentScroll.frame), CGRectGetWidth(_textfieldNaviBar.frame), CGRectGetHeight(_textfieldNaviBar.frame));
}

- (void)hideNavigationBar
{
    if ([_textfieldNaviBar isDescendantOfView:self.view])
    {
        [_textfieldNaviBar removeFromSuperview];
    }
}

- (void)setAreaBtnTitle
{
    if ([_areaList count] <= 0)
    {
        return;
    }
    NSMutableString * title = [NSMutableString string];
    int selprovince = [_areaPicker selectedRowInComponent:0];
    int selcity = [_areaPicker selectedRowInComponent:1];
    int selcounty = [_areaPicker selectedRowInComponent:2];
    
    NSDictionary * provincedict = [_areaList objectAtIndex:selprovince];
    if ([provincedict objectForKey:@"Freight_Area_Name"])
    {
        [title appendString:[provincedict objectForKey:@"Freight_Area_Name"]];
    }
    
    NSArray * citylist = [provincedict objectForKey:@"citylist"];
    if (selcity >= 0 && selcity < [citylist count])
    {
        NSDictionary * citydict = [citylist objectAtIndex:selcity];
        if ([citydict objectForKey:@"Freight_Area_Name"])
        {
            [title appendFormat:@",%@", [citydict objectForKey:@"Freight_Area_Name"]];
        }
        
        NSArray * districtlist = [citydict objectForKey:@"districtlist"];
        if (selcounty >= 0 && selcounty < [districtlist count])
        {
            NSDictionary * countydict = [districtlist objectAtIndex:selcounty];
            if ([countydict objectForKey:@"Freight_Area_Name"])
            {
                [title appendFormat:@",%@", [countydict objectForKey:@"Freight_Area_Name"]];
            }
        }
    }
    
    [_countyBtn setTitle:title forState:UIControlStateNormal];
}

- (void)addComConsigneeAddress
{
    [self onBgBtn:nil];
    
    NSString * UserName = _nameTf.text;
    if ([UserName length] <= 0)
    {
        ToastAlertView * alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲，别忘记收货人姓名"];
        [alert release];
        [_nameTf bounceStart];
        return;
    }
    
    NSString * CusMobile = _phonenumTf.text;
    if ([CusMobile length] <= 0 || [CusMobile length] < 11 ||  ![Utils isNumber:CusMobile])
    {
        ToastAlertView * alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲，请输入正确的手机号码"];
        [alert release];
        [_phonenumTf bounceStart];
        return;
    }
    
    NSString * PostCode = _postcodeTf.text;
    if ([PostCode length] < 6)
    {
        ToastAlertView * alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲，请填写正确的邮政编码"];
        [alert release];
        [_postcodeTf bounceStart];
        return;
    }
    
    NSString * Province = @"";
    NSString * ProvinceName = @"";
    NSString * City = @"";
    NSString * CityName = @"";
    NSString * County = @"";
    NSString * CountyName = @"";
    
    if ([_countyBtn.currentTitle length] <= 0)
    {
//        ToastAlertView * alert = [ToastAlertView new];
//        [alert showAlertMsg:@"请选择地区信息"];
//        [alert release];
        [_countyBtn bounceStart];
        return;
    }

    {
        int selprovince = [_areaPicker selectedRowInComponent:0];
        int selcity = [_areaPicker selectedRowInComponent:1];
        int selcounty = [_areaPicker selectedRowInComponent:2];
        
        NSDictionary * provincedict = [_areaList objectAtIndex:selprovince];
        if ([provincedict objectForKey:@"Freight_Area_Code"])
        {
            Province = [provincedict objectForKey:@"Freight_Area_Code"];
        }
        ProvinceName = [provincedict objectForKey:@"Freight_Area_Name"] ? [provincedict objectForKey:@"Freight_Area_Name"] : @"";
        
        NSArray * citylist = [provincedict objectForKey:@"citylist"];
        if (selcity >= 0 && selcity < [citylist count])
        {
            NSDictionary * citydict = [citylist objectAtIndex:selcity];
            if ([citydict objectForKey:@"Freight_Area_Code"])
            {
                City = [citydict objectForKey:@"Freight_Area_Code"];
            }
            CityName = [citydict objectForKey:@"Freight_Area_Name"] ? [citydict objectForKey:@"Freight_Area_Name"] : @"";
            
            NSArray * districtlist = [citydict objectForKey:@"districtlist"];
            if (selcounty >= 0 && selcounty < [districtlist count])
            {
                NSDictionary * countydict = [districtlist objectAtIndex:selcounty];
                if ([countydict objectForKey:@"Freight_Area_Code"])
                {
                    County = [countydict objectForKey:@"Freight_Area_Code"];
                }
                CountyName = [countydict objectForKey:@"Freight_Area_Name"] ? [countydict objectForKey:@"Freight_Area_Name"] : @"";
            }
            else
            {
                ToastAlertView * alert = [ToastAlertView new];
                [alert showAlertMsg:@"亲，别忘记选择镇/区"];
                [alert release];
                return;
            }
        }
        else
        {
            ToastAlertView * alert = [ToastAlertView new];
            [alert showAlertMsg:@"亲，别忘记选择城市"];
            [alert release];
            return;
        }
    }
    
    NSString * Address = _addrTf.text;
    if ([Address length] <= 0)
    {
        ToastAlertView * alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲，没有完整的收货地址哦，是准备把货送到外太空吗？"];
        [alert release];
        [_addrTf bounceStart];
        return;
    }
    
    if (self.isSalesproduct)
    {
        NSDictionary * deliverinfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      CusMobile, @"CusMobile",
                                      PostCode, @"PostCode",
                                      City, @"City",
                                      @"0", @"CusEmail",
                                      County, @"County",
                                      Address, @"Address",
                                      Province, @"Province",
                                      UserName, @"UserName",
                                      ProvinceName, @"ProvinceName",
                                      CityName, @"CityName",
                                      CountyName, @"CountyName",nil];
        
        if (self.isModifyAddrinfo)
        {
            // 修改地址
            [[NSNotificationCenter defaultCenter] postNotificationName:CTP_MSG_MODIFY_ADDR_INFO object:deliverinfo];
            [self onleftBtnAction:nil];
            return;
        }
        
        self.deliverInfoDict = deliverinfo;
    }
    if (!self.userInfoDict && [Global sharedInstance].custInfoDict ) {
        self.userInfoDict = [Global sharedInstance].custInfoDict;
    }

    NSString * code         = @"addComConsigneeAddress";
    NSString * UserId       = [self.userInfoDict objectForKey:@"UserId"];
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               CusMobile, @"CusMobile",
                               @"0", @"CityName",
                               PostCode, @"PostCode",
                               @"0", @"ProvinceName",
                               @"0", @"AddressId",
                               @"", @"UserType",
                               City, @"City",
                               @"0", @"CountyName",
                               @"0", @"CusEmail",
                               CusMobile, @"CusTelnum",
                               County, @"County",
                               Address, @"Address",
                               UserId, @"UserId",
                               @"0", @"IfDefault",
                               Province, @"Province",
                               UserName, @"UserName",
                               UserName, @"CusName",
                               nil];
    __block CTPNewAddrVCtler *weakSelf = self;
    [MyAppDelegate.cserviceEngine postXMLWithCode:code
                                                                           params:params
                                          onSucceeded:^(NSDictionary *dict) {
                                              DDLogInfo(@"%s--%@", __func__, dict.description);
//                                              id Data = [dict objectForKey:@"Data"];
                                              
                                              [weakSelf.activityviewInfo stopAnimating];
                                              weakSelf.saveBtn.enabled = YES;
                                              weakSelf.contentScroll.userInteractionEnabled = YES;
                                              
                                              if (weakSelf.isSalesproduct)
                                              {
                                                  // 购买流程
                                                  CTPInvoiceInfoVCtler * vctler = [CTPInvoiceInfoVCtler new];
                                                  [vctler setProductOrderInfo:weakSelf.salesProductInfoDict
                                                                    orderInfo:weakSelf.orderInfoDict
                                                                  deliverInfo:weakSelf.deliverInfoDict
                                                                 customerInfo:weakSelf.CustomerInfo];
                                                  vctler.PackageInfoDict        = weakSelf.PackageInfoDict;
                                                  vctler.ContractInfo           = weakSelf.ContractInfo;
                                                  [self.navigationController pushViewController:vctler animated:YES];
                                                  [vctler release];
                                                  
                                                  NSDictionary *loginDict = [Global sharedInstance].loginInfoDict;
                                                  NSString *Account = [loginDict objectForKey:@"UserLoginName"] ? [loginDict objectForKey:@"UserLoginName"] : @"";
                                                  
                                                  NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
                                                  NSString * key = [NSString stringWithFormat:@"%@_%@", Account, kCacheAddress];
                                                  [def setObject:weakSelf.deliverInfoDict forKey:key];
                                                  [def synchronize];
                                                  
                                                  return;
                                              }
                                              
                                          } onError:^(NSError *engineError) {
                                              DDLogInfo(@"%s--%@", __func__, engineError);
                                              [SVProgressHUD dismiss];
                                              weakSelf.saveBtn.enabled = YES;
                                              weakSelf.contentScroll.userInteractionEnabled = YES;
                                              [weakSelf.activityviewInfo stopAnimating];
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
                                                      [alertView release];
                                                  }
                                                  if([engineError.userInfo[@"ResultCode"] isEqualToString:@"203"])
                                                  {
                                                     
                                                      // 购买流程
                                                      CTPInvoiceInfoVCtler * vctler = [CTPInvoiceInfoVCtler new];
                                                      [vctler setProductOrderInfo:self.salesProductInfoDict
                                                                        orderInfo:self.orderInfoDict
                                                                      deliverInfo:self.deliverInfoDict
                                                                     customerInfo:self.CustomerInfo];
                                                      vctler.PackageInfoDict        = self.PackageInfoDict;
                                                      vctler.ContractInfo           = self.ContractInfo;
                                                      [self.navigationController pushViewController:vctler animated:YES];
                                                      [vctler release];
                                                  }
                                              }
                                              else{
                                                  ToastAlertView *alert = [ToastAlertView new];
                                                  [alert showAlertMsg:@"系统繁忙,请重新提交"];
                                                  [alert release];
                                              }
                                          }];
    
    [_activityviewInfo startAnimating];
    _activityviewInfo.center = _saveBtn.center;
    _saveBtn.enabled = NO;
    _contentScroll.userInteractionEnabled = NO;
}

- (void)qryProvince
{
    
    NSString * code         = @"qryOrganization";
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"2", @"Type",
                               @"", @"ProvinceCode",
                               @"", @"CityCode",
                               nil];
    if (self.qryProvinceOpt) {
        [self.qryProvinceOpt cancel];
        self.qryProvinceOpt = nil;
    }
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];

    __block CTPNewAddrVCtler *weakSelf = self;
    [MyAppDelegate.cserviceEngine postXMLWithCode:code
                                           params:params
                                      onSucceeded:^(NSDictionary *dict)
    {
        //格式化数据(将指定的数据格式化成数组)
        dict = [Utils objFormatArray:dict path:@"Data/Items"];
        
        DDLogInfo(@"%s--%@", __func__, dict.description);
        id Data = [dict objectForKey:@"Data"];
        
        id Items = [Data objectForKey:@"Items"];
        NSArray * arr = nil;
        if (Items != nil)
        {
            arr = Items;
        }else
        {
            arr = [NSArray array];
        }
        [weakSelf.areaList release], weakSelf.areaList = nil;
        weakSelf.areaList = [[NSMutableArray alloc] initWithArray:arr];
        
        [weakSelf saveCacheArea];
        [weakSelf.areaPicker reloadComponent:0];
        [weakSelf pickerView:weakSelf.areaPicker didSelectRow:0 inComponent:0];
        
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
                [alertView release];
            }
        }
        else{
            ToastAlertView *alert = [ToastAlertView new];
            [alert showAlertMsg:@"系统繁忙,请重新提交"];
            [alert release];
        }
    }];
}

- (void)qryCity:(NSString *)province
{
    if (![province length])
    {
        return;
    }
    
    if (!_netCitys)
    {
        _netCitys = [[NSMutableDictionary alloc] init];
    }
    
    if (self.qryCityOpt) {
        [self.qryCityOpt cancel];
        self.qryCityOpt = nil;
    }
    
    NSString * code         = @"qryOrganization";
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"2", @"Type",
                               province, @"ProvinceCode",
                               @"", @"CityCode",
                               nil];
    __block CTPNewAddrVCtler *weakSelf = self ;
    [MyAppDelegate.cserviceEngine postXMLWithCode:code
                                           params:params
                                      onSucceeded:^(NSDictionary *dict)
    {
        //格式化数据(将指定的数据格式化成数组)
        dict = [Utils objFormatArray:dict path:@"Data/Items"];
        
        DDLogInfo(@"%s--%@", __func__, dict.description);
        id Data = [dict objectForKey:@"Data"];
        if (Data && [Data respondsToSelector:@selector(objectForKey:)]) {
            id Items = [Data objectForKey:@"Items"];
            NSArray * arr = nil;
            if (Items != nil)
            {
                arr = Items;
            }else
            {
                arr = [NSArray array];
            }
            
            for (NSDictionary * dict in weakSelf.areaList)
            {
                NSString * Freight_Area_Code = [dict objectForKey:@"Freight_Area_Code"];
                if ([Freight_Area_Code isEqualToString:province])
                {
                    NSMutableDictionary * mutaDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    [mutaDict setObject:arr forKey:@"citylist"];
                    [weakSelf.areaList replaceObjectAtIndex:[weakSelf.areaList indexOfObject:dict] withObject:mutaDict];
                    [weakSelf saveCacheArea]; //更新保存
                    break;
                }
            }
            
            [weakSelf.areaPicker reloadComponent:1];
            [weakSelf pickerView:weakSelf.areaPicker didSelectRow:0 inComponent:1];
        }
    } onError:^(NSError *engineError) {
        DDLogInfo(@"%s--%@", __func__, engineError);
        //token超时处理
        {
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
                    [alertView release];
                }
            }
            else{
                ToastAlertView *alert = [ToastAlertView new];
                [alert showAlertMsg:@"系统繁忙,请重新提交"];
                [alert release];
            }
        }
    }];
}

- (void)qryDistrict:(NSString *)province city:(NSString *)city
{
    if (![province length] ||
        ![city length])
    {
        return;
    }
    
    if (!_netDistricts)
    {
        _netDistricts = [NSMutableDictionary new];
    }
    
    if (self.qryDistrictOpt) {
        [self.qryDistrictOpt cancel];
        self.qryDistrictOpt = nil;
    }
    
    NSString * code         = @"qryOrganization";
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"2", @"Type",
                               province, @"ProvinceCode",
                               city, @"CityCode",
                               nil];
    
    __block NSString *provinceCode = province ;
    __block NSString *cityCode = city ;
    __block CTPNewAddrVCtler *weakSelf = self;
    [MyAppDelegate.cserviceEngine postXMLWithCode:code
                                           params:params
                                      onSucceeded:^(NSDictionary *dict)
    {
        //格式化数据(将指定的数据格式化成数组)
        dict = [Utils objFormatArray:dict path:@"Data/Items"];
        
        DDLogInfo(@"%s--%@", __func__, dict.description);
        
        id Data = [dict objectForKey:@"Data"];
        id Items = [Data objectForKey:@"Items"];
        NSArray * arr = nil;
        if (Items != nil)
        {
            arr = Items;
        }else
        {
            arr = [NSArray array];
        }
        
        for (NSDictionary * provincedict in weakSelf.areaList)
        {
            NSString * Freight_Area_Code = [provincedict objectForKey:@"Freight_Area_Code"];
            if ([Freight_Area_Code isEqualToString:provinceCode])
            {
                NSMutableArray * citylist = [NSMutableArray arrayWithArray:[provincedict objectForKey:@"citylist"]];
                for (NSDictionary * citydict in citylist)
                {
                    NSString * tmpcode = [citydict objectForKey:@"Freight_Area_Code"];
                    if ([tmpcode isEqualToString:cityCode])
                    {
                        NSMutableDictionary * mutaCitydict = [NSMutableDictionary dictionaryWithDictionary:citydict];
                        [mutaCitydict setObject:arr forKey:@"districtlist"];
                        [citylist replaceObjectAtIndex:[citylist indexOfObject:citydict] withObject:mutaCitydict];
                        
                        NSMutableDictionary * mutaProvincedict = [NSMutableDictionary dictionaryWithDictionary:provincedict];
                        [mutaProvincedict setObject:citylist forKey:@"citylist"];
                        [weakSelf.areaList replaceObjectAtIndex:[weakSelf.areaList indexOfObject:provincedict] withObject:mutaProvincedict];
                        
                        [weakSelf saveCacheArea];
                        break;
                    }
                }
                break;
            }
        }
        
        //刷新
        [weakSelf.areaPicker reloadComponent:2];
        [weakSelf pickerView:weakSelf.areaPicker didSelectRow:0 inComponent:2];
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
                [alertView release];
            }
        }
        else{
            ToastAlertView *alert = [ToastAlertView new];
            [alert showAlertMsg:@"系统繁忙,请重新提交"];
            [alert release];
        }
    }];
}

-(NSString *) getDocumentFolderByName:(NSString *)foldername
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if ([foldername length])
    {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:foldername];
    }
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileMgr fileExistsAtPath:documentsDirectory isDirectory:&isDir])
    {
        [fileMgr createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return documentsDirectory;
}

- (void)loadCacheArea
{
    [_areaList release], _areaList = nil;
    NSString * path = [[self getDocumentFolderByName:nil] stringByAppendingPathComponent:CTP_SAVE_AREA_LIST];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileMgr fileExistsAtPath:path isDirectory:&isDir])
    {
        _areaList = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
}

- (void)saveCacheArea
{
    // 缓存到本地
    NSString * path = [[self getDocumentFolderByName:nil] stringByAppendingPathComponent:CTP_SAVE_AREA_LIST];
    BOOL ret = [_areaList writeToFile:path atomically:YES];
    NSLog(@"save area %d", ret);
}
//初始化数据使用
- (void)setInitAddrinfo
{
    if (!self.isSalesproduct ||
        !self.isModifyAddrinfo ||
        !self.addrInfo)
    {
        return;
    }
    
    if ([self.addrInfo objectForKey:@"UserName"])
    {
        _nameTf.text = [self.addrInfo objectForKey:@"UserName"];
    }
    
    if ([self.addrInfo objectForKey:@"CusMobile"])
    {
        _phonenumTf.text = [self.addrInfo objectForKey:@"CusMobile"];
    }
    
    if ([self.addrInfo objectForKey:@"PostCode"])
    {
        _postcodeTf.text = [self.addrInfo objectForKey:@"PostCode"];
    }
    
    if ([self.addrInfo objectForKey:@"Address"])
    {
        _addrTf.text = [self.addrInfo objectForKey:@"Address"];
    }
    
    NSString * Province = [self.addrInfo objectForKey:@"Province"] ? [self.addrInfo objectForKey:@"Province"] : @"";
    NSString * City = [self.addrInfo objectForKey:@"City"] ? [self.addrInfo objectForKey:@"City"] : @"";
    NSString * County = [self.addrInfo objectForKey:@"County"] ? [self.addrInfo objectForKey:@"County"] : @"";
    __block NSMutableString * text = [NSMutableString string];
    
    [_areaList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        // 省
        if ([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"Freight_Area_Code"])
        {
            NSString * provincecode = [obj objectForKey:@"Freight_Area_Code"];
            if ([provincecode isEqualToString:Province])
            {
                *stop = YES;
                [text appendString:([obj objectForKey:@"Freight_Area_Name"] ? [obj objectForKey:@"Freight_Area_Name"] : @"")];
                [_areaPicker selectRow:idx inComponent:0 animated:NO];
                
                // 市
                NSArray * citylist = [obj objectForKey:@"citylist"];
                [citylist enumerateObjectsUsingBlock:^(id cityobj, NSUInteger cityidx, BOOL *citystop)
                {
                    if ([cityobj isKindOfClass:[NSDictionary class]] && [cityobj objectForKey:@"Freight_Area_Code"])
                    {
                        NSString * citycode = [cityobj objectForKey:@"Freight_Area_Code"];
                        if ([citycode isEqualToString:City])
                        {
                            *citystop = YES;
                            [text appendFormat:@", %@", ([cityobj objectForKey:@"Freight_Area_Name"] ? [cityobj objectForKey:@"Freight_Area_Name"] : @"")];
                            [_areaPicker selectRow:cityidx inComponent:1 animated:NO];
                            
                            // 区
                            NSArray * districtlist = [cityobj objectForKey:@"districtlist"];
                            [districtlist enumerateObjectsUsingBlock:^(id districtobj, NSUInteger districtidx, BOOL *districtstop)
                            {
                                if ([districtobj isKindOfClass:[NSDictionary class]] && [districtobj objectForKey:@"Freight_Area_Code"])
                                {
                                    NSString * districtcode = [districtobj objectForKey:@"Freight_Area_Code"];
                                    if ([districtcode isEqualToString:County])
                                    {
                                        *districtstop = YES;
                                        [text appendFormat:@", %@", ([districtobj objectForKey:@"Freight_Area_Name"] ? [districtobj objectForKey:@"Freight_Area_Name"] : @"")];
                                        [_areaPicker selectRow:districtidx inComponent:2 animated:NO];
                                    }
                                }
                            }];// 区
                        }
                    }
                }];// 市
            }
        }// 省
    }];
    [_countyBtn setTitle:text forState:UIControlStateNormal];
    
//    [_navbar setTitle:@"修改地址"];
    self.title = @"修改地址";
}

- (void)checkBaritemButtonEnable
{
    UINavigationItem * navitem = [_textfieldNaviBar topItem];
    NSArray * leftBarButtonItems = [navitem leftBarButtonItems];
    for (UIBarButtonItem * barbtn in leftBarButtonItems)
    {
        if (barbtn.tag == kBarItemTag)
        {
            barbtn.enabled = (_clickView.tag == kTextfieldTag) ? NO : YES;
        }
        else if (barbtn.tag == kBarItemTag + 1)
        {
            barbtn.enabled = (_clickView.tag == kTextfieldTag + 4) ? NO : YES;
        }
    }
}

#pragma mark UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext)
    {
        UITextField * next = (UITextField *)[_contentScroll viewWithTag:textField.tag+1];
        if ((id)next == _countyBtn)
        {
            [self onAreaBtn:nil];
        }
        else
        {
            [next becomeFirstResponder];
            [self hidePickerView];
        }
        return YES;
    }
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_clickView == _countyBtn)
    {
        [self hidePickerView];
    }
    _clickView = textField;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self checkBaritemButtonEnable];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (_clickView == textField)
    {
        _clickView = nil;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _phonenumTf)
    {
        return ([string length] <= 0 || [textField.text length] < 11);
    }
    else if (textField == _postcodeTf)
    {
        return ([string length] <= 0 || [textField.text length] < 6);
    }
    return YES;
}

#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_clickView == _countyBtn)
    {
        [self hidePickerView];
    }
    _clickView = textView;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self checkBaritemButtonEnable];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (_clickView == textView)
    {
        _clickView = nil;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self checkBaritemButtonEnable];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 animations:^{
        NSDictionary *userInfo = [notification userInfo];
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        int keyboadHeight = keyboardRect.size.height + CGRectGetHeight(_textfieldNaviBar.frame);
        
        int tabbarH = 49;//0
//        if (!((AppDelegate *)[UIApplication sharedApplication].delegate).mainVctler.isTabbarHidden)
//        {
//            tabbarH = kCTPTabbarHeight;
//        }
        CGRect rc = _contentScroll.frame;
        rc.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(_contentScroll.frame) - keyboadHeight + tabbarH + kBarHeight;
        _contentScroll.frame = rc;
        if (_clickView)
        {
            [_contentScroll scrollRectToVisible:CGRectInset(_clickView.frame, 0, -8) animated:YES];
        }
    } completion:^(BOOL finished) {
        [self showNavigationBar];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect rc = _contentScroll.frame;
    rc.size.height = CGRectGetMaxY(_greyBgView.frame) - CGRectGetMinY(_contentScroll.frame);
    _contentScroll.frame = rc;
    
    if (_clickView)
    {
        [_contentScroll scrollRectToVisible:_clickView.frame animated:YES];
    }
    [self hideNavigationBar];
}

#pragma mark CTPBaseDataSourceDelegate
- (void)OnStartRequest:(id)sender
{
    ;
}


#pragma mark UIPickerViewDataSource
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
            if (iPhone5 && cnt <= 0)
            {
                cnt = 1;
            }
            return cnt;
        }
            break;
        case 1:
        {
            int selprovice = [pickerView selectedRowInComponent:0];
            if (selprovice < [_areaList count] && selprovice >= 0)
            {
                NSDictionary * province = [_areaList objectAtIndex:selprovice];
                int cnt = [[province objectForKey:@"citylist"] count];
                if (iPhone5 && cnt <= 0)
                {
                    cnt = 1;
                }
                return cnt;
            }
        }
            break;
        case 2:
        {
            int selprovice = [pickerView selectedRowInComponent:0];
            if (selprovice < [_areaList count] && selprovice >= 0)
            {
                NSDictionary * province = [_areaList objectAtIndex:selprovice];
                NSArray * citylist = [province objectForKey:@"citylist"];
                int selcity = [pickerView selectedRowInComponent:1];
                if (selcity < [citylist count] && selcity >= 0)
                {
                    NSDictionary * city = [citylist objectAtIndex:selcity];
                    int cnt = [[city objectForKey:@"districtlist"] count];
                    if (iPhone5 && cnt <= 0)
                    {
                        cnt = 1;
                    }
                    return cnt;
                }
            }
        }
            break;
        default:
            break;
    }
    return iPhone5 ? 1 : 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
        {
            if (row >= 0 && row < [_areaList count])
            {
                NSDictionary * province = [_areaList objectAtIndex:row];
                return [province objectForKey:@"Freight_Area_Name"];
            }
        }
            break;
        case 1:
        {
            int selprovice = [pickerView selectedRowInComponent:0];
            if (selprovice < [_areaList count] && selprovice >= 0)
            {
                NSDictionary * province = [_areaList objectAtIndex:selprovice];
                NSArray * citylist = [province objectForKey:@"citylist"];
                if ([citylist isKindOfClass:[NSArray class]] && row >= 0 && row < [citylist count])
                {
                    NSDictionary * city = [citylist objectAtIndex:row];
                    return [city objectForKey:@"Freight_Area_Name"];
                }
            }
        }
            break;
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
        }
            break;
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
            if (row < [_areaList count] && row >= 0)
            {
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
        }
            break;
        case 1:
        {
            int selprovice = [pickerView selectedRowInComponent:0];
            if (selprovice < [_areaList count] && selprovice >= 0)
            {
                NSDictionary * province = [_areaList objectAtIndex:selprovice];
                NSArray * citylist = [province objectForKey:@"citylist"];
                if ([citylist isKindOfClass:[NSArray class]] && row < [citylist count] && row >= 0)
                {
                    NSDictionary * city = [citylist objectAtIndex:row];
                    NSArray * districtlist = [city objectForKey:@"districtlist"];
                    if (![districtlist count])
                    {
                        [self qryDistrict:[province objectForKey:@"Freight_Area_Code"] city:[city objectForKey:@"Freight_Area_Code"]];
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void) onLeftBtnAction:(id)sender
{
    [self hidePickerView];
    [super onLeftBtnAction:nil];
}
@end
