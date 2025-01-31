//
//  CTPNumberPickerVCtler.m
//  CTPocketv3
//
//  Created by apple on 13-5-13.
//
//

#import "CTPNumberPickerVCtler.h"
#import "UIView+RoundRect.h"
#import "AppDelegate.h"
#import "UIView+BounceAnimation.h"
#import <QuartzCore/QuartzCore.h>
#import "SelectPackagesVCtler.h"
#import "CTPProtocolFillVCtler.h"
#import "Global.h"
#import "CserviceOperation.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "ToastAlertView.h"
#import "SIAlertView.h"


#define kBarHeight 49

@interface CTPNumberPickerVCtler ()

@property (nonatomic, retain) NSDictionary * areaInfodict;  // 号码归属地信息
@property (nonatomic, strong) CserviceOperation *qryProvinceOpt ;
@property (nonatomic, strong) CserviceOperation *qryCityOpt;
@property (nonatomic, strong) CserviceOperation *qryPrettyNumberInfoOpt;
@property (nonatomic, strong) CserviceOperation *qryPhoneNumberCardOpt;
@property (nonatomic, strong) CserviceOperation *createContractOrderOpt;
@property (nonatomic, strong) CserviceOperation *LocationByphoneNbrInfoOpt;

@property (nonatomic, strong) NSString *userId;


- (void)onBgBtn:(id)sender;
- (void)onNavigationBarPrevBtn:(id)sender;
- (void)onNavigationBarNextBtn:(id)sender;
- (void)onNavigationBarConfirmBtn:(id)sender;
- (void)onProvinceBtn:(id)sender;
- (void)onCityBtn:(id)sender;
- (void)onNumbertypeBtn:(id)sender;
- (void)onFeetypeBtn:(id)sender;
- (void)onSearchBtn:(id)sender;

- (void)showPickerView;
- (void)hidePickerView;
- (void)showNavigationBar;
- (void)hideNavigationBar;

- (void)qryProvince;
- (void)qryCity:(NSString *)province;
- (void)loadCacheArea;
- (void)saveCacheArea;

- (void)getNumberlist;
- (void)prettyNumberInfo;
- (void)qryPhoneNumberCard;

- (void)onRefreshBtn:(id)sender;
- (void)onScrollTopBtn:(id)sender;
- (void)onMoneyBtn:(id)sender;
- (void)onNextstepBtn:(id)sender;

- (int)getTotalFee;
- (NSDictionary *)getSelectedPhone;

- (void)createContractOrder;    // 生成订单（合约机）

// notification
- (void)onNotificationLogin4Number:(NSNotification *)sender;
- (void)onNotificationLogin4CreateOrder:(NSNotification *)sender;

- (void)getLocationByphoneNbrInfo;
- (void)setNumAttrFirst;

@end

@implementation CTPNumberPickerVCtler

@synthesize bIsprettyNumber;
@synthesize SalesproductInfoDict;
@synthesize PackageInfoDict;
@synthesize OptPackageList;
@synthesize ContractInfo;
@synthesize areaInfodict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       // 靓号类型（AAAA --1    AAA --2     ABCD --3     AABB --4       ABC--5       AA--6  ）
        _numTypeArr = [[NSArray alloc] initWithObjects:@"不限", @"AAAA（例如尾号：8888）", @"AAA", @"ABCD", @"AABB", @"ABC", @"AA", nil];
        
        // 不限 1-499 500-1000 1000-1500 1500-2000 2000-3000 3000-4000 4000-5000 5000以上
        _feeTypeArr = [[NSArray alloc] initWithObjects:@"不限", @"1-499", @"500-1000", @"1000-1500", @"1500-2000", @"2000-3000", @"3000-4000", @"4000-5000", @"5000以上",nil];
        
        _pageNum = 1;
        _PageSize = 10;
        _TotalCount = 0;
        _selectedRow = 1;
        
        _selectedProvinceIdx = 0;
        _selectedCityIdx     = 0;
        _selectedNumtypeIdx  = 0;
        _selectedFeetypeIdx  = 0;
        
        //查询usrid
        [self qryUserId];
        
        [self loadCacheArea]; //读取本地保存的数据
        if (![_areaList count])
        {
            [self qryProvince];  //没有数据情况下 查询省份数据
        }
        
        _hasSetNumAttr = NO;
        [self getLocationByphoneNbrInfo];  //号码归属地查询 （查询本机并显示）
        
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //add by liuruxian 2014-03-02
    if ([_areaPicker isDescendantOfView:MyAppDelegate.window])
    {
        [_areaPicker removeFromSuperview];
    }
    [_areaPicker release], _areaPicker = nil;
    [_textfieldNaviBar release], _textfieldNaviBar = nil;
    
    //add by liuruxian 2014-03-04
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
    
    for (NSString * province in _netCitys)
    {
        [[_netCitys objectForKey:province] cancel];
    }
    [_netCitys release];
    [_areaList release];
    
    [_numTypeArr release];
    [_feeTypeArr release];
    
    [_numberList release], _numberList = nil;
    
    self.SalesproductInfoDict = nil;
    self.PackageInfoDict = nil;
    self.OptPackageList = nil;
    self.ContractInfo = nil;
    self.areaInfodict = nil;
    
    //网络对象
    if (self.qryProvinceOpt) {
        [self.qryProvinceOpt cancel];
        self.qryProvinceOpt = nil;
    }
    if (self.qryCityOpt) {
        [self.qryCityOpt cancel];
        self.qryCityOpt = nil;
    }
    if (self.qryPrettyNumberInfoOpt) {
        [self.qryPrettyNumberInfoOpt cancel];
        self.qryPrettyNumberInfoOpt = nil;
    }
    if (self.qryPhoneNumberCardOpt) {
        [self.qryPhoneNumberCardOpt cancel];
        self.qryPhoneNumberCardOpt = nil;
    }
    if (self.createContractOrderOpt) {
        [self.createContractOrderOpt cancel];
        self.createContractOrderOpt = nil;
    }
    if (self.LocationByphoneNbrInfoOpt) {
        [self.LocationByphoneNbrInfoOpt cancel];
        self.LocationByphoneNbrInfoOpt = nil;
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    {
        [self setLeftButton:[UIImage imageNamed:@"btn_back_recharge.png"]];
        if (self.bIsprettyNumber)
        {
            self.title = @"天翼靓号";
        }
        else
        {
            self.title = @"号码选择";
        }
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    {
        UIImage * img = [UIImage imageNamed:@"huidi.png"];
        UIImageView * bgview = [[UIImageView alloc] initWithImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)]];
         bgview.frame = CGRectMake(10, 0, CGRectGetWidth(self.view.frame) - 20, CGRectGetHeight(self.view.frame)-49-15-45);
        [self.view addSubview:bgview];
        _greyBgView     = bgview;
        
        UITableView * tableview = [[UITableView alloc] initWithFrame:CGRectInset(bgview.frame, 5, 5) style:UITableViewStylePlain];
        tableview.backgroundColor   = [UIColor clearColor];
        tableview.separatorStyle    = UITableViewCellSeparatorStyleNone;
        tableview.delegate      = (id<UITableViewDelegate>)self;
        tableview.dataSource    = (id<UITableViewDataSource>)self;
        tableview.scrollsToTop  = YES;
        _numberListTable        = tableview;
        [self.view addSubview:tableview];
        
        {
            CGRect frame = CGRectMake(0, -EGORefreshTableHeaderView_Height, CGRectGetWidth(_numberListTable.frame), EGORefreshTableHeaderView_Height);
            EGORefreshTableHeaderView * footRefreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:frame];
            footRefreshView.delegate = (id<EGORefreshTableHeaderDelegate>)self;
            footRefreshView.hidden = YES;
            [_numberListTable addSubview:footRefreshView];
            _footRefreshView = footRefreshView;
            [footRefreshView release];
        }
        
        [bgview release];
        [tableview release];
    }

    {
        UIScrollView * scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_numberListTable.frame), 0)];
        scrollview.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1];
        scrollview.showsVerticalScrollIndicator = NO;
        _contentScroll = scrollview;
    }
    {
#define kTextfieldTag   10
        int tftag    = kTextfieldTag;
        int interval = 10;
        int originX = interval;
        int originY = 10;
        int height  = 38;
        
        {
            originX             = 15;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX - 10, originY, 55, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       =  [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1];//(36, 36, 36, 1);
            lab.textAlignment   = UITextAlignmentLeft;
            lab.text            = @"归属地: ";
            [_contentScroll addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
            
            {
                UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame           = CGRectMake(originX, originY, (CGRectGetWidth(_contentScroll.frame) - originX - interval*2)/2, height);
                [btn dwMakeRoundCornerWithRadius:5];
                [btn setTitleColor:[UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1] forState:UIControlStateNormal];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
                btn.titleLabel.font = [UIFont systemFontOfSize:14];
                btn.titleLabel.textAlignment = UITextAlignmentLeft;
                btn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
                btn.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
                btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                btn.tag           = tftag++;
                [btn addTarget:self action:@selector(onProvinceBtn:) forControlEvents:UIControlEventTouchUpInside];
                [_contentScroll addSubview:btn];
                originX                 = CGRectGetMaxX(btn.frame) + interval;
                _provinceBtn            = btn;
                
                UIImage * img     = [UIImage imageNamed:@"query_btn_s.png"];
                [btn setBackgroundImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)] forState:UIControlStateSelected];
                {
                    UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_arrow_s.png"]];
                    arrow.frame         = CGRectMake(CGRectGetWidth(btn.frame) - 18, (CGRectGetHeight(btn.frame) - 13)/2, 13, 13);
                    [btn addSubview:arrow];
                    [arrow release];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 23)];
                }
            }
            
            {
                UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame           = CGRectMake(originX, originY, (CGRectGetWidth(_contentScroll.frame) - originX - interval), height);
                [btn dwMakeRoundCornerWithRadius:5];
                [btn setTitleColor:[UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1] forState:UIControlStateNormal];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
                btn.titleLabel.font = [UIFont systemFontOfSize:14];
                btn.titleLabel.textAlignment = UITextAlignmentLeft;
                btn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
                btn.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
                btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                btn.tag           = tftag++;
                [btn addTarget:self action:@selector(onCityBtn:) forControlEvents:UIControlEventTouchUpInside];
                [_contentScroll addSubview:btn];
                originY                 = CGRectGetMaxY(btn.frame) + 10;
                _cityBtn                = btn;
                
                UIImage * img     = [UIImage imageNamed:@"query_btn_s.png"];
                [btn setBackgroundImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)] forState:UIControlStateSelected];
                {
                    UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_arrow_s.png"]];
                    arrow.frame         = CGRectMake(CGRectGetWidth(btn.frame) - 18, (CGRectGetHeight(btn.frame) - 13)/2, 13, 13);
                    [btn addSubview:arrow];
                    [arrow release];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 23)];
                }
            }
            
            {
                UIPickerView * picker = [[UIPickerView alloc] init];
                picker.dataSource     = (id<UIPickerViewDataSource>)self;
                picker.delegate       = (id<UIPickerViewDelegate>)self;
                picker.showsSelectionIndicator = YES;
                _areaPicker           = picker;
                
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
                    // add by liuruxian 2014-02-28
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                        prevbtn.tintColor = [UIColor whiteColor];
                    }
                    
                    UIBarButtonItem * nextbtn = [[UIBarButtonItem alloc] initWithTitle:@"下一项" style:UIBarButtonItemStyleBordered target:self action:@selector(onNavigationBarNextBtn:)];
                    nextbtn.tag               = bartag++;
                    // add by liuruxian 2014-02-28
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                        nextbtn.tintColor = [UIColor whiteColor];
                    }
                    
                    UIBarButtonItem * confirmbtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(onNavigationBarConfirmBtn:)];
                    confirmbtn.tag            = bartag++;
                    // add by liuruxian 2014-02-28
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
            }
        }
        
        {
            originX             = 15;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX - 10, originY, 70, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1];
            lab.textAlignment   = UITextAlignmentLeft;
            lab.text            = @"靓号类型: ";
            [_contentScroll addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
            
            UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame           = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - interval, height);
            [btn dwMakeRoundCornerWithRadius:5];
            [btn setTitleColor:[UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.titleLabel.textAlignment = UITextAlignmentLeft;
            btn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
            btn.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
            btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.tag           = tftag++;
            [btn addTarget:self action:@selector(onNumbertypeBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_contentScroll addSubview:btn];
            originY                 = CGRectGetMaxY(btn.frame) + 10;
            _numTypeBtn             = btn;
            
            UIImage * img     = [UIImage imageNamed:@"query_btn_s.png"];
            [btn setBackgroundImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)] forState:UIControlStateSelected];
            [btn setTitle:[_numTypeArr objectAtIndex:0] forState:UIControlStateNormal];
            {
                UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_arrow_s.png"]];
                arrow.frame         = CGRectMake(CGRectGetWidth(btn.frame) - 18, (CGRectGetHeight(btn.frame) - 13)/2, 13, 13);
                [btn addSubview:arrow];
                [arrow release];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 23)];
            }
        }
        
        {
            originX             = 15;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX - 10, originY, 95, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1];
            lab.textAlignment   = UITextAlignmentLeft;
            lab.text            = @"预存话费区间: ";
            [_contentScroll addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
            
            UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame           = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - interval, height);
            [btn dwMakeRoundCornerWithRadius:5];
            [btn setTitleColor:[UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.titleLabel.textAlignment = UITextAlignmentLeft;
            btn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
            btn.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
            btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.tag           = tftag++;
            [btn addTarget:self action:@selector(onFeetypeBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_contentScroll addSubview:btn];
            originY                 = CGRectGetMaxY(btn.frame) + 10;
            _feeTypeBtn             = btn;
            
            UIImage * img     = [UIImage imageNamed:@"query_btn_s.png"];
            [btn setBackgroundImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)] forState:UIControlStateSelected];
            [btn setTitle:[_feeTypeArr objectAtIndex:0] forState:UIControlStateNormal];
            {
                UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_arrow_s.png"]];
                arrow.frame         = CGRectMake(CGRectGetWidth(btn.frame) - 18, (CGRectGetHeight(btn.frame) - 13)/2, 13, 13);
                [btn addSubview:arrow];
                [arrow release];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 23)];
            }
        }
        
        {
            originX             = 15;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX - 10, originY, 55, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1] ;
            lab.textAlignment   = UITextAlignmentLeft;
            lab.text            = @"自定义: ";
            [_contentScroll addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
            
            UITextField* textfield = [[UITextField alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - interval*2 - 50, height)];
            textfield.placeholder  = @"生日/纪念日(2-4位)";
            textfield.textColor    = [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1] ;
            textfield.font         = [UIFont systemFontOfSize:14];
            textfield.keyboardType = UIKeyboardTypeNumberPad;
            [textfield dwMakeRoundCornerWithRadius:5];
            textfield.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
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
            originX                 = CGRectGetMaxX(textfield.frame) + 10;
            _tailNumTf              = textfield;
            [textfield release];
            
            {
                UIImage * img       = [UIImage imageNamed:@"query_btn.png"];
                UIImage * himg      = [UIImage imageNamed:@"query_btn_highlight.png"];
                UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame           = CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - interval, height);
                [btn setBackgroundImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)] forState:UIControlStateNormal];
                [btn setBackgroundImage:[himg resizableImageWithCapInsets:UIEdgeInsetsMake(himg.size.height/2, himg.size.width/2, himg.size.height/2, himg.size.width/2)] forState:UIControlStateHighlighted];
                [btn setBackgroundImage:[himg resizableImageWithCapInsets:UIEdgeInsetsMake(himg.size.height/2, himg.size.width/2, himg.size.height/2, himg.size.width/2)] forState:UIControlStateDisabled];
                [btn setTitle:@"搜索" forState:UIControlStateNormal];
                [btn setTitle:@"" forState:UIControlStateDisabled];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [btn addTarget:self action:@selector(onSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
                [_contentScroll addSubview:btn];
                originY             = CGRectGetMaxY(btn.frame) + 10;
                _searchBtn          = btn;
            }
        }
        //覆盖按钮 作为pickerview的点击消失
        {
            UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame           = CGRectMake(0, 0, CGRectGetWidth(_contentScroll.frame), MAX(CGRectGetHeight(_contentScroll.frame), originY));
            [btn addTarget:self action:@selector(onBgBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_contentScroll addSubview:btn];
            [_contentScroll sendSubviewToBack:btn];
        }

        _contentScroll.frame = CGRectMake(CGRectGetMinX(_contentScroll.frame), CGRectGetMinY(_contentScroll.frame), CGRectGetWidth(_contentScroll.frame), originY);
    }
    
    {
        UIView * bgview             = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
        bgview.backgroundColor      = [UIColor colorWithRed:217/255. green:217/255. blue:217/255. alpha:1];
        bgview.layer.cornerRadius   = 8;
        bgview.autoresizingMask     = UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:bgview];
        _bottomView                 = bgview;
        
        int originX = 0;
        int originY = 10;
        int height  = 38;
        {
            originX             = 20;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, 70, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1];
            lab.textAlignment   = UITextAlignmentLeft;
            lab.text            = @"预存话费: ";
            [bgview addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
        }
        
        UIImage * img_normal    = [UIImage imageNamed:@"Recharge_moneyBg1.png"];
        UIImage * img_selected  = [UIImage imageNamed:@"Recharge_moneyBg2.png"];
        {
            UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame           = CGRectMake(originX, originY + (int)(height - img_normal.size.height)/2, img_normal.size.width, img_normal.size.height);
            [btn setBackgroundImage:img_normal forState:UIControlStateNormal];
            [btn setBackgroundImage:img_selected forState:UIControlStateSelected];
            [btn setTitle:@"100元" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:157/255. green:154/255. blue:147/255. alpha:1] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [btn addTarget:self action:@selector(onMoneyBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.selected        = YES;
            [bgview addSubview:btn];
            _moneyBtn100        = btn;
            originX             = CGRectGetMaxX(btn.frame) + 10;
        }
        
        {
            UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame           = CGRectMake(originX, originY + (int)(height - img_normal.size.height)/2, img_normal.size.width, img_normal.size.height);
            [btn setBackgroundImage:img_normal forState:UIControlStateNormal];
            [btn setBackgroundImage:img_selected forState:UIControlStateSelected];
            [btn setTitle:@"50元" forState:UIControlStateNormal];//kRGBUIColor(157,154,147,1)
            [btn setTitleColor:[UIColor colorWithRed:157/255. green:154/255. blue:147/255. alpha:1] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [btn addTarget:self action:@selector(onMoneyBtn:) forControlEvents:UIControlEventTouchUpInside];
            [bgview addSubview:btn];
            _moneyBtn50         = btn;
            originY             = CGRectGetMaxY(btn.frame) + 10;
        }
        
#if 0
        {
            originX             = 20;
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX , originY, 70, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = kUIColorDarkBlack;
            lab.textAlignment   = UITextAlignmentLeft;
            lab.text            = @"应付总额: ";
            [bgview addSubview:lab];
            originX             = CGRectGetMaxX(lab.frame) + 5;
            [lab release];
        }
        {
            UILabel * lab       = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(_contentScroll.frame) - originX - 15, height)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font            = [UIFont systemFontOfSize:14];
            lab.textColor       = [UIColor redColor];
            lab.textAlignment   = UITextAlignmentLeft;
            lab.text            = @"100元";
            [bgview addSubview:lab];
            _totalPayFeeLab     = lab;
            [lab release];
        }
#endif
        
        {
            UIImage * img       = [UIImage imageNamed:@"query_btn.png"];
            UIImage * himg      = [UIImage imageNamed:@"query_btn_highlight.png"];
            UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame           = CGRectMake(CGRectGetWidth(bgview.frame) - 66 - 30, originY, 66, 34);
            [btn setBackgroundImage:[img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)] forState:UIControlStateNormal];
            [btn setBackgroundImage:[himg resizableImageWithCapInsets:UIEdgeInsetsMake(himg.size.height/2, himg.size.width/2, himg.size.height/2, himg.size.width/2)] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[himg resizableImageWithCapInsets:UIEdgeInsetsMake(himg.size.height/2, himg.size.width/2, himg.size.height/2, himg.size.width/2)] forState:UIControlStateDisabled];
            if (!self.bIsprettyNumber)
            {
                [btn setTitle:@"立即购买" forState:UIControlStateNormal];
            }
            else
            {
                [btn setTitle:@"下一步" forState:UIControlStateNormal];
            }
            [btn setTitle:@"" forState:UIControlStateDisabled];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [btn addTarget:self action:@selector(onNextstepBtn:) forControlEvents:UIControlEventTouchUpInside];
            [bgview addSubview:btn];
            originY             = CGRectGetMaxY(btn.frame) + 10;
            _buyBtn             = btn;
        }
        
        originY                 += 20;
        bgview.frame            = CGRectMake(CGRectGetMinX(bgview.frame), CGRectGetHeight(self.view.frame) - originY, CGRectGetWidth(bgview.frame), originY);

        _numberListTable.frame  = CGRectMake(CGRectGetMinX(_numberListTable.frame), CGRectGetMinY(_numberListTable.frame), CGRectGetWidth(_numberListTable.frame), CGRectGetMinY(bgview.frame) - CGRectGetMinY(_numberListTable.frame) - 49 - (iPhone5?40:63));
        [bgview release];
    }
    //转圈
    {
        UIActivityIndicatorView * activityview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityview.frame = CGRectMake(0, 0, 14, 14);
        activityview.hidesWhenStopped = YES;
        [_contentScroll addSubview:activityview];
        _activityviewInfoSearch = activityview;
        _activityviewInfoSearch.center = _searchBtn.center;
        [activityview release];
    }
    
    {
        UIActivityIndicatorView * activityview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityview.frame = CGRectMake(0, 0, 14, 14);
        activityview.hidesWhenStopped = YES;
        [_bottomView addSubview:activityview];
        _activityviewInfoBuy = activityview;
        _activityviewInfoBuy.center = _buyBtn.center;
        [activityview release];
    }
    
    if ([_areaList count])
    {
        NSDictionary * province = [_areaList objectAtIndex:_selectedProvinceIdx];
        [_provinceBtn setTitle:[province objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
        
        NSArray * citylist = [province objectForKey:@"citylist"];
        if (![citylist count])
        {
            [self qryCity:[province objectForKey:@"Freight_Area_Code"]];
        }
        else
        {
            NSDictionary * city = [citylist objectAtIndex:_selectedCityIdx];
            if ([city objectForKey:@"Freight_Area_Name"])
            {
                [_cityBtn setTitle:[city objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
            }
        }
    }
    
    NSLog(@"salesProductInfoDict %@",self.SalesproductInfoDict);
    NSLog(@"ContractInfo %@",self.ContractInfo);
    NSLog(@"PackageInfoDict %@",self.PackageInfoDict);
    NSLog(@"OptPackageList %@", self.OptPackageList);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _greyBgView = nil;
    _contentScroll = nil;
    _provinceBtn = nil;
    _cityBtn = nil;
    [_areaPicker release], _areaPicker = nil;
    [_textfieldNaviBar release], _textfieldNaviBar = nil;
    _numTypeBtn = nil;
    _feeTypeBtn = nil;
    _searchBtn = nil;
    _numberListTable = nil;
    _footRefreshView = nil;
    [_contentScroll release], _contentScroll = nil;
    _moneyBtn100 = nil;
    _moneyBtn50 = nil;
    _totalPayFeeLab = nil;
    _bottomView = nil;
    _activityviewInfoSearch = nil;
    _activityviewInfoBuy = nil;
    _buyBtn = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = YES;
}


#pragma mark -
#pragma mark - CTPNavBarDelegate
-(void)onleftBtnAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self onNavigationBarConfirmBtn:nil];

    if (self.createContractOrderOpt) {
        [self.createContractOrderOpt cancel];
        self.createContractOrderOpt = nil;
    }
    if (self.qryProvinceOpt) {
        [self.qryProvinceOpt cancel];
        self.qryProvinceOpt = nil ;
    }
    if (self.LocationByphoneNbrInfoOpt) {
        [self.LocationByphoneNbrInfoOpt cancel];
        self.LocationByphoneNbrInfoOpt = nil;
    }
    if (self.qryCityOpt) {
        [self.qryCityOpt cancel];
        self.qryCityOpt = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark private
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
    if ([nview isKindOfClass:[UIButton class]])
    {
        [_clickView resignFirstResponder];
        [(UIButton *)nview sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else if ([nview isKindOfClass:[UITextField class]])
    {
        [self hidePickerView];
        [nview becomeFirstResponder];
    }
}

- (void)onNavigationBarNextBtn:(id)sender
{
    int tag = _clickView.tag;
    UIView * nview = [_contentScroll viewWithTag:1+tag];
    if ([nview isKindOfClass:[UIButton class]])
    {
        [_tailNumTf resignFirstResponder];
        [(UIButton *)nview sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else if ([nview isKindOfClass:[UITextField class]])
    {
        [self hidePickerView];
        [nview becomeFirstResponder];
    }
}

- (void)onNavigationBarConfirmBtn:(id)sender
{
    [self onBgBtn:nil];
}

- (void)onProvinceBtn:(id)sender
{
    if ([_clickView isKindOfClass:[UIButton class]] && _clickView != sender)
    {
        ((UIButton *)_clickView).selected = NO;
    }
    ((UIButton *)sender).selected = YES;
    _clickView = sender;
    
    [self showPickerView];
    [_areaPicker reloadAllComponents];
    [self pickerView:_areaPicker didSelectRow:_selectedProvinceIdx inComponent:0];
}

- (void)onCityBtn:(id)sender
{
    if ([_clickView isKindOfClass:[UIButton class]] && _clickView != sender)
    {
        ((UIButton *)_clickView).selected = NO;
    }
    ((UIButton *)sender).selected = YES;
    _clickView = sender;
    
    [self showPickerView];
    [_areaPicker reloadAllComponents];
    
    if (_selectedProvinceIdx < [_areaList count] && _selectedProvinceIdx >= 0)
    {
        NSDictionary * province = [_areaList objectAtIndex:_selectedProvinceIdx];
        if ([[province objectForKey:@"citylist"] count] <= _selectedCityIdx)
        {
            _selectedCityIdx = 0;
            NSDictionary * city = [[province objectForKey:@"citylist"] objectAtIndex:_selectedCityIdx];
            if ([city objectForKey:@"Freight_Area_Name"])
            {
                [_cityBtn setTitle:[city objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
            }
        }
    }
    [self pickerView:_areaPicker didSelectRow:_selectedCityIdx inComponent:0];
}

- (void)onNumbertypeBtn:(id)sender
{
    if ([_clickView isKindOfClass:[UIButton class]] && _clickView != sender)
    {
        ((UIButton *)_clickView).selected = NO;
    }
    ((UIButton *)sender).selected = YES;
    _clickView = sender;
    
    [self showPickerView];
    [_areaPicker reloadAllComponents];
    [self pickerView:_areaPicker didSelectRow:_selectedNumtypeIdx inComponent:0];
}

- (void)onFeetypeBtn:(id)sender
{
    if ([_clickView isKindOfClass:[UIButton class]] && _clickView != sender)
    {
        ((UIButton *)_clickView).selected = NO;
    }
    ((UIButton *)sender).selected = YES;
    _clickView = sender;
    
    [self showPickerView];
    [_areaPicker reloadAllComponents];
    [self pickerView:_areaPicker didSelectRow:_selectedFeetypeIdx inComponent:0];
}

- (void)onSearchBtn:(id)sender
{
    [self onBgBtn:nil];
    
    _pageNum = 1;
    _TotalCount = 0;
    _selectedRow = 1;
    [_numberList removeAllObjects];
    [_numberListTable reloadData];
    
    [self getNumberlist];
    
}

- (void) onLeftBtnAction:(id)sender {
    AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([_areaPicker isDescendantOfView:app.window])
    {
        _areaPicker.hidden = YES ;
    }
    [super onLeftBtnAction:nil];
}

- (void)showPickerView
{
    [_tailNumTf resignFirstResponder];
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
    //add by liuruxian 2014-03-04
    MyAppDelegate.tabBarController.tabbarView.userInteractionEnabled = NO;
    
    AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([_areaPicker isDescendantOfView:app.window])
    {
        [self showNavigationBar];
        return;
    }
    
    _areaPicker.frame = CGRectMake(0, CGRectGetHeight(app.window.frame), CGRectGetWidth(_areaPicker.frame), CGRectGetHeight(_areaPicker.frame));
    
    _areaPicker.backgroundColor = [UIColor whiteColor];
    [app.window addSubview:_areaPicker];
    
    [UIView animateWithDuration:0.25 animations:^{
        _areaPicker.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(_areaPicker.frame));
        
        CGRect rc = _numberListTable.frame;
        rc.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(_numberListTable.frame) - CGRectGetHeight(_areaPicker.frame) - CGRectGetHeight(_textfieldNaviBar.frame) + kBarHeight;
        _numberListTable.frame = rc;
    } completion:^(BOOL finished) {
        [self showNavigationBar];
        if (_clickView)
        {
            [_numberListTable scrollRectToVisible:CGRectInset(_clickView.frame, 0, -8) animated:YES];
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
        
        CGRect rc = _numberListTable.frame;
        rc.size.height = CGRectGetMinY(_bottomView.frame) - CGRectGetMinY(_numberListTable.frame);
        _numberListTable.frame = rc;
        if ([_clickView isKindOfClass:[UIButton class]])
        {
            ((UIButton *)_clickView).selected = NO;
        }
        _clickView = nil;
        [self hideNavigationBar];
    } completion:^(BOOL finished) {
        [_areaPicker removeFromSuperview];
    }];
}

- (void)showNavigationBar
{
    if (![_textfieldNaviBar isDescendantOfView:self.view])
    {
        [self.view addSubview:_textfieldNaviBar];
        _textfieldNaviBar.frame = CGRectMake(0, CGRectGetMaxY(_numberListTable.frame), CGRectGetWidth(_textfieldNaviBar.frame), CGRectGetHeight(_textfieldNaviBar.frame));
    }
}

- (void)hideNavigationBar
{
    if ([_textfieldNaviBar isDescendantOfView:self.view])
    {
        [_textfieldNaviBar removeFromSuperview];
    }
}

//  网络 查询省份
- (void)qryProvince
{
    if (self.qryProvinceOpt) {
        [self.qryProvinceOpt cancel];
        self.qryProvinceOpt = nil;
    }
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"1", @"Type",   // 用组织机构
                               @"", @"ProvinceCode",
                               @"", @"CityCode",
                               nil];
    __block typeof (self)weakSelf = self;
    __block typeof (_areaPicker)pick = _areaPicker;
    self.qryProvinceOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrganization"
                                                                  params:params
                                 onSucceeded:^(NSDictionary *dict) {
                                     DDLogInfo(@"%s--%@", __func__, dict.description);
                                     id Data = [dict objectForKey:@"Data"];
                                     
                                     id Items = [Data objectForKey:@"Items"];
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
                                     [weakSelf.areaList release], weakSelf.areaList = nil;
                                     weakSelf.areaList = [[NSMutableArray alloc] initWithArray:arr];
                                     
                                     [weakSelf saveCacheArea];
                                     [pick reloadComponent:0];
                                     
                                     if ([weakSelf.areaList count])
                                     {
                                         weakSelf.selectedProvinceIdx = 0;
                                         [weakSelf.provinceBtn setTitle:[[weakSelf.areaList objectAtIndex:0] objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
                                         
                                         weakSelf.selectedCityIdx = 0;
                                         [weakSelf qryCity:[[weakSelf.areaList objectAtIndex:0] objectForKey:@"Freight_Area_Code"]];
                                         [weakSelf.cityBtn setTitle:@"" forState:UIControlStateNormal];
                                     }
                                     //设置首显的城市省会
                                     [weakSelf setNumAttrFirst];
                                     
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
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    __block typeof (self)weakSelf = self;
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"1", @"Type",   // 用组织机构
                               province, @"ProvinceCode",
                               @"", @"CityCode",
                               nil];
    
    self.qryCityOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrganization"
                                                             params:params
                            onSucceeded:^(NSDictionary *dict) {
                                DDLogInfo(@"%s--%@", __func__, dict.description);
                                
                                id Data = [dict objectForKey:@"Data"];
                                id Items = [Data objectForKey:@"Items"];
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
                                
                                for (NSDictionary * dict in weakSelf.areaList)
                                {
                                    NSString * Freight_Area_Code = [dict objectForKey:@"Freight_Area_Code"];
                                    if ([Freight_Area_Code isEqualToString:province])
                                    {
                                        NSMutableDictionary * mutaDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                                        [mutaDict setObject:arr forKey:@"citylist"];
                                        [weakSelf.areaList replaceObjectAtIndex:[weakSelf.areaList indexOfObject:dict] withObject:mutaDict];
                                        [weakSelf saveCacheArea];
                                        
                                        if ([[[weakSelf.areaList objectAtIndex:weakSelf.selectedProvinceIdx] objectForKey:@"Freight_Area_Code"] isEqualToString:Freight_Area_Code])
                                        {
                                            weakSelf.selectedCityIdx = 0;
                                            NSDictionary * city = [arr objectAtIndex:weakSelf.selectedCityIdx];
                                            if ([city objectForKey:@"Freight_Area_Name"])
                                            {
                                                [weakSelf.cityBtn setTitle:[city objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
                                            }
                                        }
                                        
                                        break;
                                    }
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

- (void)loadCacheArea
{
    [_areaList release], _areaList = nil;
    NSString * path = [[self getDocumentFolderByName:nil] stringByAppendingPathComponent:CTP_SAVE_AREA_ORG_CODE_LIST];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileMgr fileExistsAtPath:path isDirectory:&isDir])
    {
        _areaList = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
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

- (void)saveCacheArea
{
    // 缓存到本地
    NSString * path = [[self getDocumentFolderByName:nil] stringByAppendingPathComponent:CTP_SAVE_AREA_ORG_CODE_LIST];
    BOOL ret = [_areaList writeToFile:path atomically:YES];
    NSLog(@"save area %d", ret);
}

- (void)getNumberlist
{
    if (self.bIsprettyNumber) // 天翼靚号 和 号码选择
    {
        [self prettyNumberInfo];
    }
    else
    {
        [self qryPhoneNumberCard];
    }
}

//天翼靚号
- (void)prettyNumberInfo
{
    
    if (self.qryPrettyNumberInfoOpt) {
        [self.qryPrettyNumberInfoOpt cancel];
        self.qryPrettyNumberInfoOpt = nil ;
    }

    NSString * PageIndex    = [NSString stringWithFormat:@"%d", _pageNum];
    NSString * PageSize     = [NSString stringWithFormat:@"%d", _PageSize];
    NSString * ProvinceCode = @"";
    NSString * AreaCode     = @"";
    NSString * Contnumber   = [_tailNumTf.text length] ? _tailNumTf.text : @"";
    NSString * Minpay       = @"";
    NSString * Maxpay       = @"";
    NSString * Prettypattern= _selectedNumtypeIdx ? [NSString stringWithFormat:@"%d",  _selectedNumtypeIdx] : @"";  // 靓号类型（AAAA --1    AAA --2     ABCD --3     AABB --4       ABC--5       AA--6  ）
    
    if (_selectedFeetypeIdx > 0 && _selectedFeetypeIdx < [_feeTypeArr count] - 1)
    {
        NSString * feetypeStr = [_feeTypeArr objectAtIndex:_selectedFeetypeIdx];
        NSArray * feetypes = [feetypeStr componentsSeparatedByString:@"-"];
        if ([feetypes count] == 2)
        {
            Minpay = [feetypes objectAtIndex:0];
            Maxpay = [feetypes objectAtIndex:1];
        }
    }
    else if (_selectedFeetypeIdx == [_feeTypeArr count] - 1)
    {
        Minpay = @"5000";
    }
    
    if ([_provinceBtn.currentTitle length] <= 0)
    {
        ToastAlertView * alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲，别忘记选择省份"];
        [alert release];
        [_provinceBtn bounceStart];
        return;
    }
    
    if ([_cityBtn.currentTitle length] <= 0)
    {
        ToastAlertView * alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲，别忘记选择城市"];
        [alert release];
        [_cityBtn bounceStart];
        return;
    }
    
    {
        int selprovince = _selectedProvinceIdx;
        int selcity = _selectedCityIdx;
        
        NSDictionary * provincedict = [_areaList objectAtIndex:selprovince];
        if ([provincedict objectForKey:@"Freight_Area_Code"])
        {
            ProvinceCode = [provincedict objectForKey:@"Freight_Area_Code"];
        }
        
        NSArray * citylist = [provincedict objectForKey:@"citylist"];
        if (selcity >= 0 && selcity < [citylist count])
        {
            NSDictionary * citydict = [citylist objectAtIndex:selcity];
            if ([citydict objectForKey:@"Freight_Area_Code"])
            {
                AreaCode = [citydict objectForKey:@"Freight_Area_Code"];
            }
        }
    }
    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               PageIndex, @"PageIndex",
                               PageSize, @"PageSize",
                               /*ESHORE_ShopId*/@"10009", @"ShopId",
                               @"" , @"HeadNumber",
                               ProvinceCode/*@"600404"*/, @"ProvinceCode",
                               /*AreaCode*/@"", @"AreaCode",
                               @"1", @"Sortby",
                               Contnumber, @"Contnumber",
                               @"", @"Level",
                               Minpay, @"Minpay",
                               Maxpay, @"Maxpay",
                               Prettypattern, @"Prettypattern",
                               nil];
    
    //异步调用
    [_activityviewInfoSearch startAnimating]; //转圈开始
    _isLoading = YES;
    _searchBtn.enabled = NO;
    _buyBtn.userInteractionEnabled = NO;
    _numberListTable.userInteractionEnabled = NO;
    
    self.qryPrettyNumberInfoOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"prettyNumberInfo"
                                                                         params:params
                                        onSucceeded:^(NSDictionary *dict) {
                                            DDLogInfo(@"%s--%@", __func__, dict.description);
//                                            id Data = [dict objectForKey:@"Data"];
                                            
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

//查询号码
- (void)qryPhoneNumberCard
{
    
    NSString * code         = @"qryPhoneNumberInfo";  //  qryPhoneNumberCard
    NSString * PageIndex    = [NSString stringWithFormat:@"%d", _pageNum];
    NSString * PageSize     = [NSString stringWithFormat:@"%d", _PageSize];
    NSString * ProvinceCode = @"";
    NSString * AreaCode     = @"";
    NSString * Contnumber   = [_tailNumTf.text length] ? _tailNumTf.text : @"";
    NSString * Minpay       = @"";
    NSString * Maxpay       = @"";
    NSString * Prettypattern= _selectedNumtypeIdx ? [NSString stringWithFormat:@"%d",  _selectedNumtypeIdx] : @"";  // 靓号类型（AAAA --1    AAA --2     ABCD --3     AABB --4       ABC--5       AA--6  ）
    NSString * aSalesproductId = [self.SalesproductInfoDict objectForKey:@"SalesProdId"] ? [self.SalesproductInfoDict objectForKey:@"SalesProdId"] : @"";
    
    if (_selectedFeetypeIdx > 0 && _selectedFeetypeIdx < [_feeTypeArr count] - 1)
    {
        NSString * feetypeStr = [_feeTypeArr objectAtIndex:_selectedFeetypeIdx];
        NSArray * feetypes = [feetypeStr componentsSeparatedByString:@"-"];
        if ([feetypes count] == 2)
        {
            Minpay = [feetypes objectAtIndex:0];
            Maxpay = [feetypes objectAtIndex:1];
        }
    }
    else if (_selectedFeetypeIdx == [_feeTypeArr count] - 1)
    {
        Minpay = @"5000";
    }
    
    if ([_provinceBtn.currentTitle length] <= 0)
    {
        ToastAlertView * alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲，别忘记选择省份"];
        [alert release];
        [_provinceBtn bounceStart];
        return;
    }
    
    if ([_cityBtn.currentTitle length] <= 0)
    {
        ToastAlertView * alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲，别忘记选择城市"];
        [alert release];
        [_cityBtn bounceStart];
        return;
    }
    
    {
        int selprovince = _selectedProvinceIdx;
        int selcity = _selectedCityIdx;
        
        NSDictionary * provincedict = [_areaList objectAtIndex:selprovince];
        if ([provincedict objectForKey:@"Freight_Area_Code"])
        {
            ProvinceCode = [provincedict objectForKey:@"Freight_Area_Code"];
        }
        
        NSArray * citylist = [provincedict objectForKey:@"citylist"];
        if (selcity >= 0 && selcity < [citylist count])
        {
            NSDictionary * citydict = [citylist objectAtIndex:selcity];
            if ([citydict objectForKey:@"Freight_Area_Code"])
            {
                AreaCode = [citydict objectForKey:@"Freight_Area_Code"];
            }
        }
    }
    
    if (self.qryPhoneNumberCardOpt) {
        [self.qryPhoneNumberCardOpt cancel];
        self.qryPhoneNumberCardOpt = nil;
    }
    
    // add by liuruxian
    NSString *ComboId = @"";
    if (self.PackageInfoDict && self.PackageInfoDict.count > 0) {
        ComboId = [self.PackageInfoDict objectForKey:@"ComboId"];
    }
    
    NSString *ContractsId = @"";
    if (self.ContractInfo) {
        ContractsId = self.ContractInfo[@"ContractsId"];
    }
    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               PageIndex, @"PageIndex",
                               PageSize, @"PageSize",
                               @"20002" /*@"ESHORE_ShopId"*/, @"ShopId",
                               @"" , @"Headnumber",
                               ProvinceCode/*@"609910"*/, @"ProvinceCode",
                               AreaCode/*@"8230200"*/, @"AreaCode",
                               @"", @"Sortby" ,
                               Contnumber, @"ContNumber",
                               Minpay, @"MinPay",
                               Maxpay, @"MaxPay",
                               Prettypattern, @"PrettyPattern",
                               aSalesproductId, @"SalesproductId",
                               ContractsId , @"ContractId",
                               ComboId , @"ComboId",

                               nil];

    _isLoading = YES;
    _searchBtn.enabled = NO;
    _buyBtn.userInteractionEnabled = NO;
    [_activityviewInfoSearch startAnimating];
    _numberListTable.userInteractionEnabled = NO;

    //add by liuruxian 2014-03-01
    __block CTPNumberPickerVCtler *weakSelf = self;
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:code
                                                                         params:params
                                    onSucceeded:^(NSDictionary *dict) {
                                        DDLogInfo(@"%s--%@", __func__, dict.description);
                                        
                                        weakSelf.searchBtn.enabled = YES;
                                        weakSelf.buyBtn.userInteractionEnabled = YES;
                                        [weakSelf.activityviewInfoSearch stopAnimating];
                                        weakSelf.numberListTable.userInteractionEnabled = YES;
                                        weakSelf.isLoading = NO;
                                        
                                        id Data = [dict objectForKey:@"Data"];
                                        id Items = [Data objectForKey:@"Items"];
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

                                        if (!weakSelf.numberList)
                                        {
                                            weakSelf.numberList = [NSMutableArray new];
                                        }
                                        [weakSelf.numberList addObjectsFromArray:arr];
                                        [weakSelf.numberListTable reloadData];
                                        weakSelf.TotalCount = [[Data objectForKey:@"TotalCount"] intValue];
                                        
                                        weakSelf.footRefreshView.curPage   = weakSelf.pageNum;
                                        weakSelf.footRefreshView.totalPage = weakSelf.TotalCount/weakSelf.PageSize + ((weakSelf.TotalCount%weakSelf.PageSize > 0) ? 1 : 0);
                                        [weakSelf.footRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:weakSelf.numberListTable];
                                        
                                        if ([weakSelf.numberList count] && weakSelf.pageNum*weakSelf.PageSize < weakSelf.TotalCount && [arr count] == 10)
                                        {
                                            int height = weakSelf.numberListTable.contentSize.height;
                                            CGRect frame = weakSelf.footRefreshView.frame;
                                            frame.origin.y = height;
                                            weakSelf.footRefreshView.frame = frame;
                                            weakSelf.footRefreshView.hidden = NO;
                                        }
                                        else
                                        {
                                            weakSelf.footRefreshView.hidden = YES;
                                        }
                                        
                                        if ([weakSelf.numberList count] <= 0)
                                        {
                                            NSString * tipmsg = @"有眼光，您选的号遭到疯抢，重新选个号吧";
                                            ToastAlertView * alert = [ToastAlertView new];
                                            [alert showAlertMsg:tipmsg];
                                            [alert release];
                                        }
                                        
                                        [SVProgressHUD dismiss];
                                    } onError:^(NSError *engineError) {
                                        DDLogInfo(@"%s--%@", __func__, engineError);
                                        
                                        weakSelf.searchBtn.enabled = YES;
                                        weakSelf.buyBtn.userInteractionEnabled = YES;
                                        [weakSelf.activityviewInfoSearch stopAnimating];
                                        weakSelf.numberListTable.userInteractionEnabled = YES;
                                        weakSelf.isLoading = NO;
                                        
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

- (void)onRefreshBtn:(id)sender
{
    [self onSearchBtn:nil];
}

- (void)onScrollTopBtn:(id)sender
{
    [_numberListTable setContentOffset:CGPointZero animated:YES];
}

- (void)onMoneyBtn:(id)sender
{
    if (sender == _moneyBtn100)
    {
        _moneyBtn100.selected = YES;
        _moneyBtn50.selected = NO;
    }
    else if (sender == _moneyBtn50)
    {
        _moneyBtn100.selected = NO;
        _moneyBtn50.selected = YES;
    }
    
    _totalPayFeeLab.text = [NSString stringWithFormat:@"%d元", [self getTotalFee]];
}

- (void)onNextstepBtn:(id)sender
{
    [self createContractOrder];
}

- (NSDictionary *)getSelectedPhone
{
    int idx = _selectedRow - 1;
    if (idx >= 0 && idx < [_numberList count] && [_numberList count])
    {
        return [_numberList objectAtIndex:idx];
    }
    return nil;
}

- (int)getTotalFee
{
    int money = 0;
    if (_moneyBtn100.selected)
    {
        money = 100;
    }
    else if (_moneyBtn50.selected)
    {
        money = 50;
    }
    
    if (_selectedRow >= 0 && _selectedRow < [_numberList count])
    {
        NSDictionary * dict     = [_numberList objectAtIndex:_selectedRow];
        if ([dict objectForKey:@"PrepayMent"] && [[dict objectForKey:@"PrepayMent"] respondsToSelector:@selector(intValue)])
        {
            money += [[dict objectForKey:@"PrepayMent"] intValue];
        }
    }
    
    return money;
}


- (void) qryUserId
{
    //请求用户id
    NSDictionary *loginDict = [Global sharedInstance].loginInfoDict;
    NSString *Account = [loginDict objectForKey:@"UserLoginName"] ? [loginDict objectForKey:@"UserLoginName"] : @"";
    
    NSDictionary *params1 = [NSDictionary dictionaryWithObjectsAndKeys:
                             Account, @"Account",
                             @"201", @"AccountType",
                             ESHORE_ShopId, @"ShopId", nil];
    
    
    __block CTPNumberPickerVCtler *weakSelf = self;
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"custIdInfo"
                                           params:params1
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          //获取用户id
                                          id Data = [dict objectForKey:@"Data"];
                                          if (Data && [Data respondsToSelector:@selector(objectForKey:)]) {
                                              weakSelf.userId = [Data objectForKey:@"UserId"];
                                              [Global sharedInstance].custInfoDict = dict[@"Data"];
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

- (void)createContractOrder
{
    NSDictionary * phonedict = [self getSelectedPhone];
    if (!phonedict)
    {
        ToastAlertView * alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲，还没有选择手机号码哦"];
        [alert release];
        return;
    }
    
    /*
     现金预存包ID
     该字段内容为空字符串时，代表没有现金预存包。
     135010051 ：50元预存包
     135010052 ：100元预存包
     135010324 ：200元预存包
     */
    NSString * CashSalesProdId = @"";
    if (_moneyBtn100.selected)
    {
        CashSalesProdId = @"135010052";
    }
    else if (_moneyBtn50.selected)
    {
        CashSalesProdId = @"135010051";
    }
    
    if (self.createContractOrderOpt) {
        [self.createContractOrderOpt cancel];
        self.createContractOrderOpt = nil;
    }
    
    NSString * code         = @"createContractOrder";
    NSString * aSalesproductId = [self.SalesproductInfoDict objectForKey:@"SalesProdId"] ? [self.SalesproductInfoDict objectForKey:@"SalesProdId"] : @"";

    NSString * UserId       = @"";

    if (self.userId && self.userId.length > 0) {
        UserId = self.userId ;
    }else {

    }
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString * PhoneNumber  = [phonedict objectForKey:@"PhoneNumber"] ? [phonedict objectForKey:@"PhoneNumber"] : @"";
    NSString * ComboId      = [self.PackageInfoDict objectForKey:@"ComboId"] ? [self.PackageInfoDict objectForKey:@"ComboId"] : @"";
    NSString * OptSalesProdId = [self.PackageInfoDict objectForKey:@"SelectPackageId"] ? [self.PackageInfoDict objectForKey:@"SelectPackageId"] : @"";
    NSString * ContractId   = [self.ContractInfo objectForKey:@"ContractsId"] ? [self.ContractInfo objectForKey:@"ContractsId"] : @"";
    
    __block NSMutableArray * OptProdId = [NSMutableArray array];
    [self.OptPackageList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            [OptProdId addObject:[NSDictionary dictionaryWithObject:[obj objectForKey:@"Id"] forKey:@"Id"]];
        }
    }];

    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               ESHORE_ShopId, @"ShopId",
                               @"0", @"GpFlag",
                               UserId, @"UserId",
                               @"true", @"NewPhoneNumber",
                               PhoneNumber, @"PhoneNumber",
                               ComboId, @"ComboId",
                               OptSalesProdId, @"OptSalesProdId",
                               CashSalesProdId, @"CashSalesProdId",
                               ContractId/*@"00000000D062F6A62E3C11C8E043AE1410AC142A"*/, @"ContractId",
                               aSalesproductId, @"SalesProdId",
                               OptProdId, @"OptProdId",
                               nil];
    
    _buyBtn.enabled = NO;
    [_activityviewInfoBuy startAnimating];
    _numberListTable.userInteractionEnabled = NO;
    _bottomView.userInteractionEnabled = NO;
    __block CTPNumberPickerVCtler *weakSelf = self;
    [MyAppDelegate.cserviceEngine postXMLWithCode:code
                                                                             params:params
                                    onSucceeded:^(NSDictionary *dict) {
                                        DDLogInfo(@"%s--%@", __func__, dict.description);
                                        if (dict && [dict respondsToSelector:@selector(objectForKey:)]) {
                                            id Data = [dict objectForKey:@"Data"];
                                            
                                            weakSelf.buyBtn.enabled = YES;
                                            [weakSelf.activityviewInfoBuy stopAnimating];
                                            weakSelf.numberListTable.userInteractionEnabled = YES;
                                            weakSelf.bottomView.userInteractionEnabled = YES;
                                            
                                            //订单创建成功
                                            CTPProtocolFillVCtler * vctler  = [CTPProtocolFillVCtler new];
                                            vctler.SalesproductInfoDict     = weakSelf.SalesproductInfoDict;
                                            vctler.PackageInfoDict          = weakSelf.PackageInfoDict;
                                            vctler.ContractInfo             = weakSelf.ContractInfo;
                                            vctler.NumberInfo               = [weakSelf getSelectedPhone];
                                            vctler.orderInfoDict            = Data;
                                            [weakSelf.navigationController pushViewController:vctler animated:YES];
                                            [vctler release];
                                        }
                                        [SVProgressHUD dismiss];
                                    } onError:^(NSError *engineError) {
                                        DDLogInfo(@"%s--%@", __func__, engineError);
                                        
                                        weakSelf.buyBtn.enabled = NO;
                                        [weakSelf.activityviewInfoBuy stopAnimating];
                                        weakSelf.numberListTable.userInteractionEnabled = NO;
                                        weakSelf.bottomView.userInteractionEnabled = NO;
                                        
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

- (void)getLocationByphoneNbrInfo
{
    NSDictionary *loginDict = [Global sharedInstance].loginInfoDict;
    NSString *PhoneNbr = [loginDict objectForKey:@"UserLoginName"] ? [loginDict objectForKey:@"UserLoginName"] : @"";
    
    NSString * code         = @"getLocationByphoneNbrInfo";

    if ([PhoneNbr length] <= 0)
    {
        return;
    }
    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               PhoneNbr, @"PhoneNbr",
                               nil];
    
    if (self.LocationByphoneNbrInfoOpt) {
        [self.LocationByphoneNbrInfoOpt cancel];
        self.LocationByphoneNbrInfoOpt = nil;
    }
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    __block CTPNumberPickerVCtler *weakSelf = self ;
    [MyAppDelegate.cserviceEngine postXMLWithCode:code
                                                                           params:params
                                          onSucceeded:^(NSDictionary *dict) {
                                              DDLogInfo(@"%s--%@", __func__, dict.description);
                                              id Data = [dict objectForKey:@"Data"];
                                              weakSelf.areaInfodict = Data;
                                              [weakSelf setNumAttrFirst];
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

- (void)setNumAttrFirst
{
    if (!self.areaInfodict || _hasSetNumAttr || ![_areaList count])
    {
        return;
    }
    
    NSString * ProvinceCode = [self.areaInfodict objectForKey:@"ProvinceCode"];
    NSString * CityCode = [self.areaInfodict objectForKey:@"CityCode"];
    [_areaList enumerateObjectsUsingBlock:^(id provinceobj, NSUInteger proviceidx, BOOL *provicestop) {
        // province
        NSString * tmpprovincecode = [provinceobj objectForKey:@"Freight_Area_Code"];
        if ([tmpprovincecode isEqualToString:ProvinceCode])
        {
            // city
            NSArray * citylist = [provinceobj objectForKey:@"citylist"];
            [citylist enumerateObjectsUsingBlock:^(id cityobj, NSUInteger cityidx, BOOL *citystop) {
                NSString * tmpcitycode = [cityobj objectForKey:@"Freight_Area_Code"];
                if ([tmpcitycode isEqualToString:CityCode])
                {
                    _hasSetNumAttr = YES;
                    *citystop = YES;
                    NSMutableArray * tmpcityArr = [NSMutableArray arrayWithArray:citylist];
                    if (cityidx != 0)
                    {
                        NSDictionary * tmpcityobj = [tmpcityArr objectAtIndex:cityidx];
                        [tmpcityArr removeObjectAtIndex:cityidx];
                        [tmpcityArr insertObject:tmpcityobj atIndex:0];
                        
                        NSMutableDictionary * tmpProvinceObj = [NSMutableDictionary dictionaryWithDictionary:provinceobj];
                        [tmpProvinceObj setObject:tmpcityArr forKey:@"citylist"];
                        [_areaList replaceObjectAtIndex:proviceidx withObject:tmpProvinceObj];
                        [self saveCacheArea];
                        
                        _selectedCityIdx = 0;
                        NSDictionary * city = [tmpcityArr objectAtIndex:_selectedCityIdx];
                        if ([city objectForKey:@"Freight_Area_Name"])
                        {
                            [_cityBtn setTitle:[city objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
                        }
                    }
                }
            }];
            
            *provicestop = YES;
            if (proviceidx != 0)
            {
                NSMutableArray * tmpprovinceArr = [NSMutableArray new];
                [tmpprovinceArr addObjectsFromArray:_areaList];
                NSDictionary * tmpprovinceobj = [tmpprovinceArr objectAtIndex:proviceidx];
                [tmpprovinceArr removeObjectAtIndex:proviceidx];
                [tmpprovinceArr insertObject:tmpprovinceobj atIndex:0];
                
                [_areaList release];
                _areaList = tmpprovinceArr;
                [self saveCacheArea];
                
                [_areaPicker reloadComponent:0];
                if ([_areaList count])
                {
                    _selectedProvinceIdx = 0;
                    [_provinceBtn setTitle:[[_areaList objectAtIndex:0] objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
                    
                    _selectedCityIdx = 0;
                    if ([citylist count])
                    {
                        NSDictionary * city = [citylist objectAtIndex:_selectedCityIdx];
                        if ([city objectForKey:@"Freight_Area_Name"])
                        {
                            [_cityBtn setTitle:[city objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
                        }
                    }
                    else
                    {
                        [self qryCity:[[_areaList objectAtIndex:0] objectForKey:@"Freight_Area_Code"]];
                        [_cityBtn setTitle:@"" forState:UIControlStateNormal];
                    }
                }
            }
        }
    }];
}

#pragma mark notification
- (void)onNotificationLogin4Number:(NSNotification *)sender
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0)
    {
        if (self.modalViewController)
        {
            [self.modalViewController dismissModalViewControllerAnimated:YES];
        }
    }
    else
    {
        if (self.presentedViewController)
        {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    [self getNumberlist];
}

- (void)onNotificationLogin4CreateOrder:(NSNotification *)sender
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0)
    {
        if (self.modalViewController)
        {
            [self.modalViewController dismissModalViewControllerAnimated:YES];
        }
    }
    else
    {
        if (self.presentedViewController)
        {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    [self onNextstepBtn:nil];
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int cnt = 0;
    if (_clickView == _provinceBtn)
    {
        cnt = [_areaList count];
    }
    else if (_clickView == _cityBtn)
    {
        if (_selectedProvinceIdx < [_areaList count] && _selectedProvinceIdx >= 0)
        {
            NSDictionary * province = [_areaList objectAtIndex:_selectedProvinceIdx];
            cnt = [[province objectForKey:@"citylist"] count];
        }
    }
    else if (_clickView == _numTypeBtn)
    {
        // 靓号类型（AAAA --1    AAA --2     ABCD --3     AABB --4       ABC--5       AA--6  ）
        cnt = [_numTypeArr count];
    }
    else if (_clickView == _feeTypeBtn)
    {
        // 不限 1-499 500-1000 1000-1500 1500-2000 2000-3000 3000-4000 4000-5000 5000以上
        cnt = [_feeTypeArr count];
    }

    if (iPhone5 && cnt == 0)
    {
        cnt = 1;
    }
    return cnt;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_clickView == _provinceBtn)
    {
        if (row >= 0 && row < [_areaList count])
        {
            NSDictionary * province = [_areaList objectAtIndex:row];
            return [province objectForKey:@"Freight_Area_Name"];
        }
    }
    else if (_clickView == _cityBtn)
    {
        if (_selectedProvinceIdx < [_areaList count] && _selectedProvinceIdx >= 0)
        {
            NSDictionary * province = [_areaList objectAtIndex:_selectedProvinceIdx];
            NSArray * citylist = [province objectForKey:@"citylist"];
            if ([citylist isKindOfClass:[NSArray class]] && row >= 0 && row < [citylist count])
            {
                NSDictionary * city = [citylist objectAtIndex:row];
                return [city objectForKey:@"Freight_Area_Name"];
            }
        }
    }
    else if (_clickView == _numTypeBtn)
    {
        // 靓号类型（AAAA --1    AAA --2     ABCD --3     AABB --4       ABC--5       AA--6  ）
        return [_numTypeArr objectAtIndex:row];
    }
    else if (_clickView == _feeTypeBtn)
    {
        // 不限 1-499 500-1000 1000-1500 1500-2000 2000-3000 3000-4000 4000-5000 5000以上
        return [_feeTypeArr objectAtIndex:row];
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView reloadAllComponents];
    
    if (_clickView == _provinceBtn)  //点击省份
    {
        _selectedProvinceIdx = row;
        if (row < [_areaList count] && row >= 0)
        {
            NSDictionary * province = [_areaList objectAtIndex:row];
            NSArray * citylist = [province objectForKey:@"citylist"];
            if (![citylist count])
            {
                [self qryCity:[province objectForKey:@"Freight_Area_Code"]]; //假如当前数据不存在 则请求数据
                _selectedCityIdx = 0;
                [_cityBtn setTitle:@"" forState:UIControlStateNormal];
            }
            else
            {
                if (_selectedCityIdx >= [citylist count] ||
                    _selectedCityIdx < 0)
                {
                    _selectedCityIdx = 0;
                }
                [_cityBtn setTitle:[[citylist objectAtIndex:_selectedCityIdx] objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
            }
            
            if ([province objectForKey:@"Freight_Area_Name"])
            {
                [_provinceBtn setTitle:[province objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
            }
        }
    }
    else if (_clickView == _cityBtn) //点击
    {
        _selectedCityIdx = row;
        if (_selectedProvinceIdx < [_areaList count] && _selectedProvinceIdx >= 0)
        {
            NSDictionary * province = [_areaList objectAtIndex:_selectedProvinceIdx];
            NSArray * citylist = [province objectForKey:@"citylist"];
            if ([citylist isKindOfClass:[NSArray class]] && row >= 0 && row < [citylist count])
            {
                NSDictionary * city = [citylist objectAtIndex:row];
                if ([city objectForKey:@"Freight_Area_Name"])
                {
                    [_cityBtn setTitle:[city objectForKey:@"Freight_Area_Name"] forState:UIControlStateNormal];
                }
            }
        }
    }
    else if (_clickView == _numTypeBtn)
    {
        // 靓号类型（AAAA --1    AAA --2     ABCD --3     AABB --4       ABC--5       AA--6  ）
        _selectedNumtypeIdx = row;
        [_numTypeBtn setTitle:[_numTypeArr objectAtIndex:row] forState:UIControlStateNormal];
    }
    else if (_clickView == _feeTypeBtn)
    {
        // 不限 1-499 500-1000 1000-1500 1500-2000 2000-3000 3000-4000 4000-5000 5000以上
        _selectedFeetypeIdx = row;
        [_feeTypeBtn setTitle:[_feeTypeArr objectAtIndex:row] forState:UIControlStateNormal];
    }
}

#pragma mark UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([_clickView isKindOfClass:[UIButton class]])
    {
        ((UIButton *)_clickView).selected = NO;
        [self hidePickerView];
    }
    _clickView = textField;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
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
    if (textField == _tailNumTf)
    {
        return ([string length] <= 0 || [textField.text length] < 4);
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
        
        {
            CGRect rc = _numberListTable.frame;
            rc.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(_numberListTable.frame) - keyboadHeight +kBarHeight ;
            _numberListTable.frame = rc;
        }

        if (_clickView)
        {
            [_numberListTable scrollRectToVisible:CGRectInset(_clickView.frame, 0, -8) animated:YES];
        }
    } completion:^(BOOL finished) {
        [self showNavigationBar];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect rc = _numberListTable.frame;
    rc.size.height = CGRectGetMinY(_bottomView.frame) - CGRectGetMinY(_numberListTable.frame);
    _numberListTable.frame = rc;
    
    if (_clickView)
    {
        [_numberListTable scrollRectToVisible:_clickView.frame animated:YES];
    }
    [self hideNavigationBar];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int cnt = [_numberList count] + 1;
    UIButton * btn = (UIButton *)[tableView viewWithTag:1];
    if (!btn)
    {
        btn         = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag     = 1;
        btn.frame   = tableView.bounds;
        [btn setTitle:@"对不起，暂时无法查询到符合搜索条件的号码，点击重试" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:157/255. green:157/255. blue:157/255. alpha:1] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        [btn addTarget:self action:@selector(onRefreshBtn:) forControlEvents:UIControlEventTouchUpInside];
        [tableView addSubview:btn];
    }
    btn.hidden      = cnt;
    return cnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        static NSString * idstr = @"number header cell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:idstr];
        if (!cell)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idstr] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UIView class]])
            {
                [obj removeFromSuperview];
            }
        }];
        [cell.contentView addSubview:_contentScroll];
        cell.frame = _contentScroll.frame;
        
        return cell;
    }
    
    static NSString * idstr = @"number list cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:idstr];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idstr] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        int originY = 5;
        int originX = 10;
        {
            UIButton * checkbtn     = [UIButton buttonWithType:UIButtonTypeCustom];
            [checkbtn setBackgroundImage:[UIImage imageNamed:@"Recharge_input3.png"] forState:UIControlStateNormal];
            [checkbtn setBackgroundImage:[UIImage imageNamed:@"Recharge_input4.png"] forState:UIControlStateSelected];
            checkbtn.frame          = CGRectMake(originX, originY, 22, 22);
            checkbtn.tag            = 1;
            [cell.contentView addSubview:checkbtn];
            originX                 = CGRectGetMaxX(checkbtn.frame) + 10;
        }
        {
            // 号码
            UILabel * numlab        = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(tableView.frame) - originX - 10, 22)];
            numlab.tag              = 2;
            numlab.backgroundColor  = [UIColor clearColor];
            numlab.font             = [UIFont systemFontOfSize:14];
            numlab.textColor        = [UIColor colorWithRed:36/255. green:36/255. blue:36/255. alpha:1];
            numlab.textAlignment    = UITextAlignmentLeft;
            [cell.contentView addSubview:numlab];
            originY                 = CGRectGetMaxY(numlab.frame);
            [numlab release];
        }
    }
    UIButton * checkbtn     = (UIButton *)[cell.contentView viewWithTag:1];
    UILabel * numlab        = (UILabel *)[cell.contentView viewWithTag:2];
    
    checkbtn.selected       = (_selectedRow == [indexPath row]) ? YES : NO;
    numlab.text             = @"";
    
    NSDictionary * dict     = [_numberList objectAtIndex:[indexPath row] - 1];
    NSString * PhoneNumber  = [dict objectForKey:@"PhoneNumber"] ? [dict objectForKey:@"PhoneNumber"] : @"";
    NSString * PrepayMent   = [dict objectForKey:@"PrepayMent"] ? [dict objectForKey:@"PrepayMent"] : @"";
    numlab.text             = [NSString stringWithFormat:@"%@      预存话费: %@", PhoneNumber, PrepayMent];
    
    cell.frame              = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetMaxY(numlab.frame) + CGRectGetMinY(numlab.frame));
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectGetHeight([self tableView:tableView cellForRowAtIndexPath:indexPath].frame);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedRow = indexPath.row;
    [tableView reloadData];

    _totalPayFeeLab.text = [NSString stringWithFormat:@"%d元", [self getTotalFee]];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height)
	{
        if (scrollView == _numberListTable)
        {
            [_footRefreshView egoRefreshScrollViewDidScroll:scrollView];
        }
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height)
	{
        if (scrollView == _numberListTable)
        {
            [_footRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
        }
	}
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

//// 开始load数据
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	// 获取下一页
    if (view == _footRefreshView)
    {
        _pageNum++;
        [self getNumberlist];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    if (view == _footRefreshView)
    {
        return _isLoading;
    }
	return NO;
}

@end
