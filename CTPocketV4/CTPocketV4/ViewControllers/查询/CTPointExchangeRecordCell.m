//
//  CTPointExchangeRecordCell.m
//  CTPocketV4
//
//  Created by Y W on 14-3-14.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTPointExchangeRecordCell.h"

#import "UIColor+Category.h"
#import "UIImage+Category.h"

#define xOffset 25
#define yOffset 15
#define labelHeight 15
#define yDistance 10

@interface CTPointExchangeRecordCell ()

@property (nonatomic, strong, readwrite) ThreeSubView *dateView;
@property (nonatomic, strong, readwrite) ThreeSubView *pointView;
@property (nonatomic, strong, readwrite) ThreeSubView *nameView;
@property (nonatomic, strong, readwrite) ThreeSubView *countView;

@property (nonatomic, strong, readwrite) UIView *separatorView;

@end

@implementation CTPointExchangeRecordCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, 0, labelHeight) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
            
            [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [threeSubView.leftButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.leftButton setTitle:@"兑换日期：" forState:UIControlStateNormal];
            [threeSubView.leftButton setBackgroundColor:[UIColor clearColor]];
            
            [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.centerButton setBackgroundColor:[UIColor clearColor]];
            
            [self.contentView addSubview:threeSubView];
            
            self.dateView = threeSubView;
        }
        
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, 0, labelHeight) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
            
            [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [threeSubView.leftButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.leftButton setTitle:@"兑换积分：" forState:UIControlStateNormal];
            [threeSubView.leftButton setBackgroundColor:[UIColor clearColor]];
            
            [threeSubView.centerButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.centerButton setBackgroundColor:[UIColor clearColor]];
            
            [threeSubView.rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [threeSubView.rightButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.rightButton setTitle:@" 分" forState:UIControlStateNormal];
            [threeSubView.rightButton setBackgroundColor:[UIColor clearColor]];
            
            [self.contentView addSubview:threeSubView];
            
            self.pointView = threeSubView;
        }
        
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, 0, labelHeight) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
            
            [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [threeSubView.leftButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.leftButton setTitle:@"兑换礼品：" forState:UIControlStateNormal];
            [threeSubView.leftButton setBackgroundColor:[UIColor clearColor]];
            
            [threeSubView.centerButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.centerButton setBackgroundColor:[UIColor clearColor]];
            
            [self.contentView addSubview:threeSubView];
            
            self.nameView = threeSubView;
        }
        
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, 0, labelHeight) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
            
            [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [threeSubView.leftButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.leftButton setTitle:@"礼品数量：" forState:UIControlStateNormal];
            [threeSubView.leftButton setBackgroundColor:[UIColor clearColor]];
            
            [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.centerButton setBackgroundColor:[UIColor clearColor]];
            
            [self.contentView addSubview:threeSubView];
            
            self.countView = threeSubView;
        }
        
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:95 G:189 B:42 A:1] cornerRadius:5] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:95 G:189 B:42 A:1] cornerRadius:5] forState:UIControlStateDisabled];
            [button setTitle:@"查询卡密" forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [self.contentView addSubview:button];
            
            self.cardCodeButton = button;
        }
        
        {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor colorWithRed:0.84f green:0.84f blue:0.84f alpha:1.00f];
            [self.contentView addSubview:view];
            
            self.separatorView = view;
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.dateView autoLayout];
    [self.pointView autoLayout];
    [self.nameView autoLayout];
    [self.countView autoLayout];
    
    CGRect rect = CGRectZero;
    
    rect = self.dateView.frame;
    rect.origin.x = xOffset;
    rect.origin.y = yOffset;
    self.dateView.frame = rect;
    
    rect = self.pointView.frame;
    rect.origin.x = xOffset;
    rect.origin.y = yOffset + labelHeight + yDistance;
    self.pointView.frame = rect;
    
    rect = self.nameView.frame;
    rect.origin.x = xOffset;
    rect.origin.y = yOffset + (labelHeight + yDistance) * 2;
    self.nameView.frame = rect;
    
    rect = self.nameView.centerButton.frame;
    rect.size.width = 215;
    self.nameView.centerButton.frame = rect;
    [self.nameView.centerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.nameView.centerButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    rect = self.countView.frame;
    rect.origin.x = xOffset;
    rect.origin.y = yOffset + (labelHeight + yDistance) * 3;
    self.countView.frame = rect;
    
    rect = self.contentView.bounds;
    self.cardCodeButton.frame = CGRectMake(rect.size.width - 10 - 70, ceilf((rect.size.height - 30)/2.0)-10, 70, 30);
    
    rect = self.contentView.bounds;
    self.separatorView.frame = CGRectMake(10, CGRectGetHeight(rect) - 1, CGRectGetWidth(rect) - 2 * 10, 1);
}

@end
