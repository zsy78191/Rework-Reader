//
//  RPSortItemOperation.h
//  rework-password
//
//  Created by 张超 on 2019/1/22.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPSortableItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface RPSortItemOperation : NSOperation
{
    
}

@property (nonatomic, strong) NSArray<id<RPSortableItem>>* sortItems;
@property (nonatomic, strong) NSString* _Nullable sortKey;
@property (nonatomic, assign) BOOL asc;
@property (nonatomic, assign) BOOL accordingIdx;

@property (nonatomic, strong) NSArray<id<RPSortableItem>>* _Nullable result;

@end

NS_ASSUME_NONNULL_END
