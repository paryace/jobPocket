//
//  CustomShareVC.m
//  CTPocketV4
//
//  Created by apple on 14-4-16.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CustomShareVC.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiBoShareVC.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface CustomShareVC ()

@end

@implementation CustomShareVC

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 截取全屏
+(UIImage*)fullScreenshots{
    
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIGraphicsBeginImageContext(screenWindow.frame.size);//全屏截图，包括window
    
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return viewImage;
    
    //    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    
}
+(BOOL)deleteFromName:(NSString *)name
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //文件名
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:name];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (!blHave) {
        //NSLog(@"no  have");
        return NO;
    }else {
        //NSLog(@" have");
        BOOL blDele= [fileManager removeItemAtPath:uniquePath error:nil];
        if (blDele) {
            //NSLog(@"dele success");
            return YES;
        }else {
            //NSLog(@"dele fail");
            return NO;
        }
    }
}

+(BOOL) setPhotoToPath:(UIImage *)image isName:(NSString *)name
{
    //此处首先指定了图片存取路径（默认写到应用程序沙盒 中）
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    //并给文件起个文件名
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:name];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (blHave) {
        NSLog(@"already have");
        //delete
        [self deleteFromName:name];
    }
    NSData *data = UIImagePNGRepresentation(image);
    BOOL result = [data writeToFile:uniquePath atomically:YES];
    if (result) {
        NSLog(@"success");
        return YES;
    }else {
        NSLog(@"no success");
        return NO;
    }
}


//获取当前屏幕内容
+ (UIImage *)getNormalImage:(UIView *)view{
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)shareHandler:(UIImage*)image
{
    
    // 定义分享列表
    NSArray *shareList = [ShareSDK customShareListWithType:
                          SHARE_TYPE_NUMBER(ShareTypeWeixiSession),
                          SHARE_TYPE_NUMBER(ShareTypeWeixiTimeline),
                          SHARE_TYPE_NUMBER(ShareTypeYiXinSession),
                          SHARE_TYPE_NUMBER(ShareTypeYiXinTimeline),
                          [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:ShareTypeSinaWeibo]
                                                             icon:[ShareSDK getClientIconWithType:ShareTypeSinaWeibo]
                                                     clickHandler:^{
                                                         WeiBoShareVC *wbVC = [[WeiBoShareVC alloc]init];
                                                         wbVC.image = image;
                                                         wbVC.shareType = SinaWeibo;
                                                         wbVC.shareText = [[NSUserDefaults standardUserDefaults] objectForKey:@"shareContent"];
                                                         UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:wbVC];
                                                         [MyAppDelegate.tabBarController presentModalViewController:naVC animated:YES];
                                                     }],
                          SHARE_TYPE_NUMBER(ShareTypeQQ),
                          SHARE_TYPE_NUMBER(ShareTypeQQSpace),
                          [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:ShareTypeTencentWeibo]
                                                             icon:[ShareSDK getClientIconWithType:ShareTypeTencentWeibo]
                                                     clickHandler:^{
                                                         WeiBoShareVC *wbVC = [[WeiBoShareVC alloc]init];
                                                         wbVC.image = image;
                                                         wbVC.shareType = TencentWeibo;
                                                         wbVC.shareText = [[NSUserDefaults standardUserDefaults] objectForKey:@"shareContent"];
                                                         UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:wbVC];
                                                         [MyAppDelegate.tabBarController presentModalViewController:naVC animated:YES];
                                                     }],
                          [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:ShareTypeRenren]
                                                             icon:[ShareSDK getClientIconWithType:ShareTypeRenren]
                                                     clickHandler:^{
                                                         WeiBoShareVC *wbVC = [[WeiBoShareVC alloc]init];
                                                         wbVC.image = image;
                                                         wbVC.shareType = renrenWeibo;
                                                         wbVC.shareText = [[NSUserDefaults standardUserDefaults] objectForKey:@"shareContent"];
                                                         UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:wbVC];
                                                         [MyAppDelegate.tabBarController presentModalViewController:naVC animated:YES];
                                                     }],
                          SHARE_TYPE_NUMBER(ShareTypeSMS),
                          nil];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[[NSUserDefaults standardUserDefaults] objectForKey:@"shareContent"]
                                       defaultContent:nil
                                                image:[ShareSDK jpegImageWithImage:image quality:0.8]
                                                title:APPTITLE
                                                  url:SHARE_DOWNLOAD_URL
                                          description:[[NSUserDefaults standardUserDefaults] objectForKey:@"shareContent"]
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authoption = [ShareSDK authOptionsWithAutoAuth:YES
                                                        allowCallback:YES
                                                        authViewStyle:SSAuthViewStyleFullScreenPopup
                                                         viewDelegate:nil
                                              authManagerViewDelegate:nil];
    
    [authoption setPowerByHidden:YES];  //分享界面powerby去掉
    
    
    id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"内容分享"      //分享视图标题
                                                              oneKeyShareList:nil  //[NSArray defaultOneKeyShareList]           //一键分享菜单
                                                               qqButtonHidden:YES                               //QQ分享按钮是否隐＋藏
                                                        wxSessionButtonHidden:YES                   //微信好友分享按钮是否隐藏
                                                       wxTimelineButtonHidden:YES                 //微信朋友圈分享按钮是否隐藏
                                                         showKeyboardOnAppear:NO                  //是否显示键盘
                                                            shareViewDelegate:nil                            //分享视图委托
                                                          friendsViewDelegate:nil                          //好友视图委托
                                                        picViewerViewDelegate:nil];                    //图片浏览视图委托
    
    
    /*
     id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"内容分享"
     oneKeyShareList:nil
     cameraButtonHidden:NO
     mentionButtonHidden:NO
     topicButtonHidden:NO
     qqButtonHidden:YES
     wxSessionButtonHidden:YES
     wxTimelineButtonHidden:YES
     showKeyboardOnAppear:YES
     shareViewDelegate:nil
     friendsViewDelegate:nil
     picViewerViewDelegate:nil];
     */
    
    
    
    [ShareSDK showShareActionSheet:nil
                         shareList:shareList
                           content:publishContent
                     statusBarTips:NO
                       authOptions:authoption
                      shareOptions: shareOptions
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                    [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                    [SVProgressHUD showErrorWithStatus:@"分享失败"];
                                }
                            }];
}

@end
