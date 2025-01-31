//
//  BBTopItemDataModel.h
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTopItemDataModel : NSObject
@property(assign,nonatomic)NSInteger selectedRow;
@property(copy,nonatomic) NSString *Freight_Area_Code;
@property(copy,nonatomic) NSString *Freight_Area_Name;
-(instancetype)initWithDictionary:(NSDictionary*)dic;
+(instancetype)unarchiveWithData:(NSData*)data;
-(NSData*)archive;
@end
