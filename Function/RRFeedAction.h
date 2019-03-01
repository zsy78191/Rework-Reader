//
//  RRFeedAction.h
//  rework-reader
//
//  Created by 张超 on 2019/2/25.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EntityFeedInfo,EntityFeedStyle,EntityFeedArticle;
NS_ASSUME_NONNULL_BEGIN

@interface RRFeedAction : NSObject

+ (void)likeArticle:(BOOL)like withUUID:(NSString*)uuid block:(void (^)(NSError*))finished;

+ (void)insertArticle:(NSArray*)article finish:(void (^)(NSUInteger))finish;
+ (void)insertArticle:(NSArray*)article withFeed:(EntityFeedInfo*)info finish:(void (^)(NSUInteger))finish;

+ (void)readArticle:(NSString*)articleUUID;
+ (void)recordArticle:(NSString*)articleUUID position:(CGFloat)position;
+ (CGFloat)loadPositionWithArticle:(NSString*)articleUUID;

+ (void)delFeed:(EntityFeedInfo*)info view:(UIViewController*)view finish:(void (^)(void))finishBlock;

@end

NS_ASSUME_NONNULL_END
