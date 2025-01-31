    //
//  CTPointsToExchageVCtler.m
//  CTPocketV4
//
//  Created by Mac-Eshore-01 on 14-3-13.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTPointsToExchageVCtler.h"
#import "CTPointsPopularVClter.h"
#import "CTPointsVCtler.h"


#define kButtonTag 100
#define kImageViewTag 120

typedef enum {
    Ascending=0,
    Descending
} SORTTYPE;

extern NSString *const PopularDataSortNotified;
extern NSString *const PointsSortDataNotified;

@interface CTPointsToExchageVCtler ()

@property (nonatomic, strong) UIView *selectedView;
@property (nonatomic, strong) CTPointsPopularVClter *popularVC;
@property (nonatomic, strong) CTPointsVCtler *pointsVC;
@property (nonatomic, strong) CTBaseViewController *curVC;
@property (nonatomic, assign) int pageIndex;
@property (nonatomic, assign) SORTTYPE pointsSortType;
@property (nonatomic, assign) SORTTYPE popularSortType;

@end

@implementation CTPointsToExchageVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.pageIndex = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"积分排序";
    [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
    [self createVC];
    [self selectedView];
}

#pragma mark - control

- (UIView *)selectedView
{
    if (!_selectedView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
        view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:view];
        
        _selectedView = view;
        
        NSArray *titleAry = [NSArray arrayWithObjects:@"人 气",@"积 分", nil];
        NSArray *imageAry = [NSArray arrayWithObjects:@"recharge_selected_bg.png",@"recharge_selected_right", nil];
        
        float xPos = 0;
        for (int i=0; i<2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(xPos,0 , _selectedView.frame.size.width/2, _selectedView.frame.size.height);
            [button setTitle:titleAry[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"recharge_unselected_bg.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:imageAry[i]] forState:UIControlStateSelected];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            button.tag = kButtonTag+i;
            [button addTarget:self action:@selector(selectedVC:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            
            xPos = CGRectGetWidth(button.frame);
        }
        
        //人气
        {
            UIButton *buttonPopular = (UIButton *)[_selectedView viewWithTag:kButtonTag];
            buttonPopular.selected = YES;
            UIImage *sortImage = [UIImage imageNamed:@"pointsExchange_Descending_icon.png"];
            UIImageView *sortImageView = [[UIImageView alloc] initWithFrame:
                                          CGRectMake(buttonPopular.frame.size.width/2 + 26,
                                                     (CGRectGetHeight(_selectedView.frame)-sortImage.size.height)/2,
                                                     sortImage.size.width, sortImage.size.height)];
            sortImageView.tag = kImageViewTag;
            sortImageView.image = sortImage ;
            [buttonPopular addSubview:sortImageView];
        }
        
        //积分
        {
            UIButton *buttonPoint = (UIButton *)[_selectedView viewWithTag:kButtonTag + 1];
            UIImage *sortImage = [UIImage imageNamed:@"pointsExchange_Ascending_icon.png"];
            UIImageView *sortImageView = [[UIImageView alloc] initWithFrame:
                                          CGRectMake(buttonPoint.frame.size.width/2 + 26,
                                                     (CGRectGetHeight(_selectedView.frame)-sortImage.size.height)/2,
                                                     sortImage.size.width, sortImage.size.height)];
            sortImageView.tag = kImageViewTag + 1;
            sortImageView.image = sortImage ;
            [buttonPoint addSubview:sortImageView];
            sortImageView.hidden = YES;
        }
//        UIImageView *imageViewR = (UIImageView *)[self.selectedView viewWithTag:kImageViewTag+1];
//        imageViewR.hidden = YES;
        
        return view ;
    }
    
    return _selectedView ;
}

#pragma mark - VC

- (void)createVC
{
    CTPointsPopularVClter *popularVC = [[CTPointsPopularVClter alloc] init];
    popularVC.infoDict = self.infoDict;
    [self addChildViewController:popularVC];
    
    popularVC.view.frame = CGRectMake(self.view.bounds.origin.x,
                                      45,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height-45);
    popularVC.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:popularVC.view];
    [self didMoveToParentViewController:popularVC];
    self.popularVC = popularVC;
    self.curVC = popularVC ;
    self.popularVC.Integral = self.Integral ;
}

- (void)selectedExchange:(int)type
{
    UIImageView *imageView = (UIImageView *)[self.selectedView viewWithTag:kImageViewTag];
    UIImageView *imageViewR = (UIImageView *)[self.selectedView viewWithTag:kImageViewTag+1];
    
    switch (type) {
        case 0:
        {
            if (!self.popularVC) {
                CTPointsPopularVClter *popularVC = [[CTPointsPopularVClter alloc] init];
                [self addChildViewController:popularVC];
                popularVC.view.frame = CGRectMake(self.view.bounds.origin.x,
                                                  45,
                                                  self.view.bounds.size.width,
                                                  self.view.bounds.size.height-45);
                popularVC.view.backgroundColor = [UIColor clearColor];
                [self.view addSubview:popularVC.view];
                self.popularVC = popularVC ;
            }
            
            if (self.curVC!=self.popularVC) {
                [self.curVC.view removeFromSuperview];
                [self.view addSubview:self.popularVC.view];
                
            }
            
            self.curVC = self.popularVC ;
            imageViewR.hidden = YES;
            imageView.hidden = NO;
            
        }
            break;
        case 1:
        {
            if (!self.pointsVC) {
                CTPointsVCtler *pointsVC = [[CTPointsVCtler alloc] init];
                pointsVC.infoDict = self.infoDict;
                [self addChildViewController:pointsVC];
                pointsVC.view.frame = CGRectMake(self.view.bounds.origin.x,
                                                    45,
                                                    self.view.bounds.size.width,
                                                    self.view.bounds.size.height-45);
                pointsVC.view.backgroundColor = [UIColor clearColor];
                [self.view addSubview:pointsVC.view];
                self.pointsVC = pointsVC ;
                self.pointsVC.Integral = self.Integral ;
            }
            
            if (self.curVC!=self.pointsVC) {
                [self.curVC.view removeFromSuperview];
                [self.view addSubview:self.pointsVC.view];
            }
            
            self.curVC = self.pointsVC ;
            
            imageView.hidden = YES;
            imageViewR.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Action

- (void)selectedVC:(UIButton *)sender
{
    UIButton *btn = (UIButton *)sender ;
    int pageIndex = btn.tag - kButtonTag;
    
    UIImageView *imageView = (UIImageView *)[[self.selectedView viewWithTag:btn.tag] viewWithTag:kImageViewTag];
    UIImageView *imageViewR = (UIImageView *)[[self.selectedView viewWithTag:btn.tag] viewWithTag:kImageViewTag+1];
    
    if (self.pageIndex == pageIndex) {
        if (self.curVC == self.popularVC) {
            switch (self.popularSortType) {
                case Ascending:
                {
                    self.popularSortType = Descending;
                    imageView.image = [UIImage imageNamed:@"pointsExchange_Ascending_icon.png"];
                }
                    break;
                case Descending:
                {
                    self.popularSortType = Ascending;
                    imageView.image = [UIImage imageNamed:@"pointsExchange_Descending_icon.png"];
                    
                }
                    break;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PopularDataSortNotified object:nil];
            
        } else {
            switch (self.pointsSortType) {
                case Ascending:
                {
                    self.pointsSortType = Descending;
                    imageViewR.image = [UIImage imageNamed:@"pointsExchange_Descending_icon.png"];
                }
                    break;
                case Descending:
                {
                     self.pointsSortType = Ascending;
                    imageViewR.image = [UIImage imageNamed:@"pointsExchange_Ascending_icon.png"];

                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:PointsSortDataNotified object:nil];
        }
        return ;
    }
    
    self.pageIndex = pageIndex ;
    [self selectedExchange:pageIndex];
    
    for (int i=0; i<2; i++) {
        UIButton *button = (UIButton *)[self.selectedView viewWithTag:kButtonTag+i];
        if (button.tag == btn.tag) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
