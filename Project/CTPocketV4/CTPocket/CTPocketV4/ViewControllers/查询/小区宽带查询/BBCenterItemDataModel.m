//
//  BBCenterItemDataModel.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "BBCenterItemDataModel.h"

@implementation BBCenterItemDataModel
-(instancetype)initWithDictionary:(NSDictionary*)dic
{
    self=[super init];
    if (self) {
        /*
         <ComAddress>蜀南庭苑21号</ComAddress>
         <FibreFlag>1</FibreFlag>
         <ComName>蜀南庭苑</ComName>
         <AreaId>120113</AreaId>
         <BroadFlag>1</BroadFlag>
         */
        self.ComAddress=dic[@"ComAddress"];
        self.ComName=dic[@"ComName"];
        self.AreaId=dic[@"AreaId"];
        self.BroadFlag=[dic[@"BroadFlag"] integerValue];
        self.FibreFlag=[dic[@"FibreFlag"] integerValue];
    }
    return self;
}
@end
