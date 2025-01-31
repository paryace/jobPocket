//
//  SelectPackagesDetailVCtler.m
//  CTPocketv3
//
//  Created by Y W on 13-6-5.
//
//

#import "SelectPackagesDetailVCtler.h"
#import "UIView+RoundRect.h"
#import "RegexKitLite.h"
#import <QuartzCore/QuartzCore.h>
#import "SelectPackagesVCtler.h"
#import "CTPOnlineServiceVCtler.h"
#import "CTPNumberPickerVCtler.h"

@interface SelectPackagesDetailVCtler () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_responseData;
    
    //下面那一块的
    UIView *_giftView; //整体背景view
    UILabel *_giftNameLabel; //业务名字label;
    UIScrollView *_giftTypeScrollView; //赠送业务列表的背景scrollview
    UILabel *_selectGiftLabel; //选择的业务
    UIButton *_nextButton;
}

@property (nonatomic, retain)NSMutableArray *selectItems; //选择的业务赠书的
@property (nonatomic, assign)int maxCount;

@end

@implementation SelectPackagesDetailVCtler

@synthesize selectItems;
@synthesize maxCount;
@synthesize selectDictionaryItems;
@synthesize SalesproductId;
@synthesize ContractId;
@synthesize SalesproductInfoDict;
@synthesize ContractInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectItems = [[[NSMutableArray alloc] init] autorelease];
    
    _responseData = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setLeftButton:[UIImage imageNamed:@"btn_back_recharge.png"]];
    {
        int yOffset = 0, xOffset = 0;
        {
            UIImage *image = [UIImage imageNamed:@"div_line.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - image.size.width)/2, yOffset, image.size.width, image.size.height)];
            imageView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:imageView];
            
            yOffset += image.size.height;
            xOffset = imageView.frame.origin.x;
            [imageView release];
        }
        
        {
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, self.view.bounds.size.width - 2 * xOffset, self.view.bounds.size.height  - yOffset)];
            bgView.backgroundColor = [UIColor colorWithRed:230/255. green:230/255. blue:230/255. alpha:1];
//            kRGBUIColor(230, 230, 230, 1);
            [self.view addSubview:bgView];
            [bgView release];
        }
        
        {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(xOffset, yOffset, self.view.bounds.size.width - 2 * xOffset, iPhone5? 268:180) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.backgroundView = nil;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.showsVerticalScrollIndicator = NO;
            tableView.dataSource = self;
            tableView.delegate = self;
            [self.view addSubview:tableView];
            _tableView = tableView;
            [tableView release];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_responseData removeAllObjects];
    
    {
        NSDictionary *Services = self.info;//[self.info objectForKey:@"Services"];
        if (Services == nil || ![Services isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSString *ContractName = [Services objectForKey:@"ContractName"];
        if (ContractName && [ContractName isKindOfClass:[NSString class]]) {
            self.title = ContractName;
            
            if (ContractName) {
                ContractName = [ContractName stringByMatching:@"\\d*\\.?\\d+元"];
                if (ContractName && ContractName.length > 1) {
                    [_responseData addObject:[NSString stringWithFormat:@"套餐月费：%@", ContractName]];
                }
            }
        }
        
        NSString *Properties = [Services objectForKey:@"Properties"];
        if (Properties == nil || ![Properties isKindOfClass:[NSString class]]) {
            return;
        }
        
        NSArray *array = [Properties componentsSeparatedByString:@","];
        NSString *str1 = nil;
        NSString *str2 = nil;
        for (int i = 0; i < array.count; i++) {
            if (i % 2 == 0) {
                str1 = [array objectAtIndex:i];
            } else {
                str2 = [array objectAtIndex:i];
                
                if (str1 && str2) {
                    [_responseData addObject:[NSString stringWithFormat:@"%@：%@", str1, str2]];
                }
                
                str1 = nil;
                str2 = nil;
            }
        }
        
        [_tableView reloadData];
    }
    
    [self loadGiftViewWithInfo:self.info];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _tableView = nil;
    _giftView = nil;
    
    [_responseData release];
    self.selectItems = nil;
}

- (void)dealloc
{
    self.info = nil;
    self.selectItems = nil;
    self.selectDictionaryItems = nil;
    self.SalesproductInfoDict = nil;
    self.ContractInfo = nil;
    
    [_responseData release];
    
    
    [super dealloc];
}

#pragma mark - functions
- (void)loadGiftViewWithInfo:(NSDictionary *)info //load业务赠送的view
{
    if (info == nil || ![info isKindOfClass:[NSDictionary class]]) {
        assert(0);
        return;
    }
    if (_giftView == nil) {
        UIView *mView = [[UIView alloc] initWithFrame:CGRectMake(0, _tableView.frame.size.height, self.view.bounds.size.width, 205)];
        mView.backgroundColor = [UIColor colorWithRed:208/255. green:208/255. blue:208/255. alpha:1];
        [mView dwMakeHeaderRoundCornerWithRadius:5];
        [self.view addSubview:mView];
        [mView release];
        _giftView = mView;
        
        UIImage *image = [UIImage imageNamed:@"icon_home_pakeg.png"];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = image;
        imageView.frame = CGRectMake(12, 0, ceilf(image.size.width * 0.6), ceilf(image.size.height * 0.6));
        [mView addSubview:imageView];
        [imageView release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) - 5, imageView.frame.origin.y, 200, imageView.frame.size.height)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        [mView addSubview:label];
        [label release];
        _giftNameLabel = label;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(14, CGRectGetMaxY(imageView.frame), mView.bounds.size.width - 14 * 2, 65)];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.layer.cornerRadius = 4;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [mView addSubview:scrollView];
        [scrollView release];
        _giftTypeScrollView = scrollView;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(imageView.frame) + 6, CGRectGetMaxY(scrollView.frame) + 9, mView.frame.size.width - (CGRectGetMinX(imageView.frame) + 8) * 2, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        [mView addSubview:label];
        [label release];
        _selectGiftLabel = label;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor colorWithRed:39/255. green:169/255. blue:37/255. alpha:1];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button dwMakeRoundCornerWithRadius:5];
        button.frame= CGRectMake(14, 145, mView.frame.size.width - 14 * 2, 30);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"下一步" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
        [mView addSubview:button];
    }
    
    [[_giftTypeScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.selectItems removeAllObjects];
    
    NSDictionary *Services = info;//[info objectForKey:@"Services"];
    if (Services == nil || ![Services isKindOfClass:[NSDictionary class]]) {
        assert(0);
        return;
    }
    
    id MaxValueAddedServiceCount = [Services objectForKey:@"MaxValueAddedServiceCount"];
    self.maxCount = -1;
    if (MaxValueAddedServiceCount && [MaxValueAddedServiceCount respondsToSelector:@selector(floatValue)]) {
        maxCount = [MaxValueAddedServiceCount intValue];
    }
    
    NSArray *Items = [[Services objectForKey:@"Items"]objectForKey:@"Item"];
    if (Items && [Items isKindOfClass:[NSArray class]]) {
        int itemCount = [Items count];
        _giftNameLabel.text = [NSString stringWithFormat:@"业务赠送(%d选%d)", itemCount, maxCount];
        
        [self loadItems:Items inScrollView:_giftTypeScrollView];
    }
    
    NSString *ContractName = [Services objectForKey:@"ContractName"];
    if (ContractName && [ContractName isKindOfClass:[NSString class]]) {
        _selectGiftLabel.text = [NSString stringWithFormat:@"您选择：%@套餐", ContractName];
    }
}

- (void)loadItems:(NSArray *)items inScrollView:(UIScrollView *)scrollView
{
    [[scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.selectItems removeAllObjects];
    
    if (items == nil || ![items isKindOfClass:[NSArray class]]) {
        return;
    }
    
    int i = 0, ySet = 5, xSet = 5, width = ceilf((scrollView.frame.size.width - xSet * 2)/3), height = 25;
    
    for (NSDictionary *dic in items) {
        
        CGRect rect = CGRectMake(xSet + i % 3 * width, ySet + i / 3 * height, width - 5, height);
        ItemButton *button = [[ItemButton alloc] initWithFrame:rect];
        button.frame = rect;
        [button setItem:dic];
        [button addTarget:self action:@selector(selectItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
        [button release];
        
        if ([self.selectDictionaryItems containsObject:dic]) {
            [self.selectItems addObject:button];
            [button setSelected:YES];
        }
        
        if (i == [items count] - 1) {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, CGRectGetMaxY(button.frame) + ySet);
        }
        i++;
    }
}

#pragma mark - action
- (void)selectItemAction:(ItemButton *)button
{
    if (button == nil || ![button isKindOfClass:[ItemButton class]]) {
        assert(0);
        return;
    }
    
    if (self.maxCount <= 0) {
//        [self alert:@"该套餐无业务赠送"];
        
        return;
    }
    
    assert(button.info != nil);
    
    if (![self.selectItems containsObject:button]) {
        if (self.selectItems.count >= self.maxCount) { //判断已选择的个数
            ItemButton *button = [self.selectItems objectAtIndex:0];
            button.selected = NO;
            [self.selectItems removeObject:button];
        }
        button.selected = YES;
        [self.selectItems addObject:button];
    }
}

- (void)backAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)talkAction:(UIButton *)button
{
    CTPOnlineServiceVCtler * vctler = [CTPOnlineServiceVCtler new];
    [self.navigationController pushViewController:vctler animated:YES];
    [vctler release];
}

- (void)nextAction:(UIButton *)button
{
    if ([self.selectItems count] < self.maxCount) {
        return;
    }
    
    CTPNumberPickerVCtler *numberPickerVCtler = [[CTPNumberPickerVCtler alloc] init];
    numberPickerVCtler.PackageInfoDict = self.info;//[self.info objectForKey:@"Services"];
    numberPickerVCtler.SalesproductInfoDict = self.SalesproductInfoDict;
    numberPickerVCtler.ContractInfo = self.ContractInfo;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (ItemButton *button in self.selectItems) {
        if ([button isKindOfClass:[ItemButton class]] && button.info) {
            [array addObject:button.info];
        }
    }
    numberPickerVCtler.OptPackageList = array;
    [array release];
    [self.navigationController pushViewController:numberPickerVCtler animated:YES];
    [numberPickerVCtler release];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _responseData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.frame = CGRectMake(40, 0, cell.contentView.frame.size.width - 40, cell.contentView.frame.size.height);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithRed:106/255. green:106/255. blue:106/255. alpha:1];
    }
    
    cell.textLabel.text = [_responseData objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

@end
