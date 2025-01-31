//
//  BBTopViewManager.m
//  CTPocketV4
//
//  Created by Gong Xintao on 14-6-6.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//  顶部视图的逻辑管理

#import "BBTopViewManager.h"
#import "AppDelegate.h"
#import "BBTopItemDataModel.h"
#import "BBTRequestParamModel.h"
#import "UIColor+Category.h"
#import "CTHelperMap.h"
#import "SVProgressHUD.h"
#import "Global.h"

#define BB_ANIMATION_DURATION  0.44

@interface BBTopViewManager()
@property(strong,nonatomic)UIView *dataView;
@property(weak,nonatomic)UIView *statusView;
@property(weak,nonatomic)UIPickerView *pickerView;

@property(strong,nonatomic)NSArray *provinces;
@property(weak,nonatomic)BBTopItemDataModel *currentP;

@property(strong,nonatomic)NSArray *citys;
@property(weak,nonatomic)BBTopItemDataModel *currentC;

@property(strong,nonatomic)NSArray *regions;

@property(weak,nonatomic)NSArray *datas;
//请求类型，省份还是城市，还是地区
@property(assign,nonatomic)BBTop_Type topTypes;
//请求参数
@property(strong,nonatomic)BBTRequestParamModel *rModel;
//选中的数据
@property(weak,nonatomic)  BBTopItemDataModel *selectItem;
@property(strong,nonatomic) UIColor *tipColor;
@property(strong,nonatomic) UIColor *contentColor;

//added by huangfq 2014-6-27
@property(assign,nonatomic) BOOL defaultP;
@property(assign,nonatomic) BOOL defaultC;

@end
@implementation BBTopViewManager
-(instancetype)init
{
    self=[super init];
    if (self) {
        _rModel=[[BBTRequestParamModel alloc] init];
        _rModel.ProvinceCode=nil;
        _rModel.CityCode=nil;
        _tipColor=[UIColor colorWithR:212 G:212 B:212 A:1];
        _contentColor=[UIColor blackColor];
    }
    return self;
}


#pragma mark - IBAction
-(IBAction)provinceClick:(UIButton*)sender
{
    self.topTypes=BBT_P;
    if (self.provinces==nil||self.provinces.count==0)
    {
        [self requestData];
        return;
    }
    self.topTypes=BBT_P;
    self.datas=self.provinces;
    [self showPicker];
}
-(IBAction)cityClick:(UIButton*)sender
{
    MyAppDelegate.window.userInteractionEnabled=YES;
    if (self.currentP==nil) {
        [self provinceClick:nil];//请求省份数据
        return;
    }
    self.topTypes=BBT_C;
    if (self.citys&&self.citys.count>0) {
        self.datas=self.citys;
        [self showPicker];
    }
    else
    {
        [self requestData];
    }
}
-(IBAction)regionClick:(UIButton*)sender
{
    MyAppDelegate.window.userInteractionEnabled=YES;
    if (self.currentC==nil) {
        [self cityClick:nil];
        return;
    }
    
    self.topTypes=BBT_R;
    if (self.regions &&self.regions.count>0){
        self.datas=self.regions;
        [self showPicker];
    }
    else
    {
        [self requestData];
    }
}

#pragma mark - method
-(void)initial;
{
    self.provinceButton.exclusiveTouch=YES;
        self.cityButton.exclusiveTouch=YES;
        self.regionButton.exclusiveTouch=YES;
    [self addArrowImage:self.provinceButton];
    [self addArrowImage:self.cityButton];
    [self addArrowImage:self.regionButton];
    //请求省份信息
    self.topTypes=BBT_P;
    [self requestData];
    /**
    __weak typeof(self) weakSelf=self;
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    @try {
        //添加定位
        [[CTHelperMap shareHelperMap] getAreaInfo:^(CTCity *city,NSError *error)
         {
             [SVProgressHUD dismiss];
            BOOL isSuccess= [CTHelperMap shareHelperMap].isSuccess;
            if (isSuccess)//定位成功后，请求数据
            {
                //请求省份数据
                weakSelf.topTypes=BBT_P;
                [weakSelf requestData];
                //请求城市数据
                weakSelf.topTypes=BBT_C;
                weakSelf.rModel.ProvinceCode=city.provincecode;
                [weakSelf requestData];
                //请求地区数据
                weakSelf.topTypes=BBT_R;
                weakSelf.rModel.CityCode=city.citycode;
                [weakSelf requestData];
                
                [weakSelf.provinceButton setTitle:city.provincename forState:UIControlStateNormal];
                [weakSelf.provinceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [weakSelf.cityButton setTitle:city.cityname forState:UIControlStateNormal];
                [weakSelf.cityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            else//定位失败后，设置初始化为no
            {
                 weakSelf.isInitial=NO;
            }
         }];
    }
    @catch (NSException *exception) {
        DDLogCVerbose(@"%@",exception);
        self.isInitial=NO;
    }
    @finally {  }
  */
}
-(void)addArrowImage:(UIButton*)btn
{
    UIImage *pimage=[UIImage imageNamed:@"prettyNum_arrow_icon"];
    UIImageView *pimageView=[[UIImageView alloc] initWithImage:pimage];
    CGSize psize=pimage.size;
    CGFloat px=  CGRectGetWidth(btn.frame)-psize.width;
    CGFloat py=  (CGRectGetHeight(btn.frame)-psize.height)/2;
    CGRect prect=CGRectMake(px, py, psize.width, psize.height);
    pimageView.frame=prect;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, psize.width)];
   [btn addSubview:pimageView];
}

#pragma mark 请求数据
-(void)requestData
{
    self.rModel.Type=3;
    self.rModel.topType=self.topTypes;
    //重置显示的数据
    self.datas=nil;
    switch (self.topTypes) {
        case BBT_P:
        {
            
            self.rModel.ProvinceCode=@"1";
            self.rModel.CityCode=nil;
            if (self.provinces&&self.provinces.count>0)
            {
                self.topTypes=BBT_P; 
                return;
            }
        }
            break;
        case BBT_C:
        {
            self.rModel.CityCode=nil;
        }
            break;
        case BBT_R:
        {
            
        }
            break;
            
        default:
            break;
    }
    //复制的作用当服务请求返回后还可以通过原始的请求参数处理相关事情
//    [self.process requestTopWithParmaModel:[self.rModel copy]];

    //added bu huangfq 2014-6-30
    [self.process getLocationByphoneNbrInfo:[self.rModel copy]];
}
#pragma mark - 显示数据的界面
-(void)showPicker
{
    if (self.dataView)
    {
        return;
    }
    //重置选中项
    switch (self.topTypes) {
        case BBT_P:
        {
            self.selectItem=self.currentP;
        }
            break;
        case BBT_C:
        {
            self.selectItem=self.currentC;
        }
            break;
        case BBT_R:
        {
            self.selectItem=self.currentR;
        }
            break;
            
        default:
            break;
    }
    [self changeColor:self.contentColor];
    CGRect windowFrame= MyAppDelegate.window.frame;
    self.dataView=[[UIView alloc] initWithFrame:windowFrame];
    self.dataView.backgroundColor=[UIColor clearColor];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(hideDataView:)];
    tap.delegate=(id<UIGestureRecognizerDelegate>)self;
    [self.dataView addGestureRecognizer:tap];
    [MyAppDelegate.window addSubview:self.dataView];
    
    //初始化picker
    {
        // picker
        UIPickerView * picker = [[UIPickerView alloc] init];
        picker.showsSelectionIndicator = YES;
        picker.dataSource     = (id<UIPickerViewDataSource>)self;
        picker.delegate       = (id<UIPickerViewDelegate>)self;
        [picker setBackgroundColor:[UIColor whiteColor]];
        picker.showsSelectionIndicator = YES;
        
        CGFloat pickerY=CGRectGetHeight(MyAppDelegate.window.frame)-CGRectGetHeight(picker.frame);
        picker.frame = CGRectMake(0, pickerY, CGRectGetWidth(picker.frame), CGRectGetHeight(picker.frame));
        [self.dataView addSubview:picker];
        self.pickerView=picker;
    }
    
    //初始化取消确认按钮
    {
        CGFloat selY=CGRectGetMinY(self.pickerView.frame)-40;
        UIView *pickerSelView = [[UIView alloc] initWithFrame:CGRectMake(0, selY, CGRectGetWidth(MyAppDelegate.window.frame), 40)];
        pickerSelView.backgroundColor = [UIColor colorWithRed:(9*16+7)/255. green:(9*16+7)/255. blue:(9*16+7)/255. alpha:1];
        [self.dataView addSubview:pickerSelView];
        switch (self.topTypes) {
            case BBT_P:
            {
                [self.pickerView selectRow: self.currentP.selectedRow inComponent:0 animated:NO];
            }
                break;
            case BBT_C:
            {
                [self.pickerView selectRow: self.currentC.selectedRow  inComponent:0 animated:NO];
            }
                break;
            case BBT_R:
            {
                
                [self.pickerView selectRow: self.currentR.selectedRow  inComponent:0 animated:NO];
            }
                break;
                
            default:
                break;
        }
        self.statusView=pickerSelView;
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        cancelBtn.frame = CGRectMake(0, 0, 80, 40);
        [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [pickerSelView addSubview:cancelBtn] ;
        
        
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [okBtn setTitle:@"完成" forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        okBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        okBtn.frame = CGRectMake(320-80, 0, 80, 40);
        [okBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        [pickerSelView addSubview:okBtn] ;
    }
    
    CGRect statusFrame= self.statusView.frame;
    CGRect sDescFrame=statusFrame;
    sDescFrame.origin.y=CGRectGetHeight(self.dataView.frame);
    self.statusView.frame=sDescFrame;
    
    CGRect pickerFrame= self.pickerView.frame;
    CGRect pDescFrame=pickerFrame;
    pDescFrame.origin.y=CGRectGetHeight(self.dataView.frame);
    self.pickerView.frame=pDescFrame; 
    [UIView transitionWithView:self.dataView duration:BB_ANIMATION_DURATION options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionTransitionNone
                    animations:^(){
                        self.statusView.frame=statusFrame;
                        self.pickerView.frame=pickerFrame;
                    }
                    completion: ^(BOOL finished){
                     
                    }];
    
}

-(void)changeColor:(UIColor*)color
{
    switch (self.topTypes) {
        case BBT_P:
        {
            [self.provinceButton setTitleColor:color forState:UIControlStateNormal];
        }
            break;
        case BBT_C:
        {
            [self.cityButton setTitleColor:color forState:UIControlStateNormal];
        }
            break;
        case BBT_R:
        {
            [self.regionButton setTitleColor:color forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}
-(void)changeColorByData
{
    UIColor *selecColor=self.contentColor;
    switch (self.topTypes) {
        case BBT_P:
        {
            if (self.currentP)
            {
                [self.provinceButton setTitleColor:selecColor forState:UIControlStateNormal];
            }else
            {
                [self.provinceButton setTitleColor:self.tipColor forState:UIControlStateNormal];
            }
        }
            break;
        case BBT_C:
        {
            if (self.currentC)
        {
            [self.cityButton setTitleColor:selecColor forState:UIControlStateNormal];
        }else
        {
            [self.cityButton setTitleColor:self.tipColor forState:UIControlStateNormal];
        }
        }
            break;
        case BBT_R:
        {  if (self.currentR)
        {
            [self.regionButton setTitleColor:selecColor forState:UIControlStateNormal];
        }else
        {
            [self.regionButton setTitleColor:self.tipColor forState:UIControlStateNormal];
        }
        }
            break;
            
        default:
            break;
    }
}
-(void)hideDataView:(UITapGestureRecognizer*)sender
{
    if (sender!=nil) {
        //防止点击picker空白的地方也会隐藏键盘
        CGPoint statusPoint=[sender locationInView:self.statusView];
        if (statusPoint.y>0)
        {
            return;
        }
    }

    
    CGRect statusFrame= self.statusView.frame;
    CGRect pickerFrame= self.pickerView.frame;
    
    [UIView transitionWithView:self.dataView duration:BB_ANIMATION_DURATION options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionTransitionNone
                    animations:^(){
                        CGRect sDescFrame=statusFrame;
                        sDescFrame.origin.y=CGRectGetHeight(self.dataView.frame);
                        self.statusView.frame=sDescFrame;
                        
                        CGRect pDescFrame=pickerFrame;
                        pDescFrame.origin.y=CGRectGetHeight(self.dataView.frame);
                        self.pickerView.frame=pDescFrame;
                    }
                    completion: ^(BOOL finished){
                        [self.dataView removeFromSuperview];
                        self.dataView=nil;
                        [self changeColorByData];
                    }];
}
-(void)cancelAction
{

    [self hideDataView:nil];
}
#pragma mark 完成按钮
-(void)doneAction
{
    [self hideDataView:nil];
    if (self.datas.count==0)
    {
        switch (self.topTypes) {
            case BBT_P:
            {
                self.currentP=nil;
                self.currentC=nil;
                self.currentR=nil;
                self.selectItem=nil;
            }
            break;
            case BBT_C:
            {
                self.currentC=nil;
                self.currentR=nil;
                self.selectItem=nil;
            }
                
            break;
            case BBT_R:
            {
                self.currentR=nil;
                self.selectItem=nil;
            }
             break;
                
            default:
                break;
        }
        return;
    }
    if (self.selectItem==nil&&self.datas.count>0)
    {
        self.selectItem=[self.datas objectAtIndex:0];
        self.selectItem.selectedRow=0;
    }
    switch (self.topTypes) {
        case BBT_P:
        {
            //如果选中的不是旧数据
            if (self.currentP.Freight_Area_Code!=self.selectItem.Freight_Area_Code)
            {
                self.rModel.ProvinceCode=self.selectItem.Freight_Area_Code;
                self.currentP=self.selectItem;
                self.currentC=nil;
                self.currentR=nil;
                self.rModel.CityCode=nil;
                self.rModel.RegionCode=nil;
                self.citys=nil;//如果更换省份，重置城市列表数据
                self.regions=nil;//如果更换省份，重置地区列表数据
                [self.provinceButton setTitle:self.currentP.Freight_Area_Name forState:UIControlStateNormal];
//                [self.cityButton setTitle:@"选择城市" forState:UIControlStateNormal];
                [self.cityButton setTitle:@"" forState:UIControlStateNormal];
                [self.cityButton setTitleColor:self.contentColor forState:UIControlStateNormal];
//                [self.regionButton setTitle:@"选择区域" forState:UIControlStateNormal];
                [self.regionButton setTitle:@"" forState:UIControlStateNormal];
                [self.regionButton setTitleColor:self.tipColor forState:UIControlStateNormal];
                [self.process resetCenter];
                MyAppDelegate.window.userInteractionEnabled=NO;
                //弹出选择城市的滚轮,因为是先调用hideDataView:方法所以需要延迟0.5秒再执行
                [self performSelector:@selector(cityClick:) withObject:nil
                           afterDelay:(BB_ANIMATION_DURATION+.2)];
            }
        }
            break;
        case BBT_C:
        {
            //如果选中的不是旧数据
            if (self.currentC.Freight_Area_Code!=self.selectItem.Freight_Area_Code)
            {
                self.rModel.CityCode=self.selectItem.Freight_Area_Code;
                self.currentC=self.selectItem;
                self.currentR=nil;
                self.rModel.RegionCode=nil;
                self.regions=nil;//如果更换省份，重置地区列表数据
                [self.cityButton setTitle:self.currentC.Freight_Area_Name forState:UIControlStateNormal];
//                [self.regionButton setTitle:@"选择区域" forState:UIControlStateNormal];
                [self.regionButton setTitle:@"" forState:UIControlStateNormal];
                [self.regionButton setTitleColor:self.contentColor  forState:UIControlStateNormal];
                [self.process resetCenter];
                MyAppDelegate.window.userInteractionEnabled=NO;
                //弹出选择城市的滚轮,因为是先调用hideDataView:方法所以需要延迟0.5秒再执行
                [self performSelector:@selector(regionClick:) withObject:nil
                           afterDelay:(BB_ANIMATION_DURATION+.2)];
            }
            
        }
            break;
        case BBT_R:
        {
            //如果选中的不是旧数据
            if (self.currentR.Freight_Area_Code!=self.selectItem.Freight_Area_Code)
            {
                self.rModel.RegionCode=self.selectItem.Freight_Area_Code;
                self.currentR=self.selectItem;
                [self.regionButton setTitle:self.currentR.Freight_Area_Name forState:UIControlStateNormal];
                [self.process resetCenter];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark -网络请求完成后
-(void)updateProvince:(NSMutableArray*)ps
{
    self.provinces=[NSArray arrayWithArray:ps];
    self.datas=self.provinces;
    self.topTypes=BBT_P;
  
    if (self.provinces.count>0) {
        
        //modified by huangfq 2014-6-27
        NSInteger index = 0;
        if ([Global sharedInstance].areaInfo) {
            
            if (!self.defaultP) {

                index = [Utils getIndexForLocation:self.provinces Location:[Global sharedInstance].areaInfo.provincename];
            }
            else
            {
                self.defaultP = YES;
            }
        }
        self.currentP=self.provinces[index];
        self.currentP.selectedRow = index;
        self.selectItem=self.currentP;
        [self.provinceButton setTitle:self.currentP.Freight_Area_Name forState:UIControlStateNormal];
        [self changeColor:self.contentColor];
        //请求省份成功后，选中默认的城市
        [self requestDefaultCity];
    };
}
-(void)requestDefaultCity
{
    
    self.topTypes=BBT_C;
    self.rModel.ProvinceCode=self.currentP.Freight_Area_Code;
    self.rModel.CityCode=nil;
    self.rModel.RegionCode=nil;
    [self requestData];
}
-(void)updateCinty:(NSMutableArray*)cs
{
    self.citys=[NSArray arrayWithArray:cs];
    self.datas=self.citys;
    self.topTypes=BBT_C;
    
    if (self.citys.count>0) {
        
        //modified by huangfq 2014-6-27
        NSInteger index = 0;
        if ([Global sharedInstance].areaInfo) {
            
            if (!self.defaultC) {
                
                index = [Utils getIndexForLocation:self.citys Location:[Global sharedInstance].areaInfo.cityname];
            }
            else
            {
                self.defaultC = YES;
            }
        }
        self.currentC=self.citys[index];
        self.currentC.selectedRow = index;
        self.selectItem=self.currentC;
        [self.cityButton setTitle:self.currentC.Freight_Area_Name forState:UIControlStateNormal];
        [self changeColor:self.contentColor];
        //请求城市成功后，选中默认的地区
        [self requestDefaultRegion];
    };
}
-(void)requestDefaultRegion
{
    self.topTypes=BBT_R;
    self.rModel.ProvinceCode=self.currentP.Freight_Area_Code;
    self.rModel.CityCode=self.currentC.Freight_Area_Code;
    self.rModel.RegionCode=nil;
    [self requestData];
}
-(void)updateRegion:(NSMutableArray*)rs
{
    self.regions=[NSArray arrayWithArray:rs];
    self.datas=self.regions;
    self.topTypes=BBT_R;
    
    NSString *regionTitle=nil;
    if (self.regions.count>1) {
        self.currentR=self.regions[1];
        self.currentR.selectedRow=1;
        self.selectItem=self.currentR;
        regionTitle=self.currentR.Freight_Area_Name;
    }
    else if (self.regions.count>0){ 
        self.currentR=self.regions[0];
        self.currentR.selectedRow=0;
        self.selectItem=self.currentR;
        regionTitle=self.currentR.Freight_Area_Name;
    }
    if (regionTitle) {
        [self.regionButton setTitle:self.currentR.Freight_Area_Name forState:UIControlStateNormal];
        [self changeColor:self.contentColor];
    }
}
#pragma mark 请求网络发生错误
-(void)occurError:(NSError *)error
{
  
}
#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.datas.count;
}
#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row>=self.datas.count)
    {
        [self.pickerView performSelector:@selector(reloadAllComponents) withObject:nil afterDelay:.44];
        return @"";
    }
    BBTopItemDataModel *item=[self.datas objectAtIndex:row];
    return item.Freight_Area_Name;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.datas.count>0)
    {
        self.selectItem=[self.datas objectAtIndex:row];
        self.selectItem.selectedRow=row;
    }
    else
    {
        self.selectItem=nil;
        self.selectItem.selectedRow=0;
    }
}
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.dataView];
    if (CGRectContainsPoint(self.statusView.frame, point) ) {
        return NO;
    }
    return YES;
}
@end
