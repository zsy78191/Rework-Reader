//
//  RRListInputer.h
//  rework-reader
//
//  Created by 张超 on 2019/2/22.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;
#import "RRFeedInfoListOtherModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RRListInputer : MVPCoredataInput

@property (nonatomic, strong, nullable) id feed;

@property (nonatomic, strong, nullable) RRFeedInfoListOtherModel* model;

@end

NS_ASSUME_NONNULL_END
