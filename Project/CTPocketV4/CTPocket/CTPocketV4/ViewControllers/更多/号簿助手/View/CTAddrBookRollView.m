//
//  CTAddrBookRollView.m
//  CTPocketV4
//
//  Created by apple on 14-3-27.
//  Copyright (c) 2014年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTAddrBookRollView.h"

extern NSString* const CTHomeVCtlerDidRefreshUserInfoNotification;

@interface CTAddrBookRollView()
{
    UILabel*    _lastLogLab;
    UIImageView*_grayView;
    UIView*     _lineView;
    UIButton*   _greenBtn;
    UILabel*    _rollbackLab;
    UIImageView*_arrowView;
    
    int         _grayLineHeight;
    int         _greenBtnOriginY;
    int         _rollbackLabOriginY;
}

@end

@implementation CTAddrBookRollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        int originX = 10, originY = (iPhone5?10:0);
        _grayLineHeight = 40;
        {
            UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(self.frame) - 2*originX, 45)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font = [UIFont systemFontOfSize:12];
            lab.textColor = [UIColor darkGrayColor];
            lab.textAlignment = UITextAlignmentCenter;
            lab.numberOfLines = 0;
            [self addSubview:lab];
            _lastLogLab = lab;
            
            NSMutableString* text = [NSMutableString new];
            [text appendString:@"最后一次成功"];
            if (self.logInfo.type == ABLogTypeUpload) {
                [text appendString:@"上传"];
            } else if (self.logInfo.type == ABLogTypeDownload) {
                [text appendString:@"下载"];
            } else {
                [text appendString:@"操作"];
            }
            [text appendString:@"时间\r\n"];
            if (self.logInfo.time) {
                NSDate* dt = [NSDate dateWithTimeIntervalSince1970:self.logInfo.time];
                NSDateFormatter* formatter = [NSDateFormatter new];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                [text appendString:[formatter stringFromDate:dt]];
            }
            if ([self getUserName]) {
                [text insertString:[self getUserName] atIndex:0];
            }
            lab.text = text;
            
            originY = CGRectGetMaxY(lab.frame) + 5;
        }
        {
            // 灰球
            UIImage* img = [UIImage imageNamed:@"addrbook_log_graypoint"];
            UIImageView* iv = [[UIImageView alloc] initWithImage:img];
            iv.frame = CGRectMake((CGRectGetWidth(self.frame) - img.size.width)/2, originY, img.size.width, img.size.height);
            [self addSubview:iv];
            originY = CGRectGetMaxY(iv.frame);
            _grayView = iv;
        }
        {
            // 灰线
            UIView* lineview = [[UIView alloc] initWithFrame:CGRectMake(0, originY, 1, _grayLineHeight)];
            lineview.backgroundColor = [UIColor colorWithRed:225/255. green:225/255. blue:225/255. alpha:1];
            lineview.center = CGPointMake(CGRectGetWidth(self.frame)/2, lineview.center.y);
            [self addSubview:lineview];
            originY = CGRectGetMaxY(lineview.frame);
            _lineView = lineview;
        }
        {
            // 绿球
            UIImage* img = [UIImage imageNamed:@"addrbook_log_greenpoint"];
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setBackgroundImage:img forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(onRollbackBtn) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake((CGRectGetWidth(self.frame) - img.size.width)/2, originY, img.size.width, img.size.height);
            btn.exclusiveTouch = YES;
            [self addSubview:btn];
            originY = CGRectGetMaxY(btn.frame) + 5;
            _greenBtn = btn;
            _greenBtnOriginY = CGRectGetMinY(btn.frame);
        }
        {
            // 向上箭头
            UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addrbook_arrow_up"]];
            iv.frame = CGRectMake(CGRectGetMaxX(_greenBtn.frame)+5, CGRectGetMaxY(_greenBtn.frame)-CGRectGetHeight(iv.frame),
                                  CGRectGetWidth(iv.frame), CGRectGetHeight(iv.frame));
            iv.userInteractionEnabled = NO;
            [self addSubview:iv];
            _arrowView = iv;
        }
        {
            UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, CGRectGetWidth(self.frame) - 20, 20)];
            lab.backgroundColor = [UIColor clearColor];
            lab.font = [UIFont systemFontOfSize:12];
            lab.textColor = [UIColor darkGrayColor];
            lab.textAlignment = UITextAlignmentCenter;
            lab.text = @"时光倒流，回到操作前";
            lab.userInteractionEnabled = NO;
            [self addSubview:lab];
            originY = CGRectGetMaxY(lab.frame) + (iPhone5?10:5);
            _rollbackLab = lab;
            _rollbackLabOriginY = CGRectGetMinY(lab.frame);
        }
        {
            UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
            [self addGestureRecognizer:pan];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onCTHomeVCtlerDidRefreshUserInfoNotification)
                                                     name:CTHomeVCtlerDidRefreshUserInfoNotification
                                                   object:nil];
    }
    return self;
}

- (void)onCTHomeVCtlerDidRefreshUserInfoNotification
{
    [self setNeedsDisplay];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSMutableString* text = [NSMutableString new];
    [text appendString:@"最后一次成功"];
    if (self.logInfo.type == ABLogTypeUpload) {
        [text appendString:@"上传"];
    } else if (self.logInfo.type == ABLogTypeDownload) {
        [text appendString:@"下载"];
    } else {
        [text appendString:@"操作"];
    }
    [text appendString:@"时间\r\n"];
    if (self.logInfo.time) {
        NSDate* dt = [NSDate dateWithTimeIntervalSince1970:self.logInfo.time];
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        [text appendString:[formatter stringFromDate:dt]];
    }
    if ([self getUserName]) {
        [text insertString:[self getUserName] atIndex:0];
    }
    _lastLogLab.text = text;
}

- (NSString *)getUserName
{
    NSMutableString *content = [NSMutableString stringWithString:@"你好,\r\n"];
    NSDictionary *custInfoDict = [Global sharedInstance].userInfoDict;
    if (custInfoDict[@"Cust_Name"]) {
        [content insertString:custInfoDict[@"Cust_Name"] atIndex:0];
    }
    return content;
}

- (void)onRollbackBtn
{
    if (self.rollbackBlock) {
        self.rollbackBlock(self);
    }
}

- (void)setRollProgress:(double)rollProgress
{
    _rollProgress = rollProgress;
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:YES];
}

- (void)refreshUI
{
    if (_rollProgress >= 0 && _rollProgress <= 1) {
        _lineView.frame = CGRectMake(CGRectGetMinX(_lineView.frame), CGRectGetMinY(_lineView.frame),
                                     CGRectGetWidth(_lineView.frame), (1-_rollProgress)*_grayLineHeight);
        
        int offsetH = _rollProgress*(_grayLineHeight + CGRectGetHeight(_grayView.frame));
        _greenBtn.frame = CGRectMake(CGRectGetMinX(_greenBtn.frame), _greenBtnOriginY-offsetH,
                                     CGRectGetWidth(_greenBtn.frame), CGRectGetHeight(_greenBtn.frame));
        _rollbackLab.frame = CGRectMake(CGRectGetMinX(_rollbackLab.frame), _rollbackLabOriginY-offsetH,
                                        CGRectGetWidth(_rollbackLab.frame), CGRectGetHeight(_rollbackLab.frame));
    }
}

- (void)startRollback
{
    _rollbackLab.text = @"正在回滚，请稍候...";
    _arrowView.hidden = YES;
}

- (void)onPanGesture:(UIPanGestureRecognizer*)gesture
{
    CGPoint pt = [gesture translationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        _rollProgress = 0;
        _arrowView.hidden = YES;
        _rollbackLab.hidden = YES;
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        double offsetY = pt.y;
        _lineView.frame = CGRectMake(CGRectGetMinX(_lineView.frame), CGRectGetMinY(_lineView.frame),
                                     CGRectGetWidth(_lineView.frame), MAX(CGRectGetHeight(_lineView.frame)+offsetY, 0));
        
        offsetY = pt.y;
        if (CGRectGetMinY(_greenBtn.frame)+offsetY < CGRectGetMinY(_grayView.frame)) {
            offsetY = CGRectGetMinY(_grayView.frame) - CGRectGetMinY(_greenBtn.frame);
        }
        _greenBtn.frame = CGRectMake(CGRectGetMinX(_greenBtn.frame), CGRectGetMinY(_greenBtn.frame)+offsetY,
                                     CGRectGetWidth(_greenBtn.frame), CGRectGetHeight(_greenBtn.frame));
        
    } else if (gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed ||
               gesture.state == UIGestureRecognizerStateEnded) {
     
        BOOL action = (fabs(CGRectGetMinY(_greenBtn.frame) - CGRectGetMinY(_grayView.frame)) <= CGRectGetHeight(_grayView.frame)/2);
        [UIView animateWithDuration:0.15 animations:^{
            
            _lineView.frame = CGRectMake(CGRectGetMinX(_lineView.frame), CGRectGetMinY(_lineView.frame),
                                         CGRectGetWidth(_lineView.frame), _grayLineHeight);
            
            _greenBtn.frame = CGRectMake(CGRectGetMinX(_greenBtn.frame), _greenBtnOriginY,
                                         CGRectGetWidth(_greenBtn.frame), CGRectGetHeight(_greenBtn.frame));
            
        } completion:^(BOOL finished) {
            
            _arrowView.hidden = NO;
            _rollProgress = 0;
            _rollbackLab.hidden = NO;
            
            if (action) {
                [self onRollbackBtn];
            }
            
        }];
        
    }
    
    [gesture setTranslation:CGPointZero inView:self];
}

@end
