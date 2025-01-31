//
//  MAUserLocation.h
//  MAMapKit
//
//  Created by yin cai on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAAnnotation.h"

@class CLLocationManager;
@class CLLocation;
@class MAUserLocationInternal;

NS_CLASS_AVAILABLE(__MAC_NA, 3_0)
/// 定位信息类
@interface MAUserLocation : NSObject<MAAnnotation>{
@private
    MAUserLocationInternal *_internal;
}

/// 位置更新状态，如果正在更新位置信息，则该值为YES
@property (readonly, nonatomic, getter=isUpdating) BOOL updating;

/// 位置信息，如果MAMapView的showsUserLocation为NO，或者尚未定位成功，则该值为nil
@property (nonatomic,retain) CLLocation *location;

/// 定位标注点要显示的标题信息
@property (retain, nonatomic) NSString *title;

/// 定位标注点要显示的子标题信息.
@property (retain, nonatomic) NSString *subtitle;
@end