//
//  RPCoreDataInsertOperation.m
//  rework-password
//
//  Created by 张超 on 2019/1/9.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPCoreDataInsertOperation.h"
#import <ObjC/Runtime.h>
@import MagicalRecord;
@import oc_util;

@implementation RPCoreDataInsertOperation

- (void)main
{
    if (!self.insertClass) {
        //NSLog(@"%@ need set class",self);
        return;
    }
    
    Class a = self.insertClass;
    BOOL needSave = !self.context;
    
    if (self.predicate) {
        NSManagedObjectContext* c = self.context?self.context:[NSManagedObjectContext MR_rootSavingContext];
        NSArray* aaa = [(id)a MR_findAllWithPredicate:self.predicate inContext:c];
        [aaa enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.modify) {
                self.modify(obj);
            }
        }];
        NSError* e;
        if (needSave) {
            [c save:&e];
        }
        if (self.finishesBlock) {
            self.finishesBlock(aaa, e);
        }
        return;
    }
    
    if (self.models) {
        NSManagedObjectContext* c = self.context?self.context:[NSManagedObjectContext MR_rootSavingContext];
        NSMutableArray* aa = [NSMutableArray arrayWithCapacity:10];
        [self.models enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSManagedObject* ca = [(id)a MR_findFirstByAttribute:self.queryKey withValue:[obj valueForKey:self.queryKey] inContext:c];
            if (!ca) {
                ca = [obj MR_inContext:c];
            }
            if (ca) {
                [self.saveKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
                    [ca setValue:[obj valueForKey:obj2] forKey:obj2];
                }];
            }
            [aa addObject:ca];
        }];
        NSError* e;
        if (needSave) {
            [c save:&e];
        }
 
        self.results = [aa copy];
        
        if (self.finishesBlock) {
            self.finishesBlock(self.results, e);
        }
        return;
    }

    NSManagedObjectContext* context = self.context?self.context:[NSManagedObjectContext MR_rootSavingContext];
    BOOL addNew = YES;
    __kindof NSManagedObject* cd = nil;
    if (self.queryKey) {
        addNew = NO;
        cd = [(id)a MR_findFirstByAttribute:self.queryKey withValue:self.queryValue inContext:context];
    }
    else {
        cd = [(id)a MR_createEntityInContext:context];
    }
    
    NSMutableArray* p = [[self propertysWithClass:a] mutableCopy];
    
    [self.saveKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
 
        id value = [self.model valueForKey:obj];
        
        if (self.modifyValue) {
            value = self.modifyValue(obj,value);
        }
//        ////NSLog(@"set %@ %@",obj,value);
        if (value) {
            [p removeObject:obj];
//            ////NSLog(@"--) %@ %@",value,obj);
            if ([value isKindOfClass:[NSManagedObject class]]) {
                value = [value MR_inContext:context];
            }
            [cd setValue:value forKey:obj];
        }
       
    }];
    
    [self.keysAndValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id value = obj;
        if (self.modifyValue) {
            value = self.modifyValue(key,value);
        }
        [p removeObject:key];
        if (![value isKindOfClass:[NSNull class]]) {
//            ////NSLog(@"--) %@ %@",value,key);
            [cd setValue:value forKey:key];
        }
        else {
            [cd setValue:nil forKey:key];
        }
        
        
    }];
    
//    [cd setValue:@(i) forKey:@"sort"];
//    [cd setValue:[NSUUID UUID] forKey:@"uuid"];
  
    
    NSString* key = [NSString stringWithFormat:@"IDX_%@",[NSStringFromClass(a) uppercaseString]];

    __block NSUInteger i = -1;
    if ([NSThread isMainThread]) {
        i = [MVCKeyValue getIntforKey:key];
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            // 需要在主线程执行的代码
             i = [MVCKeyValue getIntforKey:key];
        });
    }
    
    if (addNew) {
       
        if ([[self.keysAndValues allKeys] containsObject:@"sort"]) {
            
        }
        else {
            if ([p containsObject:@"sort"]) {
                [cd setValue:@(i) forKey:@"sort"];
            }
        }
        
        if ([p containsObject:@"uuid"]) {
            [cd setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        }
        
        if ([p containsObject:@"uniqueIdentifier"]) {
            NSString* i = [NSProcessInfo processInfo].globallyUniqueString;
            [cd setValue:i forKey:@"uniqueIdentifier"];
        }
    }
    
    if (self.modifyValue) {
        [p enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [cd setValue:self.modifyValue(obj,[cd valueForKey:obj]) forKey:obj];
        }];
    }
    
    NSError* e;
    if (needSave) {
        [context save:&e];
    }
    
    if (!e && addNew) {
        if ([[self.keysAndValues allKeys] containsObject:@"sort"]) {
            
        }
        else {
            if ([p containsObject:@"sort"]) {
                if ([NSThread isMainThread]) {
                    [MVCKeyValue setInt:i+1 forKey:key];
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [MVCKeyValue setInt:i+1 forKey:key];
                    });
                }
            }
        }
    }
    
    self.result = cd;
    
    if (self.finishBlock) {
        self.finishBlock(cd, e);
    }
}

- (NSArray *)propertysWithClass:(Class)c
{
    unsigned int count = 0;
    //获取属性的列表
    objc_property_t *propertyList =  class_copyPropertyList(c, &count);
    NSMutableArray *propertyArray = [NSMutableArray array];
    for(int i=0;i<count;i++)
    {
        //取出每一个属性
        objc_property_t property = propertyList[i];
        //获取每一个属性的变量名
        const char* propertyName = property_getName(property);
        NSString *proName = [[NSString alloc] initWithCString:propertyName encoding:NSUTF8StringEncoding];
        [propertyArray addObject:proName];
    }
    //c语言的函数，所以要去手动的去释放内存
    free(propertyList);
    return propertyArray.copy;
}

@end
