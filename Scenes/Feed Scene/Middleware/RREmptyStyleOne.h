//
//  RREmptyStyleOne.h
//  rework-reader
//
//  Created by 张超 on 2019/3/11.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface RREmptyStyleOne : MVPEmptyMiddleware
@property (nonatomic, assign) BOOL shouldDisplay;
- (void)reload;
@property (nonatomic, strong) void(^action)(void);
@end

NS_ASSUME_NONNULL_END
