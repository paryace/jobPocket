//
//  CTContractChooseVCtler.m
//  CTPocketV4
//
//  Created by liuruxian on 13-11-19.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTContractChooseVCtler.h"
#import "CserviceOperation.h"
#import "AppDelegate.h"
#import "CTContractPhoneCell.h"
#import "SVProgressHUD.h"
#import "SelectPackagesVCtler.h"
#import "ToastAlertView.h"
#import "SIAlertView.h"

#define kSelectPageBtn 1010
#define kFirstBtn   1020
#define kSecondBtn  1120
#define kThirdBtn   1220

@interface CTContractChooseVCtler () <UITableViewDataSource,UITableViewDelegate>
{
    int                  _selectIndex;
    NSString             *_contactTypeID;
    NSDictionary         *_phoneInfoDic;  //合约ID 和 销售类型
    
    //选择页面
    NSMutableArray       *_allArray;
    NSMutableDictionary  *_pageDict;
    NSDictionary *_phoneInfoDictionary;
    
    UIImageView *_selectedImageview;
    UIImageView *_selBgImageview;
    UIScrollView *_scrollview;
    UIScrollView *_labelScrollview;
    UILabel *_discriptionlabel;
    UITableView          *_contractTableview;
    UIButton *_nextBtn;
    NSArray *_respondArray;
    UIImageView *test ;
    
    
}


@property (nonatomic, strong) CserviceOperation *contractOpt;

@end

@implementation CTContractChooseVCtler

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
    
    [self setLeftButton:[UIImage imageNamed:@"btn_back_recharge.png"]];
    self.view.backgroundColor = [UIColor whiteColor];
    _allArray = [NSMutableArray new];
    _pageDict = [NSMutableDictionary new];

    //三选
    float yOriginal = 0;
    UIImageView *grayBgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"query_billlist_dtbg.png"]];
    grayBgView.frame = CGRectMake(0, yOriginal, self.view.frame.size.width, grayBgView.frame.size.height);
    [self.view addSubview:grayBgView];
    
    
    _selBgImageview = grayBgView;
    
    yOriginal = CGRectGetMaxY(_selBgImageview.frame) + 1;

    UITableView *tableview         = [[UITableView alloc]initWithFrame:CGRectMake(10, yOriginal, CGRectGetWidth(self.view.frame)-20,iPhone5?300:220)];
    [self.view addSubview:tableview];
    tableview.backgroundColor = [UIColor colorWithRed:220/255. green:220/255. blue:220/255. alpha:1];

    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.separatorStyle       = UITableViewCellSeparatorStyleNone;
    _contractTableview = tableview;

    UIImage *image = [UIImage imageNamed:@"packages_statement.png"];
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(tableview.frame), image.size.width, 114)];
    imageview.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin ;
    imageview.userInteractionEnabled = YES;
    test = imageview ;
    imageview.backgroundColor = [UIColor colorWithRed:208/255. green:208/255. blue:208/255. alpha:1];
    [self.view addSubview:imageview];
    
    {
        UIScrollView *scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(15, 10, imageview.frame.size.width - 25,45)];
        scrollview.backgroundColor = [UIColor clearColor];
        [imageview addSubview:scrollview];
        _labelScrollview = scrollview;
        int ySet = 0;
        {
            UILabel *label        = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, scrollview.frame.size.width, scrollview.frame.size.height)];
            label.textAlignment   = UITextAlignmentLeft;
            label.backgroundColor = [UIColor clearColor];
            label.text            = @"";
            label.textColor       = [UIColor blackColor];
            label.font            = [UIFont systemFontOfSize:14];
            [scrollview addSubview:label];
            [label setNumberOfLines:0];
            label.lineBreakMode = UILineBreakModeWordWrap;
            _discriptionlabel = label;
        }
        ySet = CGRectGetMaxY(scrollview.frame) + 5;
        
        UIImage *image = [UIImage imageNamed:@"packages_nextStep.png"];
        CGRect rect    = CGRectMake(217 ,ySet, image.size.width, image.size.height);
        UIButton *btn  = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame      = rect;
        _nextBtn       = btn;
        btn.enabled    = NO;
        btn.backgroundColor = [UIColor clearColor];
        [btn setBackgroundImage:image forState:UIControlStateNormal];
        [btn setTitle:@"下一步" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        btn.titleLabel.textAlignment = UITextAlignmentCenter;
        [btn addTarget:self action:@selector(nextstepAction) forControlEvents:UIControlEventTouchUpInside];
        
        [imageview addSubview:btn];
    }
    
    
    [self contractnetRequest:self._phoneInfo contractID:self._buyType];
}

- (void) viewDidAppear:(BOOL)animated
{
//    test.frame = CGRectMake(0, CGRectGetMaxY(_contractTableview.frame), self.view.frame.size.width, 114);
}

#pragma mark - fun

-(void)CreatePageBtn :(id)dataInfo
{
//    int count = array.count;
    NSArray *array  ;
    if ([dataInfo isKindOfClass:[NSDictionary class]]) {
        array = [NSArray arrayWithObject:dataInfo];
    }else{
        array = [NSArray arrayWithArray:dataInfo];
    }
    
//    
//    id contracts = [dataInfo objectForKey:@"Contracts"];
//    int count = 0;
//    if ([contracts isKindOfClass:[NSString class]]) {
//        count = 1;
//        array = [NSArray arrayWithObject:contracts];
//    }else{
//        array = [NSArray arrayWithArray:contracts];
//        count = array.count ;
//    }
    int yOriginal = _selBgImageview.frame.origin.y;
    
    UIImageView *selectedView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"query_billlist_dtsel.png"]];
    selectedView.frame = CGRectMake(0, yOriginal, _selBgImageview.frame.size.width/array.count, _selBgImageview.frame.size.height);
    _selectedImageview = selectedView;
    [self.view addSubview:selectedView];
    
    //销售 价格 新品
    int xOriginal = 0;
    {
        for (int i=0; i<array.count; i++)
        {
            NSString * str = [[array objectAtIndex:i]objectForKey:@"Time"];
//            id obj = array;
//            if([obj isKindOfClass:[NSString class]])
            {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = kSelectPageBtn + i;
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitle:str forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:16];
                [btn addTarget:self action:@selector(selectedPage:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:btn];
                
                btn.frame = CGRectMake(xOriginal, yOriginal ,selectedView.frame.size.width-1, selectedView.frame.size.height);
                xOriginal = CGRectGetMaxX(btn.frame);
                
                if (i < 2)
                {
                    UIImageView * lineview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"query_billlist_dtdiv.png"]];
                    lineview.frame = CGRectMake(xOriginal, yOriginal, 1, _selBgImageview.image.size.height);
                    [self.view addSubview:lineview];
                    xOriginal = CGRectGetMaxX(lineview.frame);
                }
            }
//            else if([obj isKindOfClass:[NSArray class]])
//            {
////                NSArray *ary = (NSArray *)obj;
//                for(int i=0;i<array.count;i++)
//                {
//                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                    btn.tag = kSelectPageBtn + i;
//                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                    [btn setTitle:str forState:UIControlStateNormal];
//                    btn.titleLabel.font = [UIFont systemFontOfSize:16];
//                    [btn addTarget:self action:@selector(selectedPage:) forControlEvents:UIControlEventTouchUpInside];
//                    [self.view addSubview:btn];
//                    
//                    btn.frame = CGRectMake(xOriginal, yOriginal ,selectedView.frame.size.width-1, selectedView.frame.size.height);
//                    xOriginal = CGRectGetMaxX(btn.frame);
//                    //分割线
//                    if (i < 2)
//                    {
//                        UIImageView * lineview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"query_billlist_dtdiv.png"]];
//                        lineview.frame = CGRectMake(xOriginal, yOriginal, 1, _selBgImageview.image.size.height);
//                        [self.view addSubview:lineview];
//                        xOriginal = CGRectGetMaxX(lineview.frame);
//                    }
//                }
//            }
        }
        
    }
}

-(void)setPhoneInfo:(NSDictionary *)dictionary buyType:(NSString *)buyType title :(NSString *)title
{
    self._phoneInfo = dictionary;   //手机信息
    self._buyType = buyType;        //购买类型
    self.title = title;             //标题
    self._contractName = title;
}

//解析字符串
-(NSMutableArray *)stringToArray:(NSString *)contractStr
{
    NSArray *strArray  = [contractStr componentsSeparatedByString:@","];
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:strArray];
    NSMutableArray *dictArray = [[NSMutableArray alloc] init];
    NSString *keyStr,*valueStr;
    NSString *strHeader = [[array objectAtIndex:0]substringFromIndex:1];
    NSString *strLast = [[array lastObject]substringToIndex:([[strArray lastObject]length]-1)];
    
    [array removeObjectAtIndex:0];
    [array removeObjectAtIndex:array.count-1];
    [array insertObject:strHeader atIndex:0];
    [array addObject:strLast];
    
    for (NSString *subStr in array) {
        NSArray *array = [subStr componentsSeparatedByString:@"="];
        keyStr = [[array objectAtIndex:0]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        valueStr = [[array objectAtIndex:1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:valueStr,keyStr, nil];
        [dictArray addObject:dict];
    }
    return  dictArray;
}

-(void)setDiscription:(NSMutableArray *)array
{
    for (NSDictionary *item in array) {
        if ([item objectForKey:@"备注"]) {
            _discriptionlabel.text =[item objectForKey:@"备注"];
            [self setLabelHeight:[item objectForKey:@"备注"]];
        }
    }
    
    
}

-(void)setLabelHeight:(NSString *)labelText
{
    CGSize size =CGSizeMake(280, 500);
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize labelsize = [labelText sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [_discriptionlabel setFrame:CGRectMake(0, 0, labelsize.width, labelsize.height)];
    
    _labelScrollview.contentSize = _discriptionlabel.frame.size;
    
    
}
//设置背景颜色
-(void)selectedPage:(UIButton *)sender
{
    int tag          = ((UIButton *)sender).tag - kSelectPageBtn;
    if (_selectIndex == tag){
        return;
    }
    _selectIndex     = tag;
    [UIView animateWithDuration:0.25 animations:^{
        _selectedImageview.center = ((UIButton *)sender).center; //改变图片位置，赋值为按钮的中心位置
        [_contractTableview reloadData];
    }];
}

#pragma mark - MKnetWork
-(void)contractnetRequest:(NSDictionary *)dictionary contractID:(NSString*)contractID
{
     _phoneInfoDic         = dictionary; 
    if (self.contractOpt) {
        [self.contractOpt cancel];
        self.contractOpt = nil;
    }
    _contactTypeID = contractID;
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [dictionary objectForKey:@"SalesProdId"] ,   @"SalesProductId",
                             _contactTypeID ,     @"ContractTypeId",
                             nil];
    
    [SVProgressHUD showWithStatus:@"请稍候..." maskType:SVProgressHUDMaskTypeGradient];
    
    self.contractOpt = [MyAppDelegate.cserviceEngine postXMLWithCode:@"contractSelect"
                                                              params:params
                                                         onSucceeded:^(NSDictionary *dict)
    {
         DDLogInfo(@"%s--%@", __func__, dict.description);
         id Data = [dict objectForKey:@"Data"];
         if (Data && [Data respondsToSelector:@selector(objectForKey:)]) {
             NSArray * tmparr = nil;
             _nextBtn.enabled = YES;
             
             id DataInfo;
             DataInfo = [Data objectForKey:@"DataInfo"];
             
             if (DataInfo) {
                 if ([DataInfo isKindOfClass:[NSDictionary class]])
                 {
                     tmparr = [NSArray arrayWithObject:DataInfo];
                 }
                 else if ([DataInfo isKindOfClass:[NSArray class]])
                 {
                     tmparr = DataInfo;
                 }
                 else
                 {
                     NSLog(@"AccList error");
                 }
                 
             } else {
                 return;
             }
             
             if ([tmparr isKindOfClass:[NSDictionary class]]) {
                 _respondArray = [[NSArray alloc] initWithObjects:tmparr, nil];
             }else if([tmparr isKindOfClass:[NSArray class]]){
                 _respondArray = [[NSArray alloc]initWithArray:tmparr];
             }
             
             [self CreatePageBtn:DataInfo];
             //赋值
             for (int i=0; i<_respondArray.count; i++) {
                 
                 if (_allArray)
                 {
                     NSMutableArray *nsmuArray = [NSMutableArray new];
                     //合约机列表(24月合约)
                     id listobj = [[[_respondArray objectAtIndex:i] objectForKey:@"Contracts"]objectForKey:@"ContractsInfo"];
                     
                     if ([listobj isKindOfClass:[NSDictionary class]])
                     {
                         [nsmuArray addObject:listobj];
                     }
                     else if ([listobj isKindOfClass:[NSArray class]])
                     {
                         [nsmuArray addObjectsFromArray:listobj];
                     }
                     
                     NSMutableArray *contractArray = [[NSMutableArray alloc] init];
                     NSString *contractID;
                     NSString *discription;
                     NSString *Time;
                     
                     for (int j=0; j<nsmuArray.count; j++) {             //     sub in contract
                         
                         NSMutableArray *tabArray ;
                         tabArray = [self stringToArray:[[nsmuArray objectAtIndex:j]objectForKey:@"ContractsProperties"]];//字符串
                         Time = (NSString *)[[nsmuArray objectAtIndex:j]objectForKey:@"Time"];
                         contractID = (NSString *)[[nsmuArray objectAtIndex:j]objectForKey:@"ContractsId"];
                         
                         NSString *ContractsName = [[nsmuArray objectAtIndex:j]objectForKey:@"ContractsName"];
                         //                        NSString *space = @" ";
                         ContractsName = [@" "stringByAppendingString : ContractsName];
                         
                         if ([ContractsName hasSuffix:@"元"]) {
                             ContractsName = [ContractsName stringByAppendingString:@""];
                         }
                         else{
                             ContractsName = [ContractsName stringByAppendingString:@"元"];
                         }
                         discription = [self._contractName stringByAppendingString:ContractsName];
                         
                         
                         NSDictionary *contratDic = [[NSDictionary alloc] initWithObjectsAndKeys:contractID,@"ContractsId",tabArray,@"ContractsProperties",ContractsName,@"ContractsName",discription,@"discription",Time,@"Time",nil];
                         [contractArray addObject:contratDic];
                     }
                     //合约选中索引
                     NSString *indexpage = [NSString stringWithFormat:@"%d",i];//
                     [_pageDict setObject:@"0" forKey:indexpage];
                     
                     [_allArray addObject:contractArray];
                 }
             }
             //动态生成页面选择按钮
             [_contractTableview reloadData];
             [SVProgressHUD dismiss];
         }
     } onError:^(NSError *engineError) {
         DDLogInfo(@"%s--%@", __func__, engineError);
         [SVProgressHUD dismiss];
         if ([engineError.userInfo objectForKey:@"ResultCode"])
         {
             if ([engineError.userInfo[@"ResultCode"] isEqualToString:@"X104"])
             {
                 // 取消掉全部请求和回调，避免出现多个弹框
                 [MyAppDelegate.cserviceEngine cancelAllOperations];
                 // 提示重新登录
                 SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                                  andMessage:@"长时间未登录，请重新登录。"];
                 [alertView addButtonWithTitle:@"确定"
                                          type:SIAlertViewButtonTypeDefault
                                       handler:^(SIAlertView *alertView) {
                                           [MyAppDelegate showReloginVC];
                                           if (self.navigationController != nil)
                                           {
                                               [self.navigationController popViewControllerAnimated:NO];
                                           }
                                       }];
                 alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                 [alertView show];
             }
         }
         else{
             ToastAlertView *alert = [ToastAlertView new];
             [alert showAlertMsg:@"系统繁忙,请重新提交"];
         }
     }];
    
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_allArray && _allArray.count > 0) {
        NSMutableArray *array = [_allArray objectAtIndex:_selectIndex];
        return array.count;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellIdenti";
    CTContractPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[CTContractPhoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    int row = indexPath.row;//获取当前选中的行数
    
    NSMutableArray *contractArray =  [_allArray objectAtIndex:_selectIndex]; //选中某页
    NSDictionary *contractDict = [contractArray objectAtIndex:row];
    
    [cell setContractInfo:[contractDict objectForKey:@"ContractsProperties"]]; //设置cell信息
    cell._contractID = [contractDict objectForKey:@"ContractsId"];//设置cell的合约ID
    
    NSString *contractIndex = [NSString stringWithFormat:@"%d",_selectIndex];
    NSString *rowIndex = [NSString stringWithFormat:@"%d",row];
    
    
    if ([rowIndex isEqualToString:[_pageDict objectForKey:contractIndex]]) {
        [cell setImage:YES];
        [self setDiscription:[contractDict objectForKey:@"ContractsProperties"]]; //备注信息
    }else{
        [cell setImage:NO];
    }
    
    return cell;
}
//设置tablevie的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (iPhone5 == YES) {
        return 41;
    }
    else{
        return  41 ;
    }
}
//cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    int row = indexPath.row;
    NSString *contractIndex = [NSString stringWithFormat:@"%d",_selectIndex];
    NSString *rowIndex = [NSString stringWithFormat:@"%d",row];
    [_pageDict setObject:rowIndex forKey:contractIndex];
    
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    UIImage *image = [UIImage imageNamed:@"packages_mark1.png"];
    
    return 15+image.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIImage *image = [UIImage imageNamed:@"packages_mark1.png"];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(6, 0, image.size.width, 24+image.size.height)] ;
    float xSet = 21;
    view.backgroundColor = [UIColor colorWithRed:220/255. green:220/255. blue:220/255. alpha:1];
    {
        for (int i=0; i<4; i++) {
            {
                
                if (i<3) {
                    image = [UIImage imageNamed:@"packages_mark1.png"];
                }else{
                    image = [UIImage imageNamed:@"packages_mark2.png"];
                }
                
                UIImageView *imageview           = [[UIImageView alloc]initWithFrame:CGRectMake(xSet,12, image.size.width, image.size.height)];
                imageview.backgroundColor        = [UIColor clearColor];
                imageview.image                  = image;
                imageview.userInteractionEnabled = YES;
                [view addSubview:imageview];
                
                UILabel *label        = [[UILabel alloc]initWithFrame:CGRectMake(0, -3, imageview.frame.size.width, imageview.frame.size.height)];
                label.textAlignment   = UITextAlignmentCenter;
                label.backgroundColor = [UIColor clearColor];
                label.textColor       = [UIColor whiteColor];
                if (i==0) {
                    label.text = @"合约";
                }else if(i==1){
                    label.text = @"总价格";
                }else if(i==2){
                    label.text = @"购机款";
                }else if(i==3){
                    label.text = @"预存话费";
                }
                label.font = [UIFont systemFontOfSize:11];
                [imageview addSubview:label];
                xSet       = CGRectGetMaxX(imageview.frame) + 27;
            }
        }
    }
    
    return view ;
}

#pragma mark - Action

-(void)nextstepAction
{
    SelectPackagesVCtler *phoneSellCtler = [[SelectPackagesVCtler alloc] init];
    //YW
    phoneSellCtler.SalesproductId = [_phoneInfoDic objectForKey:@"SalesProdId"];
    //zy
    NSString *contractIndex = [NSString stringWithFormat:@"%d",_selectIndex];
    NSString *str = [_pageDict objectForKey:contractIndex];
    int row = [str intValue];
    phoneSellCtler.ContractInfo = [[_allArray objectAtIndex:_selectIndex]objectAtIndex:row];
    
    phoneSellCtler.SalesproductInfoDict = _phoneInfoDic;
    
    [self.navigationController pushViewController:phoneSellCtler animated:YES];
    
//    [phoneSellCtler release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
