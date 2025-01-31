//
//  BBCenterItem.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "BBCenterItem.h"
#import "BBCenterItemDataModel.h"
#import "UIColor+Category.h"
@interface BBCenterItem()
@property(assign,nonatomic)CGRect regionRect;
@end
@implementation BBCenterItem

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}
 -(void)awakeFromNib
{
    [super awakeFromNib];
    self.regionRect=self.region.frame;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)renderData:(BBCenterItemDataModel*)model withRow:(int)row;
{ 
    self.name.text=model.ComName;
    NSString *address=model.ComAddress;
    self.region.text=address; 
    
    self.state.textColor=[UIColor colorWithR:84 G:190 B:45 A:1];
    int f=model.FibreFlag;
    if(f>=1)
    {
        self.state.text=@"该小区可安装中国电信光纤宽带";
    }else
    {
        self.state.text=@"该小区暂不支持中国电信光纤宽带接入";
        self.state.textColor=[UIColor colorWithR:126 G:126 B:126 A:1];
    }
    int namePrefix=(row%10)+1;
    NSString *imageName=[NSString stringWithFormat:@"bb_residential_%i.jpg",namePrefix]; 
    self.icon.image=[UIImage imageNamed:imageName];
    /**
     当fiberFlag=-1时，
     显示：
     当当fiberFlag=1，2时
     显示：
     */
}
@end
