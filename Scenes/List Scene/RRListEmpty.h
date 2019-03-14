//
//  RRListEmpty.h
//  rework-reader
//
//  Created by 张超 on 2019/3/13.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface RRListEmpty : MVPEmptyMiddleware
{
    
}
@property (nonatomic, strong) void (^actionBlock)(void);
@end

NS_ASSUME_NONNULL_END
