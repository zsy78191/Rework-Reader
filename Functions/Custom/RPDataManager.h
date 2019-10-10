//
//  RPDataManager.h
//  rework-password
//
//  Created by 张超 on 2019/1/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPSortableItem.h"

@class NSManagedObject,NSManagedObjectContext;

NS_ASSUME_NONNULL_BEGIN

@interface RPDataManager : NSObject

+ (instancetype)sharedManager;

- (id)insertClass:(NSString*)className
            model:(id)model
             keys:(NSArray*)keys
           modify:(id (^ _Nullable)(id key,id value))modifyValue
           finish:(void (^ _Nullable)(__kindof NSManagedObject* obj, NSError* e))finish;

- (id)insertClass:(NSString*)className
            model:(id)model
             keys:(NSArray*)keys
          context:(nullable NSManagedObjectContext*)contenxt
           modify:(id (^ _Nullable)(id key,id value))modifyValue
           finish:(void (^ _Nullable)(__kindof NSManagedObject* obj, NSError* e))finish;

- (id)insertClass:(NSString*)className
    keysAndValues:(NSDictionary*)dict
           modify:(id (^ _Nullable)(id key,id value))modifyValue
           finish:(void (^ _Nullable)(__kindof NSManagedObject* obj, NSError* e))finish;

- (id)updateClass:(NSString*)className
         queryKey:(NSString*)key
       queryValue:(id)value
    keysAndValues:(NSDictionary*)dict
           modify:(id (^ _Nullable)(id key,id value))modifyValue
           finish:(void (^ _Nullable)(__kindof NSManagedObject* obj, NSError* e))finish;

- (id)updateClass:(NSString*)className
            model:(id)model
         queryKey:(NSString*)key
       queryValue:(id)value
             keys:(NSArray*)keys
           modify:(id (^ _Nullable)(id key,id value))modifyValue
           finish:(void (^ _Nullable)(__kindof NSManagedObject* obj, NSError* e))finish;

- (id)udpateDatas:(NSString*)className
           models:(NSArray*)models
         queryKey:(NSString*)key
         saveKeys:(NSArray*)savekeys
           modify:(id (^ _Nullable)(id key,id value))modifyValue
           finish:(void (^ _Nullable)(NSArray* results, NSError* e))finish;

- (id)updateDatas:(NSString*)className
        predicate:(NSPredicate* _Nullable )predicate
           modify:(void (^ _Nullable)(id obj))modify
           finish:(void (^ _Nullable)(NSArray* results, NSError* e))finish;

- (id)getFirst:(NSString*)className
     predicate:(NSPredicate* _Nullable )p
           key:(NSString* _Nullable )key
         value:(id _Nullable)value
          sort:(NSString* _Nullable )sort
           asc:(BOOL)asc;

- (id)getAll:(NSString*)className
   predicate:(NSPredicate* _Nullable )p
         key:(NSString* _Nullable )key
       value:(id _Nullable)value
        sort:(NSString* _Nullable )sort
         asc:(BOOL)asc;

- (id)getCount:(NSString*)className
     predicate:(NSPredicate* _Nullable )p
           key:(NSString* _Nullable )key
         value:(id _Nullable)value
          sort:(NSString* _Nullable )sort
           asc:(BOOL)asc;

- (void)delData:(NSString*)className
      predicate:(NSPredicate* _Nullable)predicate
            key:(NSString* _Nullable)key
          value:(id _Nullable)value
      beforeDel:(BOOL (^ _Nullable)(__kindof NSManagedObject*))beforeDel
         finish:(void (^ _Nullable)(NSUInteger count, NSError* e))finish;

- (void)delData:(__kindof NSManagedObject*)obj
    relationKey:(NSString* _Nullable)rkey
      beforeDel:(BOOL (^ _Nullable)(__kindof NSManagedObject*))beforeDel
         finish:(void (^ _Nullable)(NSUInteger count, NSError* e))finish;


- (NSDictionary*)dictionaryWithModels:(id)models
                              getKeys:(NSArray*)keys getModel:(BOOL)model;

- (NSDictionary*)dictionaryWithModels:(id)models
                       getWithoutKeys:(NSArray*)keys getModel:(BOOL)model;

- (NSArray*)arrayWithModels:(id)models getKeys:(NSArray*)keys;
- (NSArray*)arrayWithModels:(id)models getWithoutKeys:(NSArray*)keys;


- (NSArray<id<RPSortableItem>>*)sortItems:(NSArray<id<RPSortableItem>>*)items
                                  withKey:(NSString* _Nullable)key
                                      asc:(BOOL)asc
                             accordingIdx:(BOOL)aidx;

@end

NS_ASSUME_NONNULL_END
