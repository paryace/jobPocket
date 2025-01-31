//
//  BBTopRepDataModel.h
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  地区及编码查询返回的数据模型

#import <Foundation/Foundation.h>

@interface BBTopRepDataModel : NSObject

@property(strong,nonatomic)NSMutableArray *Data;//数组每个元素的模型是BBTopItemDataModel

-(void)writeToFile:(NSString*)path;
-(void)readFromFile:(NSString*)path;
+(void)deleteDir;
-(void)transformWithArray:(NSArray*)array;
@end
