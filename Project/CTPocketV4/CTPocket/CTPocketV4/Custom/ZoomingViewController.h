//
//  ZoomingViewController.h
//  TapZoomRotate
//
//  Created by Matt Gallagher on 2010/09/27.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>

@interface ZoomingViewController : NSObject
{
	UIView *view;
	UIView *proxyView;
	UITapGestureRecognizer *singleTapGestureRecognizer;
   
}

@property (nonatomic, retain, readonly) UIView *proxyView;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) UITextView *textview;

- (void)dismissFullscreenView;

@end
