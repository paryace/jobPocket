//
//  CTPointCommodityDetailVCtler.m
//  CTPocketV4
//
//  Created by Y W on 14-3-11.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTPointCommodityDetailVCtler.h"

#import "ThreeSubView.h"

#import "UIColor+Category.h"
#import "UIImage+Category.h"
#import "SIAlertView.h"
#import "CTPointQueryVCtler.h"
#import "CTPointConfirmExchangeVCtler.h"

@interface CTPointCommodityDetailVCtler () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CTPointCommodityDetailVCtler

- (void)loadView
{
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 61;
        tableView.sectionHeaderHeight = 30;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.view = tableView;
        self.tableView = tableView;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"商品详情";  // modified by shallow, 2014-03-31
    
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 160)];
        view.backgroundColor = self.view.backgroundColor;
        
        int xOffset = 20, yOffset = 20;
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, yOffset + 10, 120, CGRectGetHeight(view.frame) - (yOffset + 10) * 2)];
            imageView.backgroundColor = self.view.backgroundColor;
            imageView.autoresizingMask = UIViewContentModeScaleAspectFill ;
            imageView.image = [UIImage imageNamed:@"CommodityListDefault"];
            imageView.contentMode = UIViewContentModeCenter;
            NSString *PicUrl = [self.commodityInfo objectForKey:@"PicUrl"];
            if (PicUrl.length > 0) {
                [imageView setImageWithURL:[NSURL URLWithString:PicUrl] placeholderImage:[UIImage imageNamed:@"CommodityListDefault"]];
            }
            [view addSubview:imageView];
        }
       /**
        xOffset = 160;
        yOffset = 35;
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 140, 16)];
            label.backgroundColor = self.view.backgroundColor;
            label.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
            label.font = [UIFont systemFontOfSize:16];
            label.text = [self.commodityInfo objectForKey:@"CommodityName"];
            
            [view addSubview:label];
            
            yOffset = CGRectGetMaxY(label.frame) + 10;
        }
        */
        xOffset = 160;
        yOffset = 8;
        {
            NSString *value=[NSString stringWithFormat:@"%@",self.commodityInfo[@"CommodityName"]];
            UIFont *font=[UIFont systemFontOfSize:14];
            CGSize size=[value sizeWithFont:font];
            NSLog(@"NSStringFromCGSize(size)-->%@",NSStringFromCGSize(size));
            CGFloat labelWidth=(CGRectGetWidth(self.view.bounds)-8-xOffset);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset,labelWidth , 53)];
            label.backgroundColor = self.view.backgroundColor;
            label.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
            label.font =font;
            label.text =value;
            label.numberOfLines=3;
            [view addSubview:label];
            
            yOffset = CGRectGetMaxY(label.frame) + 10;
        }
        
        
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, 0, 20) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
            threeSubView.backgroundColor = self.view.backgroundColor;
            
            [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [threeSubView.leftButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.leftButton setTitleEdgeInsets:UIEdgeInsetsMake(7, 0, 0, 0)];
            [threeSubView.leftButton setTitle:@"所需积分" forState:UIControlStateNormal];
            
            [threeSubView.centerButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
            [threeSubView.centerButton setTitle:[self.commodityInfo objectForKey:@"IntegralPrice"] forState:UIControlStateNormal];
            [threeSubView.centerButton setTitleColor:[UIColor colorWithR:95 G:189 B:42 A:1] forState:UIControlStateNormal];
            
            [threeSubView.rightButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [threeSubView.rightButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.rightButton setTitleEdgeInsets:UIEdgeInsetsMake(7, 0, 0, 0)];
            [threeSubView.rightButton setTitle:@"积分" forState:UIControlStateNormal];
            
            [threeSubView autoLayout];
            
            CGRect rect = threeSubView.frame;
            rect.origin.x = xOffset;
            rect.origin.y = 61 ;//yOffset
            threeSubView.frame = rect;
            
            [view addSubview:threeSubView];
            
            yOffset = CGRectGetMaxY(threeSubView.frame) + 10;
        }
        
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];//91
            button.frame = CGRectMake(xOffset, 91, 140, 40);//91
            button.backgroundColor = [UIColor clearColor];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:95 G:189 B:42 A:1] cornerRadius:5] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:95 G:189 B:42 A:1] cornerRadius:5] forState:UIControlStateDisabled];
            [button addTarget:self action:@selector(goExchangeVC) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"立即兑换" forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [view addSubview:button];
        }
        self.tableView.tableHeaderView = view;
    }
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 10)];
        view.backgroundColor = self.tableView.backgroundColor;
        
        int xOffset = 0, yOffset = 20;
        
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, yOffset, 0, 20) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
            threeSubView.backgroundColor = self.view.backgroundColor;
            
            [threeSubView.leftButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [threeSubView.leftButton setTitle:@" " forState:UIControlStateNormal];
            [threeSubView.leftButton setBackgroundColor:[UIColor colorWithR:95 G:189 B:42 A:1]];
            
            [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.centerButton setTitle:@"  积分兑换说明" forState:UIControlStateNormal];
            
            [threeSubView autoLayout];
            
            [view addSubview:threeSubView];
            
            yOffset = CGRectGetMaxY(threeSubView.frame) + 15;
        }
        
        xOffset = 10;
        {
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor clearColor];//self.view.backgroundColor;
            label.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
            label.font = [UIFont systemFontOfSize:15];
            label.text = [self.commodityInfo objectForKey:@"CommodityInfo"];
            label.numberOfLines = 0;
            CGSize constrainedSize = CGSizeZero;
            constrainedSize.width = CGRectGetWidth(view.frame) - xOffset * 2;
            constrainedSize.height = 1000;
            constrainedSize = [label.text sizeWithFont:label.font constrainedToSize:constrainedSize lineBreakMode:label.lineBreakMode];
            CGRect rect = CGRectZero;
            rect.origin = CGPointMake(xOffset, yOffset);
            rect.size = constrainedSize;
            label.frame = rect;
            
            [view addSubview:label];
            
            yOffset = CGRectGetMaxY(label.frame) + 20;
        }
        
        CGRect rect = view.frame;
        rect.size.height = yOffset;
        view.frame = rect;
        
        self.tableView.tableFooterView = view;
    }
}

#pragma mark - funcs

- (void)goExchangeVC
{
    int IntegralPrice = [self.commodityInfo[@"IntegralPrice"] intValue];
    if (self.Integral<IntegralPrice) {
        NSString *less = [NSString stringWithFormat:@"亲，你还需要%d积分即可兑换此宝贝了喔！",IntegralPrice-self.Integral];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:less];
        [alertView addButtonWithTitle:@"确认"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  
                              }];
        [alertView addButtonWithTitle:@"查看我的积分"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  CTPointQueryVCtler *vc = [[CTPointQueryVCtler alloc] init];
                                  [self.navigationController pushViewController:vc animated:YES];
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    } else {
        CTPointConfirmExchangeVCtler *vc = [[CTPointConfirmExchangeVCtler alloc] init];
        vc.Integral = self.Integral;
        vc.commodityInfo = self.commodityInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

@end
