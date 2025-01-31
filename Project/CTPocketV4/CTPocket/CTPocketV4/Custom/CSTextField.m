/*--------------------------------------------
 *Name：CSTextField
 *Desc：自定义的textfield
 *Date：2014/05/21
 *Auth：lip
 *--------------------------------------------*/

#import "CSTextField.h"

@implementation CSTextField
{
    CGFloat spitW;
    UILabel *labHolder;
    UILabel *labMoney;
}

- (id)init
{
    self = [super init];
    if (self) {
        spitW = 12;
        [self initControl];
    }
    return self;
}

-(void)initControl
{
    self.font = [UIFont systemFontOfSize:14];
    self.layer.borderWidth = 0;
    self.layer.borderColor = RGB(111, 197, 55, 1).CGColor;
    //self.layer.cornerRadius = 3;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.keyboardType = UIKeyboardTypeNumberPad;
    self.backgroundColor = [UIColor whiteColor];
    
    labMoney = [[UILabel alloc]init];
    labMoney.text = @"元";
    labMoney.backgroundColor = [UIColor clearColor];
    labMoney.font = self.font;
    [self addSubview:labMoney];
    
    labHolder = [[UILabel alloc]init];
    labHolder.backgroundColor = [UIColor clearColor];
    labHolder.font = self.font;
    labHolder.textColor = RGB(199, 199, 205, 1);
    [self addSubview:labHolder];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds.origin.x +=spitW;
    bounds.size.width -= spitW*2;
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x +=spitW;
    bounds.size.width -= spitW*2;
    return bounds;
}

-(NSInteger)getPice
{
    return [self.text integerValue];
}

-(void)setMoneyholder:(NSString *)moneyholder
{
    _moneyholder = moneyholder;
    labHolder.text = _moneyholder;
}

-(void)setCurMoney:(NSString *)curMoney
{
    _curMoney = curMoney;
    self.text = curMoney;
    self.iscurMoney = YES;
    if([_curMoney integerValue] > 5 && [_curMoney integerValue] != 100)
    {
        UIColor *cruColor = RGB(30, 196, 34, 1);
        self.textColor = cruColor;
        labMoney.textColor = cruColor;
    }
    else
    {
        self.textColor = [UIColor blackColor];
        labMoney.textColor = [UIColor blackColor];
        self.iscurMoney = NO;
    }
}

-(void)setIscurMoney:(BOOL)iscurMoney
{
    _iscurMoney = iscurMoney;
    if(_iscurMoney)
        labHolder.hidden = NO;
    else
    {
        labHolder.hidden = YES;
        self.textColor = [UIColor blackColor];
        labMoney.textColor = [UIColor blackColor];
    }
    
}

-(void)setFocus:(BOOL)focus
{
    _focus = focus;
    if(focus)
    {
        self.layer.borderWidth = 1;
        self.font = [UIFont boldSystemFontOfSize:14];
        labMoney.font = [UIFont boldSystemFontOfSize:14];
    }else
    {
        self.layer.borderWidth = 0;
        self.textColor = [UIColor blackColor];
        labMoney.textColor = [UIColor blackColor];
        self.font = [UIFont systemFontOfSize:14];
        labMoney.font = [UIFont systemFontOfSize:14];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if(self.text == nil || [self.text length] <=0){
        labMoney.hidden = YES;
        self.iscurMoney = NO;
    }else
        labMoney.hidden = NO;
    
    CGFloat contW = self.frame.size.width-spitW*2-10;
    CGFloat cx = [self widthForString:self.text font:self.font];
    if(cx > contW)
        cx = contW;
    cx = cx+spitW+2;
    CGFloat labw = [self widthForString:labMoney.text font:labMoney.font];
    labMoney.frame = CGRectMake(cx, 0, labw, self.frame.size.height);
    if(_iscurMoney)
    {
        cx = cx+labw+5;
        labw = [self widthForString:labHolder.text font:labHolder.font];
        labHolder.frame = CGRectMake(cx, 0, labw, self.frame.size.height);
    }
}

/*
 @method 获取字符串的宽度
 @param value 待计算的字符串
 @param font 字体的大小
 @result CGFloat 返回的款度
 */
-(CGFloat)widthForString:(NSString*)value font:(UIFont*)font
{
    CGSize sizeToFit;
    if([value respondsToSelector:@selector(sizeWithAttributes:)])
    {//iOS7
        sizeToFit = [value sizeWithAttributes:@{NSFontAttributeName:font}];
    }else
    {
        sizeToFit = [value sizeWithFont:font];
    }
    return sizeToFit.width;
}

@end
