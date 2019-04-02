//
//  RREmpty.m
//  rework-reader
//
//  Created by 张超 on 2019/2/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RREmpty.h"
#import "ClassyKitLoader.h"
@import ui_base;
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

//- (NSDictionary *)buttonTitleAttributesForState:(NSUInteger)state
//{
//    NSDictionary* style = [[NSUserDefaults standardUserDefaults] valueForKey:@"style"];
//    return @{
//             NSForegroundColorAttributeName:UIColor.hex(style[@"$main-tint-color"])
//             };
//}

- (UIImage *)image
{
    return [UIImage imageNamed:@"nodata"];
}

//- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
//{
////    return - 100;
//}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

//- (void)emptyDataSetDidAppear:(UIScrollView *)scrollView;{
//    [scrollView setContentOffset:CGPointMake(0, self.top) animated:YES];
//}

@end
