//
//  MAAnnotationView.h
//  MAMapKit
//
//  Created by yin cai on 11-12-13.
//  Copyright (c) 2011年 Autonavi Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#if __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED

enum {
    MAAnnotationViewDragStateNone = 0,      ///< 静止状态.
    MAAnnotationViewDragStateStarting,      ///< 开始拖动
    MAAnnotationViewDragStateDragging,      ///< 拖动中
    MAAnnotationViewDragStateCanceling,     ///< 取消拖动
    MAAnnotationViewDragStateEnding         ///< 拖动结束
};
typedef NSUInteger MAAnnotationViewDragState;

#endif



@class MAAnnotationViewInternal;
@protocol MAAnnotation;

///标注view
@interface MAAnnotationView : UIView
{
@private
    MAAnnotationViewInternal *_internal;
}

/**
 *初始化并返回一个annotation view
 *@param annotation 关联的annotation对象
 *@param reuseIdentifier 如果要重用view,传入一个字符串,否则设为nil,建议重用view
 *@return 初始化成功则返回annotation view,否则返回nil
 */
- (id)initWithAnnotation:(id <MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

///复用标志
@property (nonatomic, readonly) NSString *reuseIdentifier;


/**
 *当view从reuse队列里取出时被调用
 *默认不做任何事
 */
- (void)prepareForReuse;

///关联的annotation
@property (nonatomic, retain) id <MAAnnotation> annotation;

///annotation view显示的图像
@property (nonatomic, retain) UIImage *image;

///默认情况下, annotation view的中心位于annotation的坐标位置，可以设置centerOffset改变view的位置，正的偏移使view朝右下方移动，负的朝左上方，单位是像素
@property (nonatomic) CGPoint centerOffset;

///默认情况下, 弹出的气泡位于view正中上方，可以设置calloutOffset改变view的位置，正的偏移使view朝右下方移动，负的朝左上方，单位是像素
@property (nonatomic) CGPoint calloutOffset;

///默认为YES,当为NO时view忽略触摸事件
@property (nonatomic, getter=isEnabled) BOOL enabled;

///默认为NO,当view被点中时被设为YES,用户不要直接设置这个属性.
@property (nonatomic, getter=isSelected) BOOL selected;

/**
 *设定view的选中状态
 *该方法被MAMapView调用
 *@param selected 如果view需要显示为选中状态，该值为YES
 *@param animated 如果需要动画效果，该值为YES,暂不支持
 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

///当为YES时，view被选中时会弹出气泡，annotation必须实现了title这个方法
@property (nonatomic) BOOL canShowCallout;


///显示在气泡左侧的view
@property (retain, nonatomic) UIView *leftCalloutAccessoryView;

///显示在气泡右侧的view
@property (retain, nonatomic) UIView *rightCalloutAccessoryView;


///当设为YES并实现了setCoordinate:方法时，支持将view在地图上拖动, ios 3.2以后支持
@property (nonatomic, getter=isDraggable) BOOL draggable __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2);

///当前view的拖动状态, ios 3.2以后支持
@property (nonatomic) MAAnnotationViewDragState dragState __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2);


@end

