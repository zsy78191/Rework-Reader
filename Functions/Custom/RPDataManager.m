//
//  RPDataManager.m
//  rework-password
//
//  Created by 张超 on 2019/1/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPDataManager.h"
#import "RPCoreDataGetOperation.h"
#import "RPCoreDataInsertOperation.h"
#import "RPCoreDataDelOperation.h"
#import "RPGetAllModelKeyAndValueOperation.h"
#import "RPDataNotificationCenter.h"
#import "RPSortItemOperation.h"
@import oc_string;

@implementation RPDataManager

+ (instancetype)sharedManager
{
    static RPDataManager* _shared_g_rpmanager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared_g_rpmanager = [[RPDataManager alloc] init];
    });
    return _shared_g_rpmanager;
}

- (id)insertOperationClass:(NSString *)className
                                             model:(id)model
                                          queryKey:(NSString*)key
                                        queryValue:(id)value
                                    keysAndValues:(NSDictionary *)dict
                                              keys:(NSArray *)keys
                                            modify:(nullable id  _Nonnull (^)(id _Nonnull, id _Nonnull))modifyValue
                                            finish:(void (^ _Nullable)(__kindof NSManagedObject * _Nonnull, NSError * _Nonnull))finish
{
    RPCoreDataInsertOperation* operation = [[RPCoreDataInsertOperation alloc] init];
    operation.insertClass = NSClassFromString(className);
    NSAssert(operation.class != nil, @"%@ not exist",className);
    operation.model = model;
    operation.saveKeys = keys;
    operation.keysAndValues = dict;
    operation.modifyValue = modifyValue;
    operation.finishBlock = finish;
    operation.queryValue = value;
    operation.queryKey = key;
    [[RPDataNotificationCenter defaultCenter] notificateWithEntityClass:className];
    return operation;
}

- (id)insertClass:(NSString *)className
                       model:(id)model
                        keys:(NSArray *)keys
                      modify:(nullable id  _Nonnull (^)(id _Nonnull, id _Nonnull))modifyValue
                      finish:(void (^ _Nullable)(__kindof NSManagedObject * _Nonnull, NSError * _Nonnull))finish
{
    RPCoreDataInsertOperation* o = [self insertOperationClass:className model:model queryKey:nil queryValue:nil keysAndValues:nil keys:keys modify:modifyValue finish:finish];
    [o start];
    return o.result;
}

- (id)insertClass:(NSString *)className
               keysAndValues:(NSDictionary *)dict
                      modify:(nullable id  _Nonnull (^)(id _Nonnull, id _Nonnull))modifyValue
                      finish:(void (^ _Nullable)(__kindof NSManagedObject * _Nonnull, NSError * _Nonnull))finish
{
    RPCoreDataInsertOperation* o = [self insertOperationClass:className model:nil queryKey:nil queryValue:nil keysAndValues:dict keys:nil modify:modifyValue finish:finish];
    [o start];
    return o.result;
}

- (id)updateClass:(NSString *)className model:(id)model queryKey:(NSString *)key queryValue:(id)value keys:(NSArray *)keys modify:(id  _Nonnull (^)(id _Nonnull, id _Nonnull))modifyValue finish:(void (^)(__kindof NSManagedObject * _Nonnull, NSError * _Nonnull))finish
{
    RPCoreDataInsertOperation* o =  [self insertOperationClass:className model:model queryKey:key queryValue:value keysAndValues:nil keys:keys modify:modifyValue finish:finish];
    [o start];
    return o.result;
}

- (id)updateClass:(NSString *)className queryKey:(NSString *)key queryValue:(id)value keysAndValues:(NSDictionary *)dict modify:(id  _Nonnull (^)(id _Nonnull, id _Nonnull))modifyValue finish:(void (^)(__kindof NSManagedObject * _Nonnull, NSError * _Nonnull))finish
{
    RPCoreDataInsertOperation* o = [self insertOperationClass:className model:nil queryKey:key queryValue:value keysAndValues:dict keys:nil modify:modifyValue finish:finish];
    [o start];
    return o.result;
}

- (id)udpateDatas:(NSString *)className models:(NSArray *)models queryKey:(NSString *)key saveKeys:(NSArray *)savekeys modify:(id  _Nonnull (^)(id _Nonnull, id _Nonnull))modifyValue finish:(void (^)(NSArray * _Nonnull, NSError * _Nonnull))finish
{
    RPCoreDataInsertOperation* o = [self insertOperationClass:className model:nil queryKey:key queryValue:nil keysAndValues:nil keys:savekeys modify:modifyValue finish:nil];
    o.models = models;
    [o start];
    return o.results;
}

- (id)updateDatas:(NSString *)className predicate:(NSPredicate *)predicate modify:(void  (^)(id ))modify finish:(void (^)(NSArray * _Nonnull, NSError * _Nonnull))finish
{
    RPCoreDataInsertOperation* operation = [[RPCoreDataInsertOperation alloc] init];
    operation.insertClass = NSClassFromString(className);
    NSAssert(operation.class != nil, @"%@ not exist",className);
    operation.modify = modify;
    operation.finishesBlock = finish;
    operation.predicate = predicate;
    [[RPDataNotificationCenter defaultCenter] notificateWithEntityClass:className];
    [operation start];
    return operation;
}


- (id)getData:(NSString *)className predicate:(NSPredicate *)p key:(NSString *)key value:(id)value sort:(NSString *)sort asc:(BOOL)asc first:(BOOL)first count:(BOOL)count
{
    RPCoreDataGetOperation* operation = [[RPCoreDataGetOperation alloc] init];
    operation.getClass = NSClassFromString(className);
    NSAssert(operation.getClass != nil, @"%@ not exist",className);
    operation.sortKey = sort;
    operation.asc = asc;
    operation.onlyFirst = first;
    operation.onlyGetCount = count;
    operation.predicate = p;
    operation.queryProperty = key;
    operation.queryValue = value;
    [operation start];
    return operation.result;
}

- (id)getFirst:(NSString *)className predicate:(NSPredicate *)p key:(NSString *)key value:(id)value sort:(NSString *)sort asc:(BOOL)asc
{
    return [self getData:className predicate:p key:key value:value sort:sort asc:asc first:YES count:NO];
}

- (id)getAll:(NSString *)className predicate:(NSPredicate *)p key:(NSString *)key value:(id)value sort:(NSString *)sort asc:(BOOL)asc
{
    return [self getData:className predicate:p key:key value:value sort:sort asc:asc first:NO count:NO];
}

- (id)getCount:(NSString *)className predicate:(NSPredicate *)p key:(NSString *)key value:(id)value sort:(NSString *)sort asc:(BOOL)asc
{
    return [self getData:className predicate:p key:key value:value sort:sort asc:asc first:NO count:YES];
}

- (void)delData:(NSString *)className predicate:(NSPredicate *)predicate key:(NSString *)key value:(id)value beforeDel:(BOOL (^)(__kindof NSManagedObject * _Nonnull))beforeDel finish:(void (^)(NSUInteger, NSError * _Nonnull))finish
{
    RPCoreDataDelOperation* operation = [[RPCoreDataDelOperation alloc] init];
    operation.delClass = NSClassFromString(className);
    NSAssert(operation.delClass != nil, @"%@ not exist",className);
    operation.predicate = predicate;
    operation.key = key;
    operation.value = value;
    if (!operation.predicate && !operation.key) {
        operation.allowDeleteAll = YES;
    }
    operation.beforeDel = beforeDel;
    operation.finishBlock = finish;
    [operation start];
    [[RPDataNotificationCenter defaultCenter] notificateWithEntityClass:className];
}

- (void)delData:(__kindof NSManagedObject *)obj relationKey:(NSString *)rkey beforeDel:(BOOL (^)(__kindof NSManagedObject * _Nonnull))beforeDel finish:(void (^)(NSUInteger, NSError * _Nonnull))finish
{
    id target = obj;
    if (rkey) {
        target = [obj valueForKey:rkey];
    }
    if ([target isKindOfClass:[NSSet class]]) {
        if (beforeDel) {
            NSArray* final = [(NSSet*)target sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES]]];
            final = final.filter(^BOOL(id  _Nonnull x) {
                return beforeDel(x);
            });
            [self delDatas:final finish:finish];
        }
        else {
            [self delDatas:target finish:finish];
        }
    }
    else {
        if (beforeDel) {
            if (beforeDel(target)) {
                [self delData:target finish:finish];
            }
        }
        else {
            [self delData:target finish:finish];
        }
    }
}

- (void)delData:(NSManagedObject*)obj  finish:(void (^)(NSUInteger, NSError * _Nonnull))finish
{
    RPCoreDataDelOperation* operation = [[RPCoreDataDelOperation alloc] init];
    operation.obj = obj;
    operation.finishBlock = finish;
    [operation start];
    [[RPDataNotificationCenter defaultCenter] notificateWithEntityClass:NSStringFromClass([obj class])];
}

- (void)delDatas:(NSArray*)objs  finish:(void (^)(NSUInteger, NSError * _Nonnull))finish
{
    RPCoreDataDelOperation* operation = [[RPCoreDataDelOperation alloc] init];
    operation.objs = objs;
    operation.finishBlock = finish;
    [operation start];
    
    NSMutableSet* set = [[NSMutableSet alloc] initWithCapacity:10];
    [objs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [set addObject:NSStringFromClass([obj class])];
    }];
    [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            [[RPDataNotificationCenter defaultCenter] notificateWithEntityClass:obj];
    }];
}

- (RPGetAllModelKeyAndValueOperation*)gamkavOp:(id)models getKeys:(NSArray *)keys getModel:(BOOL)model
{
    RPGetAllModelKeyAndValueOperation* operation = [[RPGetAllModelKeyAndValueOperation alloc] init];
    operation.allModels = models;
    operation.getKeys = keys;
    operation.getModel = model;
    return operation;
}

- (NSDictionary *)dictionaryWithModels:(id)models getKeys:(NSArray *)keys getModel:(BOOL)model
{
    RPGetAllModelKeyAndValueOperation* operation = [self gamkavOp:models getKeys:keys getModel:model];
    [operation start];
    return operation.result;
}

- (NSDictionary *)dictionaryWithModels:(id)models getWithoutKeys:(NSArray *)keys getModel:(BOOL)model
{
    RPGetAllModelKeyAndValueOperation* operation = [self gamkavOp:models getKeys:keys getModel:model];
    operation.reverse = YES;
    [operation start];
    return operation.result;
}

- (NSArray *)arrayWithModels:(id)models getKeys:(NSArray *)keys
{
    RPGetAllModelKeyAndValueOperation* operation = [self gamkavOp:models getKeys:keys getModel:YES];
    [operation start];
    return operation.originSortResult;
}

- (NSArray *)arrayWithModels:(id)models getWithoutKeys:(nonnull NSArray *)keys
{
    RPGetAllModelKeyAndValueOperation* operation = [self gamkavOp:models getKeys:keys getModel:YES];
    [operation setReverse:YES];
    [operation start];
    return operation.originSortResult;
}

- (NSArray<id<RPSortableItem>> *)sortItems:(NSArray<id<RPSortableItem>> *)items
                                   withKey:(NSString *)key
                                       asc:(BOOL)asc
                              accordingIdx:(BOOL)aidx
{
    RPSortItemOperation* operation = [[RPSortItemOperation alloc] init];
    [operation setSortItems:items];
    [operation setSortKey:key];
    [operation setAsc:asc];
    [operation setAccordingIdx:aidx];
    [operation start];
    return operation.result;
}

@end
