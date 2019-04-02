//
//  RRImportApper.m
//  rework-reader
//
//  Created by 张超 on 2019/3/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRImportApper.h"

@implementation RRImportApper

- (void)mvp_setupView:(__kindof UIView *)view
{
    switch (view.tag) {
        case MVPViewTagManageView:
        {
            UITableView* t = view;
            [t setAllowsMultipleSelection:YES];
            break;
        }
        case MVPViewTagContentView:
        {
            break;
        }
        default:
            break;
    }
}

@end
