//
//  CTValueAddedVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-11-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//  增值业务

#import "CTValueAddedVCtler.h"
#import "AppDelegate.h"
#import "CTValueAddedView.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"
#import "CTOrderSuccessVCtler.h"

@interface CTValueAddedVCtler () <CTValueAddedViewDelegate>
{
    NSMutableArray *_itemList;
    UIScrollView *_itemScrollView;
}

@end

@implementation CTValueAddedVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // 标题
        self.title = @"增值业务办理";
        // 左按钮
        [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _itemList = [NSMutableArray array];
    
    _itemScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _itemScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _itemScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_itemScrollView];
    
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy年MM月dd日"];
        // 办理日期
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 16)];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = [UIFont systemFontOfSize:14.0f];
        dateLabel.textColor = [UIColor blackColor];
        dateLabel.text = [NSString stringWithFormat:@"办理日期：%@", [df stringFromDate:[NSDate date]]];
        [_itemScrollView addSubview:dateLabel];
        
        NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
        NSString *phoneNbr = loginInfoDict[@"UserLoginName"] ? loginInfoDict[@"UserLoginName"] : @"";
        // 办理手机号码
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20+16+8, 280, 16)];
        phoneLabel.backgroundColor = [UIColor clearColor];
        phoneLabel.font = [UIFont systemFontOfSize:14.0f];
        phoneLabel.textColor = [UIColor blackColor];
        phoneLabel.text = [NSString stringWithFormat:@"办理手机号码：%@", phoneNbr];
        [_itemScrollView addSubview:phoneLabel];
        
        // 分割线
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 76, self.view.bounds.size.width, 1)];
        separator.backgroundColor = [UIColor colorWithRed:0.84f green:0.84f blue:0.84f alpha:1.00f];
        [_itemScrollView addSubview:separator];
        
        //
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 92, 280, 16)];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.font = [UIFont systemFontOfSize:14.0f];
        tipLabel.textColor = [UIColor blackColor];
        tipLabel.text = @"请选择所需办理的增值业务：";
        [_itemScrollView addSubview:tipLabel];
    }
    
    [self qryBusinessFind];
    [self qryProductInfo];
}

#pragma mark - Custom Methods

- (void)qryBusinessFind
{
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNbr = loginInfoDict[@"UserLoginName"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            ESHORE_ShopId, @"ShopId",
                            phoneNbr, @"PhoneNumber",
                            @"1", @"Index",
                            @"40", @"PageSize", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryBusinessFind"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          if ([dict[@"Data"][@"Item"] isKindOfClass:[NSArray class]])
                                          {
                                              [_itemList addObjectsFromArray:dict[@"Data"][@"Item"]];
                                          }
                                          else if ([dict[@"Data"][@"Item"] isKindOfClass:[NSDictionary class]])
                                          {
                                              [_itemList addObject:dict[@"Data"][@"Item"]];
                                          }
                                          
                                          CGFloat originY = 120;
                                          int i = 1;
                                          for (NSDictionary *dict in _itemList) {
                                              CTValueAddedView *view = [[CTValueAddedView alloc] initWithFrame:CGRectMake(18, originY, 284, 104)];
                                              view.delegate = self;
                                              [view setContent:dict AndTag:i];
                                              [_itemScrollView addSubview:view];
                                              
                                              originY = originY + 114;
                                              i++;
                                          }
                                          _itemScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, originY);
                                          
                                      } onError:^(NSError *engineError) {
                                                                                    
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
                                              }
                                          }
                                          else
                                          {
                                              if ([engineError.localizedDescription isEqualToString:@"似乎已断开与互联网的连接。"]) {
                                                  // 取消掉全部请求和回调，避免出现多个弹框
                                                  [MyAppDelegate.cserviceEngine cancelAllOperations];
                                              }
                                              
                                              SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                               andMessage:engineError.localizedDescription];
                                              [alertView addButtonWithTitle:@"确定"
                                                                       type:SIAlertViewButtonTypeDefault
                                                                    handler:^(SIAlertView *alertView) {
                                                                        NSLog(@"取消");
                                                                    }];
                                              alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                              [alertView show];
                                          }
                                          
                                      }];
}

- (void)qryProductInfo
{
    NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
    NSString *phoneNbr = loginInfoDict[@"UserLoginName"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            phoneNbr, @"PhoneNbr", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryProductInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict) {
                                          
                                          int i = 1;
                                          for (NSDictionary *obj1 in _itemList) {
                                              if ([dict[@"Data"][@"ResultInfo"] isKindOfClass:[NSArray class]])
                                              {
                                                  for (NSDictionary *obj2 in dict[@"Data"][@"ResultInfo"]) {
                                                      if ([obj1[@"ProdCode"] isEqualToString:obj2[@"VProductId"]]) {
                                                          CTValueAddedView *view = (CTValueAddedView *)[_itemScrollView viewWithTag:i];
                                                          [view setOrderBtnTitle:@"退订"];
                                                          break;
                                                      }
                                                  }
                                              }
                                              else if ([dict[@"Data"][@"ResultInfo"] isKindOfClass:[NSDictionary class]])
                                              {
                                                  if ([obj1[@"ProdCode"] isEqualToString:dict[@"Data"][@"ResultInfo"][@"VProductId"]]) {
                                                      CTValueAddedView *view = (CTValueAddedView *)[_itemScrollView viewWithTag:i];
                                                      [view setOrderBtnTitle:@"退订"];
                                                  }
                                              }
                                              
                                              i++;
                                          }
                                          
                                      } onError:^(NSError *engineError) {
                                          
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
                                              }
                                          }
                                          else
                                          {
                                              if ([engineError.localizedDescription isEqualToString:@"似乎已断开与互联网的连接。"]) {
                                                  // 取消掉全部请求和回调，避免出现多个弹框
                                                  [MyAppDelegate.cserviceEngine cancelAllOperations];
                                              }
                                              
                                              SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                               andMessage:engineError.localizedDescription];
                                              [alertView addButtonWithTitle:@"确定"
                                                                       type:SIAlertViewButtonTypeDefault
                                                                    handler:^(SIAlertView *alertView) {
                                                                        NSLog(@"取消");
                                                                    }];
                                              alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                              [alertView show];
                                          }
                                          
                                      }];
}

#pragma mark - CTValueAddedViewDelegate

- (void)didSelectOrderButton:(int)tag
{
    CTValueAddedView *view = (CTValueAddedView *)[_itemScrollView viewWithTag:tag];
    NSLog(@"%@", view.orderBtn.titleLabel.text);
    if ([view.orderBtn.titleLabel.text isEqualToString:@"订购"])
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:[NSString stringWithFormat:@"您确定要开通%@吗？", _itemList[tag-1][@"ProdName"]]];
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  NSLog(@"取消");
                              }];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [SVProgressHUD showWithStatus:@"订购中..." maskType:SVProgressHUDMaskTypeGradient];
                                  
                                  NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
                                  NSString *phoneNbr = loginInfoDict[@"UserLoginName"];
                                  
                                  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          phoneNbr, @"PhoneNbr",
                                                          @"0", @"ActionType",
                                                          @"0", @"ProductOfferType",
                                                          _itemList[tag-1][@"ProdCode"], @"ProductOfferID", nil];
                                  
                                  [MyAppDelegate.cserviceEngine postXMLWithCode:@"productOfferInfo"
                                                                         params:params
                                                                    onSucceeded:^(NSDictionary *dict) {
                                                                        [SVProgressHUD dismiss];
                                                                        CTOrderSuccessVCtler *vc = [[CTOrderSuccessVCtler alloc] init];
                                                                        vc.actionType = 0;
                                                                        vc.prodName = _itemList[tag-1][@"ProdName"];
                                                                        [self.navigationController pushViewController:vc animated:YES];
                                                                        
                                                                    } onError:^(NSError *engineError) {
                                                                        [SVProgressHUD showErrorWithStatus:engineError.localizedDescription];
                                                                        
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
                                                                            }
                                                                            else
                                                                            {
                                                                                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                                                                 andMessage:engineError.localizedDescription];
                                                                                [alertView addButtonWithTitle:@"确定"
                                                                                                         type:SIAlertViewButtonTypeDefault
                                                                                                      handler:^(SIAlertView *alertView) {
                                                                                                          NSLog(@"取消");
                                                                                                      }];
                                                                                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                                                [alertView show];
                                                                            }
                                                                        }
 
                                                                    }];
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }
    else if ([view.orderBtn.titleLabel.text isEqualToString:@"退订"])
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:[NSString stringWithFormat:@"您确定要退订%@吗？", _itemList[tag-1][@"ProdName"]]];
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  NSLog(@"取消");
                              }];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [SVProgressHUD showWithStatus:@"退订中..." maskType:SVProgressHUDMaskTypeGradient];
                                  
                                  NSDictionary *loginInfoDict = [Global sharedInstance].loginInfoDict;
                                  NSString *phoneNbr = loginInfoDict[@"UserLoginName"];
                                  
                                  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          phoneNbr, @"PhoneNbr",
                                                          @"1", @"ActionType",
                                                          @"0", @"ProductOfferType",
                                                          _itemList[tag-1][@"ProdCode"], @"ProductOfferID", nil];
                                  
                                  [MyAppDelegate.cserviceEngine postXMLWithCode:@"productOfferInfo"
                                                                         params:params
                                                                    onSucceeded:^(NSDictionary *dict) {
                                                                        [SVProgressHUD dismiss];
                                                                        NSLog(@"%@", dict);
                                                                        CTOrderSuccessVCtler *vc = [[CTOrderSuccessVCtler alloc] init];
                                                                        vc.actionType = 1;
                                                                        vc.prodName = _itemList[tag-1][@"ProdName"];
                                                                        [self.navigationController pushViewController:vc animated:YES];
                                                                        
                                                                    } onError:^(NSError *engineError) {
                                                                        [SVProgressHUD dismiss];
                                                                        
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
                                                                            }
                                                                        }
                                                                        else
                                                                        {
                                                                            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                                                                             andMessage:engineError.localizedDescription];
                                                                            [alertView addButtonWithTitle:@"确定"
                                                                                                     type:SIAlertViewButtonTypeDefault
                                                                                                  handler:^(SIAlertView *alertView) {
                                                                                                      NSLog(@"取消");
                                                                                                  }];
                                                                            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                                                                            [alertView show];
                                                                        }
                                                                        
                                                                    }];
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }
}

- (void)layoutAllViews:(CTValueAddedView *)view
{
    // 重排全部CTValueAddedView位置
    CGFloat originY = 120;
    for (int i = 1; i <= [_itemList count]; i++)
    {
        CTValueAddedView *view = (CTValueAddedView *)[_itemScrollView viewWithTag:i];
        CGRect rect = view.frame;
        rect.origin.y = originY;
        view.frame = rect;
        
        originY = originY + rect.size.height + 10;
    }
    
    _itemScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, originY);
}

@end
