//
//  RRProvideDataProtocol.h
//  rework-reader
//
//  Created by 张超 on 2019/2/20.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RRFeedArticleModel,MWFeedInfo;
@protocol RRProvideDataProtocol <NSObject>

@optional

@property (nonatomic, strong) __nullable id (^nextArticle)(id current);
@property (nonatomic, strong) __nullable id (^lastArticle)(id current);
@property (nonatomic, strong) __nullable id (^nextFeed)(id current);
@property (nonatomic, strong) __nullable id (^lastFeed)(id current);

- (void)loadData:(RRFeedArticleModel*)m feed:(MWFeedInfo*)feedInfo;
- (void)loadNext;
- (void)loadLast;

// RRXXTODO:暂时先放在这里
- (void)pageUp;
- (void)pageDown;
- (void)switchFavorite;
- (void)switchReadlater;
@end

NS_ASSUME_NONNULL_END
