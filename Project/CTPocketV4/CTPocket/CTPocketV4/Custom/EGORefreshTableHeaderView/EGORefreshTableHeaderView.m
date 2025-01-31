//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:0x4f/255.0 green:0x6b/255.0 blue:0x7b/255.0 alpha:1.0];
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;

@end

@implementation EGORefreshTableHeaderView

@synthesize delegate = _delegate;
@synthesize curPage;
@synthesize totalPage;

- (id)initWithFrame:(CGRect)frame
{
	UIColor * textColor = TEXT_COLOR;
	NSString * arrow = @"jian0.png";
	if((self = [super initWithFrame:frame])) 
	{
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, self.frame.size.height)];
		//label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor     = textColor;
		label.shadowColor   = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset  = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment   = UITextAlignmentCenter;
		label.hidden = YES;
		[self addSubview:label];
		_lastUpdatedLabel=label;
        [label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width,self.frame.size.height)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = textColor;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
        [label release];
		
		CALayer * layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, (frame.size.height - 50.0f)/2, 23.0f, 50.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
        
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(15.0f, (frame.size.height - 20.0f)/2, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
        [view release];
		
		[self setState:EGOOPullRefreshNormal];
		
    }
	
    return self;
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];

		_lastUpdatedLabel.text = [NSString stringWithFormat:@"最后更新: %@", [dateFormatter stringFromDate:date]];
        [dateFormatter release];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}
}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = [NSString stringWithFormat:@"当前第%d页,总共%d页，上拉请求更多...",curPage,totalPage];//NSLocalizedString(@"更多...", @"更多...");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = [NSString stringWithFormat:@"当前第%d页,总共%d页，上拉请求更多...",curPage,totalPage];
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = [NSString stringWithFormat:@"当前第%d页,总共%d页，上拉请求更多...",curPage,totalPage];
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

//手指在屏幕上不断拖动调用此方法
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView 
{	
	if (self.hidden == YES)
	{
		return;
	}
	
	if (_state == EGOOPullRefreshLoading) {
		
//		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
//		offset = MIN(offset, self.frame.size.height);
		scrollView.contentInset = UIEdgeInsetsMake(0, 0.0f, self.frame.size.height, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) 
		{
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && 
			scrollView.contentOffset.y + (scrollView.frame.size.height) < scrollView.contentSize.height + self.frame.size.height && 
			scrollView.contentOffset.y > 0.0f && 
			!_loading) 
		{
			[self setState:EGOOPullRefreshNormal];
		} 
		else if (_state == EGOOPullRefreshNormal && 
				 scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + self.frame.size.height  && 
				 !_loading) 
		{
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.bottom != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
	
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView 
{
	if (self.hidden == YES)
	{
		return;
	}
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (!_loading)
	{
		if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height + self.frame.size.height)
		{
			if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
				[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
			}
			
			[self setState:EGOOPullRefreshLoading];
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.2];
			scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, self.frame.size.height, 0.0f);
			
			[UIView commitAnimations];
		}
	}
	
}

//当开发者页面刷新完毕调用此方法，[delegate egoRefreshScrollViewDataSourceDidFinishedLoading: scrollView];
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView 
{	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];

}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {

	NSLog(@"%@ dealloc", [self class]);
    [super dealloc];
//	_delegate=nil;
//	_activityView = nil;
//	_statusLabel = nil;
//	_arrowImage = nil;
//	_lastUpdatedLabel = nil;
}


@end
