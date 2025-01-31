//
//  CTBdSalesPackageCell.m
//  CTPocketV4
//
//  Created by Y W on 14-3-21.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTBdSalesPackageCell.h"

#import "UIColor+Category.h"
#import "AutoScrollLabel.h"

#define VerticalButtonDistance 5
#define HorizonButtonDistance 5
#define ContentHeight 16
#define HorizonButtonStart 45

@interface CTBdSalesPackageCell (){
    
    BOOL initialization;
}

@property (nonatomic, strong) UIButton *button;

@end

@implementation CTBdSalesPackageCell

+ (CGFloat)CellHeightWithPackageModel:(PackageModel *)packageModel
{// 短信TsDx   彩信 TsCx
    NSUInteger count = 0;
    if (packageModel.MinAmount.length > 0) {
        count++;
    }
    if (packageModel.AmoutBack.length > 0) {
        count++;
    }
    if (packageModel.TsYy.length > 0) {
        count++;
    }
    /**
    if (packageModel.TsDx.length > 0) {
        count++;
    }
    if (packageModel.TsCx.length > 0) {
        count++;
    }*/
    if (packageModel.TsDcx.length > 0) {
        count++;
    }
    if (packageModel.TsLl.length > 0) {
        count++;
    }
    if (packageModel.TsWifi.length > 0) {
        count++;
    }
    NSString *AmoutBack=packageModel.AmoutBack;
//    NSString *AmoutBack=@"";
    int backLen=AmoutBack.length;
    if (backLen>0)
    {
        if (count > 6)
        {
            return VerticalButtonDistance * 4 + ContentHeight * 3;
        }else  if (count > 2)
        {
                return VerticalButtonDistance * 3 + ContentHeight * 2;
        } else
        {
                return VerticalButtonDistance * 2 + ContentHeight;
         }
    }
    else
    {
        if (count >= 4)
        {
            return VerticalButtonDistance * 3 + ContentHeight * 2;
        } else
        {
            return VerticalButtonDistance * 2 + ContentHeight;
        }
    }
    /*
    if (packageModel.MinAmount.length > 0 && packageModel.MinAmount.length > 0) {
        if (count > 6) {
        return VerticalButtonDistance * 4 + ContentHeight * 3;
        }else
        if (count > 2) {
            return VerticalButtonDistance * 3 + ContentHeight * 2;
        } else {
            return VerticalButtonDistance * 2 + ContentHeight;
        }
    } else if (packageModel.MinAmount.length > 0 || packageModel.MinAmount.length > 0) {
        if (count > 3) {
            return VerticalButtonDistance * 3 + ContentHeight * 2;
        } else {
            return VerticalButtonDistance * 2 + ContentHeight;
        }
    } else {
        if (count > 4) {
            return VerticalButtonDistance * 3 + ContentHeight * 2;
        } else {
            return VerticalButtonDistance * 2 + ContentHeight;
        }
    }**/
}

- (void)addDetailButton
{
    if (self.button == nil) {
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.backgroundColor = [UIColor clearColor];
        [self.button setTitle:@"详情>>" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor colorWithR:131 G:200 B:98 A:1] forState:UIControlStateNormal];
        [self.button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.button addTarget:self action:@selector(goDetail) forControlEvents:UIControlEventTouchUpInside];
        [self.button setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
        self.button.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - 100, 0, 100, 30);
        [self.contentView addSubview:self.button];
    }
    
}

- (void)goDetail
{
    if (self.goDetailBlock) {
        self.goDetailBlock();
    }
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self.autoLB scroll];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(initialization){
        
        return;
    }
    
    initialization  = YES;
    if (CGRectGetHeight(self.contentView.frame) > CGRectGetHeight(self.button.frame)) {
        [self addDetailButton];
    }
    /**
     月消费：
     */
    CGFloat xOffset = HorizonButtonStart, yOffset = VerticalButtonDistance;
    CGFloat limitWidth=CGRectGetWidth(self.contentView.frame) - HorizonButtonDistance-60;
    
    if (self.packageModel.MinAmount.length > 0) {
        ThreeSubView *threeSubView = [self threeSubViewWithOrigin:CGPointMake(xOffset, yOffset) leftTitle:@"月消费：￥" centerTitle:self.packageModel.MinAmount];
        [self.contentView addSubview:threeSubView];
        
        xOffset = CGRectGetMaxX(threeSubView.frame);
        if (xOffset > CGRectGetWidth(self.contentView.frame) - HorizonButtonDistance) { //判断要换行呢
            xOffset = HorizonButtonStart;
            yOffset += ContentHeight + VerticalButtonDistance;
            
            CGRect rect = threeSubView.frame;
            rect.origin = CGPointMake(xOffset, yOffset);
            threeSubView.frame = rect;
            
            xOffset = CGRectGetMaxX(rect);
        }
        xOffset += HorizonButtonDistance;
    }
    
    /**
     月返还：
     */
    CGFloat btn_detial_distance=266;
    if (self.packageModel.AmoutBack.length > 0) {
        
        NSString *txt_return=[NSString stringWithFormat:@"月返还:￥%@",self.packageModel.AmoutBack];;
        CGRect rect_auto= CGRectMake(xOffset, yOffset-2, btn_detial_distance-xOffset-8, 20);
       self.autoLB= [[AutoScrollLabel alloc]initWithFrame:rect_auto];
        self.autoLB.font = [UIFont systemFontOfSize:12];
        self.autoLB.backgroundColor = [UIColor clearColor];
        self.autoLB.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
        self.autoLB.textAlignment = UITextAlignmentLeft;
        self.autoLB.text=txt_return;
        [self.autoLB setOnce:YES];
        [self.contentView addSubview:self.autoLB];
        xOffset += HorizonButtonDistance+btn_detial_distance;

    }
    /**
     语音：
     */
    if (self.packageModel.TsYy.length > 0) {
        ThreeSubView *threeSubView = [self threeSubViewWithOrigin:CGPointMake(xOffset, yOffset) leftImageName:@"PhoneDetailCall" centerTitle:self.packageModel.TsYy];
        [self.contentView addSubview:threeSubView];
        
        xOffset = CGRectGetMaxX(threeSubView.frame);
        if (xOffset >limitWidth) { //判断要换行呢
            xOffset = HorizonButtonStart;
            yOffset += ContentHeight + VerticalButtonDistance;
            
            CGRect rect = threeSubView.frame;
            rect.origin = CGPointMake(xOffset, yOffset);
            threeSubView.frame = rect;
            
            xOffset = CGRectGetMaxX(rect);
        }
        xOffset += HorizonButtonDistance;
    }
    
    if (self.packageModel.TsDcx.length > 0) {
        ThreeSubView *threeSubView = [self threeSubViewWithOrigin:CGPointMake(xOffset, yOffset) leftImageName:@"PhoneDetailMessage" centerTitle:self.packageModel.TsDcx];
        [self.contentView addSubview:threeSubView];
        
        xOffset = CGRectGetMaxX(threeSubView.frame);
        if (xOffset >limitWidth) { //判断要换行呢
            xOffset = HorizonButtonStart;
            yOffset += ContentHeight + VerticalButtonDistance;
            
            CGRect rect = threeSubView.frame;
            rect.origin = CGPointMake(xOffset, yOffset);
            threeSubView.frame = rect;
            
            xOffset = CGRectGetMaxX(rect);
        }
        xOffset += HorizonButtonDistance;
    }
    /**
     流量
     */
    if (self.packageModel.TsLl.length > 0) {
        ThreeSubView *threeSubView = [self threeSubViewWithOrigin:CGPointMake(xOffset, yOffset) leftImageName:@"PhoneDetailFlow" centerTitle:self.packageModel.TsLl];
        [self.contentView addSubview:threeSubView];
        
        xOffset = CGRectGetMaxX(threeSubView.frame);
        if (xOffset > limitWidth) { //判断要换行呢
            xOffset = HorizonButtonStart;
            yOffset += ContentHeight + VerticalButtonDistance;
            
            CGRect rect = threeSubView.frame;
            rect.origin = CGPointMake(xOffset, yOffset);
            threeSubView.frame = rect;
            
            xOffset = CGRectGetMaxX(rect);
        }
        xOffset += HorizonButtonDistance;
    }
    
    /**
     wifi时长
     */
    if (self.packageModel.TsWifi.length > 0) {
        ThreeSubView *threeSubView = [self threeSubViewWithOrigin:CGPointMake(xOffset, yOffset) leftImageName:@"PhoneDetailWifi" centerTitle:self.packageModel.TsWifi];
        [self.contentView addSubview:threeSubView];
        
        xOffset = CGRectGetMaxX(threeSubView.frame);
        if (xOffset > limitWidth) { //判断要换行呢
            xOffset = HorizonButtonStart;
            yOffset += ContentHeight + VerticalButtonDistance;
            
            CGRect rect = threeSubView.frame;
            rect.origin = CGPointMake(xOffset, yOffset);
            threeSubView.frame = rect;
            
            xOffset = CGRectGetMaxX(rect);
        }
        xOffset += HorizonButtonDistance;
    }
    
}

- (ThreeSubView *)threeSubViewWithOrigin:(CGPoint)origin leftTitle:(NSString *)leftTitle centerTitle:(NSString *)centerTitle
{
    ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(origin.x, origin.y, 0, ContentHeight) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    threeSubView.backgroundColor = [UIColor clearColor];
    
    [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [threeSubView.leftButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
    [threeSubView.leftButton setTitle:leftTitle forState:UIControlStateNormal];
    
    [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
    [threeSubView.centerButton setTitle:centerTitle forState:UIControlStateNormal];
    
    [threeSubView autoLayout];
    
    return threeSubView;
}

- (ThreeSubView *)threeSubViewWithOrigin:(CGPoint)origin leftImageName:(NSString *)imageName centerTitle:(NSString *)centerTitle
{
    ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(origin.x, origin.y, 0, ContentHeight) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    threeSubView.backgroundColor = [UIColor clearColor];
    
    [threeSubView.leftButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
    [threeSubView.centerButton setTitle:centerTitle forState:UIControlStateNormal];
    
    [threeSubView autoLayout];
    
    return threeSubView;
}

@end
