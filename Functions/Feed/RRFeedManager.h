//
//  RRFeedManager.h
//  rework-reader
//
//  Created by 张超 on 2019/6/3.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EntityFeedInfo,EntityHub;
@interface RRFeedHub : NSObject
{
    
}

@property (nonatomic, readonly) RRFeedHub* (^ named)(NSString* name);
@property (nonatomic, readonly) RRFeedHub* (^ icond)(NSString* icon);
@property (nonatomic, readonly) RRFeedHub* (^ insertFeed)(EntityFeedInfo* feed);
@property (nonatomic, readonly) RRFeedHub* (^ insertFeeds)(NSArray<EntityFeedInfo*>* feeds);
@property (nonatomic, readonly) RRFeedHub* (^ removeFeed)(EntityFeedInfo* feed);
@property (nonatomic, readonly) RRFeedHub* (^ save)(void (^finished)(BOOL));

- (NSString*)name;
- (NSString*)icon;
- (NSArray<EntityFeedInfo*>*)feeds;

- (instancetype)initWithName:(NSString*)name;
+ (RRFeedHub*)hubWithEntity:(EntityHub*)hub;
+ (NSArray<RRFeedHub*>*)allHubs;

@end

@interface RRFeedManager : NSObject
 
+ (RRFeedHub*)hubWithName:(NSString*)name;
+ (NSArray<RRFeedHub*>*)allHubs;
+ (void)removeAllHUBs;
+ (void)removeHUB:(EntityHub*)hub complete:(void (^)(BOOL))complete;

+ (NSArray*)failedFeedInfos;

@end

NS_ASSUME_NONNULL_END
