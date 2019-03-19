//
//  RPCoreDataInsertOperation.h
//  rework-password
//
//  Created by 张超 on 2019/1/9.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;
NS_ASSUME_NONNULL_BEGIN

@interface RPCoreDataInsertOperation : NSOperation

@property (nonatomic, strong) Class insertClass;

@property (nonatomic, strong) id (^ modifyValue)(id key,id value);
@property (nonatomic, strong) void (^finishBlock)(__kindof NSManagedObject* _Nullable obj, NSError* e);
@property (nonatomic, strong) void (^finishesBlock)(NSArray* objs, NSError* e);

@property (nonatomic, strong) id model;
@property (nonatomic, strong) NSArray* saveKeys;

@property (nonatomic, strong) NSDictionary* keysAndValues;

@property (nonatomic, strong) NSString* queryKey;
@property (nonatomic, strong) NSString* queryValue;

#pragma mark - 另一种批量
@property (nonatomic, strong, nullable) NSArray* models;
//@property (nonatomic, strong) NSArray<NSString*>* saveKeys;

#pragma mark - 第三种批量
@property (nonatomic, strong, nullable) NSPredicate* predicate;
@property (nonatomic, strong) void (^ modify)(id obj);

@property (nonatomic, strong) id result;
@property (nonatomic, strong) id results;

@end

NS_ASSUME_NONNULL_END
