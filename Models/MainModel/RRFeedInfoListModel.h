//
//  RRFeedInfoListModel.h
//  rework-reader
//
//  Created by 张超 on 2019/2/21.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;
@class EntityFeedInfo,EntityHub;
#import "RRCanEditProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface RRFeedInfoListModel : MVPModel <RRCanEditProtocol>

@property (nonatomic, strong) EntityFeedInfo* feed;
@property (nonatomic, strong) EntityHub* thehub;

@property (nullable, nonatomic, copy) NSString *copyright;
@property (nullable, nonatomic, copy) NSString *generator;
@property (nullable, nonatomic, copy) NSString *icon;
@property (nullable, nonatomic, copy) NSString *language;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *managingEditor;
@property (nullable, nonatomic, copy) NSString *summary;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *ttl;
@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSDate *updateDate;
@property (nullable, nonatomic, copy) NSURL *url;
@property (nullable, nonatomic, copy) NSNumber* sort;
@property (nonatomic) BOOL useautoupdate;
@property (nonatomic) BOOL usesafari;
@property (nonatomic) BOOL usettl;
@property (nonatomic) BOOL useachieve;

- (void)loadFromFeed:(EntityFeedInfo*)feed;

@end

NS_ASSUME_NONNULL_END
