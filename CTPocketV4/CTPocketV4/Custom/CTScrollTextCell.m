//
//  CTScrollTextCell.m
//  CTPocketV4
//
//  Created by Y W on 14-3-19.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTScrollTextCell.h"

#import "AutoScrollLabel.h"

#import "UIColor+Category.h"

#define XDistance 10
#define YDistance 3

@interface CTScrollTextCell ()

@property (nonatomic, assign, readwrite) CGRect imageFrame;
@property (nonatomic, strong, readwrite) AutoScrollLabel *autoLabel;

@end


@implementation CTScrollTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.imageFrame = CGRectMake(XDistance, YDistance, 14, 14);
        
        {
            AutoScrollLabel *autoLB = [[AutoScrollLabel alloc]initWithFrame:self.contentView.bounds];
            autoLB.font = [UIFont boldSystemFontOfSize:14.0f];
            autoLB.backgroundColor = [UIColor clearColor];
            autoLB.textAlignment = UITextAlignmentLeft;
            autoLB.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
            [self addSubview:autoLB];
            
            self.autoLabel = autoLB;
        }
    }
    return self;
}

- (void)setText:(NSString *)text
{
    [self.autoLabel setText:text];
}

- (void)setTextColor:(UIColor *)textColor
{
    [self.autoLabel setTextColor:textColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int xOffset = 0;
    if (self.imageView.image) {
        
        self.imageView.frame = self.imageFrame;
        
        xOffset = CGRectGetMaxX(self.imageView.frame) + XDistance;
    } else {
        xOffset = XDistance;
    }
    
    CGRect rect = CGRectZero;
    rect.origin = CGPointMake(xOffset, YDistance);
    rect.size.width = self.contentView.bounds.size.width - xOffset - XDistance;
    rect.size.height = self.contentView.bounds.size.height - YDistance * 2;
    self.autoLabel.frame = rect;
    [self.autoLabel readjustLabels];
}

@end
