//
//  RPCoreDataGetOperation.h
//  rework-password
//
//  Created by 张超 on 2019/1/8.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPCoreDataGetOperation : NSOperation

@property (nonatomic, strong) Class getClass;

/**
 default NO
 */
@property (nonatomic, assign) BOOL onlyFirst;

/**
 default NO
 仅获取数量
 只获取数量时，约束条件仅对predicte有效。
 */
@property (nonatomic, assign) BOOL onlyGetCount;

@property (nonatomic, strong) NSString* queryProperty;
@property (nonatomic, strong) id queryValue;
@property (nonatomic, strong) NSString* sortKey;

/**
 default YES
 */
@property (nonatomic, assign) BOOL asc;

@property (nonatomic, strong) NSPredicate* predicate;
@property (nonatomic, strong) void (^queryBlock)(id __nullable data,NSError* __nullable e);

- (void)runAtMainQuene;

@property (nullable, readonly, retain) id result;

@end

NS_ASSUME_NONNULL_END
