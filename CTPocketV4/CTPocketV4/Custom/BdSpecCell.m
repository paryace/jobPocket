//
//  BdSpecCell.m
//  CTPocketV4
//
//  Created by Y W on 14-3-20.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//


@interface BdSpecCellSelectControl : NSObject

@property (nonatomic, readonly, strong) NSMutableDictionary *controlDic;

+ (instancetype)shareBdSpecCellSelectControl;

@end



@interface BdSpecCellSelectControl ()

@property (nonatomic, readwrite, strong) NSMutableDictionary *controlDic;

@end


@implementation BdSpecCellSelectControl

+ (instancetype)shareBdSpecCellSelectControl
{
    static BdSpecCellSelectControl *shareBdSpecCellSelectControl = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareBdSpecCellSelectControl = [[BdSpecCellSelectControl alloc] init];
    });
    return shareBdSpecCellSelectControl;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.controlDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end








#import "BdSpecCell.h"

#import "UIColor+Category.h"

#import "QryBdSpec.h"
#import "Utils.h"
#import <SDWebImage/SDWebImageManager.h>
#define HorizonButtonStart 45
#define HorizonButtonDistance 10
#define VerticalButtonStart 7
#define VerticalButtonDistance 10
#define ButtonIconHeight 30


@interface BdSpecCell ()

@property (nonatomic, weak) NSArray *Configs;

@end

@implementation BdSpecCell

+ (CGFloat)CellHeightWithConfigList:(NSArray *)configList
{
    if (configList.count == 0) {
        return 0;
    }
    
    ConfigModel *model = [configList objectAtIndex:0];
    
    NSUInteger itemCount = configList.count;
    NSUInteger countOneFloor = model.Columns;
    if (countOneFloor == 0) {
        countOneFloor = 1;
    }
    NSUInteger floors = (itemCount+1)/countOneFloor ;
    if (floors == 0) {
        floors = 1;
    }
    return VerticalButtonStart * 2 + floors * ButtonIconHeight + (floors - 1) * VerticalButtonDistance;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.text = @"";
        self.textLabel.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
        self.textLabel.font = [UIFont systemFontOfSize:12];
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.numberOfLines = 0;
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buttonSelectNotification:) name:@"CTSelectButtonSelectNotification" object:nil];
    }
    return self;
}

- (void)setConfigList:(NSArray *)configList
{
    if (configList == self.Configs) {
        return;
    } else {
        self.Configs = configList;
    }
    
    [self removeSubButtons]; 
    
    if (configList.count == 0) {
        self.textLabel.text = @"";
        return;
    }
    ConfigModel *model = [configList objectAtIndex:0];
    self.textLabel.text = model.SpecName;
    
 
    NSUInteger countOneFloor = model.Columns;
    if (countOneFloor == 0) {
        countOneFloor = 1;
    }
    
    NSUInteger buttonWidth = ceilf((CGRectGetWidth(self.contentView.frame) - HorizonButtonStart - HorizonButtonDistance * countOneFloor)/countOneFloor);
    
    
    for (int i = 0; i < configList.count; i++) {
        
        ConfigModel *model = [configList objectAtIndex:i];
        
        NSUInteger xOffset = HorizonButtonStart + (buttonWidth + HorizonButtonDistance) * (i % countOneFloor);
        NSUInteger yOffset = VerticalButtonStart + (ButtonIconHeight + VerticalButtonDistance) * (i / countOneFloor);
        
        CGRect rect = CGRectZero;
        rect.origin = CGPointMake(xOffset, yOffset);
        rect.size = CGSizeMake(buttonWidth, ButtonIconHeight);
        
        __weak typeof(self)weakSelf = self;
        CTSelectButton *selectButton = [[CTSelectButton alloc] initWithExitImageFrame:rect selectBlock:^(id object) {
            
            if ([object isKindOfClass:[ConfigModel class]]) {
                ConfigModel *configModel = (ConfigModel *)object;
                if (configModel.Pid && configModel.SpecName) {
                    [[BdSpecCellSelectControl shareBdSpecCellSelectControl].controlDic setObject:configModel.Pid forKey:configModel.SpecName];
                }
            }
            
            if (weakSelf.selectBlock) {
                weakSelf.selectBlock(object);
            }
        }];
        
        [selectButton setTitleColor:[UIColor colorWithR:39 G:39 B:39 A:1] forState:UIControlStateNormal];
        [selectButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        selectButton.object = model;
       /*
        if (model.SpecName) {
            NSString *Pid =  [[BdSpecCellSelectControl shareBdSpecCellSelectControl].controlDic objectForKey:model.SpecName];
            if ([Pid isEqualToString:model.Pid]) {
                [selectButton setBackgroundImage:selectButton.selectImage forState:UIControlStateNormal];
            }
        }*/
       
                if (model.SpecValue )
        {
            [selectButton setTitle:model.SpecValue forState:UIControlStateNormal];
        }
       
        
        [self.contentView addSubview:selectButton];
        /**
         @Author                gongxt
         @Description           如果默认的defaultId和当前的model.Pid相同，选中当前的selectButton
         */
        
        BOOL isDefault=self.defaultId&&[self.defaultId isEqualToString:model.Pid];
        if (isDefault)
        {
            selectButton.selected=YES;
            [selectButton setBackgroundImage:selectButton.selectImage forState:UIControlStateNormal];
        }
//        __weak typeof(model)weakModel = model;
        __weak typeof(selectButton)weakSelectButton = selectButton;
        if (model.PicFlag&&[Utils isValidateUrl:model.PicUrl])
        {
            [weakSelectButton setBackgroundImage:nil forState:UIControlStateNormal];
            [weakSelectButton setTitle:nil forState:UIControlStateNormal];
            [weakSelectButton setBackgroundColor:[UIColor whiteColor]];
            [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:model.PicUrl] options:SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                if (image) {
                    if (weakSelectButton.selected)
                    {
                        weakSelectButton.imageEdgeInsets=[weakSelf normalInset:image.size btnSize:weakSelectButton.frame.size];
                        [weakSelectButton setBackgroundImage:nil forState:UIControlStateNormal];
                        UIImage *image=[UIImage imageNamed:@"WriteOrderInfo_btn_selected_transparency"];
                        UIImageView *imageView=[[UIImageView alloc] initWithImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 20)]];
                        imageView.userInteractionEnabled=YES;
                        imageView.frame=weakSelectButton.bounds;
                        imageView.tag=TAG_IMAGE_ADSPECELL;
                        [weakSelectButton addSubview:imageView];
                    }
                    else
                    {
                        weakSelectButton.imageEdgeInsets=[weakSelf normalInset:image.size btnSize:weakSelectButton.frame.size];
                    }
                    [weakSelectButton setImage:image forState:UIControlStateNormal];
                }
            }];
        }

    }
    
}
-(UIEdgeInsets)selectInset:(CGSize)imageSize btnSize:(CGSize)btnSize
{//w:36 h:32
    CGFloat w1=btnSize.width-18.0f;
    CGFloat h1=btnSize.height-2.0f;
    CGFloat w2=h1*imageSize.width/imageSize.height;
    CGFloat top=1.0f;
    CGFloat left=(w1-w2)/2.0f+1.0f;
    CGFloat bottom=1.0f;
    CGFloat right=(w1-w2)/2.0f+17.0f;
    return UIEdgeInsetsMake(top, left, bottom, right);;
}
-(UIEdgeInsets)normalInset:(CGSize)imageSize btnSize:(CGSize)btnSize
{//w:36 h:32
    CGFloat w1=btnSize.width-2.0f;
    CGFloat h1=btnSize.height-2.0f;
    CGFloat w2=h1*imageSize.width/imageSize.height;
    CGFloat top=1.0f;
    CGFloat left=(w1-w2)/2.0f+1.0f;
    CGFloat bottom=1.0f;
    CGFloat right=(w1-w2)/2.0f+1.0f;
    return UIEdgeInsetsMake(top, left, bottom, right);;
}

- (void)removeSubButtons
{
    NSMutableArray *subViews = [NSMutableArray arrayWithArray:self.contentView.subviews];
    NSUInteger count = subViews.count;
    for (int i = 0; i < count; i++) {
        UIView *subView = [subViews objectAtIndex:i];
        if ([subViews isKindOfClass:[CTSelectButton class]]) {
            [subView removeFromSuperview];
            i--;
            count--;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.contentView.bounds;
    rect.origin.x = HorizonButtonDistance;
    rect.origin.y = HorizonButtonDistance;
    rect.size.width = HorizonButtonStart - HorizonButtonDistance;
    self.textLabel.textAlignment=NSTextAlignmentLeft;
    self.textLabel.frame = rect;
    [self.textLabel sizeToFit];
 
}
- (void)buttonSelectNotification:(NSNotification *)notification
{
    /**
     @Author                gongxt
     @Description           设置默认选项为空
     */
    self.defaultId=nil;
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[BdSpecCellSelectControl shareBdSpecCellSelectControl].controlDic removeAllObjects];
}

@end
