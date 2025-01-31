//
//  BBCenterItem.h
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBCenterItemDataModel;
@interface BBCenterItem : UITableViewCell
@property(weak,nonatomic)IBOutlet UIImageView *icon;
@property(weak,nonatomic)IBOutlet UILabel *name;
@property(weak,nonatomic)IBOutlet UILabel *region;
@property(weak,nonatomic)IBOutlet UILabel *state;
-(void)renderData:(BBCenterItemDataModel*)model withRow:(int)row;
@end
