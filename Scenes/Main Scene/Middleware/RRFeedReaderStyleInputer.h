//
//  RRFeedReaderStyleInputer.h
//  rework-reader
//
//  Created by 张超 on 2019/2/21.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface RRFeedReaderStyleInputer : MVPArrayInput
@property (nonatomic, strong) NSMutableArray* hideItem;
- (void)hideModel:(id)model;
- (void)showAll;

- (void)reset;
@end

NS_ASSUME_NONNULL_END
