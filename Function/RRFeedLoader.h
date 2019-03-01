//
//  RRFeedLoader.h
//  rework-reader
//
//  Created by 张超 on 2019/2/13.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Fork_MWFeedParser;
NS_ASSUME_NONNULL_BEGIN

@interface RRFeedLoader : NSObject

+ (instancetype)sharedLoader;

- (FMFeedParserOperation*)loadOfficalWithInfoBlock:(void(^)(MWFeedInfo* info))infoblock
                       itemBlock:(void(^)(MWFeedItem* item))itemblock
                      errorBlock:(void(^)(NSError* error))errblock
                     finishBlock:(void(^)(void))finishblock;


- (FMFeedParserOperation*)loadFeed:(NSString*)url
       infoBlock:(void(^)(MWFeedInfo* info))infoblock
       itemBlock:(void(^)(MWFeedItem* item))itemblock
      errorBlock:(void(^)(NSError* error))errblock
     finishBlock:(void(^)(void))finishblock
  needUpdateIcon:(BOOL)need;

- (void)reloadAll:(NSArray<NSString*>*)feedURIs
        infoBlock:(void(^)(MWFeedInfo* info))infoblock
        itemBlock:(void(^)(MWFeedInfo* info,MWFeedItem* item))itemblock
       errorBlock:(void(^)(NSError* error))errblock
      finishBlock:(void(^)(void))finishblock;

- (void)cancel:(FMFeedParserOperation*)operation;

@property (nonatomic, strong) NSDateFormatter* shrotDateFormatter;
@property (nonatomic, strong) NSDateFormatter* shrotDateAndTimeFormatter;

- (__kindof UIViewController*)feedItem:(NSString*)url
                            errorBlock:(void(^)(NSError* error))errblock
                           finishBlock:(void(^)(void))finishblock;

- (__kindof UIViewController*)feedItem:(NSString*)url
                            errorBlock:(void(^)(NSError* error))errblock
                           cancelBlock:(void(^)(void))cancelBlock
                           finishBlock:(void(^)(void))finishblock;
- (void)canncelCurrentFeed;


- (void)refresh:(NSArray*)origin endRefreshBlock:(void (^)(void))endBlock finishBlock:(void (^)(NSUInteger all,NSUInteger error, NSUInteger article))finishBlock;


@end

NS_ASSUME_NONNULL_END
