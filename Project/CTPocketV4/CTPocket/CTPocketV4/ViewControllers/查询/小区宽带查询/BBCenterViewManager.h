//
//  BBCenterManager.h
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  中间的视图的逻辑管理

#import <Foundation/Foundation.h>
#import "BBNWRequstProcess.h"
#import "BBSearchField.h"
typedef enum BBCenterViewType{BBC_NONE,BBC_HasData=1,BBC_NoData=2 } BBCenterViewType;
@class BBCenterRepDataModel;
@interface BBCenterViewManager : NSObject
@property(weak,nonatomic)BBNWRequstProcess *process;

@property(weak,nonatomic)IBOutlet UITableView *tableView;
@property(weak,nonatomic)IBOutlet UIView *tipView1;
@property(weak,nonatomic)IBOutlet UIView *tipView2;
@property(weak,nonatomic)IBOutlet UIView *noDataView;
@property(weak,nonatomic)IBOutlet UIButton *searchButton;
@property(weak,nonatomic)IBOutlet BBSearchField *textField;
-(IBAction)search:(id)sender;


-(void)initial; 

-(void)updateWithData:(BBCenterRepDataModel*)repData;
-(void)occurError:(NSError *)error;
-(void)reset;
@end
