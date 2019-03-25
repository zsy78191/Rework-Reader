//
//  RREmpty.m
//  rework-reader
//
//  Created by 张超 on 2019/2/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RREmpty.h"
#import "ClassyKitLoader.h"

@implementation RREmpty

- (NSString *)titleForEmptyTitle
{
    return @"点击右下方按钮添加开启订阅";
}

- (NSString *)buttonTitleForState:(NSUInteger)state
{
    return @"推荐订阅源";
}

- (void)didTapButton:(UIButton *)button
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"nodata"];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return - 100;
}


@end
