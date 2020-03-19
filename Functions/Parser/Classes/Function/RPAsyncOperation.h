//
//  RPAsyncOperation.h
//  rework-password
//
//  Created by 张超 on 2019/1/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RPAsyncOperationStateReady = 0,
    RPAsyncOperationStateExecuting,
    RPAsyncOperationStateFinished,
} RPAsyncOperationState;

@interface RPAsyncOperation : NSOperation

@property (nonatomic, assign) RPAsyncOperationState state;

@end

NS_ASSUME_NONNULL_END
