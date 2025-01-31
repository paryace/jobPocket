//
//  BBNWRequstProcess.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  网络处理

#import "BBNWRequstProcess.h"

#import "AppDelegate.h"

#import "Utils.h"
#import "SIAlertView.h"
#import "SVProgressHUD.h"
#import "ToastAlertView.h"

#import "BBTopViewManager.h"
#import "BBTRequestParamModel.h"
#import "BBTopRepDataModel.h"

#import "BBCenterViewManager.h"
#import "BBCRequestParamModel.h"
#import "BBCenterRepDataModel.h"
#import "BBTopItemDataModel.h"
#import "CTCity.h"

@implementation BBNWRequstProcess
#pragma mark - 请求区域信息
#pragma mark 把模型转化为格式为dictionary请求参数
-(NSDictionary*)dictionaryWIthTopParamModel:(BBTRequestParamModel*)model
{
    NSString *CityCode=model.CityCode?model.CityCode:@"";
    NSString *ProvinceCode=model.ProvinceCode?model.ProvinceCode:@"";
    NSString *Type=[NSString stringWithFormat:@"%i",model.Type];
    return @{@"CityCode":CityCode,@"ProvinceCode":ProvinceCode,@"Type":Type};
}

#pragma mark 请求省份或城市或地区
-(void)requestTopWithParmaModel:(BBTRequestParamModel*)model
{
    
    if (model.cachePath&&model.topType!=BBT_P)
    {
        BBTopRepDataModel *top=[[BBTopRepDataModel alloc] init];
        [top readFromFile:model.cachePath];
        if (top.Data.count>0)
        {
            switch (model.topType) { 
                case BBT_C:
                {
                    [self.tManager updateCinty:top.Data];
                }
                    break;
                case BBT_R:
                {
                      [self.tManager updateRegion:top.Data];
                }
                    break;
                    
                default:
                    break;
            }
            return;
        }
    }
    
      [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    __weak typeof(self) weakSelf=self;
    __block typeof(model) weakmodel=model;
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryOrganization"
                                           params:[self dictionaryWIthTopParamModel:model]
                                      onSucceeded:^(NSDictionary *dict)
    {
        //格式化数据(将指定的数据格式化成数组)
        dict = [Utils objFormatArray:dict path:@"Data/Items"];
        
        id Data = [dict objectForKey:@"Data"];
        
        id Items = [Data objectForKey:@"Items"];
        NSArray * arr = nil;
        if (Items != nil)
        {
            arr = Items;
        }
        else
        {
            arr = [NSArray array];
        }
           BBTopRepDataModel *top=[[BBTopRepDataModel alloc] init];
          [top transformWithArray:arr];
          switch (weakmodel.topType) {
              case BBT_P:
              {
                  [weakSelf.tManager updateProvince:top.Data];
              }
                  break;
              case BBT_C:
              {
                  [weakSelf.tManager updateCinty:top.Data];
              }
                  break;
              case BBT_R:
              {
                  [weakSelf.tManager updateRegion:top.Data];
              }
                  break;
                  
              default:
                  break;
          }
        if (weakmodel.cachePath&&weakmodel.topType!=BBT_P) {//省份的数据不写到硬盘上
             [top writeToFile:weakmodel.cachePath];
        }
       
          [SVProgressHUD dismiss];
      } onError:^(NSError *engineError) {
          
          [self.tManager occurError:engineError];
          [SVProgressHUD dismiss];
          if ([engineError.userInfo objectForKey:@"ResultCode"])
          {
              if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"X104"])
              {
                  // 取消掉全部请求和回调，避免出现多个弹框
                  [MyAppDelegate.cserviceEngine cancelAllOperations];
              }
          }
          else{
              ToastAlertView *alert = [ToastAlertView new];
              [alert showAlertMsg:@"系统繁忙,请重新提交"];
          }
      }];

}

 
#pragma mark - 请求查询的信息

#pragma mark 把模型转化为格式为dictionary请求参数
-(NSDictionary*)dictionaryWIthCenterParamModel:(BBCRequestParamModel*)model
{
    NSString *areaId=model.AreaId?model.AreaId:@"";
    NSString *ComName=model.ComName?model.ComName:@"";
    NSString *PageIndex=[NSString stringWithFormat:@"%i",model.PageIndex];
    NSString *PageSize=[NSString stringWithFormat:@"%i",model.PageSize];
    return @{@"AreaId":areaId,@"ComName":ComName,@"PageIndex":PageIndex,@"PageSize":PageSize};
}

-(void)requestSearch:(BBCRequestParamModel*)model
{
   
    if (self.tManager.currentR==nil)
    {
        [[ToastAlertView new] showAlertMsg:@"亲，请先选择省份和市区"];
        return ;
    }
    if (model.ComName==nil||model.ComName.length==0)
    {
        [[ToastAlertView new] showAlertMsg:@"亲，您还没填写小区哦"];
        return ;
    }
    model.AreaId=self.tManager.currentR.Freight_Area_Code;//地区编码
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    __weak typeof(self) weakSelf=self;
    [MyAppDelegate.cserviceEngine postXMLWithCode:@"qryBroadbandInfo"
                                           params:[self dictionaryWIthCenterParamModel:model]
                                      onSucceeded:^(NSDictionary *dict) {
                                          id Data = [dict objectForKey:@"Data"];
                                          
                                          id DataList = [Data objectForKey:@"DataList"];
                                          
                                          id Items = [DataList objectForKey:@"Items"];
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
                                          BBCenterRepDataModel *repData=[[BBCenterRepDataModel alloc] init];
                                          repData.TotalCount=[Data[@"TotalCount"] integerValue];
                                          [repData transformWithArray:arr];
                                          [weakSelf.cManager updateWithData:repData];
                                          [SVProgressHUD dismiss];
                                      } onError:^(NSError *engineError) {
                                          [SVProgressHUD dismiss];
                                          [self.cManager occurError:engineError];
                                          // 取消掉全部请求和回调，避免出现多个弹框
                                          [MyAppDelegate.cserviceEngine cancelAllOperations];
                                          if ([engineError.userInfo objectForKey:@"ResultCode"])
                                          {
                                              if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"X104"])
                                              {
                                              }
                                          }
                                          else{
//                                              ToastAlertView *alert = [ToastAlertView new];
//                                              [alert showAlertMsg:@"系统繁忙,请重新提交"];
                                          }
                                      }];
}
#pragma mark 清除界面中间的tableview的数据
-(void)resetCenter
{
    [self.cManager reset];
}

//added by huangfq 2014-6-27
- (void) getLocationByphoneNbrInfo:(BBTRequestParamModel*)model
{
    
    if (![Global sharedInstance].areaInfo) {
        
        [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
        
        __weak typeof(self) weakSelf=self;
        __block typeof(model) weakmodel=model;
        //用户归属地查询
        NSString *PhoneNbr = [Global sharedInstance].loginInfoDict [@"UserLoginName"];
        NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                                   PhoneNbr, @"PhoneNbr",
                                   nil];
        
        [MyAppDelegate.cserviceEngine postXMLWithCode:@"getLocationByphoneNbrInfo"
                                               params:params
                                          onSucceeded:^(NSDictionary *dict) {
                                              DDLogInfo(@"%s--%@", __func__, dict.description);
                                              id Data = [dict objectForKey:@"Data"];
                                              if (Data) {
                                                  
                                                  NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                              [Data objectForKey:@"ProvinceCode"],@"provincecode",
                                                                              [Data objectForKey:@"CityCode"],@"citycode",
                                                                              [Data objectForKey:@"City"],@"cityname",
                                                                              @"",@"hbcitycode",
                                                                              @"",@"hbprovincecode",
                                                                              @"",@"citynameAlph",
                                                                              [Data objectForKey:@"Province"],@"provincename",
                                                                              nil];
                                                  
                                                  CTCity *city = [CTCity modelObjectWithDictionary:dictionary];
                                                  [Global sharedInstance].areaInfo = city;
                                                  [weakSelf performSelectorOnMainThread:@selector(requestTopWithParmaModel:) withObject:weakmodel waitUntilDone:NO];
                                                  
                                                  [SVProgressHUD dismiss];
//                                                  [weakSelf requestTopWithParmaModel:weakmodel];
                                                  
                    
                                              }
                                          } onError:^(NSError *engineError) {
                                              
                                              [SVProgressHUD dismiss];
                                          }];

    }
    else
    {
        [self requestTopWithParmaModel:model];
    }
}

@end
