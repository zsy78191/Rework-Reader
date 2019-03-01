//
//  RRReadStyle.h
//  rework-reader
//
//  Created by 张超 on 2019/2/22.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RRCoreDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RRReadStyle : NSObject
{
    
}
- (instancetype)initWithEntity:(EntityFeedStyle*)style;

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong, nullable) EntityFeedInfo* feed;
@property (nonatomic, strong, nullable) NSSet<EntityFeedInfo*>* feeds;
@property (nonatomic, assign) BOOL onlyUnread;
@property (nonatomic, assign) BOOL onlyReaded;
@property (nonatomic, assign) NSInteger daylimit;
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, assign) BOOL canEdit;

- (NSPredicate*)predicate;
- (NSArray<NSSortDescriptor*>*)sort;

@end

NS_ASSUME_NONNULL_END
