
//
//  RPGetAllModelKeyAndValueOperation.m
//  rework-password
//
//  Created by 张超 on 2019/1/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPGetAllModelKeyAndValueOperation.h"
#import "RPKeyAndValueModelProtocol.h"
@import oc_string;

@implementation RPGetAllModelKeyAndValueOperation

- (void)main
{
    NSMutableArray* a = [NSMutableArray arrayWithCapacity:10];
    NSMutableDictionary* d = [NSMutableDictionary dictionary];
//    self.allModels =
    NSArray* t = self.allModels.filter(^BOOL(id  _Nonnull x) {
        return [x conformsToProtocol:@protocol(RPKeyAndValueModelProtocol)];
    });
    [t.filter(^BOOL(id<RPKeyAndValueModelProtocol>  _Nonnull x) {
        if (self.reverse) {
            return [self.getKeys indexOfObject:x.entityKey] == NSNotFound;
        }
        return [self.getKeys indexOfObject:x.entityKey] != NSNotFound;
    }) enumerateObjectsUsingBlock:^(id<RPKeyAndValueModelProtocol>_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.entityKey) {
            if (self.getModel) {
                 [d setValue:obj forKey:obj.entityKey];
                [a addObject:obj];
            }
            else {
                 [d setValue:obj.entityValue forKey:obj.entityKey];
                [a addObject:obj];
            }
        }
    }];
    self.result = [d copy];
    self.originSortResult = [a copy];
}

@end
