//
//  RPCoreDataGetOperation.m
//  rework-password
//
//  Created by 张超 on 2019/1/8.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPCoreDataGetOperation.h"
@import MagicalRecord;

@interface RPCoreDataGetOperation ()
{
    
}
@property (nullable, readwrite, retain) id result;
@end

@implementation RPCoreDataGetOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.onlyFirst = NO;
        self.onlyGetCount = NO;
        self.asc = YES;
    }
    return self;
}

- (void)main
{
    if (!self.getClass) {
        //NSLog(@"%@ need set class",self);
        return;
    }
    
    Class a = self.getClass;
    id result = @(0);
    NSManagedObjectContext* context = [NSManagedObjectContext MR_rootSavingContext];
    if (self.onlyGetCount) {
        if (self.predicate) {
            @try {
                result = [NSNumber numberWithInteger:[(id)a MR_countOfEntitiesWithPredicate:self.predicate inContext:context]];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
        else
        {
            result = [NSNumber numberWithInteger: [(id)a MR_countOfEntitiesWithContext:context]];
        }
    }
    else  if (self.onlyFirst) {
        if (self.predicate) {
            result =  [(id)a MR_findFirstWithPredicate:self.predicate sortedBy:self.sortKey ascending:self.asc inContext:context];
        }
        else if(self.queryProperty)
        {
            result = [(id)a MR_findFirstByAttribute:self.queryProperty withValue:self.queryValue inContext:context];
        }
        else if(self.sortKey)
        {
            result = [(id)a MR_findFirstOrderedByAttribute:self.sortKey ascending:self.asc inContext:context];
        }
        else
        {
            result = [(id)a MR_findFirstInContext:context];
        }
    }
    else
    {
        if (self.predicate) {
            result =  [(id)a MR_findAllSortedBy:self.sortKey ascending:self.asc withPredicate:self.predicate inContext:context];
        }
        else if(self.queryProperty)
        {
            result = [(id)a MR_findByAttribute:self.queryProperty withValue:self.queryValue andOrderBy:self.sortKey ascending:self.asc inContext:context];
        }
        else if(self.sortKey)
        {
            result = [(id)a MR_findAllSortedBy:self.sortKey ascending:self.asc inContext:context];
        }
        else
        {
            result = [(id)a MR_findAllInContext:context];
        }
    }
    self.result = result;
    if (self.queryBlock) {
        self.queryBlock(result, nil);
    }
}

- (void)runAtMainQuene
{
    [[NSOperationQueue mainQueue] addOperation:self];
}

@end
