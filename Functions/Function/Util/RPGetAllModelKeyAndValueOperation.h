//
//  RPGetAllModelKeyAndValueOperation.h
//  rework-password
//
//  Created by 张超 on 2019/1/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPGetAllModelKeyAndValueOperation : NSOperation

@property (nonatomic, strong) NSArray* allModels;
@property (nonatomic, strong) NSArray* getKeys;

@property (nonatomic, strong) NSDictionary* result;
@property (nonatomic, strong) NSArray* originSortResult;


/**
 反向取值
 */
@property (nonatomic, assign) BOOL reverse;

/**
 获取Model而不是Value，default is NO
 */
@property (nonatomic, assign) BOOL getModel;

@end

NS_ASSUME_NONNULL_END
