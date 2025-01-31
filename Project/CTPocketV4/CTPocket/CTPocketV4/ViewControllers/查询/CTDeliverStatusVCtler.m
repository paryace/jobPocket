//
//  CTDeliverStatusVCtler.m
//  CTPocketV4
//
//  Created by 许忠洲 on 13-11-26.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//  物流状态

#import "CTDeliverStatusVCtler.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "ToastAlertView.h"

@interface CTDeliverStatusVCtler ()
{
    UIScrollView *_deliverScrollView;
}

@end

@implementation CTDeliverStatusVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // 标题
        self.title = @"物流状态";
        // 左按钮
        [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _deliverScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _deliverScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_deliverScrollView];
    
    [self showLoadingAnimated:YES];
    [self qryFreightStateInfo];
}

- (void)qryFreightStateInfo
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.orderId, @"OrderId", nil];
    
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryFreightStateInfo"
                                           params:params
                                      onSucceeded:^(NSDictionary *dict)
    {
        //格式化数据(将指定的数据格式化成数组)
        dict = [Utils objFormatArray:dict path:@"Data/FreightStateList"];
                                          
          [self hideLoadingViewAnimated:YES];
          
          // 现实物流信息
          {
              CGFloat originY = 16.0f;
              
              // 订单号
              UILabel *OrderNo = [[UILabel alloc] initWithFrame:CGRectMake(18, originY, 284, 16)];
              OrderNo.backgroundColor = [UIColor clearColor];
              OrderNo.font = [UIFont boldSystemFontOfSize:14.0f];
              OrderNo.textColor = [UIColor blackColor];
              OrderNo.text = [NSString stringWithFormat:@"订单号：%@", dict[@"Data"][@"OrderNo"]];
              [_deliverScrollView addSubview:OrderNo];
              originY = originY + 20.0f;
              
              // 物流单位
              UILabel *FreightCo = [[UILabel alloc] initWithFrame:CGRectMake(18, originY, 284, 16)];
              FreightCo.backgroundColor = [UIColor clearColor];
              FreightCo.font = [UIFont boldSystemFontOfSize:14.0f];
              FreightCo.textColor = [UIColor blackColor];
              FreightCo.text = [NSString stringWithFormat:@"物流单位：%@", dict[@"Data"][@"FreightCo"]];
              [_deliverScrollView addSubview:FreightCo];
              originY = originY + 20.0f;
              
              // 货运单号
              UILabel *FreightNo = [[UILabel alloc] initWithFrame:CGRectMake(18, originY, 284, 16)];
              FreightNo.backgroundColor = [UIColor clearColor];
              FreightNo.font = [UIFont boldSystemFontOfSize:14.0f];
              FreightNo.textColor = [UIColor blackColor];
              FreightNo.text = [NSString stringWithFormat:@"货运单号：%@", dict[@"Data"][@"FreightNo"]];
              [_deliverScrollView addSubview:FreightNo];
              originY = originY + 16 + 16;
              
              // 分割线
              UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, originY, self.view.bounds.size.width, 1)];
              separator.backgroundColor = [UIColor colorWithRed:0.84f green:0.84f blue:0.84f alpha:1.00f];
              [_deliverScrollView addSubview:separator];
              originY = originY + 1 + 8;
              
              int i = 1;
              NSArray *tList = [NSArray array];
              if (dict[@"Data"][@"FreightStateList"] != nil)
              {
                  tList = [NSArray arrayWithArray:dict[@"Data"][@"FreightStateList"]];
              }
              
              for (NSDictionary *FreightStateItem in tList)
              {
                  // 时间
                  UILabel *StateDate = [[UILabel alloc] initWithFrame:CGRectMake(56, originY, 244, 16)];
                  StateDate.backgroundColor = [UIColor clearColor];
                  StateDate.font = [UIFont systemFontOfSize:14.0f];
                  StateDate.textColor = [UIColor blackColor];
                  StateDate.text = FreightStateItem[@"StateDate"];
                  [_deliverScrollView addSubview:StateDate];
                  originY = originY + 20;
                  
                  // 状态
                  UILabel *FreightStateName = [[UILabel alloc] initWithFrame:CGRectMake(56, originY, 244, 16)];
                  FreightStateName.backgroundColor = [UIColor clearColor];
                  FreightStateName.font = [UIFont systemFontOfSize:14.0f];
                  FreightStateName.textColor = [UIColor blackColor];
                  FreightStateName.numberOfLines = 0;
                  FreightStateName.text = FreightStateItem[@"FreightStateName"];
                  [FreightStateName sizeToFit];
                  [_deliverScrollView addSubview:FreightStateName];
                  originY = originY + FreightStateName.bounds.size.height + 8;
                  
                  if (i != [dict[@"Data"][@"FreightStateList"] count])
                  {
                      // 分割线
                      UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, originY, self.view.bounds.size.width, 1)];
                      separator.backgroundColor = [UIColor colorWithRed:0.84f green:0.84f blue:0.84f alpha:1.00f];
                      [_deliverScrollView addSubview:separator];
                      originY = originY + 1 + 8;
                  }
                  
                  i++;
              }
              
              _deliverScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, originY);
          }
          
      } onError:^(NSError *engineError) {
          
          [self hideLoadingViewAnimated:YES];
          
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
              ToastAlertView *alert = [ToastAlertView new];
              [alert showAlertMsg:@"engineError.localizedDescription"];
          }
          
      }];
}

@end
