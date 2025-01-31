//
//  CTSelectPhoneNumberCell.h
//  CTPocketV4
//
//  Created by Y W on 14-3-19.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CTSelectButton.h"

@interface CTSelectPhoneNumberCell : UITableViewCell

@property (nonatomic, strong, readonly) CTSelectButton *button;
@property (nonatomic, copy, readwrite) CTSelectButtonSelectBlock selectBlock; 
@end
