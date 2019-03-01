//
//  RRFeedInfoModel.h
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;


NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RRFeedInfoTypeText,
    RRFeedInfoTypeSwitch,
    RRFeedInfoTypeTitle,
} RRFeedInfoType;

@interface RRFeedInfoModel : MVPModel

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSString* value;
@property (nonatomic, strong) id origin_value;
@property (nonatomic, assign) RRFeedInfoType type;
@property (nonatomic, strong) id switchValue;

@end

NS_ASSUME_NONNULL_END
