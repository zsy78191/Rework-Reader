//
//  RRFeedInfoListOtherModel.h
//  rework-reader
//
//  Created by 张超 on 2019/2/21.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;
#import "RRReadStyle.h"
#import "RRCanEditProtocol.h"
typedef enum : NSUInteger {
    RRFeedInfoListOtherModelTypeTitle,
    RRFeedInfoListOtherModelTypeItem
} RRFeedInfoListOtherModelType;

NS_ASSUME_NONNULL_BEGIN

@interface RRFeedInfoListOtherModel : MVPModel <RRCanEditProtocol>

@property (nonatomic, assign) RRFeedInfoListOtherModelType type;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) NSString* subtitle;
@property (nonatomic, strong) NSString* icon;
@property (nonatomic, strong, nullable) NSString* key;
@property (nonatomic, assign) BOOL canRefresh;

@property (nonatomic, strong, nullable) RRReadStyle* readStyle;

@end

NS_ASSUME_NONNULL_END
