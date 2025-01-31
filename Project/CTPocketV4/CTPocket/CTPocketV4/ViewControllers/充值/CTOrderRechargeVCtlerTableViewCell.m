//
//  CTOrderRechargeVCtlerTableViewCell.m
//  CTPocketV4
//
//  Created by quan on 14-5-27.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTOrderRechargeVCtlerTableViewCell.h"
#import <SDWebImage/SDWebImageManager.h>


#define kWidth  320.0f

@implementation CTOrderRechargeVCtlerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    
        
    }
    return self;
}
- (void)setData:(NSDictionary*)dict{
    
    [self.iconImageView setImageWithURL:[NSURL URLWithString:dict[@"bankIcon"]]];
    self.payTypeLabel.text = dict[@"bankName"];
    
}
- (UIImageView *)iconImageView{
    
    if (!_iconImageView) {
     
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 4, 36, 36)];
        _iconImageView.userInteractionEnabled = YES;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UILabel *)payTypeLabel{
    
    if (!_payTypeLabel) {
        
        _payTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake (70,12, 150, 20)];
        _payTypeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_payTypeLabel];
    }
    return _payTypeLabel;
}
- (UIButton *)selectBtn{
    
    if (!_selectBtn) {
        
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.frame = CGRectMake(240, 4, 36, 36);
        [_selectBtn setImage:[UIImage imageNamed:@"btn_scrolltotop_enable.png"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"btn_scrolltotop_disable"] forState:UIControlStateSelected];
        [self addSubview:_selectBtn];
    }
    return _selectBtn;
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
