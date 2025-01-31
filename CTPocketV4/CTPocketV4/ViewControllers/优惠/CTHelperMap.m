//
//  CTHelperMap.m
//  CTPocketV4
//
//  Created by liuruxian on 14-1-15.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTHelperMap.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "ToastAlertView.h"
#import "CTQryCity.h"
#import "CTHBMapViewSingleton.h"

@interface CTHelperMap ()

@property (nonatomic, /*strong*/copy) LoactionBlock finishBlock;    // modified by zy, 2014-02-21
@property (nonatomic, strong) MAReverseGeocodingInfo *userAddrinfo;

@property (nonatomic, strong) CserviceOperation * qryNumAttr;   // added by zy, 2014-02-21

@end

@implementation CTHelperMap

+ (CTHelperMap *) shareHelperMap
{
    static CTHelperMap *shareHelperMap = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken,^{
        shareHelperMap = [[CTHelperMap alloc] init];
    });
    
    return shareHelperMap;
}

- (id) init{
    
    self = [super init];
    
    if (self) {
        
        self.isSuccess = NO;
        self.isTip = NO ;
        MAMapView *mapView = [CTHBMapViewSingleton sharedSingleton];
        mapView.hidden = YES ;
        mapView.delegate = (id<MAMapViewDelegate>)self;
        [MyAppDelegate.window addSubview:mapView];
        self.mapView = mapView ;
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"8110100",@"citycode",
                                    @"609001",@"provincecode",
                                    @"北京",@"cityname",
                                    @"北京",@"provincename",
                                    @"110000",@"hbcitycode",
                                    @"",@"hbprovincecode",
                                    @"",@"ProvinceName",
                                    nil];
        
        CTCity *city = [CTCity modelObjectWithDictionary:dictionary];
        self.areaInfo = city ;
        
        //定位消息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(locationCurrentPos)
                                                     name:@"ReloadMsg" object:nil];
        //查询归属地
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkAttribute)
                                                     name:CHECKATTRIBUTEMSG object:nil];
        //更新定位或者归属地信息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataLocatedInfo)
                                                     name:LOCATIONCURMSG object:nil];
    }
    
    return  self;
}

- (void) locatedCurrentPosition
{
    //定位开始
    self.getAreaInfoBlock = nil;
}

- (void) qryAreaInfo {
    //登录成功 调用的消息
    if ([Global sharedInstance].isLogin == YES) {
        [self getLocationByphoneNbrInfo];
    }else{
        //定位
        if (!self.isSuccess) {
            [self.mapView setShowsUserLocation:YES];
//            @try
//            {
////
//            }
//            @catch(NSException * e)
//            {
//                NSLog(@"Exception: %@", e);
//            }
//            @finally {
//                UIAlertView * alert =[[UIAlertView alloc] initWithTitle:@"错误"
//                                                                message: @"智秀为何要让他出来啊～～!!!!!"
//                                                               delegate:self
//                                                      cancelButtonTitle:nil
//                                                      otherButtonTitles:@"OK", nil];
//                 [alert show];
//            }
        }
//        if (!self.isTip) {
//            self.isTip = YES;
//            __weak CTHelperMap * weakSelf = self;
//            [self setLocation:^(CTCity *cityInfo,NSError *error)
//             {
//                 if (cityInfo) {
//                     //使用城市对照表查询归属地
//                     [weakSelf filterContentForSearchText:cityInfo.hbcitycode];
//                 }else{
//                     //定位失败,使用默认得归属地信息 写死北京得数据
//                     NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                 @"8110100",@"citycode",
//                                                 @"609001",@"provincecode",
//                                                 @"北京",@"cityname",
//                                                 @"北京",@"provincename",
//                                                 @"110000",@"hbcitycode",
//                                                 @"",@"hbprovincecode",
//                                                 @"",@"ProvinceName",
//                                                 nil];
//                     
//                     CTCity *city = [CTCity modelObjectWithDictionary:dictionary];
//                     weakSelf.areaInfo = city ;
//                     weakSelf.isSuccess = NO;
//                     if (weakSelf.getAreaInfoBlock) {
//                         weakSelf.getAreaInfoBlock(city,nil);
//                     }
//                 }
//             }];
//            
//        }else
//        {
//            //用户授权使用定位服务
//            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
//            {
//                __weak __typeof(&*self)weakSelf = self;
//                [self setLocation:^(CTCity *cityInfo,NSError *error)
//                 {
//                     if (cityInfo) {
//                         //使用城市对照表查询归属地
//                         [weakSelf filterContentForSearchText:cityInfo.hbcitycode];
//                     }else{
//                         //定位失败,使用默认得归属地信息 写死北京得数据
//                         NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                     @"8110100",@"citycode",
//                                                     @"609001",@"provincecode",
//                                                     @"北京",@"cityname",
//                                                     @"北京",@"provincename",
//                                                     @"110000",@"hbcitycode",
//                                                     @"",@"hbprovincecode",
//                                                     @"",@"ProvinceName",
//                                                     nil];
//                         
//                         CTCity *city = [CTCity modelObjectWithDictionary:dictionary];
//                         weakSelf.areaInfo = city ;
//                         weakSelf.isSuccess = NO;
//                         
//                         if (weakSelf.getAreaInfoBlock) {
//                             weakSelf.getAreaInfoBlock(city,nil);
//                         }
//                     }
//                 }];
//            } else {
//                //定位未打开 且未登录得情况
//                if(self.isSuccess)
//                {
//                    
//                } else {
//                    self.isSuccess = NO ;
//                    //提示用户打开定位
//                    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                @"8110100",@"citycode",
//                                                @"609001",@"provincecode",
//                                                @"北京",@"cityname",
//                                                @"北京",@"provincename",
//                                                @"110000",@"hbcitycode",
//                                                @"",@"hbprovincecode",
//                                                @"",@"ProvinceName",
//                                                nil];
//                    
//                    CTCity *city = [CTCity modelObjectWithDictionary:dictionary];
//                    self.areaInfo = city ;
//                    if (self.getAreaInfoBlock) {
//                        self.getAreaInfoBlock(city,nil);
//                    }
//                }
//                return ;
//            }
//        }
    }
     DDLogInfo(@"^^^^^^^^^*****^^^^^^^^^%s",__func__);
}

//再次定位或者查询归属地信息
- (void) getAreaInfo : (GetAreaInfoBlock) Block
{
    if (Block) {
        self.getAreaInfoBlock = Block;
    }
    
    [self qryAreaInfo];
    DDLogInfo(@"^^^^^^^^^*****^^^^^^^^^%s",__func__);
}

//查找数据
- (void)filterContentForSearchText:(NSString*)searchText
{
    //匹配号百城市编码
    __weak __typeof(&*self)weakSelf = self;
    [[CTQryCity shareQryCity] qryCityFinishBlock:^(CTQryCity_Model *model,NSError *error)
     {
         NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(SELF.hbcitycode contains[cd] %@)",searchText];
         NSPredicate *tempPre = resultPredicate;
         
         id filteredArray = [model.citysArray filteredArrayUsingPredicate:tempPre];
         if (filteredArray && [filteredArray isKindOfClass:[NSArray class]])
         {
             NSArray *array = filteredArray;
             if (array.count>0) {
                 weakSelf.areaInfo = [filteredArray objectAtIndex:0];
             } else{
                 
             }
         } else if ([filteredArray isKindOfClass:[CTCity class]]) {
             weakSelf.areaInfo = filteredArray;
         }
         
         if (weakSelf.getAreaInfoBlock) {
             weakSelf.getAreaInfoBlock(weakSelf.areaInfo,nil);
         }
     }];
}

- (void) dealloc
{
    [self.mapView setDelegate:nil];
    [self.searchView setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - fun

- (void) setLocation : (LoactionBlock)finishBlock
{
    @try {
        
        self.finishBlock = finishBlock;
//        [self.mapView setShowsUserLocation:YES];
    }
    @catch (NSException *exception) {
        self.mapView=nil;
    }
    @finally {
        
    }
}

#pragma mark - NSNotification 

- (void) updataLocatedInfo
{
    //登录后发送的更新消息
    [self qryAreaInfo];
}

- (void) locationCurrentPos
{
    
}

- (void) checkAttribute
{
    [self getLocationByphoneNbrInfo];
}

#pragma mark - netWork

- (void) getLocationByphoneNbrInfo
{
    //用户归属地查询
    NSString *PhoneNbr = [Global sharedInstance].loginInfoDict [@"UserLoginName"];
    
    NSDictionary * params   = [NSDictionary dictionaryWithObjectsAndKeys:
                               PhoneNbr, @"PhoneNbr",
                               nil];
    
    __weak __typeof(&*self)weakSelf = self;
    self. qryNumAttr = [MyAppDelegate.cserviceEngine postXMLWithCode:@"getLocationByphoneNbrInfo"
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
                                              weakSelf.areaInfo = city ;
                                              weakSelf.isSuccess = YES ;
                                              
//                                              if (weakSelf.getAreaInfoBlock) {
//                                                  weakSelf.getAreaInfoBlock(weakSelf.areaInfo,nil);
//                                              }
                                              
                                          }
                                      } onError:^(NSError *engineError) {
                                          
                                          ToastAlertView *alert = [ToastAlertView new];
                                          [alert showAlertMsg:@"获取归属地失败"];
                                          
                                          //默认成北京
                                          NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      @"8110100",@"citycode",
                                                                      @"609001",@"provincecode",
                                                                      @"北京",@"cityname",
                                                                      @"北京",@"provincename",
                                                                      @"110000",@"hbcitycode",
                                                                      @"",@"hbprovincecode",
                                                                      @"",@"ProvinceName",
                                                                      nil];
                                          weakSelf.isSuccess = NO;
                                          weakSelf.areaInfo = nil;
                                          CTCity *city = [CTCity modelObjectWithDictionary:dictionary];
                                          weakSelf.areaInfo = city ;
                                          
//                                          if (weakSelf.getAreaInfoBlock) {
//                                              weakSelf.getAreaInfoBlock(nil,engineError);
//                                          }
                                      }];
}



- (void) transData : (NSDictionary *)dictionary
{
    //转化数据对象
}

#pragma mark - mapViewDelegate

-(NSString *)mapViewSearchKey
{
    return BESTTONE_POI_KEY;
}

#pragma mark - mapViewDelegate
/**
 *用户位置更新后，会调用此函数
 */

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
{
    [mapView setUserInteractionEnabled:NO];
    
    if (!userLocation)
    {
        return;
    }
    DDLogInfo(@"%s %f %f", __func__, userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    self.userLocation = userLocation;
    
    if (!self.searchView)
    {
        self.searchView = [MASearch maSearchWithDelegate:(id<MASearchDelegate>)self];
    }
    
    MAReverseGeocodingSearchOption * opt = [MAReverseGeocodingSearchOption new];
    opt.config              = @"SPAS";
    opt.authKey             = BESTTONE_POI_KEY;
    opt.encode              = @"UTF-8";
    opt.x                   = [NSString stringWithFormat:@"%f", userLocation.location.coordinate.longitude];
    opt.y                   = [NSString stringWithFormat:@"%f", userLocation.location.coordinate.latitude];
    
    [self.searchView reverseGeocodingSearchWithOption:opt];

    DDLogInfo(@"%s %f %f", __func__, userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
//    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    self.userLocation = userLocation;

    if (!self.searchView)
    {
        self.searchView = [MASearch maSearchWithDelegate:(id<MASearchDelegate>)self];
    }
}
/**
 *定位失败后，会调用此函数
 */
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    DDLogCInfo(@"%s %@", __func__, error);
    
//    [mapView setShowsUserLocation:NO];
    
//    if (self.finishBlock) {
//        self.isSuccess = NO;
//        self.areaInfo = nil;
//        self.finishBlock(nil,error);
//    }
    if (self.getAreaInfoBlock) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"8110100",@"citycode",
                                    @"609001",@"provincecode",
                                    @"北京",@"cityname",
                                    @"北京",@"provincename",
                                    @"110000",@"hbcitycode",
                                    @"",@"hbprovincecode",
                                    @"",@"ProvinceName",
                                    nil];
        self.isSuccess = NO;
        self.areaInfo = nil;
        CTCity *city = [CTCity modelObjectWithDictionary:dictionary];
        self.areaInfo = city ;
        self.isSuccess = NO;
        if (self.getAreaInfoBlock) {
            self.getAreaInfoBlock(_areaInfo,nil);
        }
    }
}

#pragma mark - searchDelegate
/*!
 @function
 @abstract 逆地理编码查询回调函数
 @param searchOption 发起逆地理编码查询的查询选项(具体字段参考MASearchOption类中的@interface定义)
 @param result 查询结果(具体字段参考MASearchResult类中的@interface定义)
 ）
 */
-(void)reverseGeocodingSearch:(MAReverseGeocodingSearchOption*)geoCodingSearchOption Result:(MAReverseGeocodingSearchResult*)result
{
    if (result && [[result resultArray] count])
    {
        MAReverseGeocodingInfo * item = [[result resultArray] objectAtIndex:0];
        MAReverseGeocodingInfo * tmp  = [[MAReverseGeocodingInfo alloc] init];
        tmp.province   = item.province;
        tmp.city       = item.city;
        tmp.district   = item.district;
        tmp.pois       = item.pois;
        tmp.roads      = item.roads;
        tmp.crosses    = item.crosses;
        
        self.userAddrinfo = tmp;
        
        NSString *cityname = tmp.city.name;
        cityname = [cityname stringByReplacingOccurrencesOfString:@"市" withString:@""];
        NSString *citycode = tmp.city.code;
        NSString *provincecode = tmp.province.code;
        NSString *provincename = tmp.province.name;
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           cityname,@"cityname",
                                           provincename,@"provincename",
                                           citycode,@"hbcitycode",
                                           provincecode,@"hbprovincecode",
                                           @"",@"citycode",
                                           @"",@"provincecode",
                                           @"",@"citynameAlph",
                                           nil];
        
        CTCity *city = [CTCity modelObjectWithDictionary:dictionary];
        self.areaInfo = city;
        self.isSuccess = YES;
        [self filterContentForSearchText:_areaInfo.hbcitycode]; // 查找内容
        if (self.getAreaInfoBlock) {
            self.isSuccess = YES ;
            self.getAreaInfoBlock(city,nil);
        }
    }
}
@end
