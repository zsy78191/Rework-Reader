//
//  RPAsyncOperation.m
//  rework-password
//
//  Created by 张超 on 2019/1/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPAsyncOperation.h"

@interface RPAsyncOperation()
{
    
}
@property (nonatomic, strong) NSRecursiveLock* lock;
@end

@implementation RPAsyncOperation

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isExecuting
{
    return self.state == RPAsyncOperationStateExecuting;
}

- (BOOL)isFinished
{
    return self.state == RPAsyncOperationStateFinished;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.state = RPAsyncOperationStateReady;
        self.lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)setState:(RPAsyncOperationState)state
{
    [_lock lock];
//    [self willChangeValueForKey:@"state"];
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _state = state;
//    [self didChangeValueForKey:@"state"];
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
    [_lock unlock];
}

- (void)start
{
    if (self.isCancelled) {
        self.state = RPAsyncOperationStateFinished;
    }
    else {
        self.state = RPAsyncOperationStateReady;
        [self main];
    }
}

- (void)main
{
    if (self.isCancelled) {
        self.state = RPAsyncOperationStateFinished;
    }
    else {
        self.state = RPAsyncOperationStateExecuting;
    }
}

@end
