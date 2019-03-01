//
//  RPDataNotificationCenter.m
//  rework-password
//
//  Created by 张超 on 2019/1/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPDataNotificationCenter.h"

@interface RPDataNotificationCenter ()
{
}
@property (nonatomic, strong) NSMapTable* table;
@end

@implementation RPDataNotificationCenter

+ (instancetype)defaultCenter
{
    static RPDataNotificationCenter* _g_defalut_center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _g_defalut_center = [[RPDataNotificationCenter alloc] init];
    });
    return _g_defalut_center;
}

- (NSMapTable *)table
{
    if (!_table) {
        _table = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:10];
    }
    return _table;
}

- (void)registEntityChange:(NSString *)entityClassName observer:(id)observer sel:(SEL)selector
{
    NSMapTable* t = [self.table objectForKey:entityClassName];
    if (!t) {
        t = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:10];
        [self.table setObject:t forKey:entityClassName];
    }
    [t setObject:NSStringFromSelector(selector) forKey:observer];
}

- (void)unregistEntityChange:(NSString *)entityClassName observer:(id)observer
{
    NSMapTable* t = [self.table objectForKey:entityClassName];
    [t removeObjectForKey:observer];
}

- (void)notificateWithEntityClass:(NSString *)entityClassName
{
    NSMapTable* t = [self.table objectForKey:entityClassName];
    NSEnumerator* e = [t keyEnumerator];
    id observer = [e nextObject];
    while (observer) {
        NSString* selectorName = [t objectForKey:observer];
        [self postObeserver:observer selector:NSSelectorFromString(selectorName)];
        observer = [e nextObject];
    }
}

- (void)postObeserver:(id)observer selector:(SEL)selector
{
    NSMethodSignature* s = [[observer class] instanceMethodSignatureForSelector:selector];
    NSAssert(s, @"%@ %@ is not exist",observer,NSStringFromSelector(selector));
    NSInvocation * i = [NSInvocation invocationWithMethodSignature:s];
    i.target = observer;
    i.selector = selector;
    [i invoke];
}

- (void)dealloc
{
    [self.table removeAllObjects];
}

@end
