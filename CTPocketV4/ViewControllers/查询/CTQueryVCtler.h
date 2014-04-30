//
//  CTQueryVCtler.h
//  CTPocketV4
//
//  Created by 许忠洲 on 13-10-25.
//  Copyright (c) 2013年 广东亿迅科技有限公司. All rights reserved.
//

#import "CTBaseViewController.h"

enum QHtableStatus{
    t_status_fullscreen = 1,
    t_status_halfscreen = 2,
};


@interface CTQueryVCtler : CTBaseViewController
<UITableViewDataSource,UITableViewDelegate>
{
    enum QHtableStatus   tstaus;
    
    int             _homeIndex;
    
    UITableView*    _tableview;
    UIImageView*    _leftNavBg;
    UIImageView*    _leftNavArrow;
    
    //
    UITableView*    _tablesubView;
}

@end
