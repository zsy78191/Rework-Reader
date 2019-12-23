
//
//  RPSortItemOperation.m
//  rework-password
//
//  Created by 张超 on 2019/1/22.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPSortItemOperation.h"
@import MagicalRecord;

@implementation RPSortItemOperation

- (void)main
{
    if (!self.sortItems) {
//        DDLogWarn(@"排序需要设置sortItems");
        return;
    }
    
    NSArray<id<RPSortableItem>>* temp = self.sortItems;
    
    
    if (!self.accordingIdx && self.sortKey) {
        NSSortDescriptor* s = [NSSortDescriptor sortDescriptorWithKey:self.sortKey ascending:self.asc];
        temp = [self.sortItems sortedArrayUsingDescriptors:@[s]];
    }
    else {
//        DDLogWarn(@"排序需要设置sortKey，或者使用accordingIdx");
        return;
    }
    
    NSManagedObjectContext* context = [NSManagedObjectContext MR_rootSavingContext];
    __block BOOL hasCoreData = NO;
    
    [temp enumerateObjectsUsingBlock:^(id<RPSortableItem>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<RPSortableItem> item = obj;
        if ([obj isKindOfClass:[NSManagedObject class]]) {
            hasCoreData = YES;
            item = (id<RPSortableItem>)[(NSManagedObject*)obj MR_inContext:context];
        }
        [item setSort:idx];
    }];
    
    if (hasCoreData) {
        NSError* e;
        [context save:&e];
        if (e) {
            ////NSLog(@"%@",e);
        }
    }

    self.result = temp;
}

@end
