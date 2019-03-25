//
//  RRBaseEmpty.h
//  rework-reader
//
//  Created by 张超 on 2019/3/23.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface RRBaseEmpty : MVPEmptyMiddleware
@property (nonatomic, strong) void (^actionBlock)(void);
@end

NS_ASSUME_NONNULL_END
