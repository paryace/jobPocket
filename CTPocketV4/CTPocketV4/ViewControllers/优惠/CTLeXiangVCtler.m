//
//  CTLeXiangVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 14-1-10.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  乐享套餐

#import "CTLeXiangVCtler.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"
#import "CTPackageView.h"
#import "StyledPageControl.h"

@interface CTLeXiangVCtler () <CTPackageViewDelegate>
@property (strong, nonatomic) NSMutableArray *packages;
@property (strong, nonatomic) UIScrollView *mScrollView;
@property (strong, nonatomic) CTPackageView *mPackageView;
@property (strong, nonatomic) UIImageView *detailBgImageView;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIButton *packageBtn;
@property (strong, nonatomic) StyledPageControl *mPageControl;
@end

@implementation CTLeXiangVCtler

#pragma mark - Lazy Instantiation

- (NSMutableArray *)packages
{
    if (!_packages) {
        _packages = [[NSMutableArray alloc] init];
        if (self.package) {
            if (self.package[@"PackageItem"]) {
                if ([self.package[@"PackageItem"] isKindOfClass:[NSDictionary class]]) {
                    [_packages addObject:self.package[@"PackageItem"]];
                }
                else if ([self.package[@"PackageItem"] isKindOfClass:[NSArray class]]) {
                    [_packages addObjectsFromArray:self.package[@"PackageItem"]];
                }
            }
        }
    }
    return _packages;
}

- (UIScrollView *)mScrollView
{
    if (!_mScrollView) {
        _mScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _mScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _mScrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_mScrollView];
    }
    return _mScrollView;
}

- (CTPackageView *)mPackageView
{
    if (!_mPackageView) {
        _mPackageView = [[CTPackageView alloc] initWithFrame:CGRectMake(120, 20, 160, 168)];
        _mPackageView.delegate = self;
        [self.mScrollView addSubview:_mPackageView];
    }
    return _mPackageView;
}

- (UIImageView *)detailBgImageView
{
    if (!_detailBgImageView) {
        _detailBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 221, 295, 106)];
        UIImage *image = [UIImage imageNamed:@"LeXiang3G_DetailBg"];
        UIImage *resizeImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, 0, image.size.height/2, 0)];
        _detailBgImageView.image = resizeImage;
        [self.mScrollView addSubview:_detailBgImageView];
    }
    return _detailBgImageView;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 24, 283, 0)];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont systemFontOfSize:12.0f];
        _detailLabel.textColor = [UIColor blackColor];
        [self.detailBgImageView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIButton *)packageBtn
{
    if (!_packageBtn) {
        _packageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _packageBtn.frame = CGRectMake(24, 0, 272, 41);
        [_packageBtn setBackgroundImage:[UIImage imageNamed:@"recharge_commit_btn"] forState:UIControlStateNormal];
        [_packageBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_packageBtn addTarget:self action:@selector(onPackageAction) forControlEvents:UIControlEventTouchUpInside];
        [self.mScrollView addSubview:_packageBtn];
    }
    return _packageBtn;
}

- (StyledPageControl *)mPageControl
{
    if (!_mPageControl) {
        _mPageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(120, 188, 160, 20)];
        [_mPageControl setPageControlStyle:PageControlStyleStrokedCircle];
        [_mPageControl setCurrentPage:0];
        [_mPageControl setDiameter:8];
        _mPageControl.strokeWidth = 1;
        [_mPageControl setNumberOfPages:[self.packages count]];
        _mPageControl.userInteractionEnabled = NO;
    }
    return _mPageControl;
}

#pragma mark - Init

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
    
    [self setAllContents];
}

#pragma mark - Custom Methods

- (void)setAllContents
{
    // 背景分割条
    for (int i = 0; i < 4; i++) {
        UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20 + 55 * i, 310, 33)];
        separator.image = [UIImage imageNamed:@"LeXiang3G_Separator"];
        [self.mScrollView addSubview:separator];
    }
    
    // 套餐UIScrollView
    [self.mPackageView addPackage:self.packages];
    
    // 遮住套餐包的内容
    UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 120, 170)];
    lv.backgroundColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    [self.mScrollView addSubview:lv];
    
    UIView *rv = [[UIView alloc] initWithFrame:CGRectMake(320-10-33, 20, 43, 170)];
    rv.backgroundColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    [self.mScrollView addSubview:rv];
    
    for (int i = 0; i < 4; i++) {
        UIImageView *separator1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20 + 55 * i, 115, 33)];
        separator1.image = [UIImage imageNamed:@"LeXiang3G_Separator_Left@2x"];
        [self.mScrollView addSubview:separator1];
        
        UIImageView *separator2 = [[UIImageView alloc] initWithFrame:CGRectMake(320-10-33, 20 + 55 * i, 38, 33)];
        separator2.image = [UIImage imageNamed:@"LeXiang3G_Separator_Right@2x"];
        [self.mScrollView addSubview:separator2];
    }
    
    [self.mScrollView addSubview:self.mPageControl];
    
    // 标题
    NSArray *titleArray = @[@"套餐金额", @"国内语音", @"国内流量", @"国内短/彩信", @"国内WIFI", @"增值业务"];
    for (int i = 0; i < 6; i++) {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 25 + 28 * i, 80, 28)];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont systemFontOfSize:14.0f];
        title.textColor = [UIColor blackColor];
        title.text = titleArray[i];
        [self.mScrollView addSubview:title];
    }
    
    // 左按钮
    UIImage *image = [UIImage imageNamed:@"LeXiang3G_LArrow@2x"] ;
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 50, 8, 75)];
    leftImageView.image = image ;
    leftImageView.userInteractionEnabled = YES ;
    [self.mScrollView addSubview:leftImageView];
    
    UIButton *lBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lBtn.frame = CGRectMake(80, 45, 40, 75);
    [lBtn addTarget:self
             action:@selector(onLeftArrowAction)
   forControlEvents:UIControlEventTouchUpInside];
    [self.mScrollView addSubview:lBtn];
    
    // 右按钮
    UIButton *rBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rBtn.frame = CGRectMake(273, 45, 40, 75);
    [rBtn addTarget:self
             action:@selector(onRightArrowAction)
   forControlEvents:UIControlEventTouchUpInside];
    [self.mScrollView addSubview:rBtn];
    
    image = [UIImage imageNamed:@"LeXiang3G_RArrow@2x"] ;
    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(286, 50, 8, 75)];
    rightImageView.image = image ;
    rightImageView.userInteractionEnabled = YES ;
    [self.mScrollView addSubview:rightImageView];
    
    // 设置下方详情内容
//    if ([self.packages count] > 0) {
//        if (self.packages[0]) {
//            NSDictionary *packageItem = self.packages[0];
    
    // modified by liuruxian 2014-04-21
    if ([self.packages count] > 0) {
        NSDictionary *packageItem;
        // add by liuruxian 2014-04-20
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"LeXiang"]) {
            int inx = [[defaults objectForKey:@"LeXiang"] integerValue];
            if ([self.packages count]>inx-1) {
                packageItem = self.packages[inx-1];
            }
        } else{
            if (self.packages[0]) {
                packageItem = self.packages[0];
            }
        }
        if (packageItem) {
            
            NSString *yy = @"语音0分钟/月";
            if (packageItem[@"Properties"][@"TS_YY"]) {
                if ([packageItem[@"Properties"][@"TS_YY"] hasPrefix:@"BD:"]) {
                    yy = [NSString stringWithFormat:@"本地语音%@分钟/月", [packageItem[@"Properties"][@"TS_YY"] stringByReplacingOccurrencesOfString:@"BD:" withString:@""]];
                }
                else if ([packageItem[@"Properties"][@"TS_YY"] hasPrefix:@"GN:"]) {
                    yy = [NSString stringWithFormat:@"国内语音%@分钟/月", [packageItem[@"Properties"][@"TS_YY"] stringByReplacingOccurrencesOfString:@"GN:" withString:@""]];
                }
            }
            self.detailLabel.text = [NSString stringWithFormat:@"%@，流量%@/月，短信%@条/月\n%@%@",
                                     yy,
                                     packageItem[@"Properties"][@"TS_LL"] ? packageItem[@"Properties"][@"TS_LL"] : @"",
                                     packageItem[@"Properties"][@"TS_DX"] ? packageItem[@"Properties"][@"TS_DX"] : @"",
                                     packageItem[@"Properties"][@"TS_TCWZF"] ? packageItem[@"Properties"][@"TS_TCWZF"] : @"",
                                     packageItem[@"Properties"][@"TS_CC_LL"] ? packageItem[@"Properties"][@"TS_CC_LL"] : @""];
            
            // 调整UI
            self.detailLabel.numberOfLines = 0;
            [self.detailLabel sizeToFit];
            CGRect imageRect = self.detailBgImageView.frame;
            imageRect.size.height = 24.0f + self.detailLabel.frame.size.height + 10.0f;
            self.detailBgImageView.frame = imageRect;
            
            CGRect btnRect = self.packageBtn.frame;
            btnRect.origin.y = self.detailBgImageView.frame.origin.y + self.detailBgImageView.frame.size.height + 20.0f;
            self.packageBtn.frame = btnRect;
            
            self.mScrollView.contentSize = CGSizeMake(320, self.packageBtn.frame.origin.y + self.packageBtn.frame.size.height + 25.0f);
        }
    }
}

- (void)onPackageAction
{
    if (self.item[@"MinAmount"]) {
        NSDictionary *packageItem = self.packages[self.mPackageView.index];
        DDLogInfo(@"%f----%f", [self.item[@"MinAmount"] floatValue], [packageItem[@"Name"] floatValue]);
        if ([self.item[@"MinAmount"] floatValue] > [packageItem[@"Name"] floatValue]) {
            
            NSString *message = [NSString stringWithFormat:@"该靓号的月最低消费%@元，请选择不低于%@元的套餐。", self.item[@"MinAmount"], self.item[@"MinAmount"]];
            
            SIAlertView *aletView = [[SIAlertView alloc] initWithTitle:nil
                                                            andMessage:message];
            [aletView addButtonWithTitle:@"确定"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                      //
                                  }];
            aletView.transitionStyle = SIAlertViewTransitionStyleBounce;
            [aletView show];
            
            return;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"选择乐享3G"
                                                        object:@{@"index": [NSString stringWithFormat:@"%d", self.mPackageView.index],
                                                                 @"combo": self.combo,
                                                                 @"package": self.package}];
}

#pragma mark - CTPackageViewDelegate

- (void)didScrollToIndex:(NSUInteger)inx
{
    NSLog(@"%d", inx);
    
    if (([self.packages count] > 0) && (inx < [self.packages count])) {
        
        [self.mPageControl setCurrentPage:inx];
        
        if (self.packages[inx]) {
            NSDictionary *packageItem = self.packages[inx];
            if (packageItem) {
                
                NSString *yy = @"语音0分钟/月";
                if (packageItem[@"Properties"][@"TS_YY"]) {
                    if ([packageItem[@"Properties"][@"TS_YY"] hasPrefix:@"BD:"]) {
                        yy = [NSString stringWithFormat:@"本地语音%@分钟/月", [packageItem[@"Properties"][@"TS_YY"] stringByReplacingOccurrencesOfString:@"BD:" withString:@""]];
                    }
                    else if ([packageItem[@"Properties"][@"TS_YY"] hasPrefix:@"GN:"]) {
                        yy = [NSString stringWithFormat:@"国内语音%@分钟/月", [packageItem[@"Properties"][@"TS_YY"] stringByReplacingOccurrencesOfString:@"GN:" withString:@""]];
                    }
                }
                self.detailLabel.text = [NSString stringWithFormat:@"%@，流量%@/月，短信%@条/月\n%@%@",
                                         yy,
                                         packageItem[@"Properties"][@"TS_LL"] ? packageItem[@"Properties"][@"TS_LL"] : @"",
                                         packageItem[@"Properties"][@"TS_DX"] ? packageItem[@"Properties"][@"TS_DX"] : @"",
                                         packageItem[@"Properties"][@"TS_TCWZF"] ? packageItem[@"Properties"][@"TS_TCWZF"] : @"",
                                         packageItem[@"Properties"][@"TS_CC_LL"] ? packageItem[@"Properties"][@"TS_CC_LL"] : @""];
                
                // 调整UI
                self.detailLabel.frame = CGRectMake(6, 24, 283, 0);
                self.detailLabel.numberOfLines = 0;
                [self.detailLabel sizeToFit];
                CGRect imageRect = self.detailBgImageView.frame;
                imageRect.size.height = 24.0f + self.detailLabel.frame.size.height + 10.0f;
                self.detailBgImageView.frame = imageRect;
                
                CGRect btnRect = self.packageBtn.frame;
                btnRect.origin.y = self.detailBgImageView.frame.origin.y + self.detailBgImageView.frame.size.height + 20.0f;
                self.packageBtn.frame = btnRect;
                
                self.mScrollView.contentSize = CGSizeMake(320, self.packageBtn.frame.origin.y + self.packageBtn.frame.size.height + 25.0f);
            }
        }
    }
}

- (void)scrollToNext:(NSInteger)inx
{
    [self.mPageControl setCurrentPage:inx];
}

#pragma mark - Btn Action

- (void)onLeftArrowAction
{
    NSLog(@"%f-%f", self.mPackageView.packageScrollView.contentOffset.x, self.mPackageView.packageScrollView.contentSize.width);
    if (self.mPackageView.packageScrollView.contentOffset.x > 0) {
        [UIView animateWithDuration:0.3f animations:^{
            [self.mPackageView.packageScrollView setContentOffset:CGPointMake(self.mPackageView.packageScrollView.contentOffset.x-80, 0) animated:NO];
            int page = self.mPackageView.packageScrollView.contentOffset.x/80;
            [self.mPageControl setCurrentPage:page];
        } completion:^(BOOL finished) {
            
        }];
        
    }
}

- (void)onRightArrowAction
{
    NSLog(@"%f-%f", self.mPackageView.packageScrollView.contentOffset.x, self.mPackageView.packageScrollView.contentSize.width);
    if (self.mPackageView.packageScrollView.contentOffset.x < self.mPackageView.packageScrollView.contentSize.width-80) {
        [UIView animateWithDuration:0.3f animations:^{
            [self.mPackageView.packageScrollView setContentOffset:CGPointMake(self.mPackageView.packageScrollView.contentOffset.x+80, 0) animated:NO];
            int page = self.mPackageView.packageScrollView.contentOffset.x/80;
            [self.mPageControl setCurrentPage:page];
        } completion:^(BOOL finished) {
            
        }];
       
    }
}




@end
