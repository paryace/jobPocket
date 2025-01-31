//
//  CTPrettyNumberVCtler.m
//  CTPocketV4
//
//  Created by liuruxian on 14-1-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTPrettyNumberVCtler.h"
#import "UIView+RoundRect.h"
#import "CTPrettyNumViewCell.h"
#import "CTTopPrettyNumVCtler.h"
#import "CTLovingPrettyNumVCtler.h"
#import "CTFreeNumVCtler.h"
#import "CTBussinessPrettyNumVCtler.h"
#import <QuartzCore/QuartzCore.h>
#import "CTQryCollected.h"
#import "ToastAlertView.h"
#import "CTCollectedPrettyNumVCtler.h"
#import "CTCitySelectedVCtler.h"
#import "CTPlanSelectVCtler.h"
#import "AppDelegate.h"
#import "CTHelperMap.h"
#import "CTShakeNumberVCtler.h"
#import "SVProgressHUD.h"
#import "SIAlertView.h"
#import "CTPackageSelectVCtler.h"
#import "CTAddPackageVCtler.h"
#import "UIImageView+mask.h"

#import "Utils.h"  //added by huangfq 2014-6-6

#define kSelectedButtonTag 1000

@interface CTPrettyNumberVCtler ()

@property (nonatomic, strong) UIView *cityView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *selectedView;
@property (nonatomic, strong) UIButton *cityButton;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIViewController *curVCtler;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *coverButton;

@property (nonatomic, assign) BOOL isClear;

@property (nonatomic, strong) CTTopPrettyNumVCtler *topVC;
@property (nonatomic, strong) CTBussinessPrettyNumVCtler *bussinessVC;
@property (nonatomic, strong) CTLovingPrettyNumVCtler *lovingVC;
@property (nonatomic, strong) CTFreeNumVCtler *freeVC;

@property (nonatomic, strong) CTPrettyNumData *selectedData;

@property (nonatomic, strong) UILabel *luckyNumLabel;
@property (nonatomic, strong) UILabel *numAttributionLabel;
@property (nonatomic, strong) UILabel *phoneNumLabel;
@property (nonatomic, strong) UILabel *phoneNumInfoLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *nSelNumView;
@property (nonatomic, strong) UIView *prettyNumInfoView;
@property (nonatomic, strong) UIButton *tipBtn;

@property (nonatomic, strong) UIImageView *directedImageView;

@end

@implementation CTPrettyNumberVCtler 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isClear = NO;
        self.selectedIndex = 0;
        self.jumpType = 0;
        self.locateData = [CTHelperMap shareHelperMap].areaInfo;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
        
    //读取文件
    [[CTQryCollected shareQryCollected] loadCacheArea];
    
    [self setTitle:@"靓号专区"];
    [self setLeftButton:[UIImage imageNamed:@"btn_back.png"]];
    UIView *cityView = [[UIView alloc]initWithFrame:
                        CGRectMake(self.view.bounds.origin.x,
                                   1,
                                   CGRectGetWidth(self.view.frame),
                                   56)];
    cityView.backgroundColor = [UIColor colorWithRed:239/255.
                                               green:239/255.
                                                blue:239/255. alpha:1];
    [self.view addSubview:cityView];
    self.cityView = cityView;
    
    {
        //地址按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[CTHelperMap shareHelperMap].areaInfo.cityname forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
        [button setBackgroundImage:[UIImage imageNamed:@"prettyNum_citybg_button.png"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.frame = CGRectMake(6, (CGRectGetHeight(cityView.frame)-38)/2, 95, 38);
        [button addTarget:self action:@selector(citySelectedAction) forControlEvents:UIControlEventTouchUpInside];
        [self.cityView addSubview:button];
        self.cityButton = button;
        {
            UIImage *image = [UIImage imageNamed:@"prettyNum_arrow_icon.png"];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:
                                      CGRectMake(95-20,
                                                 (CGRectGetHeight(button.frame)-image.size.height)/2,
                                                 image.size.width,
                                                 image.size.height)];
            imageView.image = image ;
            [button addSubview:imageView];
        }
        
        UIImage *cancelImage = [UIImage imageNamed:@"prettyNum_citybg_button.png"];
        UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [searchBtn setBackgroundImage:cancelImage forState:UIControlStateNormal];
        [searchBtn addTarget:self
                   action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
        [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
        searchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        searchBtn.frame = CGRectMake(CGRectGetMaxX(button.frame) +10 + 200 - 48,
                                  (CGRectGetHeight(cityView.frame)-38)/2,
                                  45,
                                  38);
        [self.cityView addSubview:searchBtn];
        
        UIImage *image = [UIImage imageNamed:@"prettyNum_searchBar_bg.png"];
        CGRect rect = CGRectMake(CGRectGetMaxX(button.frame)+10,
                                               (CGRectGetHeight(cityView.frame)-38)/2,
                                               200,
                                               38);
        UITextField *textField = [[UITextField alloc] initWithFrame:rect];
        textField.delegate = (id<UITextFieldDelegate>)self;
        textField.backgroundColor = [UIColor clearColor];
        textField.borderStyle = UITextBorderStyleNone;
        textField.background = image ;
        textField.textColor = [UIColor blackColor];
        textField.font = [UIFont systemFontOfSize:14];
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.returnKeyType = UIReturnKeySearch;
        textField.enablesReturnKeyAutomatically = YES;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [textField dwMakeRoundCornerWithRadius:5];
        
        {
            image = [UIImage imageNamed:@"SearchIcon.png"];
            UIView *view = [[UIView alloc] initWithFrame:
                            CGRectMake(0, 0, image.size.width + 12, textField.frame.size.height)];
            view.backgroundColor = [UIColor clearColor];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.backgroundColor = [UIColor clearColor];
            CGRect rect = imageView.frame;
            rect.origin.x = 8;
            rect.origin.y = ceilf((view.frame.size.height - rect.size.height) / 2);
            imageView.frame = rect;
            
            [view addSubview:imageView];
            
            textField.leftView = view;
            textField.leftViewMode = UITextFieldViewModeAlways;
        }
        
        {
            image = [UIImage imageNamed:@"prettyNum_cancel_icon.png"];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            [button setImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(cancelSearchAction) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(0, 0, image.size.width + 12, textField.frame.size.height);
            CGRect rect = button.frame;
            rect.origin.x = 8;
            rect.origin.y = ceilf((button.frame.size.height - rect.size.height) / 2);
            button.frame = rect;
            textField.rightView = button;

            textField.rightViewMode = UITextFieldViewModeAlways;
        }
  
        textField.placeholder = @"  自选尾号 (2-4位)";
        [self.cityView addSubview:textField];
        
        self.searchTextField = textField;
    }
    
    //查询时使用得覆盖button
    
    UIButton *coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    coverBtn.backgroundColor = [UIColor clearColor];
    coverBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    coverBtn.hidden = YES;
    coverBtn.frame = CGRectMake(0, 165,
                                self.view.frame.size.width,
                                self.view.frame.size.height - CGRectGetMaxY(self.cityView.frame));
    [coverBtn addTarget:self action:@selector(cancelkeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    [MyAppDelegate.window addSubview:coverBtn];
    [MyAppDelegate.window bringSubviewToFront:coverBtn];
    self.coverButton = coverBtn;
    
    UIView *selectedView = [[UIView alloc]initWithFrame:
                            CGRectMake(0,
                                       CGRectGetMaxY(self.cityView.frame)+1,
                                       CGRectGetWidth(self.cityView.frame),
                                       42)];
    selectedView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:selectedView];
    self.selectedView = selectedView ;
    
    {
        //顶级靓号、事业靓号、爱情靓号、0元靓号
        NSArray *array = [NSArray arrayWithObjects:@"全部",@"顶级",@"爱情",@"0元", nil];
        UIImage *selected = [UIImage imageNamed:@"recharge_selected_bg.png"];
        UIImage *nonselected = [UIImage imageNamed:@"recharge_unselected_bg.png"];
        float xPos = 0;
        for(int i=0;i<4;i++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.tag = kSelectedButtonTag + i;
            [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundImage:nonselected forState:UIControlStateNormal];
            [button setBackgroundImage:selected forState:UIControlStateSelected];
            button.frame = CGRectMake(xPos,
                                      CGRectGetMinX(self.selectedView.frame),
                                      CGRectGetWidth(self.selectedView.frame)/4,
                                      CGRectGetHeight(self.selectedView.frame));
            [button addTarget:self action:@selector(selectedVCtlerAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.selectedView addSubview:button];
            xPos = CGRectGetMaxX(button.frame);
        }
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                              CGRectGetMaxY(self.selectedView.frame),
                                                                              CGRectGetWidth(self.view.frame),
                                                                              self.view.bounds.size.height - CGRectGetMaxY(self.selectedView.frame)-96)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame)*4,scrollView.frame.size.height);
    scrollView.pagingEnabled = YES ;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = (id<UIScrollViewDelegate>)self ;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView ;

    {
        CTTopPrettyNumVCtler *vc = [[CTTopPrettyNumVCtler alloc]init];
        self.topVC = vc ;
        vc.view.backgroundColor = [UIColor whiteColor];
        vc.view.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
        [scrollView addSubview:vc.view];
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
         self.curVCtler = self.topVC;

        CTBussinessPrettyNumVCtler *vc1 = [[CTBussinessPrettyNumVCtler alloc]init];
        self.bussinessVC = vc1 ;
        vc1.view.frame = CGRectMake(CGRectGetWidth(scrollView.frame), 0, scrollView.frame.size.width, scrollView.frame.size.height);
        vc1.view.backgroundColor = [UIColor whiteColor];
        vc1.view.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
        [scrollView addSubview:vc1.view];

        CTLovingPrettyNumVCtler *vc2 = [[CTLovingPrettyNumVCtler alloc]init];
        self.lovingVC = vc2 ;
        vc2.view.backgroundColor = [UIColor whiteColor];
        vc2.view.frame = CGRectMake(CGRectGetWidth(scrollView.frame)*2, 0, scrollView.frame.size.width, scrollView.frame.size.height);
        vc2.view.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
        [scrollView addSubview:vc2.view];

        CTFreeNumVCtler *vc3 = [[CTFreeNumVCtler alloc]init];
        self.freeVC = vc3 ;
        vc3.view.backgroundColor = [UIColor whiteColor];
        vc3.view.frame = CGRectMake(CGRectGetWidth(scrollView.frame)*3,0 , scrollView.frame.size.width, scrollView.frame.size.height);
        vc3.view.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
        [scrollView addSubview:vc3.view];
    }
    
    {
        float yPos = iPhone5 ? 258 : 170 ;
        UIView *prettyNumInfoView = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                                            CGRectGetMaxY(self.selectedView.frame)+ yPos,
                                                                            CGRectGetWidth(self.view.frame),
                                                                            96)];
        prettyNumInfoView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        prettyNumInfoView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:prettyNumInfoView];
        self.prettyNumInfoView = prettyNumInfoView ;
        {
            
            UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:prettyNumInfoView.bounds];
            bgImageView.backgroundColor = [UIColor colorWithRed:239/255. green:239/255. blue:239/255. alpha:1];
            [prettyNumInfoView addSubview:bgImageView];
            //***************覆盖的view
            
            UIView *nselView = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       CGRectGetWidth(prettyNumInfoView.frame)-60,
                                                                       52)];
            nselView.backgroundColor = [UIColor colorWithRed:239/255. green:239/255. blue:239/255. alpha:1];
            [prettyNumInfoView addSubview:nselView];
            self.nSelNumView = nselView ;
            {
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(90, (CGRectGetHeight(nselView.frame)-18)/2, 150,18)];
                label.text = @"请先选择一个号码";
                label.textColor = [UIColor blackColor];
                label.font = [UIFont systemFontOfSize:18];
                label.backgroundColor = [UIColor clearColor];
                [nselView addSubview:label];
            }
            
            //感叹号
            UIButton *tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
            tipButton.frame = CGRectMake(14, 14, 33, 33);
            tipButton.backgroundColor = [UIColor clearColor];
            [tipButton setImage:[UIImage imageNamed:@"WriteOrderInfo_icon1.png"] forState:UIControlStateNormal];
            [tipButton addTarget:self action:@selector(tipForComsumes) forControlEvents:UIControlEventTouchUpInside];
            [prettyNumInfoView addSubview:tipButton];
            self.tipBtn = tipButton;
            
            //****************
            UILabel *numAttributionLab = [[UILabel alloc]initWithFrame:
                                          CGRectMake(50,
                                                     11,
                                                     80,
                                                     14)];
            numAttributionLab.backgroundColor = [UIColor clearColor];
            numAttributionLab.font = [UIFont systemFontOfSize:14];
            numAttributionLab.text = @"";
            numAttributionLab.textColor = [UIColor blackColor];
            self.numAttributionLabel = numAttributionLab;
            [prettyNumInfoView addSubview:numAttributionLab];
            
            UILabel *numLab = [[UILabel alloc]initWithFrame:
                               CGRectMake(134,
                                          9,
                                          170,
                                          16)];
            numLab.backgroundColor = [UIColor clearColor];
            numLab.textColor = [UIColor blackColor];
            numLab.text = @"";
            numLab.font = [UIFont boldSystemFontOfSize:18];
            [prettyNumInfoView addSubview:numLab];
            self.phoneNumLabel = numLab ;
            
            UILabel *prettyNumInfoLab = [[UILabel alloc]initWithFrame:
                                         CGRectMake(50,
                                                    18+13,
                                                    200,
                                                    14)];
            prettyNumInfoLab.backgroundColor = [UIColor clearColor];
            prettyNumInfoLab.text = @"";
            prettyNumInfoLab.textAlignment = UITextAlignmentCenter ;
            prettyNumInfoLab.font = [UIFont systemFontOfSize:14];
            prettyNumInfoLab.textColor = [UIColor blackColor];
            [prettyNumInfoView addSubview:prettyNumInfoLab];
            self.phoneNumInfoLabel = prettyNumInfoLab ;
            
            //摇一摇按钮
            UIImage *shakeImage = [UIImage imageNamed:@"prettyNum_shake_btn.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(CGRectGetMaxX(prettyNumInfoView.frame)-shakeImage.size.width, 6, shakeImage.size.width, shakeImage.size.height);
            [button setBackgroundImage:shakeImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(shakeAction) forControlEvents:UIControlEventTouchUpInside];
            [prettyNumInfoView addSubview:button];
        
            UIButton *choosepackageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [choosepackageBtn setTitle:@"选择套餐" forState:UIControlStateNormal];
            [choosepackageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            choosepackageBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            [choosepackageBtn setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn.png"] forState:UIControlStateNormal];
            [choosepackageBtn setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn_hl.png"] forState:UIControlStateHighlighted];
            choosepackageBtn.frame = CGRectMake(21, CGRectGetMaxY(prettyNumInfoLab.frame)+8, CGRectGetWidth(self.view.frame)-42, 38);
            [choosepackageBtn addTarget:self action:@selector(choosePackageAction) forControlEvents:UIControlEventTouchUpInside];
            [prettyNumInfoView addSubview:choosepackageBtn];
            
            [prettyNumInfoView bringSubviewToFront:nselView];
        }
        
    }
        
    [self.view bringSubviewToFront:coverBtn];

    //
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(setCollectedNotification:)
                                                name:COLLECTPRETTYNUMBERCOUNT object:nil];
    //城市切换消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedCityNotification:)
                                                 name:SELECTCITY_MSG object:nil];
    //发送选中城市的数据
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedPretteyNum:)
                                                 name:@"SELECTPRETTYNUM" object:nil];
    //跳转收藏页面
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jumpToCollected)
                                                 name:@"JUMPTOCOLLECTED" object:nil];
    
    
    //设置收藏信息
    int count = [CTQryCollected shareQryCollected].collectedMutableDict.count ;
    if (count == 0) {
        [self setRightButton:[UIImage imageNamed:@"prettyNum_collected_icon.png"]
                      isShow:NO msgCount:[NSString stringWithFormat:@"%d",count]];
    }else{
        [self setRightButton:[UIImage imageNamed:@"prettyNum_collected_icon.png"]
                      isShow:YES msgCount:[NSString stringWithFormat:@"%d",count]];
    }
    
    //确保跳转时传递数据 不用再次定位
    if (!self.locateData) {
        self.locateData = [CTHelperMap shareHelperMap].areaInfo ;
    }
    [self location];
    [self setSelectedVC:self.selectedIndex];
    
    NSString *key = [NSString stringWithFormat:@"%@%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],@"DIRECTED"];
    //  引导层
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *isShow = [defaults objectForKey:key];
   
    if ([isShow isEqualToString:@"YES"]) {
        
    }
    else
    {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        UIImageView *directedImageView ;
        
        if (!iPhone5)
        {
            directedImageView = [[UIImageView alloc] initWithFrame:
                                              CGRectMake(0, 0,
                                                         CGRectGetWidth(window.frame),
                                                         480)];
            
            directedImageView.backgroundColor = [UIColor clearColor];
            directedImageView.userInteractionEnabled = YES ;
            directedImageView.autoresizingMask = UIViewContentModeScaleAspectFill;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
            {
                directedImageView.image = [UIImage imageNamed:@"prettyNum_directed_iphone4s1.png"];
            } else {
                directedImageView.image = [UIImage imageNamed:@"prettyNum_directed_iphone4s.png"];
            }
        } else
        {
            directedImageView = [[UIImageView alloc] initWithFrame:
                                 CGRectMake(0, 0,
                                            CGRectGetWidth(window.frame),
                                            568)];
            
            directedImageView.backgroundColor = [UIColor clearColor];
            directedImageView.userInteractionEnabled = YES ;
            directedImageView.autoresizingMask = UIViewContentModeScaleAspectFill;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                directedImageView.image = [UIImage imageNamed:@"prettyNum_directed_iphone52.png"];
            } else {
                directedImageView.image = [UIImage imageNamed:@"prettyNum_directed_iphone5.png"];
            }
            
        }

        //modified by huangfq 2014-6-6
        directedImageView = [directedImageView accordingImageForImageView:directedImageView.image];
        if (directedImageView) {
            
            self.directedImageView = directedImageView;
            [window addSubview:directedImageView];
            {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.backgroundColor = [UIColor clearColor];
                button.frame = directedImageView.bounds;
                [button addTarget:self action:@selector(removeDirected) forControlEvents:UIControlEventTouchUpInside];
                [directedImageView addSubview:button];
            }

            [defaults setObject:@"YES" forKey:key];
            [defaults synchronize];
        }
    }
}

- (void) removeDirected
{
    __weak typeof(self)wSelf = self ;
    [UIView animateWithDuration:0.3 animations:^()
     {
          wSelf.directedImageView.alpha = 0;
     }completion:^(BOOL finished){
         
         [wSelf.directedImageView removeFromSuperview];
     }];
}

- (void) location
{
    NSString *cityName = [NSString stringWithFormat:@"%@",self.locateData.cityname];
    if ([cityName hasSuffix:@"市"]) {
        cityName = [cityName substringToIndex:cityName.length-1];
    }
    
    [self.cityButton setTitle:cityName forState:UIControlStateNormal];
    self.topVC.areaInfo = self.locateData ;
    self.bussinessVC.areaInfo = self.locateData;
    self.lovingVC.areaInfo = self.locateData;
    self.freeVC.areaInfo = self.locateData;
    
    [self.topVC location];
    [self.bussinessVC location];
    [self.lovingVC location];
    [self.freeVC location];
}

#pragma mark - fun

- (void) setSelectedVC : (int) index
{
    UIButton *btn = (UIButton *)[self.selectedView viewWithTag:kSelectedButtonTag+index];
    btn.selected = YES;
    CGRect rect = self.scrollView.frame ;
    [self.scrollView setContentOffset:CGPointMake(index*rect.size.width,0)];
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
}

- (void)dealloc{
    DDLogInfo(@"*********** %s", __func__);
    //保存文件
    [[CTQryCollected shareQryCollected] saveCacheArea];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (float)systemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];;
}

- (void)setRightButton:(UIImage *)image isShow : (BOOL) isShow msgCount : (NSString *)count
{
    if (!image)
    {
        return;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 0, image.size.width , image.size.height);
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onRightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (isShow)
    {
        UIImage *image = [UIImage imageNamed:@"prettyNum_squre_icon.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:
                                  CGRectMake(CGRectGetMaxX(btn.frame)-22, btn.frame.origin.y-6, image.size.width, image.size.height)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = image;
        [btn addSubview:imageView];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:
                        CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
        lab.backgroundColor = [UIColor clearColor];
        lab.textAlignment = UITextAlignmentCenter ;
        lab.textColor = [UIColor whiteColor];
        lab.text = count;
        lab.font = [UIFont systemFontOfSize:9];
        [imageView addSubview:lab];
    }
    
    UIBarButtonItem *baritem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = baritem;
}

- (void) showSelectedInfo : (BOOL) isLucky
{
    if (!self.selectedData) {
        self.phoneNumLabel.text = @"";
        self.phoneNumInfoLabel.text = @"";
        self.numAttributionLabel.text = @"";
        //显示view
        
        return ;
    }

    self.luckyNumLabel.text = @"已选号码";
    
    NSString *cityName = [NSString stringWithFormat:@"%@",self.selectedData.City];
    if ([cityName hasSuffix:@"市"]) {
        cityName = [cityName substringToIndex:cityName.length-1];
    }
    self.numAttributionLabel.text = [NSString stringWithFormat:@"%@ %@",self.selectedData.Province,cityName];
    
    NSMutableString *phoneNum =  [NSMutableString stringWithString:self.selectedData.PhoneNumber] ;
    [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    [phoneNum insertString:@" " atIndex:3];
    [phoneNum insertString:@" " atIndex:8];
    self.phoneNumLabel.text = phoneNum;
    
    NSString *pay = [NSString stringWithFormat:@"%0.f",[self.selectedData.PrepayMent floatValue]];//dictionary[@"PrepayMent"]
    NSString *consume = [NSString stringWithFormat:@"%0.f",[self.selectedData.MinAmount floatValue]];//[dictionary[@"MinAmount"]
    self.phoneNumInfoLabel.text = [NSString stringWithFormat:@"预存%@元 月最低消费%@元",pay,consume];
    
    if ([pay floatValue] > 0.0) {
        self.tipBtn.hidden = NO;
    } else {
        self.tipBtn.hidden = YES;
    }
    
}

#pragma mark - netWork 

- (void) getRcdNumber
{
    NSString *ProvinceCode = self.locateData.provincecode;
    NSString *AreaCode = self.locateData.citycode;
    NSString *ShopId = BUSSINESS_SHOPID;
    NSString *PageIndex = [NSString stringWithFormat:@"%d",arc4random()%10 + 1];  //int value =
    NSString *PageSize = @"1";
    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               ProvinceCode,@"ProvinceCode",
                               AreaCode,@"AreaCode",
                               ShopId,@"ShopId",
                               PageIndex,@"PageIndex",
                               PageSize,@"PageSize",
                               nil];
    
    if (![SVProgressHUD isVisible]) {
        [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    }
    
    [MyAppDelegate.cserviceEngine
     postXMLWithCode:@"getRcdNumber"
     params:params
     onSucceeded:^(NSDictionary *dict)
    {
         DDLogInfo(@"%s--%@", __func__, dict.description);
         id Data = [dict objectForKey:@"Data"];
         //获取信息失败
         if (Data) {
             id Items = [Data objectForKey:@"Items"];
             if (Items) {
                 if ([Items isKindOfClass:[NSDictionary class]]) {
                     NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:Items];
                     [mutableDict setObject:@"" forKey:@"isCollected"];
                     [mutableDict setObject:@"" forKey:@"Type"];
                     [mutableDict setObject:@"" forKey:@"SpecialOffers"];
                     CTPrettyNumData *prettyData = [CTPrettyNumData modelObjectWithDictionary:[NSDictionary dictionaryWithDictionary:mutableDict]];
                     self.selectedData = prettyData ;
                     [self showSelectedInfo:YES]; //显示幸运号码
                 }
             } else {
                 self.selectedData = nil ;
                 [self showSelectedInfo:YES];
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
             }
         }
         else{
             ToastAlertView *alert = [ToastAlertView new];
             [alert showAlertMsg:@"系统繁忙,请重新提交"];
         }
     }];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
     __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                         if (!strongSelf) {
                             return;
                         }
                         
                         if (strongSelf.isClear) {
                             strongSelf.isClear = NO;
                             self.coverButton.hidden = YES;
                             [textField resignFirstResponder];
                         }else{
                             CGRect rect = strongSelf.searchTextField.frame;
                             rect.size.width= 200 -52;
                             strongSelf.searchTextField.frame = rect ;
                             self.coverButton.hidden = NO;
                         }
                    }completion:^(BOOL finish){
                        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                        if (!strongSelf) {
                            return;
                        }
                        
                    }];
}

- (void) cancelSearchAction
{
    [self.searchTextField resignFirstResponder];
    self.isClear = YES;
    self.searchTextField.text = @"";
    //发送停止搜索消息
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                         if (!strongSelf) {
                             return;
                         }
                         CGRect rect = strongSelf.searchTextField.frame;
                         rect.size.width = 200;
                         strongSelf.searchTextField.frame = rect ;
                         
                     }completion:^(BOOL finish){
                         __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                         if (!strongSelf) {
                             return;
                         }
                         self.coverButton.hidden = YES;
                         
                     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CANCELSEARCH_MSG object:nil];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.isClear = YES;
    //发送停止搜索消息
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                         if (!strongSelf) {
                             return;
                         }
                         CGRect rect = strongSelf.searchTextField.frame;
                         rect.size.width = 200;
                         strongSelf.searchTextField.frame = rect ;
                         
                     }completion:^(BOOL finish){
                         __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                         if (!strongSelf) {
                             return;
                         }
                         self.coverButton.hidden = YES;
                         
                     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CANCELSEARCH_MSG object:nil];
    
    return YES;
}

#define NUMBERS  @"0123456789"
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs    = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS]invertedSet];
    NSString *filtered    = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];
    BOOL canChange        = [string isEqualToString:filtered];
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([toBeString length]>4) {
        textField.text = [toBeString substringToIndex:4];
        canChange = NO ;
    }
    return canChange;
}

#pragma mark - NSNotification

- (void) jumpToCollected
{
    CTCollectedPrettyNumVCtler *vc = [CTCollectedPrettyNumVCtler new];
    vc.selectedDict = [self.locateData dictionaryRepresentation];
    [self.navigationController pushViewController:vc animated:YES];
}
//选中得城市消息通知消息
- (void) selectedPretteyNum : (NSNotification *) notification
{
    CTPrettyNumData *selectedData = [notification object];
    self.selectedData = selectedData ;
    [self showSelectedInfo:NO];
    self.nSelNumView.hidden = YES ;
}

- (void) selectedCityNotification : (NSNotification *) notification {
    
    self.selectedData = nil; //号码信息
    
    CTCity *city = [notification object];
    self.locateData = city;
    NSString *cityName = [NSString stringWithFormat:@"%@",city.cityname];
    if ([cityName hasSuffix:@"市"]) {
        cityName = [cityName substringToIndex:cityName.length-1];
    }
    
    [self.cityButton setTitle:cityName forState:UIControlStateNormal];
    self.nSelNumView.hidden = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [self.locateData dictionaryRepresentation];
    [defaults setObject:dict forKey:CITYINFO];
    [defaults synchronize];
}

- (void) setCollectedNotification : (NSNotification *) notification
{
    int count = [CTQryCollected shareQryCollected].collectedMutableDict.count ;
    if (count ==0) {
        [self setRightButton:[UIImage imageNamed:@"prettyNum_collected_icon.png"]
                      isShow:NO msgCount:[NSString stringWithFormat:@"%d",count]];
    }else{
        [self setRightButton:[UIImage imageNamed:@"prettyNum_collected_icon.png"]
                      isShow:YES msgCount:[NSString stringWithFormat:@"%d",count]];
    }
}

- (void) jumpToPackage : (NSNotification *) obj
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action 

- (void) shakeAction
{
    //摇一摇跳转要使用当前选中的城市编码
    CTShakeNumberVCtler *vc = [CTShakeNumberVCtler new];
    vc.selectedCity = self.locateData;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void) getNumProudInfo
{
    //靓号-频道选择接口 (测试)
    NSDictionary *dictionary = [self.selectedData dictionaryRepresentation];
    NSString *PhoneNumber = dictionary[@"PhoneNumber"];
    NSString *ShopId = BUSSINESS_SHOPID;
    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               PhoneNumber,@"PhoneNumber",
                               ShopId,@"ShopId",
                               nil];
    
    __weak typeof(self) wself = self;
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    [MyAppDelegate.cserviceEngine
     postXMLWithCode:@"getNumProudInfo"
     params:params
     onSucceeded:^(NSDictionary *dict) {
         DDLogInfo(@"%s--%@", __func__, dict.description);
         id data = dict[@"Data"];
         if (data) {
             NSString *Status = data[@"Status"];
             if ([Status isEqualToString:@"2"]) {
                 //跳转到套餐页面
//                 CTPlanSelectVCtler *vc = [CTPlanSelectVCtler new];
                 CTAddPackageVCtler * vc = [CTAddPackageVCtler new];
                 vc.item = [wself.selectedData dictionaryRepresentation];
                 [wself.navigationController pushViewController:vc animated:YES];
                 //保存信息
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setObject:[wself.locateData dictionaryRepresentation] forKey:CITYINFO];
                 [defaults synchronize];
             }
             else {
                 SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                  andMessage:@"您选的号码必定人人喜爱，已被人抢先一步，请重新选择一个号码。"];
                 [alertView addButtonWithTitle:@"换个号码"
                                          type:SIAlertViewButtonTypeDefault
                                       handler:^(SIAlertView *alertView) {
                                           
                                       }];
                 
                 alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                 [alertView show];
             }
         }
         
         [SVProgressHUD dismiss];
         
     } onError:^(NSError *engineError) {
         DDLogInfo(@"%s--%@", __func__, engineError);
         
         [SVProgressHUD dismiss];
         
     }];
}

- (void) choosePackageAction
{
    //选择套餐
    if (self.selectedData) {
        [self getNumProudInfo];
    } else {
        ToastAlertView *alert = [ToastAlertView new];
        [alert showAlertMsg:@"亲,请选择一个靓号"];
    }
}

- (void) selectedVCtlerAction : (id)sender
{
    if (self.coverButton.hidden == NO) {
        [self cancelkeyBoard:nil];
    }
    
    UIButton *btn = (UIButton *)sender ;
    int index = btn.tag - kSelectedButtonTag ;
    
    if (btn.selected) {
        return;
    }
    
    self.selectedIndex = index ;
    
    for (int i=0; i<4; i++) {
        UIButton *button = (UIButton *)[self.selectedView viewWithTag:i+kSelectedButtonTag];
        if (index==i) {
            button.selected = YES;
        }else{
            button.selected = NO;
        }
    }
    
    [self.scrollView setContentOffset:CGPointMake(index*CGRectGetWidth(self.scrollView.frame), self.scrollView.frame.origin.x)];
    [self setPhoneNumInfo:index];
}

- (void)setPhoneNumInfo:(int)index
{
    //设置选中号码信息
    switch (index) {
        case 0:
        {
            if (self.topVC.selectedData) {
                self.selectedData = self.topVC.selectedData ;
                [self showSelectedInfo:NO];
            }
        }
            break;
        case 1:
        {
            if (self.bussinessVC.selectedData) {
                self.selectedData = self.bussinessVC.selectedData ;
                [self showSelectedInfo:NO];
            }
        }
            break;
        case 2:
        {
            if (self.lovingVC.selectedData) {
                self.selectedData = self.lovingVC.selectedData ;
                [self showSelectedInfo:NO];
            }
        }
            break;
        case 3:
        {
            if (self.freeVC.selectedData) {
                self.selectedData = self.freeVC.selectedData ;
                [self showSelectedInfo:NO];
            }
        }
            break;
    }
}

- (void) searchAction
{
    [self.searchTextField resignFirstResponder];
    self.coverButton.hidden = YES ;
    if ([self.searchTextField.text length] > 0) {
        NSString *text = self.searchTextField.text ;
        [[NSNotificationCenter defaultCenter] postNotificationName:SEARCHTOP_MSG object:text];
        [[NSNotificationCenter defaultCenter] postNotificationName:SEARCHBUSSINESS_MSG object:text];
        [[NSNotificationCenter defaultCenter] postNotificationName:SEARCHLOVING_MSG object:text];
        [[NSNotificationCenter defaultCenter] postNotificationName:SEARCHFREE_MSG object:text];
    }else{
        
    }
}

- (void) onRightBtnAction:(id)sender {
    
    [self.searchTextField resignFirstResponder];
    self.coverButton.hidden = YES;
    if (self.searchTextField.text.length == 0) {
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.3
                         animations:^(void){
                             __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                             if (!strongSelf) {
                                 return;
                             }
                             
                             CGRect rect = strongSelf.searchTextField.frame;
                             if (rect.size.width < 150){
                                 rect.size.width += 52;
                                 strongSelf.searchTextField.frame = rect ;
                             }
                             
                         }completion:^(BOOL finish){
                             __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                             if (!strongSelf) {
                                 return;
                             }
                         }];
    }
    
    CTCollectedPrettyNumVCtler *vc = [CTCollectedPrettyNumVCtler new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action

- (void) citySelectedAction
{
    [self.searchTextField resignFirstResponder];
    self.coverButton.hidden = YES;
    if (self.searchTextField.text.length == 0) {
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.3
                         animations:^(void){
                             __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                             if (!strongSelf) {
                                 return;
                             }
                             CGRect rect = strongSelf.searchTextField.frame;
                             if (rect.size.width < 150){
                                 rect.size.width += 52;
                                 strongSelf.searchTextField.frame = rect ;
                             }
                             
                         }completion:^(BOOL finish){
                             __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                             if (!strongSelf) {
                                 return;
                             }
                         }];
    }
    
    CTCitySelectedVCtler *vc = [CTCitySelectedVCtler new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) cancelkeyBoard : (id)sender
{
    [self.searchTextField resignFirstResponder];
    self.coverButton.hidden = YES;
    if (self.searchTextField.text.length == 0) {
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.3
                         animations:^(void){
                             __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                             if (!strongSelf) {
                                 return;
                             }
                             
                             CGRect rect = strongSelf.searchTextField.frame;
                              {
                                 rect.size.width += 52;
                                 strongSelf.searchTextField.frame = rect ;
                             }
                             
                         }completion:^(BOOL finish){
                             __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                             if (!strongSelf) {
                                 return;
                             }
                         }];
    }
}

- (void) tipForComsumes
{
    /*
        如果能除净（商小数点后不大于2位），就按除净规则显示，如：
        预存话费 90 元，每月固定返还 3.75 元，激活后共返还 24 个月。
        
        如果不能除净，前23个月返还的金额是商取整数部分，第24个月返还剩下部分，如：
        预存话费 80 元，激活后共返还 24 个月，前 23 个月每月返还 3 元，第 24 个月返还 11 元。
    */
    
    NSString *message = @"";
    float pay = [self.selectedData.PrepayMent floatValue]/24.0 ;//;[self.selectedData.PrepayMent floatValue]/24;
    NSString *payStr = [NSString stringWithFormat:@"%0.3f",pay];
    NSString *lastStr = [payStr substringFromIndex:payStr.length-1];
    if ([lastStr integerValue]>0) {
        //不能整除
        int ret = floorf([self.selectedData.PrepayMent floatValue]/24.0) ; //向下取整
        message = [NSString stringWithFormat:@"预存话费%@元，激活后共返还24个月,前23个月每月返还%d元,第24个月返还%d元",self.selectedData.PrepayMent,ret,[self.selectedData.PrepayMent integerValue]-ret*23];
        
    } else {
        message = [NSString stringWithFormat:@"预存话费%@元,每月固定返还%0.2f元,激活后共返还24个月",self.selectedData.PrepayMent,pay];
    }
    
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"重要提示"
                                                     andMessage:message];
    [alertView addButtonWithTitle:@"知道了"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

- (void) onLeftBtnAction:(id)sender
{
    if (self.isTop) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [super onLeftBtnAction:sender];
    }
    
    [self.coverButton removeFromSuperview];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint pos = scrollView.contentOffset;
    int curPos = self.selectedIndex*CGRectGetWidth(scrollView.frame);
    if (pos.x>=0) {
        if (pos.x>curPos) { //向左
            if (pos.x>(self.selectedIndex + 0.9)*CGRectGetWidth(scrollView.frame)) { //超过一般位置
                int pageIndex = ceilf(pos.x/CGRectGetWidth(scrollView.frame));
                self.selectedIndex = pageIndex ;
                
                for (int i=0; i<4; i++) {
                    UIButton *button = (UIButton *)[self.selectedView viewWithTag:i+kSelectedButtonTag];
                    if (pageIndex==i) {
                        button.selected = YES;
                    }else{
                        button.selected = NO;
                    }
                }
                [self setPhoneNumInfo:self.selectedIndex];
            }
        }
        else {
            if (pos.x<(self.selectedIndex - 0.9)*CGRectGetWidth(scrollView.frame)) {
                int pageIndex = floorf(pos.x/CGRectGetWidth(scrollView.frame));
                self.selectedIndex = pageIndex ;
                for (int i=0; i<4; i++) {
                    UIButton *button = (UIButton *)[self.selectedView viewWithTag:i+kSelectedButtonTag];
                    if (pageIndex==i) {
                        button.selected = YES;
                    }else{
                        button.selected = NO;
                    }
                }
                 [self setPhoneNumInfo:self.selectedIndex];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

}

@end
