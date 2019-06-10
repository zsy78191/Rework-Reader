//
//  RRFeedListPresenter.h
//  rework-reader
//
//  Created by 张超 on 2019/1/28.
//  Copyright © 2019 orzer. All rights reserved.
//



@import mvc_base;
#import "RRReadMode.h"

NS_ASSUME_NONNULL_BEGIN
@class RRFeedInfoListOtherModel,RRFeedInputer,RRFeedReaderStyleInputer;
@interface RRFeedListPresenter : MVPPresenter

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) MVPComplexInput* complexInput;
@property (nonatomic, strong) RRFeedInputer* inputer;
@property (nonatomic, strong) RRFeedReaderStyleInputer* readStyleInputer;
@property (nonatomic, assign) BOOL needUpdate;
@property (nonatomic, assign) BOOL needUpdateFeed;
@property (nonatomic, assign) RRReadMode mode;
@property (nonatomic, assign) BOOL updating;
@property (nonatomic, weak) UIRefreshControl* refresher;
@property (nonatomic, assign) BOOL hasDatas;
@property (nonatomic, assign) double offsetY;
@property (nonatomic, assign) BOOL firstEnter;
@property (nonatomic, strong) NSArray* selectArray;
@property (nonatomic, assign) BOOL selectMoreThanOne;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, strong) RRFeedInfoListOtherModel* unreadModel;
@property (nonatomic, strong) RRFeedInfoListOtherModel* laterModel;
@property (nonatomic, strong) RRFeedInfoListOtherModel* favModel;
@property (nonatomic, strong) RRFeedInfoListOtherModel* recentModel;

@property (nonatomic, strong) NSMutableDictionary* listItemSetting;

@end

NS_ASSUME_NONNULL_END
