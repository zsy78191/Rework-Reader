//
//  RRTableView.m
//  rework-reader
//
//  Created by 张超 on 2019/3/21.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRTableView.h"

@implementation RRTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
//        self.accessibilityTraits = UIAccessibilityTraitHeader;
    }
    return self;
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction
{
    return [super accessibilityScroll:direction];
}


@end
