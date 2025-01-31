//
//  CTPhoneListViewController.m
//  CTPocketV4
//
//  Created by Y W on 14-3-24.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTPhoneListViewController.h"

#import "SIAlertView.h"
#import "ThreeSubView.h"
#import "CTSelectBar.h"
#import "CTFilterSalesCell.h"
#import "SVProgressHUD.h"
#import "ISRefreshControl.h"

#import "UIColor+Category.h"

#import "Utils.h"
#import <SDWebImage/SDWebImageManager.h>

#import "CTSelectPhoneVCtler.h"
#import "CTScrollTopBtn.h"
#import "CTLoadingCell.h"
#define SectionHeaderViewHeight 88


@interface CTPhoneListViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
      NSString *cellIdentifier;
      PhoneType searchType;
}

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, strong) id refreshControl;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIControl *view_mask;// add by gongxt 2014-04-04 用来隐藏键盘


@property (nonatomic, strong) ThreeSubView *oneThreeSubView;
@property (nonatomic, strong) NSMutableArray *oneArray;
@property (nonatomic, assign) NSUInteger onePageIndex;
@property (nonatomic, assign) PhoneSortType oneSortType;
@property (nonatomic, assign) BOOL isOneFinished;



@property (nonatomic, strong) ThreeSubView *twoThreeSubView;
@property (nonatomic, strong) NSMutableArray *twoArray;
@property (nonatomic, assign) NSUInteger twoPageIndex;
@property (nonatomic, assign) PhoneSortType twoSortType;
@property (nonatomic, assign) BOOL isTwoFinished;


@property (nonatomic, strong) ThreeSubView *threeThreeSubView;
@property (nonatomic, strong) NSMutableArray *threeArray;
@property (nonatomic, assign) NSUInteger threePageIndex;
@property (nonatomic, assign) PhoneSortType threeSortType;
@property (nonatomic, assign) BOOL isThreeFinished;

@property (nonatomic, assign) NSUInteger pageSize;

@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic, assign) ThreeSubView *currentSelectThreeSubView;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, strong) NSMutableArray *currentSortTypeArray;

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL isfinished;
@property (nonatomic, assign) BOOL isLoadingMore;

@property (nonatomic, assign) PhoneSortType currentSortType;
@property (nonatomic, strong) FilterSlsPrdList *filterSlsPrdListNetworking;

@property(nonatomic,strong)CTScrollTopBtn *btn_scroll2top;

@property(nonatomic,strong)NSString *oldKeyWord;
@property (nonatomic, strong) NSString *stock;

 @property (nonatomic, weak)CTLoadingCell *loadCell;
@end

@implementation CTPhoneListViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        [self setLeftButton:[UIImage imageNamed:@"btn_back"]];
        
        self.oneArray = [NSMutableArray array];  self.onePageIndex = 1, self.oneSortType = PhoneSortTypeSalesAsc;
        self.twoArray = [NSMutableArray array];  self.twoPageIndex = 1; self.twoSortType = PhoneSortTypePriceAsc;
        self.threeArray = [NSMutableArray array];  self.threePageIndex = 1; self.threeSortType = PhoneSortTypePackageAsc;
        
        self.pageSize = 20;
        self.isfinished = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    switch (self.phoneType) {
        case PhoneTypeContract:
            self.title = @"合约机";
            break;
        case PhoneTypeNude:
            self.title = @"单买手机";
            break;
        default:
            self.title = @"精品手机";
            break;
    }
    
    //搜索的输入框
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), SectionHeaderViewHeight)];
        view.backgroundColor = self.view.backgroundColor;
        
        {
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 6, CGRectGetWidth(view.frame) - 10 * 2, 32)];
            textField.backgroundColor = [UIColor whiteColor];
            textField.layer.cornerRadius = 3;
            textField.delegate = self;
            textField.spellCheckingType = UITextSpellCheckingTypeNo;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.returnKeyType = UIReturnKeySearch;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.placeholder = @"千元大屏机";
            {
                UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, CGRectGetHeight(textField.frame))];
                mView.backgroundColor = [UIColor clearColor];
                textField.leftView = mView;
                textField.leftViewMode = UITextFieldViewModeAlways;
            }
            {
                UIImage *image = [UIImage imageNamed:@"prettyNum_search_icon"];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                CGRect rect = CGRectZero;
                rect.size = CGSizeMake(image.size.width + 18, image.size.height);
                button.frame = rect;
                [button setImage:image forState:UIControlStateNormal];
                button.backgroundColor = [UIColor clearColor];
                [button addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
                textField.rightView = button;
                textField.rightViewMode = UITextFieldViewModeAlways;
            }
            [view addSubview:textField];
            
            // add by gongxt 2014-04-04
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHiden:) name:UIKeyboardWillHideNotification object:nil];
            
            self.textField = textField;
        }
        
        //tableview 并添加下拉刷新控件
        {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SectionHeaderViewHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - SectionHeaderViewHeight)];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.rowHeight = [CTFilterSalesCell CellHeight]; 
            tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            if (1||[[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
                ISRefreshControl *refreshControl = [[ISRefreshControl alloc] init];
                [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
                [tableView addSubview:refreshControl];
                
                self.refreshControl = refreshControl;
            } else {
                UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
                [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
                [tableView addSubview:refreshControl];
                
                self.refreshControl = refreshControl;
            }
            
            [self.view addSubview:tableView];
            self.tableView = tableView;
        }
        
        /*
         *此处为销量 价格 套餐 三个选项的view
         *
         */
        NSMutableArray *items = [NSMutableArray array];
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, 0, 10) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:^{}];
            threeSubView.backgroundColor = [UIColor clearColor];
            
            //销量左边的小图标
            [threeSubView.leftButton setImage:[UIImage imageNamed:@"PhoneSearchIconSales"] forState:UIControlStateNormal];
            
            //中间的销量title
            [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.centerButton setTitle:@"销量" forState:UIControlStateNormal];
            
            //销量右边的箭头
            [threeSubView.rightButton setImage:[UIImage imageNamed:@"PhoneSearchIconArrowUp"] forState:UIControlStateNormal];
            [threeSubView.rightButton setImage:[UIImage imageNamed:@"PhoneSearchIconArrowDown"] forState:UIControlStateSelected];
            
            [items addObject:threeSubView];
            
            self.oneThreeSubView = threeSubView;
            
            [threeSubView autoLayout];
        }
        
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, 0, 10) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:^{}];
            threeSubView.backgroundColor = [UIColor clearColor];
            
            [threeSubView.leftButton setImage:[UIImage imageNamed:@"PhoneSearchIconPrice"] forState:UIControlStateNormal];
            
            [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.centerButton setTitle:@"价格" forState:UIControlStateNormal];
            
            [threeSubView.rightButton setImage:[UIImage imageNamed:@"PhoneSearchIconArrowUp"] forState:UIControlStateNormal];
            [threeSubView.rightButton setImage:[UIImage imageNamed:@"PhoneSearchIconArrowDown"] forState:UIControlStateSelected];
            
            [items addObject:threeSubView];
            
            self.twoThreeSubView = threeSubView;
            
            [threeSubView autoLayout];
        }
        
        if (self.phoneType!=PhoneTypeNude)
        {
            ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, 0, 10) leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:^{}];
            threeSubView.backgroundColor = [UIColor clearColor];
            
            [threeSubView.leftButton setImage:[UIImage imageNamed:@"PhoneSearchIconAmount"] forState:UIControlStateNormal];
            
            [threeSubView.centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [threeSubView.centerButton setTitleColor:[UIColor colorWithR:49 G:49 B:49 A:1] forState:UIControlStateNormal];
            [threeSubView.centerButton setTitle:@"套餐" forState:UIControlStateNormal];
            
            [threeSubView.rightButton setImage:[UIImage imageNamed:@"PhoneSearchIconArrowUp"] forState:UIControlStateNormal];
            [threeSubView.rightButton setImage:[UIImage imageNamed:@"PhoneSearchIconArrowDown"] forState:UIControlStateSelected];
            
            [items addObject:threeSubView];
            
            self.threeThreeSubView = threeSubView;
            
            [threeSubView autoLayout];
            
        }
        
        //自定义CTSelectBar控件
        {
            CTSelectBar *selectBar = [[CTSelectBar alloc] initWithFrame:CGRectMake(0, ceilf(SectionHeaderViewHeight/2.0), CGRectGetWidth(self.view.frame), ceilf(SectionHeaderViewHeight/2.0))];
            selectBar.backgroundColor = self.view.backgroundColor;
            __weak typeof(self) weakSelf = self;
            selectBar.selectBlock = ^(UIView *view){
                weakSelf.currentSelectThreeSubView = (ThreeSubView *)view;
                [weakSelf reloadData];
            };
            selectBar.items = items;
            [view addSubview:selectBar];
        }
        
        //调整 销量  价格  套餐   三个item的位置（图标，title，箭头）
        {
            for (ThreeSubView *threeSubView in items) {
                [threeSubView autoFit];
                threeSubView.rightButton.userInteractionEnabled = NO;
                [threeSubView.leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
                [threeSubView.rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
                
                
                if (threeSubView != [items lastObject]) {
                    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(ceilf(CGRectGetWidth(threeSubView.frame) - 1), 0, 1, CGRectGetHeight(threeSubView.frame) + 1)];
                    lineView.backgroundColor = [UIColor colorWithR:220 G:220 B:220 A:1];
                    [threeSubView addSubview:lineView];
                    threeSubView.clipsToBounds = NO;
                }
            }
        }
        
        {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, ceilf(SectionHeaderViewHeight/2.0), CGRectGetWidth(view.frame), 1)];
            lineView.backgroundColor = [UIColor colorWithR:220 G:220 B:220 A:1];
            [view addSubview:lineView];
        }
        
        [self.view addSubview:view];
    }
    
    {//滚到顶部按钮
        
        __weak typeof(self) weakSelf = self;
        self.btn_scroll2top=[[CTScrollTopBtn alloc] initWithFrame:CGRectZero selectBlock:
                                 ^(id obj){
                                     UITableView *tableView=weakSelf.tableView;
                                     CGRect rect_table=CGRectMake(0, 0,CGRectGetWidth(tableView.frame),
                                                                  CGRectGetHeight(tableView.frame));
                                     [tableView scrollRectToVisible:rect_table animated:YES];
                                 }
                             delegate:self];
        self.btn_scroll2top.exclusiveTouch=YES;
        [self.view addSubview:self.btn_scroll2top];
        CGFloat btn_width=43;//高度和宽度相同
        CGFloat btnX=CGRectGetWidth(self.tableView.frame)-btn_width-8;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]-6.0>=0)
        {//6.0以上通过AutoLayout设置坐标系
            
            self.btn_scroll2top.translatesAutoresizingMaskIntoConstraints=NO;
            
            NSDictionary *dic=@{@"btn":self.btn_scroll2top};
            
          
            //x坐标
            NSString *format_horizontal=[NSString stringWithFormat:@"H:|-%f-[btn]",btnX];
            NSArray *constraints_horizontal=[NSLayoutConstraint constraintsWithVisualFormat:format_horizontal
                                                                                    options:0 metrics:nil views:dic];
            [self.view addConstraints:constraints_horizontal];
            
             //y坐标
            NSLayoutConstraint *constraints_vertical=[NSLayoutConstraint constraintWithItem:self.btn_scroll2top
                                                                                  attribute :NSLayoutAttributeBottom
                                                                                  relatedBy :NSLayoutRelationEqual
                                                                                  toItem    :self.tableView
                                                                                  attribute :NSLayoutAttributeBottom
                                                                                  multiplier:1.0
                                                                                  constant  :-60];
            [self.view addConstraint:constraints_vertical];

            
            
            NSString *format_width=[NSString stringWithFormat:@"H:[btn(==%f)]",btn_width];
            //设置按钮的宽
            NSArray *constriants_width= [NSLayoutConstraint constraintsWithVisualFormat:format_width options:0 metrics:nil views:dic];
            [self.btn_scroll2top addConstraints:constriants_width];
            
            
            NSString *format_height=[NSString stringWithFormat:@"V:[btn(==%f)]",btn_width];
            //设置按钮的高
            NSArray *constriants_height= [NSLayoutConstraint constraintsWithVisualFormat:format_height options:0 metrics:nil views:dic];
            [self.btn_scroll2top addConstraints:constriants_height];
        }
        else
        { //6.0以下通过改变frame设置坐标系 
            CGFloat btnY=CGRectGetMaxY(self.tableView.frame)-btn_width-151;
            CGRect frame_btn=CGRectMake(btnX, btnY, btn_width, btn_width);
            self.btn_scroll2top.frame=frame_btn;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    //收到内存警告时，清理不用的数据（当前选择item之外的两个item对应的数据）
    switch (self.currentSortType) {
        case PhoneSortTypeSalesAsc:
        case PhoneSortTypeSalesDes:
            [self.twoArray removeAllObjects]; self.twoPageIndex = 1;
            [self.threeArray removeAllObjects]; self.threePageIndex = 1;
            break;
        case PhoneSortTypePriceAsc:
        case PhoneSortTypePriceDes:
            [self.oneArray removeAllObjects]; self.onePageIndex = 1;
            [self.threeArray removeAllObjects]; self.threePageIndex = 1;
            break;
        case PhoneSortTypePackageAsc:
        case PhoneSortTypePackageDes:
            [self.oneArray removeAllObjects]; self.onePageIndex = 1;
            [self.twoArray removeAllObjects]; self.twoPageIndex = 1;
            break;
        default:
            break;
    }
}

#pragma mark - funcs
-(void)cellIdentifierV
{
    static NSString *c1 = @"Cell1";
    static NSString *c2 = @"Cell2";
    static NSString *c3 = @"Cell3";
    if (self.currentSelectThreeSubView == self.oneThreeSubView)
    {
        cellIdentifier=c1;
    }
    else if (self.currentSelectThreeSubView == self.twoThreeSubView)
    {
         cellIdentifier=c2;
    }
    else if (self.currentSelectThreeSubView == self.threeThreeSubView)
    {
        cellIdentifier=c3;
    }
}

- (void)showTips
{
    if (self.tipLabel == nil) {
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 320, 22)];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.font = [UIFont systemFontOfSize:16];
        tipLabel.textColor = [UIColor colorWithR:49 G:49 B:49 A:1];
        tipLabel.textAlignment = UITextAlignmentCenter;
        tipLabel.text = @"亲，暂时没有可购买的商品哟";
        self.tipLabel = tipLabel;
    }
    [self.view addSubview:self.tipLabel];
}

- (void)reloadData
{
    
    searchType=self.phoneType;
    self.isLoadingMore=NO;
    if (self.currentSelectThreeSubView == self.oneThreeSubView)
    {
        // add by liuruxian 2014-04-22 禁止触摸事件
        self.twoThreeSubView.userInteractionEnabled = NO;
        self.threeThreeSubView.userInteractionEnabled = NO;
        self.twoThreeSubView.exclusiveTouch = NO;
        self.twoThreeSubView.exclusiveTouch = NO;
        
        //隐藏非当前所选item的两个箭头
        self.twoThreeSubView.rightButton.hidden = YES;
        self.threeThreeSubView.rightButton.hidden = YES;
        
        //若本身的箭头为隐藏，则表示是从别的item选择此item，故只需要显示选择item数据即可
        if (self.oneThreeSubView.rightButton.hidden) {
            self.oneThreeSubView.rightButton.hidden = NO;
        } else {
            //此处本身的箭头不为隐藏，则表示重复点击了此item，则需要改变排序规则，重新加载数据
            [self.currentSortTypeArray removeAllObjects];
            self.onePageIndex = 1;
            if (self.oneSortType == PhoneSortTypeSalesAsc) {
                self.oneSortType = PhoneSortTypeSalesDes;
                self.oneThreeSubView.rightButton.selected = YES;
            } else {
                self.oneSortType = PhoneSortTypeSalesAsc;
                self.oneThreeSubView.rightButton.selected = NO;
            }
        }
        
        self.currentSortType = self.oneSortType;
        self.currentPageIndex = self.onePageIndex;
        self.currentSortTypeArray = self.oneArray;
        self.isfinished=self.isOneFinished;
    }
    else if (self.currentSelectThreeSubView == self.twoThreeSubView)
    {
        // add by liuruxian 2014-04-22 禁止触摸事件
        self.oneThreeSubView.userInteractionEnabled = NO;
        self.threeThreeSubView.userInteractionEnabled = NO;
        self.oneThreeSubView.exclusiveTouch = NO;
        self.threeThreeSubView.exclusiveTouch = NO;
        
        self.oneThreeSubView.rightButton.hidden = YES;
        self.threeThreeSubView.rightButton.hidden = YES;
        
        if (self.twoThreeSubView.rightButton.hidden) {
            self.twoThreeSubView.rightButton.hidden = NO;
        } else {
            [self.currentSortTypeArray removeAllObjects];
            self.twoPageIndex = 1;
            if (self.twoSortType == PhoneSortTypePriceAsc) {
                self.twoSortType = PhoneSortTypePriceDes;
                self.twoThreeSubView.rightButton.selected = YES;
            } else {
                self.twoSortType = PhoneSortTypePriceAsc;
                self.twoThreeSubView.rightButton.selected = NO;
            }
        }
        
        self.currentSortType = self.twoSortType;
        self.currentPageIndex = self.twoPageIndex;
        self.currentSortTypeArray = self.twoArray;
        self.isfinished=self.isTwoFinished;
    }
    else if (self.currentSelectThreeSubView == self.threeThreeSubView)
    {
        // add by liuruxian 2014-04-22 禁止触摸事件
        self.oneThreeSubView.userInteractionEnabled = NO;
        self.twoThreeSubView.userInteractionEnabled = NO;
        
        self.oneThreeSubView.exclusiveTouch = NO;
        self.twoThreeSubView.exclusiveTouch = NO;
        
        self.oneThreeSubView.rightButton.hidden = YES;
        self.twoThreeSubView.rightButton.hidden = YES;
        
        if (self.threeThreeSubView.rightButton.hidden) {
            self.threeThreeSubView.rightButton.hidden = NO;
        } else {
            [self.currentSortTypeArray removeAllObjects];
            self.threePageIndex = 1;
            if (self.threeSortType == PhoneSortTypePackageAsc) {
                self.threeSortType = PhoneSortTypePackageDes;
                self.threeThreeSubView.rightButton.selected = YES;
            } else {
                self.threeSortType = PhoneSortTypePackageAsc;
                self.threeThreeSubView.rightButton.selected = NO;
            }
        }
        
        searchType=PhoneTypeContract;
        self.currentSortType = self.threeSortType;
        self.currentPageIndex = self.threePageIndex;
        self.currentSortTypeArray = self.threeArray;
        self.isfinished=self.isThreeFinished;
    }
    
    [self.tableView reloadData];
    
    NSString *okw=self.oldKeyWord;
    NSString *kw=self.keyWord;
    BOOL needReloadByKW=(![okw isEqualToString:kw]&&kw.length>0);
    
    if (needReloadByKW||self.currentSortTypeArray.count == 0)
    {
        [self.currentSortTypeArray removeAllObjects];
        self.currentPageIndex = 1;
        self.isfinished=NO;
        if (self.currentSelectThreeSubView == self.oneThreeSubView)
        {
            self.isOneFinished=NO;
        }
        else if (self.currentSelectThreeSubView == self.twoThreeSubView)
        {
            self.isTwoFinished=NO;
        }
        else if (self.currentSelectThreeSubView == self.threeThreeSubView)
        {
            self.isThreeFinished=NO;
        }
        [self loadMore];
    } else{
        // add by liuruxian 2014-04-22 释放触摸事件
        if (self.currentSelectThreeSubView == self.oneThreeSubView)
        {
            self.twoThreeSubView.userInteractionEnabled = YES;
            self.threeThreeSubView.userInteractionEnabled = YES;
            self.threeThreeSubView.exclusiveTouch = YES;
            self.twoThreeSubView.exclusiveTouch = YES;
        }
        else if (self.currentSelectThreeSubView == self.twoThreeSubView)
        {
            self.oneThreeSubView.userInteractionEnabled = YES;
            self.threeThreeSubView.userInteractionEnabled = YES;
            self.threeThreeSubView.exclusiveTouch = YES;
            self.twoThreeSubView.exclusiveTouch = YES;
        }
        else if (self.currentSelectThreeSubView == self.threeThreeSubView)
        {
            self.twoThreeSubView.userInteractionEnabled = YES;
            self.oneThreeSubView.userInteractionEnabled = YES;
            self.threeThreeSubView.exclusiveTouch = YES;
            self.twoThreeSubView.exclusiveTouch = YES;
        }
    }
}

- (void)changePageIndex
{
    //将选择的pageIndex +1
    if (self.currentSelectThreeSubView == self.oneThreeSubView)
    {
        self.onePageIndex += 1;
        self.currentPageIndex = self.onePageIndex;
    }
    else if (self.currentSelectThreeSubView == self.twoThreeSubView)
    {
        self.twoPageIndex += 1;
        self.currentPageIndex = self.twoPageIndex;
    }
    else if (self.currentSelectThreeSubView == self.threeThreeSubView)
    {
        self.threePageIndex += 1;
        self.currentPageIndex = self.threePageIndex ;
    }
}

- (void)reloadDataWithResponseDictionary:(NSDictionary *)responseDictionary
{
    FilterSlsPrdListModel *filterSlsPrdListModel = [FilterSlsPrdListModel modelObjectWithDictionary:responseDictionary];
    if (filterSlsPrdListModel.DataList.count<self.pageSize)
    {
        self.isfinished=YES;
        if (self.currentSelectThreeSubView == self.oneThreeSubView)
        {
            self.isOneFinished=YES;
        }
        else if (self.currentSelectThreeSubView == self.twoThreeSubView)
        {
            self.isTwoFinished=YES;
        }
        else if (self.currentSelectThreeSubView == self.threeThreeSubView)
        {
            self.isThreeFinished=YES;
        }
    }
    [self.currentSortTypeArray addObjectsFromArray:filterSlsPrdListModel.DataList];
    [self.tableView reloadData];
    [self changePageIndex];
    if (self.currentSortTypeArray.count == 0) {
        [self showTips];
    } else {
        [self.tipLabel removeFromSuperview];
    }
    // add by liuruxian 2014-04-22 释放触摸事件
    if (self.currentSelectThreeSubView == self.oneThreeSubView)
    {
        self.twoThreeSubView.userInteractionEnabled = YES;
        self.threeThreeSubView.userInteractionEnabled = YES;
        self.threeThreeSubView.exclusiveTouch = YES;
        self.twoThreeSubView.exclusiveTouch = YES;
    }
    else if (self.currentSelectThreeSubView == self.twoThreeSubView)
    {
        self.oneThreeSubView.userInteractionEnabled = YES;
        self.threeThreeSubView.userInteractionEnabled = YES;
        self.threeThreeSubView.exclusiveTouch = YES;
        self.twoThreeSubView.exclusiveTouch = YES;
    }
    else if (self.currentSelectThreeSubView == self.threeThreeSubView)
    {
        self.twoThreeSubView.userInteractionEnabled = YES;
        self.oneThreeSubView.userInteractionEnabled = YES;
        self.threeThreeSubView.exclusiveTouch = YES;
        self.twoThreeSubView.exclusiveTouch = YES;
    }
}

#pragma mark - action

- (void)handleRefresh:(id)refreshControl
{
    self.isLoadingMore=NO;
    self.isfinished=NO;
    if (self.currentSelectThreeSubView == self.oneThreeSubView)
    {
        self.isOneFinished=NO;
    }
    else if (self.currentSelectThreeSubView == self.twoThreeSubView)
    {
        self.isTwoFinished=NO;
    }
    else if (self.currentSelectThreeSubView == self.threeThreeSubView)
    {
        self.isThreeFinished=NO;
    }
    if (self.currentSelectThreeSubView == self.oneThreeSubView)
    {
        //刷新时移出当前所选的item所有数据，将pageIndex置1
        [self.currentSortTypeArray removeAllObjects];
        self.onePageIndex = 1;
        self.currentPageIndex = self.onePageIndex; //注意这地方要将currentPageIndex也设置为1
    }
    else if (self.currentSelectThreeSubView == self.twoThreeSubView)
    {
        [self.currentSortTypeArray removeAllObjects];
        self.twoPageIndex = 1;
        self.currentPageIndex = self.twoPageIndex;
    }
    else if (self.currentSelectThreeSubView == self.threeThreeSubView)
    {
        [self.currentSortTypeArray removeAllObjects];
        self.threePageIndex = 1;
        self.currentPageIndex = self.threePageIndex;
    }
   
    [self loadMore];
}

- (void)search
{
    [self.textField resignFirstResponder];
    self.keyWord = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (0 && self.keyWord.length == 0) {
        return;
    }
    
    if (self.currentSelectThreeSubView == self.oneThreeSubView)
    {
        [self.currentSortTypeArray removeAllObjects];
        self.onePageIndex = 1;
        self.currentPageIndex = self.onePageIndex;
    }
    else if (self.currentSelectThreeSubView == self.twoThreeSubView)
    {
        [self.currentSortTypeArray removeAllObjects];
        self.twoPageIndex = 1;
        self.currentPageIndex = self.twoPageIndex;
    }
    else if (self.currentSelectThreeSubView == self.threeThreeSubView)
    {
        [self.currentSortTypeArray removeAllObjects];
        self.threePageIndex = 1;
        self.currentPageIndex = self.threePageIndex;
    }
    [self loadMore];
}

#pragma mark - networking

- (void)checkError:(NSError *)error
{
    // add by liuruxian 2014-04-22 释放触摸事件
    if (self.currentSelectThreeSubView == self.oneThreeSubView)
    {
        self.twoThreeSubView.userInteractionEnabled = YES;
        self.threeThreeSubView.userInteractionEnabled = YES;
        self.threeThreeSubView.exclusiveTouch = YES;
        self.twoThreeSubView.exclusiveTouch = YES;
    }
    else if (self.currentSelectThreeSubView == self.twoThreeSubView)
    {
        self.oneThreeSubView.userInteractionEnabled = YES;
        self.threeThreeSubView.userInteractionEnabled = YES;
        self.threeThreeSubView.exclusiveTouch = YES;
        self.twoThreeSubView.exclusiveTouch = YES;
    }
    else if (self.currentSelectThreeSubView == self.threeThreeSubView)
    {
        self.twoThreeSubView.userInteractionEnabled = YES;
        self.oneThreeSubView.userInteractionEnabled = YES;
        self.threeThreeSubView.exclusiveTouch = YES;
        self.twoThreeSubView.exclusiveTouch = YES;
    }
    
    if (error.userInfo[@"ResultCode"])
    {
        if ([error.userInfo[@"ResultCode"] isEqualToString:@"X104"])
        {
            // 取消掉全部请求和回调，避免出现多个弹框
            [MyAppDelegate.cserviceEngine cancelAllOperations];
             __weak typeof(self) weakSelf = self;
            // 提示重新登录
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                             andMessage:@"长时间未登录，请重新登录。"];
            [alertView addButtonWithTitle:@"确定"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                      [MyAppDelegate showReloginVC];
                                      if (weakSelf.navigationController != nil)
                                      {
                                          [weakSelf.navigationController popViewControllerAnimated:NO];
                                      }
                                  }];
            
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            [alertView show];
        }
    }
    else
    {
        NSString* msg = [error localizedDescription];
        if ([error code] == -1001) {
            msg = @"网络不给力，请稍后再试";
        } else if ([error code] == -1004 ||
                   [error code] == -1009) {
            msg = @"无网络连接，请检查网络设置";
        }
        // 取消掉全部请求和回调，避免出现多个弹框
        [MyAppDelegate.cserviceEngine cancelAllOperations];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                         andMessage:msg];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:nil];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }
}
//加载更多
- (void)loadMore
{
    [self.tipLabel removeFromSuperview];
    if (self.filterSlsPrdListNetworking == nil) {
        self.filterSlsPrdListNetworking = [[FilterSlsPrdList alloc] init];
    } else {
        [self.filterSlsPrdListNetworking cancel];
    }
//    if (!self.isLoadingMore) {
        [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeGradient];
//    }
    self.loading = YES;
    [self.loadCell setView:YES];
    __weak typeof(self) weakSelf = self;
    NSString *kw=self.keyWord;
    
    [self.filterSlsPrdListNetworking filterSlsPrdListWithSortby:self.currentSortType Type:searchType
                                                          Index:self.currentPageIndex PageSize:self.pageSize KeyWord:kw finishBlock:^(NSDictionary *resultParams, NSError *error) {
        [weakSelf.loadCell setView:NO];
        weakSelf.loading = NO;
//        if (!weakSelf.isLoadingMore) {
              [SVProgressHUD dismiss];
//        }
        weakSelf.isLoadingMore=NO;
        [weakSelf.refreshControl endRefreshing];
        if (error) {
            weakSelf.isfinished = YES;
            [weakSelf checkError:error];
            return;
        }
        [weakSelf reloadDataWithResponseDictionary:[resultParams objectForKey:@"Data"]];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        
        if (self.isfinished) {
            return 0;
        }
        return 1;
    }
    return self.currentSortTypeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        static NSString *loadcell = @"loadcell";
        CTLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:loadcell];
        cell.userInteractionEnabled=NO;
        if (cell==nil) {
            cell = [[CTLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadcell];
        }
        if (self.loading) {
            [cell setView:YES];
            
        } else {
            [cell setView:NO];
        }
        self.loadCell=cell;
        return  cell;
    }
    CTFilterSalesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CTFilterSalesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSArray *array=self.currentSortTypeArray;
    int row=indexPath.row;
    // modified by liuruxian 2014-04-28
    if (row>=array.count)
    {
        return cell;
    }
    
    QryBdSalesComInfoModel *model = [ array objectAtIndex:row];
    
    cell.nameLabel.text = model.SalesProdName;
    NSString *disInfo= model.SalesProdDisInfo;
    cell.disInfoLabel.text =disInfo;
    UIButton *btn=cell.priceThreeSubView.centerButton;
    NSString *SalesProdDisPrice=[Utils smartNumberStringWithFloat:model.SalesProdDisPrice];
    [btn setTitle:SalesProdDisPrice forState:UIControlStateNormal]; 
    [cell.priceThreeSubView autoLayout];
    
    cell.iconImageView.image = [UIImage imageNamed:@""];
    if (model.SalesProdPicUrl) {
        [cell.iconImageView setImageWithURL:[NSURL URLWithString:model.SalesProdPicUrl]];
    }
    
    cell.disIconImageView.image = [UIImage imageNamed:@""];
    if (model.SalesProdDisPicUrl) {
        [cell.disIconImageView setImageWithURL:[NSURL URLWithString:model.SalesProdDisPicUrl]];
    }
    
    //有多个赠品时，使用第一个赠品的数据显示
    for (GiftModel *giftModel in model.Gifts) {
        if ([giftModel.Count intValue] > 0) {
            cell.giftLabel.text = [NSString stringWithFormat:@"%@x%@", giftModel.Name, giftModel.Count];
            cell.giftImageView.image = nil;
            if (giftModel.IconUrl) {
                [cell.giftImageView setImageWithURL:[NSURL URLWithString:giftModel.IconUrl]];
            }
            break;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![[Reachability reachabilityWithHostname:@"cservice.client.189.cn"] isReachable])
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                       andMessage:@"无网络连接，请检查网络设置"];
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:nil];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
        return;
    }
    
    QryBdSalesComInfoModel *model = [self.currentSortTypeArray objectAtIndex:indexPath.row];
    
    NSLog(@"销售价格%f \r\n市场价格 %@ \r\n销售品ID %@",model.SalesProdDisPrice,model.MarketPrice,model.SalesProdId);
    CTSelectPhoneVCtler *selectPhoneVCtler = [[CTSelectPhoneVCtler alloc] init];
    selectPhoneVCtler.salesId = model.SalesProdId;
    [self.navigationController pushViewController:selectPhoneVCtler animated:YES];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point_offset= scrollView.contentOffset;
    
    if (point_offset.y> 50)
    {
        [self.btn_scroll2top enable];
    }
    else
    {
        [self.btn_scroll2top disable];
    }
    
    
/* modified by gongxt 实现加载更多的功能**/
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 5;
    if(y > h + reload_distance) {
        NSInteger arrayCount=self.currentSortTypeArray.count;
        NSInteger pageCount=(self.currentPageIndex-1) * self.pageSize;
        if (arrayCount < pageCount) {
            return;
        }
        if (self.loading) {
            return;
        }
        if (self.isfinished) {
            return;
        }
        self.isLoadingMore=YES;
         [self loadMore];
    }
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

/** modified by gongxt
//判断当上拉到一定位置时加载更多
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSInteger arrayCount=self.currentSortTypeArray.count;
    NSInteger pageCount=(self.currentPageIndex-1) * self.pageSize;
    if (arrayCount < pageCount) {
        return;
    }
    
    if (self.loading) {
        return;
    }
	if((scrollView.contentOffset.y > 0)) {
        if (scrollView.contentSize.height > scrollView.frame.size.height) {
            if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height + 50) {
                [self loadMore];
            }
        } else if (scrollView.contentOffset.y > 50) {
            [self loadMore];
        }
    }
}
*/
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self search];
    return YES;
}

#pragma mark 接收显示键盘得通知
-(void)keyboardShow:(NSNotification*)ntc
{
    
    self.oldKeyWord=self.keyWord; 
    if (self.view_mask) {
        return;
    }
    // add by gongxt 2014-04-04
    NSDictionary *info= [ntc userInfo];
    NSValue *v= [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect_text_field=[v CGRectValue];
    CGFloat mixY=CGRectGetMinY(rect_text_field);
    
    
    CGRect rect_header=[self.textField convertRect:self.textField.frame toView:self.view];
    CGFloat maxY=CGRectGetMaxY(rect_header);
    
    CGRect rect_mask=CGRectMake(0, maxY, CGRectGetWidth(self.view.bounds), (mixY-maxY));
    self.view_mask=[[UIControl alloc] initWithFrame:rect_mask];
    [self.view_mask addTarget:self action:@selector(textFieldResign) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.view_mask];
    
}
-(void)textFieldResign
{
    [self.textField resignFirstResponder];
    self.textField.text=@"";
}
#pragma mark 接收隐藏键盘得通知
-(void)keyboardHiden:(NSNotification*)ntc
{
    // add by gongxt 2014-04-04
    [self.view_mask removeFromSuperview];
    self.view_mask=nil;
    
}

@end
