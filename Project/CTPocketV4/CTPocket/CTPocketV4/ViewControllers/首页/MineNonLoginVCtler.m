//
//  MineNonLoginVCtler.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-5-26.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "MineNonLoginVCtler.h"
#import "MineRightManager.h" 
#import "UIColor+Category.h"
#import "MineNonLoginItemCell.h"
#import "UIImage+Category.h"
@interface MineNonLoginVCtler ()
{
    CGFloat selfWidth;
    UINib *nib;
}
@end

@implementation MineNonLoginVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.title=@"我的";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor=[UIColor colorWithR:37 G:37 B:37 A:1];
    selfWidth=CGRectGetWidth(self.view.bounds);
    self.recommendView.hidden=self.recommendHiden;
    
    UIColor *lightedColor=[UIColor colorWithR:21 G:21 B:21 A:1];;
    [self.recommendView setBackgroundImage:[UIImage imageWithColor:lightedColor cornerRadius:0] forState:UIControlStateHighlighted];
    self.tableView.exclusiveTouch=YES;
    self.recommendView.exclusiveTouch=YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.recommendView.hidden=self.recommendHiden;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
#pragma mark - IBAction
-(IBAction)login:(id)sender
{
    [self.manager login];
}
-(IBAction)showShare:(id)sender
{
    [self  showShare];
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *identifier=@"cell";
    if (nib==nil)
    {
        nib=[UINib nibWithNibName:@"MineNonLoginItemCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
    MineNonLoginItemCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];  
    return cell;
}
#pragma mark - UITableViewDelegate
 /** */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView=[[UIView alloc] init];
    sectionView.frame=CGRectMake(0, 0, selfWidth, 1);
//    sectionView.backgroundColor=[UIColor colorWithR:54 G:54 B:54 A:1]; 
    sectionView.backgroundColor=[UIColor clearColor];
    return sectionView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    [self.manager showDingdang];
}
#pragma mark - method
-(void)resetRecommend
{
    self.recommendView.hidden=self.recommendHiden;
}
@end
