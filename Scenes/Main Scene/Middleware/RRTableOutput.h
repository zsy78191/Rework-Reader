//
//  RRTableOutput.h
//  rework-reader
//
//  Created by 张超 on 2019/2/28.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface RRTableOutput : MVPTableViewOutput

@property (nonatomic, strong) void (^newOffsetBlock)(CGFloat offsetY);

@end

NS_ASSUME_NONNULL_END
