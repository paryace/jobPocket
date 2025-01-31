//
//  CTBdSalesPriceCell.m
//  CTPocketV4
//
//  Created by Y W on 14-3-22.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTBdSalesPriceCell.h"

#import "ThreeSubView.h"

#import "UIColor+Category.h"

#define XStart 10

#define customGrayColor [UIColor colorWithR:162 G:162 B:162 A:1]

@interface CTBdSalesPriceCell ()

@property (nonatomic, strong) ThreeSubView *disPriceThreeSubView;
@property (nonatomic, strong) ThreeSubView *marketPriceThreeSubView;
@property (nonatomic, strong) UIView *lineView;

@end


@implementation CTBdSalesPriceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(self.contentView.frame)) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
            
            [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [threeSubView.leftButton setTitleColor:customGrayColor forState:UIControlStateNormal];
            [threeSubView.leftButton setTitle:@"特惠价：" forState:UIControlStateNormal];
            
            UIFont *font=[UIFont fontWithName:@"Thonburi-Bold" size:23];//Thonburi-Bold
            [threeSubView.centerButton.titleLabel setFont:font];
            [threeSubView.centerButton setTitleColor:[UIColor colorWithR:240 G:103 B:81 A:1] forState:UIControlStateNormal];
            
            [threeSubView.rightButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [threeSubView.rightButton setTitleColor:customGrayColor forState:UIControlStateNormal];
            [threeSubView.rightButton setTitle:@"元" forState:UIControlStateNormal];
            
            threeSubView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
            [self.contentView addSubview:threeSubView];
            
            self.disPriceThreeSubView = threeSubView;
        }
        
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(self.contentView.frame)) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
            
            [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [threeSubView.leftButton setTitleColor:customGrayColor forState:UIControlStateNormal];
            [threeSubView.leftButton setTitle:@"市场价:" forState:UIControlStateNormal];
            
            [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [threeSubView.centerButton setTitleColor:customGrayColor forState:UIControlStateNormal];
            
            [threeSubView.rightButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [threeSubView.rightButton setTitleColor:customGrayColor forState:UIControlStateNormal];
            [threeSubView.rightButton setTitle:@"元" forState:UIControlStateNormal];
            
            threeSubView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            
            UIView *lineView = [[UIView alloc] init];
            lineView.backgroundColor =customGrayColor;
            [threeSubView addSubview:lineView];
            self.lineView = lineView;
            
            [self.contentView addSubview:threeSubView];
            
            self.marketPriceThreeSubView = threeSubView;
        }
    }
    return self;
}

- (void)setDisPrice:(NSString *)DisPrice
{
    [self.disPriceThreeSubView.centerButton setTitle:DisPrice forState:UIControlStateNormal];
}

- (void)setMarketPrice:(NSString *)MarketPrice
{
    [self.marketPriceThreeSubView.centerButton setTitle:MarketPrice forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.disPriceThreeSubView autoLayout];
    [self.marketPriceThreeSubView autoLayout];
    
    CGRect rect = self.disPriceThreeSubView.frame;
    rect.origin.x = XStart;
    self.disPriceThreeSubView.frame = rect;
    
    rect = self.marketPriceThreeSubView.frame;
    rect.origin.x = CGRectGetMaxX(self.disPriceThreeSubView.frame) + 20;
    self.marketPriceThreeSubView.frame = rect;
    
    rect = self.marketPriceThreeSubView.bounds;
    rect.origin.y = ceilf(CGRectGetHeight(rect)/2.0);
    rect.size.height = 1;
    self.lineView.frame = rect;

    CGFloat leftY=self.disPriceThreeSubView.leftButton.frame.origin.y;
    UIButton *centerBtn= self.disPriceThreeSubView .centerButton;
    CGRect centerRect=centerBtn.frame;
    centerRect.origin.y=leftY-6;
    centerBtn.frame=centerRect;
}

@end
