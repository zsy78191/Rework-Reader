//
//  RPCoreDataDelOperation.h
//  rework-password
//
//  Created by 张超 on 2019/1/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NSManagedObject;

@interface RPCoreDataDelOperation : NSOperation

@property (nonatomic, strong) Class delClass;
@property (nonatomic, assign) BOOL allowDeleteAll;

@property (nonatomic, strong, nullable) NSString* key;
@property (nonatomic, strong, nullable) id value;

@property (nonatomic, strong, nullable) NSPredicate* predicate;

@property (nonatomic, strong) BOOL (^ beforeDel)(__kindof NSManagedObject*);
@property (nonatomic, strong) void (^finishBlock)(NSUInteger count, NSError* e);

#pragma mark - 第二种删法，画优先于第一种
@property (nonatomic, strong) __kindof NSManagedObject* obj;
@property (nonatomic, strong) NSArray<__kindof NSManagedObject*>* objs;

@end

NS_ASSUME_NONNULL_END
