//
//  BBTRequestParamModel.h
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  地区及编码查询请求参数模型

#import <Foundation/Foundation.h>
#import "BBTopViewManager.h"
@interface BBTRequestParamModel : NSObject<NSCopying>
 
@property(copy,nonatomic)NSString *ProvinceCode;
@property(copy,nonatomic)NSString *CityCode;
@property(copy,nonatomic)NSString *RegionCode;
@property(assign,nonatomic)   int Type;

//用于网络请求返回后，调用省份还是城市或者地区的数据设置方法
@property(assign,nonatomic)BBTop_Type topType;
/**
 缓存的路径，城市的缓存路径由 城市对应的省份编码 组成(如 600103)
 区域的缓存路径有 城市对应的省份编码_城市编码组成 组成(如 600103_320201)
 */
@property(copy,nonatomic)NSString *cachePath;

@end
