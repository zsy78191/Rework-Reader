//
//  RRFeedAction.h
//  rework-reader
//
//  Created by 张超 on 2019/2/25.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EntityFeedInfo,EntityFeedStyle,EntityFeedArticle;
NS_ASSUME_NONNULL_BEGIN

@class MWFeedInfo;

@interface RRFeedAction : NSObject

+ (void)likeArticle:(BOOL)like withUUID:(NSString*)uuid block:(void (^)(NSError*))finished;
+ (void)readLaterArticle:(BOOL)readerLater withUUID:(NSString*)uuid block:(void (^)(NSError*))finished;

+ (void)insertFeedInfo:(MWFeedInfo*)info finish:(void (^)(void))finish;

+ (void)insertArticle:(NSArray*)article finish:(void (^)(NSUInteger))finish;
+ (void)insertArticle:(NSArray*)article withFeed:(EntityFeedInfo*)info finish:(void (^)(NSUInteger))finish;

+ (void)markFeedAsEnable:(BOOL)enable feedUUID:(NSString *)uuid;


+ (void)readArticle:(NSString*)articleUUID;
+ (void)readArticle:(NSString *)articleUUID onlyMark:(BOOL)onlymark;
+ (void)recordArticle:(NSString*)articleUUID position:(CGFloat)position;
+ (CGFloat)loadPositionWithArticle:(NSString*)articleUUID;

+ (void)delFeed:(EntityFeedInfo*)info
           view:(UIViewController*)view
           item:(nullable id)sender
          arrow:(UIPopoverArrowDirection)arrow
         finish:(void (^)(void))finishBlock;

+ (void)preloadImages:(NSString*)uuid;
+ (void)preloadEntityImages:(EntityFeedArticle*)article;

+ (void)showCookie;
@end

NS_ASSUME_NONNULL_END
