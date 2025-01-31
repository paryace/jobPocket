//
//  BBTopViewManager.h
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  顶部视图的逻辑管理

#import <Foundation/Foundation.h>
#import "BBNWRequstProcess.h"
@class BBTopItemDataModel;
typedef enum BBTop_Type{BBT_P=1,BBT_C=2,BBT_R=3}BBTop_Type;

@interface BBTopViewManager : NSObject
@property(weak,nonatomic)BBNWRequstProcess *process;
@property(weak,nonatomic)BBTopItemDataModel *currentR;//用于查询光纤数据

@property(weak,nonatomic)IBOutlet UIButton *provinceButton;
-(IBAction)provinceClick:(UIButton*)sender;

@property(weak,nonatomic)IBOutlet UIButton *cityButton;
-(IBAction)cityClick:(UIButton*)sender;

@property(weak,nonatomic)IBOutlet UIButton *regionButton;
-(IBAction)regionClick:(UIButton*)sender;


-(void)updateProvince:(NSMutableArray*)ps;
-(void)updateCinty:(NSMutableArray*)cs;
-(void)updateRegion:(NSMutableArray*)rs;
-(void)occurError:(NSError *)error;
-(void)initial;
 
@end
