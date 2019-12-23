//
//  FMFeedParserOperation.h
//  Fork-MWFeedParser
//
//  Created by 张超 on 2019/1/15.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPAsyncOperation.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FMParseTypeFull = 0,
    FMParseTypeItems,
    FMParseTypeInfo,
} FMParseType;
@class MWFeedInfo;
@class MWFeedItem;

@interface FMFeedParserOperation : RPAsyncOperation

@property (nonatomic, strong) NSURL* feedURL;
@property (nonatomic, strong) NSString* title;

@property (nonatomic, assign) FMParseType type;

@property (nonatomic, weak) NSOperationQueue* netWorkQuene;
@property (nonatomic, weak) NSURLSession* session;

@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, strong) void(^ parseCanncelBlock)(void);
@property (nonatomic, strong) void(^ parseInfoBlock)(MWFeedInfo* info);
@property (nonatomic, strong) void(^ parseItemBlock)(MWFeedItem* item);
@property (nonatomic, strong) void(^ parseFinishBlock)(void);
@property (nonatomic, strong) void(^ parseErrorBlock)(NSError* error);

@end

NS_ASSUME_NONNULL_END
