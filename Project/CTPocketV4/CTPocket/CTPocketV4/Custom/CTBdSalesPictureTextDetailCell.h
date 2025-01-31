//
//  CTBdSalesPictureTextDetailCell.h
//  CTPocketV4
//
//  Created by Y W on 14-3-21.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CTBdSalesPictureTextDetailDidFinishLoadBlock)();

@interface CTBdSalesPictureTextDetailCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, strong) NSString *Detail;

@property (nonatomic, readwrite, copy) CTBdSalesPictureTextDetailDidFinishLoadBlock didFinishLoadBlock;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView*)tableView withHeight:(NSMutableArray*)heightObject;
-(void)removeWebView;
-(void)addIndicator;
-(void)setActionView2WebView;
-(void)removeFilter;
@end
