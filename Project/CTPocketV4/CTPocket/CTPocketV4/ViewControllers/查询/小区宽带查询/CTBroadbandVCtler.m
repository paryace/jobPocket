//
//  CTBroadbandVCtler.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-5.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  小区宽带的主controller

#import "CTBroadbandVCtler.h"
#import "BBTopRepDataModel.h"
#import "CTMoreVCtler.h"
@interface CTBroadbandVCtler ()

@end

@implementation CTBroadbandVCtler

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"%s",__func__);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib. 
    [self setBackButton];
    self.title=@"小区宽带资源查询";
    self.requestProcess.tManager=self.topManager;
    self.requestProcess.cManager=self.centerManager;
    
    self.topManager.process=self.requestProcess;
    [self.topManager initial];
    
    self.centerManager.process=self.requestProcess;
    self.centerManager.textField=self.textField;
    [self.centerManager initial];
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    BOOL needRefreshUI = ![def objectForKey:kMoreBBHiden];
    if (needRefreshUI) {
        [def setObject:@"YES" forKey:kMoreBBHiden];
        [def synchronize];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CTRefreshNewFlag object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BBTopRepDataModel deleteDir];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
#pragma mark 隐藏键盘
-(IBAction)hideKeyWord:(UITapGestureRecognizer*)gueture
{
    [self.textField resignFirstResponder];
}
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (CGRectContainsPoint(self.topView.frame, point) ) { 
        return NO;
    }
    if (CGRectContainsPoint(self.searchButton.frame, point) ) {
        return NO;
    }
    if (CGRectContainsPoint(self.textField.frame, point) ) {
        return NO;
    }
    return YES;
}
@end
