//
//  WeiBoShareVC.m
//  iMovie
//
//  Created by 许 忠洲 on 13-5-21.
//  Copyright (c) 2013年 eshore. All rights reserved.
//  微博分享编辑视图

#import "WeiBoShareVC.h"
#import <ShareSDK/ShareSDK.h>
#import "ToastAlertView.h"
#import "SVProgressHUD.h"
#import "ZoomingViewController.h"

#define SHARE_MESSAGE_PRINT(_SHARE_STATE_) \
switch (_SHARE_STATE_) {\
    case SSResponseStateSuccess:\
    {\
        NSLog(@"发送成功");\
        [SVProgressHUD showSuccessWithStatus:@"分享成功"];\
    }\
        break;\
    case SSResponseStateFail:\
    {\
        NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);\
        [SVProgressHUD showErrorWithStatus:@"分享失败"];\
    }\
        break;\
    case SSResponseStateCancel:\
    {\
        NSLog(@"发送取消");\
    }\
        break;\
    default:\
        break;\
}

@interface WeiBoShareVC ()

@end

@implementation WeiBoShareVC
@synthesize shareType, shareText, imageUrl, filmName, shareUrlStr, showDate;
@synthesize shareTextView;

- (void)setShareText:(NSString *)ashareText
{
    if (ashareText.length > 117) {
        ashareText = [NSString stringWithFormat:@"%@...", [ashareText substringToIndex:117]];
    }
    shareText = ashareText;
}

- (void)shareToWeibo
{
    [shareTextView resignFirstResponder];
    
    double number = [shareTextView.text length];
    
    if (number > 120.0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"分享内容不可以超过120个字！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSMutableString *shareStr = [NSMutableString stringWithString:shareTextView.text];
    
    //FIXME:
    if (_extraText.length)
        [shareStr appendString:_extraText];
    
    // 构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:shareStr
                                       defaultContent:nil //@"默认分享内容，没内容时显示"
                                                image:[ShareSDK pngImageWithImage:coverImage.image]
                                                title:@"掌上营业厅"
                                                  url:@"http://189.io/BeWGdn"
                                          description:shareStr
                                            mediaType:SSPublishContentMediaTypeNews];
        
    // 授权选项
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    [authOptions setPowerByHidden:YES];
    
    switch (self.shareType) {
        case SinaWeibo:
        {
            if ([ShareSDK hasAuthorizedWithType:ShareTypeSinaWeibo]) {
                // 分享
                [ShareSDK shareContent:publishContent
                                  type:ShareTypeSinaWeibo
                           authOptions:authOptions
                         statusBarTips:NO
                                result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                        if (state == SSResponseStateFail) {
                                            [self showShareFailAlert];
                                        }
                                        SHARE_MESSAGE_PRINT(state);
                                }];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [ShareSDK authWithType:ShareTypeSinaWeibo
                               options:authOptions
                                result:^(SSAuthState state, id<ICMErrorInfo> error) {
                                    if (state == SSAuthStateSuccess) {
                                        // 分享
                                        [ShareSDK shareContent:publishContent
                                                          type:ShareTypeSinaWeibo
                                                   authOptions:authOptions
                                                 statusBarTips:NO
                                                        result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                                            SHARE_MESSAGE_PRINT(state);
                                                        }];
                                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                    } else if (state == SSAuthStateFail) {
                                        [self showAuthFailAlert];
                                    }
                                }];
            }
        }
            break;
        case TencentWeibo:
        {
            if ([ShareSDK hasAuthorizedWithType:ShareTypeTencentWeibo]) {
                // 分享
                [ShareSDK shareContent:publishContent
                                  type:ShareTypeTencentWeibo
                           authOptions:authOptions
                         statusBarTips:NO
                                result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                    if (state == SSResponseStateFail) {
                                        [self showShareFailAlert];
                                    }
                                    SHARE_MESSAGE_PRINT(state);
                                }];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [ShareSDK authWithType:ShareTypeTencentWeibo
                               options:authOptions
                                result:^(SSAuthState state, id<ICMErrorInfo> error) {
                                    if (state == SSAuthStateSuccess) {
                                        // 分享
                                        [ShareSDK shareContent:publishContent
                                                          type:ShareTypeTencentWeibo
                                                   authOptions:authOptions
                                                 statusBarTips:NO
                                                        result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                                            SHARE_MESSAGE_PRINT(state);
                                                        }];
                                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                    } else if (state == SSAuthStateFail) {
                                        [self showAuthFailAlert];
                                    }
                                }];
            }
        }
            break;
        case renrenWeibo:
        {
            if ([ShareSDK hasAuthorizedWithType:ShareTypeRenren]) {
                // 分享
                [ShareSDK shareContent:publishContent
                                  type:ShareTypeRenren
                           authOptions:authOptions
                         statusBarTips:NO
                                result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                    if (state == SSResponseStateFail) {
                                        [self showShareFailAlert];
                                    }
                                    SHARE_MESSAGE_PRINT(state);
                                }];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [ShareSDK authWithType:ShareTypeRenren
                               options:authOptions
                                result:^(SSAuthState state, id<ICMErrorInfo> error) {
                                    if (state == SSAuthStateSuccess) {
                                        // 分享
                                        [ShareSDK shareContent:publishContent
                                                          type:ShareTypeRenren
                                                   authOptions:authOptions
                                                 statusBarTips:NO
                                                        result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                                            SHARE_MESSAGE_PRINT(state);
                                                        }];
                                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                    } else if (state == SSAuthStateFail) {
                                        [self showAuthFailAlert];
                                    }
                                }];
            }
        }
            break;
        default:
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

#pragma mark -

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
    // 返回按钮
    {
        UIImage *image = [UIImage imageNamed:@"btn_back"];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
//        [button setTitle:@"返回" forState:UIControlStateNormal];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self.navigationController action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    // 标题
    switch (self.shareType) {
        case SinaWeibo:
            self.title = @"分享到新浪微博";
            break;
        case TencentWeibo:
            self.title = @"分享到腾讯微博";
            break;
        case renrenWeibo:
            self.title = @"分享到人人网";
            break;
        default:
            self.title = @"分享";
            break;
    }
    // 分享按钮
    {
        UIImage *image = [UIImage imageNamed:@"btn_share"];
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0.0, 0.0, image.size.width , image.size.height)];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"btn_share_press"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(shareToWeibo) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    }
    CGFloat tvHeight = 960/2-20-44-252-8-8-8-40;
    if (iPhone5) {
        tvHeight = 1136/2-20-44-252-8-8-8-40;
    }
    // 文本框
    {
        shareTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, 8, 320-16, tvHeight)];
        shareTextView.delegate = self;
        shareTextView.layer.cornerRadius = 2.0f;
        shareTextView.layer.masksToBounds = YES;
        shareTextView.font = [UIFont systemFontOfSize:14.0f];
        shareTextView.text = shareText;
        [self.view addSubview:shareTextView];
        [shareTextView becomeFirstResponder];
    }
    // 海报
    {
        coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8+tvHeight+8, 40, 40)];
        coverImage.image = self.image;
        
        btnImage = [[UIButton alloc] initWithFrame:CGRectMake(8, 8+tvHeight+8, 40, 40)];
        [btnImage setImage:self.image forState:UIControlStateNormal];
        [btnImage setAdjustsImageWhenHighlighted:NO];
        [self.view addSubview:btnImage];
        
        zoomingViewController = [[ZoomingViewController alloc] init];
        zoomingViewController.textview = shareTextView;
        zoomingViewController.view = btnImage;
    }
    // 还可以输入文字数
    {
        tip = [[UILabel alloc] initWithFrame:CGRectMake(160, 8+tvHeight+8, 320-160-8, 14)];
        tip.backgroundColor = [UIColor clearColor];
        tip.textAlignment = UITextAlignmentRight;
        tip.font = [UIFont systemFontOfSize:12];
        tip.textColor = [UIColor grayColor];
        
        double number = [shareTextView.text length];
        
        tip.text = [NSString stringWithFormat:@"还可以输入%d个字", (int)(120.0 - number)];
        [self.view addSubview:tip];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [shareTextView resignFirstResponder];
    [super viewWillDisappear:animated];
    [zoomingViewController dismissFullscreenView];
}


#pragma mark - TextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    double number = [shareTextView.text length];
    
    tip.text = [NSString stringWithFormat:@"还可以输入%d个字", (int)(120.0 - number)];
}

#pragma mark - UIViewController Rotation 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)showAuthFailAlert
{

}

- (void)showShareFailAlert
{
    ToastAlertView* alert = [ToastAlertView new];
    [alert showAlertMsg:@"分享失败"];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [shareTextView resignFirstResponder];
}

@end
