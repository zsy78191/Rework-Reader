//
//  RRSettingApperance.m
//  rework-reader
//
//  Created by 张超 on 2019/3/7.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSettingApperance.h"

@implementation RRSettingApperance

- (void)mvp_setupView:(__kindof UIView *)view
{
//    ////NSLog(@"v %@",view);
    switch (view.tag) {
        case MVPViewTagContentView:
        {
            [view setBackgroundColor:[UIColor clearColor]];
            break;
        }
        case MVPViewTagManageView:
        {
            UITableView* t = view;
            t.backgroundView = [UIView new];
            t.backgroundView.backgroundColor = [UIColor clearColor];
//            [view setBackgroundColor:[UIColor greenColor]];
            break;
        }
        default:
            break;
    }
    
}

@end
