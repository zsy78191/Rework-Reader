//
//  RRFeedManager.m
//  rework-reader
//
//  Created by 张超 on 2019/6/3.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedManager.h"
#import "RRCoreDataModel.h"
@import MagicalRecord;
@import oc_string;
@interface RRFeedHub ()
{
    
}

@property (nonatomic, strong) EntityHub* hub;
@end

@implementation RRFeedHub

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.hub = [EntityHub MR_findFirstOrCreateByAttribute:@"title" withValue:name inContext:[NSManagedObjectContext MR_rootSavingContext]];
        if (!self.hub.uuid) {
            self.hub.uuid = [NSUUID UUID].UUIDString;
        }
        self.hub.title = name;
    }
    return self;
}

+ (RRFeedHub *)hubWithEntity:(id)hub
{
    RRFeedHub* f = [[RRFeedHub alloc] init];
    f.hub = hub;
    return f;
}

+ (NSArray<RRFeedHub *> *)allHubs
{
    return [EntityHub MR_findAllSortedBy:@"sort" ascending:YES inContext:[NSManagedObjectContext MR_rootSavingContext]].map(^id _Nonnull(id  _Nonnull x) {
        return [RRFeedHub hubWithEntity:x];
    });
}

- (NSArray<EntityFeedInfo *> *)feeds
{
    if (!self.hub) {
        return @[];
    }
    return [self.hub.infos sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES]]];
}

- (NSString *)name
{
    return self.hub.title;
}

- (NSString *)icon
{
    return self.hub.icon;
}

- (RRFeedHub * _Nonnull (^)(NSString * _Nonnull))named
{
    return ^(NSString* name) {
        self.hub.title = name;
        return self;
    };
}

- (RRFeedHub * _Nonnull (^)(NSString * _Nonnull))icond
{
    return ^(NSString* icon) {
        self.hub.icon = icon;
        return self;
    };
}

- (RRFeedHub * _Nonnull (^)(EntityFeedInfo * _Nonnull))insertFeed
{
    return ^(EntityFeedInfo* feed) {
        [self.hub addInfosObject:feed];
        return self;
    };
}

- (RRFeedHub * _Nonnull (^)(NSArray<EntityFeedInfo *> * _Nonnull))insertFeeds
{
    return ^(NSArray* feeds) {
        [self.hub addInfos:[NSSet setWithArray:feeds]];
        return self;
    };
}

- (RRFeedHub * _Nonnull (^)(EntityFeedInfo * _Nonnull))removeFeed
{
    return ^(EntityFeedInfo* feed) {
        [self.hub removeInfosObject:feed];
        return self;
    };
}

- (RRFeedHub * _Nonnull (^)(void (^ _Nonnull)(BOOL)))save
{
    return ^ (void (^ finish)(BOOL)) {
//
        [[self.hub managedObjectContext] MR_saveOnlySelfWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
            if (finish) {
                finish(contextDidSave);
            }
        }];
        return self;
    };
}

@end

@implementation RRFeedManager

+ (RRFeedHub*)hubWithName:(NSString*)name;
{
    return [[RRFeedHub alloc] initWithName:name];
}

+ (NSArray<RRFeedHub*>*)allHubs;
{
    return [RRFeedHub allHubs];
}

+ (void)removeAllHUBs
{
    [[NSManagedObjectContext MR_rootSavingContext] MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [EntityHub MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"1 > 0"] inContext:localContext];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        if (contextDidSave) {
            NSLog(@"remove all hubs");
        }
        else {
            NSLog(@"%@ %@",error,@(contextDidSave));
        }
    }];
}

+ (void)removeHUB:(EntityHub*)hub complete:(void (^)(BOOL))complete;
{
    [[NSManagedObjectContext MR_rootSavingContext] MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
//        EntityHub* hub = [hub MR_inContext:localContext];
        [hub MR_deleteEntityInContext:localContext];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        if (complete) {
            complete(contextDidSave);
        }
        if (contextDidSave) {
            NSLog(@"remove the hub");
        }
        else {
            NSLog(@"%@ %@",error,@(contextDidSave));
        }
    }];
}

@end
