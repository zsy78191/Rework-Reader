//
//  RREmptyStyleOne.m
//  rework-reader
//
//  Created by 张超 on 2019/3/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RREmptyStyleOne.h"
@import DZNEmptyDataSet;

@interface RREmptyStyleOne () <DZNEmptyDataSetDelegate>
@property (nonatomic, weak) UIScrollView* handleView;
@end

@implementation RREmptyStyleOne

- (NSString *)titleForEmptyTitle
{
    return @"订阅源不可用";
}

- (void)reload
{
    
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    self.handleView = scrollView;
    return self.shouldDisplay;
}

- (void)setShouldDisplay:(BOOL)shouldDisplay
{
    _shouldDisplay = shouldDisplay;
    if (self.handleView) {
        [self.handleView reloadEmptyDataSet];
    }
}

- (UIImage *)image
{
    return [UIImage imageNamed:@"error"];
}

- (NSString *)buttonTitleForState:(NSUInteger)state
{
    return @"返回";
}

- (void)didTapButton:(UIButton *)button
{
    if (self.action) {
        self.action();
    }
}

@end
