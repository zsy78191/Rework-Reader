//
//  RPSortableItem.h
//  rework-password
//
//  Created by 张超 on 2019/1/22.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RPSortableItem <NSObject>

@property (nonatomic,readonly) NSString* sortKey;
- (void)setSort:(NSUInteger)sort;

@end

NS_ASSUME_NONNULL_END
