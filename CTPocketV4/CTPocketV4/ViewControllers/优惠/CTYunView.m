//
//  CTYunView.m
//  CTPocketV4
//
//  Created by 许忠洲 on 14-1-15.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTYunView.h"

@interface CTYunView () <UIScrollViewDelegate,ScrollviewGestureDelegate>
@end

@implementation CTYunView

#pragma mark - Lazy Instantiation

- (UIScrollView *)packageScrollView
{
    if (!_packageScrollView) {
        _packageScrollView = [[packageScrollView alloc] initWithFrame:CGRectMake(-40, 0, 160, 112)];
        _packageScrollView.bounds = CGRectMake(0, 0, 80, 112);
        _packageScrollView.backgroundColor = [UIColor clearColor];
        _packageScrollView.showsHorizontalScrollIndicator = NO;
        _packageScrollView.pagingEnabled = YES;
        _packageScrollView.clipsToBounds = NO;
        _packageScrollView.delegate = self;
        _packageScrollView.scrollGestureDelegate = self;
        [self addSubview:_packageScrollView];
    }
    return _packageScrollView;
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// 重写hitTest:withEvent:将整个UIView的移动量重定位给UIScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event])
    {
        return self.packageScrollView;
    }
    
    return  nil;
}

#pragma mark - Custom Methods

- (void)addPackage:(NSArray *)package
{
    if ([package count] > 0) {
        int i = 0;
        for (NSDictionary *packageItem in package) {
            UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(80 * i, 0, 74, 112)];
            UIImage *tImage = [UIImage imageNamed:@"LeXiangPackage_BG@2x"];
            UIImage *resizeImage = [tImage resizableImageWithCapInsets:UIEdgeInsetsMake(tImage.size.height/2, tImage.size.width/2, tImage.size.height/2, tImage.size.width/2)];
            bg.image = resizeImage;
            bg.tag = i+1;
//            [self.packageScrollView addSubview:bg];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(80 * i, 0, 74, 168);
            btn.tag = i+1;
            if (i==0) {
                btn.selected = YES;
            }
            [btn setBackgroundImage:[UIImage imageNamed:@"LeXiangPackage_BG@2x"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"LeXiangPackage_BG_Selected@2x"] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(choosePackageAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.packageScrollView addSubview:btn];
            
            UILabel *title1 = [[UILabel alloc] initWithFrame:CGRectMake(80 * i, 0, 74, 28)];
            title1.backgroundColor = [UIColor clearColor];
            title1.font = [UIFont systemFontOfSize:14.0f];
            title1.textColor = [UIColor blackColor];
            title1.textAlignment = UITextAlignmentCenter;
            title1.text = [NSString stringWithFormat:@"%@元", (packageItem[@"Properties"][@"TS_NAME"] ? packageItem[@"Properties"][@"TS_NAME"] : @"")];
            title1.tag = i+1;
            [self.packageScrollView addSubview:title1];
            
            UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(80 * i, 28, 74, 28)];
            title2.backgroundColor = [UIColor clearColor];
            title2.font = [UIFont systemFontOfSize:14.0f];
            title2.textColor = [UIColor blackColor];
            title2.textAlignment = UITextAlignmentCenter;
            if (packageItem[@"Properties"][@"TS_YY"]) {
                NSString *t = [packageItem[@"Properties"][@"TS_YY"] stringByReplacingOccurrencesOfString:@"BD:" withString:@""];
                title2.text = [NSString stringWithFormat:@"%@分钟", [t stringByReplacingOccurrencesOfString:@"GN:" withString:@""]];
            }
            title2.tag = i+1;
            [self.packageScrollView addSubview:title2];
            
            UILabel *title3 = [[UILabel alloc] initWithFrame:CGRectMake(80 * i, 56, 74, 28)];
            title3.backgroundColor = [UIColor clearColor];
            title3.font = [UIFont systemFontOfSize:14.0f];
            title3.textColor = [UIColor blackColor];
            title3.textAlignment = UITextAlignmentCenter;
            title3.text = packageItem[@"Properties"][@"TS_LL"] ? packageItem[@"Properties"][@"TS_LL"] : @"";
            title3.tag = i+1;
            [self.packageScrollView addSubview:title3];
            
            UILabel *title4 = [[UILabel alloc] initWithFrame:CGRectMake(80 * i, 84, 74, 28)];
            title4.backgroundColor = [UIColor clearColor];
            title4.font = [UIFont systemFontOfSize:14.0f];
            title4.textColor = [UIColor blackColor];
            title4.textAlignment = UITextAlignmentCenter;
            title4.text = [NSString stringWithFormat:@"%@条/%@条",
                           packageItem[@"Properties"][@"TS_DX"] ? packageItem[@"Properties"][@"TS_DX"] : @"",
                           packageItem[@"Properties"][@"TS_CX"] ? packageItem[@"Properties"][@"TS_CX"] : @""];
            title4.tag = i+1;
            [self.packageScrollView addSubview:title4];
            
            i++;
        }
        
        for (UIView *v in self.packageScrollView.subviews) {
            if (v.tag == 1) {
                if ([v isKindOfClass:[UIImageView class]]) {
                    ((UIImageView *)v).image = [UIImage imageNamed:@"LeXiangPackage_BG_Selected@2x"];
                }
                else if ([v isKindOfClass:[UILabel class]]) {
                    ((UILabel *)v).textColor = [UIColor colorWithRed:0.43 green:0.77 blue:0.21 alpha:1];
                }
            }
        }
        
        self.packageScrollView.contentSize = CGSizeMake(80 * [package count], 112);
        
        // add by liuruxian 2014-04-21
        NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
        if ([userDefults objectForKey:@"YunKa"]) {
            int tag = [[userDefults objectForKey:@"YunKa"] integerValue];
            UIButton *btn = (UIButton *)[self.packageScrollView viewWithTag:tag];
            if (btn) {
                [self choosePackageAction:btn];
                float xPos = 80*(tag -1);
                [self.packageScrollView setContentOffset:CGPointMake(xPos, self.packageScrollView.frame.origin.y)];
            }
        }
    }
}

#pragma Action
- (void)choosePackageAction:(UIButton *)sender
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    int t = ((UIButton *)sender).tag;
    for (UIButton *v in self.packageScrollView.subviews) {
        if (v.tag == t) {
            if ([v isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)v;
                btn.selected = YES;
                self.index = t-1;
                if ([self.delegate respondsToSelector:@selector(didScrollToIndex:)]) {
                    [self.delegate didScrollToIndex:self.index];
                }
                [userDefults setObject:[NSString stringWithFormat:@"%d",btn.tag] forKey:@"YunKa"];
                [userDefults synchronize];
            }
            else if ([v isKindOfClass:[UILabel class]]) {
                ((UILabel *)v).textColor = [UIColor colorWithRed:0.43 green:0.77 blue:0.21 alpha:1];
            }
        }
        else {
            if ([v isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)v;
                btn.selected = NO;
            }
            else if ([v isKindOfClass:[UILabel class]]) {
                ((UILabel *)v).textColor = [UIColor blackColor];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int t = scrollView.contentOffset.x / 80;
    if ((t >= 0) && (t < self.packageScrollView.contentSize.width / 80)) {
        self.index = t;
        
//        for (UIView *v in self.packageScrollView.subviews) {
//            if (v.tag == t+1) {
//                if ([v isKindOfClass:[UIImageView class]]) {
//                    UIImage *tImage = [UIImage imageNamed:@"LeXiangPackage_BG_Selected@2x"];
//                    UIImage *resizeImage = [tImage resizableImageWithCapInsets:UIEdgeInsetsMake(tImage.size.height/2, tImage.size.width/2, tImage.size.height/2, tImage.size.width/2)];
//                    ((UIImageView *)v).image = resizeImage;
//                }
//                else if ([v isKindOfClass:[UILabel class]]) {
//                    ((UILabel *)v).textColor = [UIColor colorWithRed:0.43 green:0.77 blue:0.21 alpha:1];
//                }
//            }
//            else {
//                if ([v isKindOfClass:[UIImageView class]]) {
//                    UIImage *tImage = [UIImage imageNamed:@"LeXiangPackage_BG@2x"];
//                    UIImage *resizeImage = [tImage resizableImageWithCapInsets:UIEdgeInsetsMake(tImage.size.height/2, tImage.size.width/2, tImage.size.height/2, tImage.size.width/2)];
//                    ((UIImageView *)v).image = resizeImage;
//                }
//                else if ([v isKindOfClass:[UILabel class]]) {
//                    ((UILabel *)v).textColor = [UIColor blackColor];
//                }
//            }
//        }
//        
        if ([self.delegate respondsToSelector:@selector(scrollToNext:)]) {
            [self.delegate scrollToNext:self.index];
        }
    }
}

@end
