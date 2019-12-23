//
//  RPCoreDataDelOperation.m
//  rework-password
//
//  Created by 张超 on 2019/1/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPCoreDataDelOperation.h"
@import MagicalRecord;
@import oc_base;
@import oc_util;
@import oc_string;

@implementation RPCoreDataDelOperation

- (void)main
{
    if (self.obj || self.objs) {
        if (self.obj) {
            [self delObj:self.obj];
        }
        if (self.objs) {
            [self delObjs:self.objs];
        }
        return;
    }
    
    
    if (!self.delClass) {
        //NSLog(@"%@ need set class",self);
        return;
    }
    
    Class a = self.delClass;
    NSManagedObjectContext* context = [NSManagedObjectContext MR_rootSavingContext];
    NSArray* willDelData = nil;
    if (self.predicate) {
         willDelData = [(id)a MR_findAllWithPredicate:self.predicate inContext:context];
    }
    else if(self.key)
    {
        willDelData = [(id)a MR_findByAttribute:self.key withValue:self.value inContext:context];
    }
    else if(self.allowDeleteAll)
    {
        willDelData = [(id)a MR_findAllInContext:context];
    }
    
    if (!willDelData) {
        return;
    }
    
    willDelData = willDelData.filter(^BOOL(id  _Nonnull x) {
        if (self.beforeDel) {
            BOOL can = self.beforeDel(x);
            return can;
        }
        return YES;
    });
   
    NSUInteger count = willDelData.count;
    [willDelData enumerateObjectsUsingBlock:^(__kindof NSManagedObject*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj MR_deleteEntityInContext:context];
    }];
    
    NSError* e;
    [context save:&e];
    
    if (self.finishBlock) {
        self.finishBlock(count, e);
    }
}

- (void)delObj:(NSManagedObject*)obj;
{
    NSManagedObjectContext* context = [NSManagedObjectContext MR_rootSavingContext];
    [obj MR_deleteEntityInContext:context];
    NSError* e;
    [context save:&e];
    if (self.finishBlock) {
        self.finishBlock(e?0:1, e);
    }
}

- (void)delObjs:(NSArray*)objs;
{
    __block NSUInteger c = 0;
    NSManagedObjectContext* context = [NSManagedObjectContext MR_rootSavingContext];
    [objs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj MR_deleteEntityInContext:context])
        {
            c++;
        }
    }];
    NSError* e;
    [context save:&e];
    if (self.finishBlock) {
        self.finishBlock(e?0:c, e);
    }
}

@end
