//
//  MineLoginedVCtler.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-5-26.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "MineLoginedVCtler.h"
#import "UIColor+Category.h"
#import "MineRightManager.h"
#import "MineLoginItemCell.h"
#import "UIImage+Category.h"
#import "AppDelegate.h"
@interface MineLoginedVCtler ()
{
    CGFloat selfWidth;
    UINib *nib;
    
}
@property(weak,nonatomic)AutoScrollLabel *nameLabel;
@property(copy,nonatomic)NSString *point;
@end

@implementation MineLoginedVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
	// Do any additional setup after loading the view.
//    self.title=@"我的";
    self.view.backgroundColor=[UIColor colorWithR:37 G:37 B:37 A:1];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    selfWidth=CGRectGetWidth(self.view.bounds);
    //设置右上角按钮和主界面右上角按钮对齐
     CGRect btnFrame= self.exitBtn.frame;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]-7.0>=0)
    {
        btnFrame.origin.y=25;
    }else
    {
        btnFrame.origin.y=4;
    }
    self.exitBtn.frame=btnFrame;
    CGRect frame=self.remarksLabel.frame;
    AutoScrollLabel *label=[[AutoScrollLabel alloc] initWithFrame:frame];
    label.font=self.remarksLabel.font;
    label.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:label];
    self.nameLabel=label;
    //不在界面上显示，起着占位符的作用
    self.remarksLabel.hidden=YES;
    UIColor *lightedColor=[UIColor colorWithR:21 G:21 B:21 A:1];;
    [self.recommendView setBackgroundImage:[UIImage imageWithColor:lightedColor cornerRadius:0] forState:UIControlStateHighlighted];
    self.exitBtn.exclusiveTouch=YES;
    self.tableView.exclusiveTouch=YES;
    self.recommendView.exclusiveTouch=YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.recommendView.hidden=self.recommendHiden;
    if (self.nameLabel.text.length>11) {
        [self.nameLabel scroll];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *identifier=@"cell";
    if (nib==nil) {
        nib=[UINib nibWithNibName:@"MineLoginItemCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
    MineLoginItemCell *cell =(MineLoginItemCell*) [tableView dequeueReusableCellWithIdentifier:identifier]; 
    int row=indexPath.row;
    if (row==0&&_point) {//设置积分
        cell.label_center.text=self.point; 
    }
    [cell setupByRow:row];
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
    int row=indexPath.row;
    switch (row) {
        case 0:
        {
            //显示积分
            [self.manager showScore];
        }
            break;
        case 1:
        {
            //显示套餐余额
            [self.manager showTaoCanYuE];
        }
            break;
        case 2:
        {
            //显示套餐余额
            [self.manager showOrder];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - IBAction
-(IBAction)exit:(id)sender
{
    [self.manager loginOut];
}
-(IBAction)showShare:(id)sender
{
    [self  showShare];
}
#pragma mark - method
-(void)resetUserName:(NSString *)useName
{
//#warning 临时数据
//    NSString *txt=@"一二三四五六七八九十一二";
    NSString *txt=[NSString stringWithFormat:@"%@,你好!",useName];
    self.nameLabel.text=txt;
    if (txt.length>11) {
        [self.nameLabel scroll];
    }
}

-(void)resetPoint:(NSString*)point
{
    if (point==nil||point.length==0) {
        point=@"--";
    }
    self.point=point;
    [self.tableView reloadData];
}
-(void)appActive
{
    if (self.nameLabel.text.length>11) {
        [self.nameLabel scroll];
    }
}
-(void)resetRecommend 
{
   self.recommendView.hidden=self.recommendHiden;
}
@end
