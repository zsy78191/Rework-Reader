//
//  RRListEmpty.m
//  rework-reader
//
//  Created by 张超 on 2019/3/13.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRListEmpty.h"

@implementation RRListEmpty

- (NSString *)titleForEmptyTitle
{
    return @"没有更多订阅，休息一会吧";
}

- (NSString *)buttonTitleForState:(NSUInteger)state
{
    return @"更新订阅";
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"bear"];
}

- (void)didTapButton:(UIButton *)button
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

@end
