//
//  RRFeedArticleModel.h
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;
@import Fork_MWFeedParser;

NS_ASSUME_NONNULL_BEGIN

@class EntityFeedArticle;
@class EntityFeedInfo;

@interface RRFeedArticleModel : MVPModel <NSCoding>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSDate *updateTime;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSArray *enclosures;
@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, copy) NSString* uuid;
@property (nonatomic, copy) NSDate* lastread;
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, assign) BOOL readed;
@property (nonatomic, assign) BOOL readlater;

- (instancetype)initWithItem:(MWFeedItem*)item;
- (instancetype)initWithEntity:(EntityFeedArticle*)article;

@property (nonatomic, strong) MWFeedInfo* feed;
@property (nonatomic, strong) EntityFeedInfo* feedEntity;

@end

NS_ASSUME_NONNULL_END
