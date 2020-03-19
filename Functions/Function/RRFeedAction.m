//
//  RRFeedAction.m
//  rework-reader
//
//  Created by 张超 on 2019/2/25.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedAction.h"
#import "RRCoreDataModel.h"
#import "RPDataManager.h"
#import "RRFeedArticleModel.h"
@import oc_base;
@import oc_util;
@import ui_base;
@import oc_string;
@import SDWebImage;
@import RegexKitLite;
//@import Fork_MWFeedParser;
#import "MWFeedInfo.h"
#import "MWFeedItem.h"
@import MagicalRecord;
@import WebKit;

@implementation RRFeedAction

+ (void)markFeedAsEnable:(BOOL)enable feedUUID:(NSString *)uuid
{
    NSDictionary* kv = @{@"lastUpdateResult":@(enable)};
    [[RPDataManager sharedManager] updateClass:@"EntityFeedInfo" queryKey:@"uuid" queryValue:uuid keysAndValues:kv modify:^id _Nonnull(id  _Nonnull key, id  _Nonnull value) {
        return value;
    } finish:^(__kindof NSManagedObject * _Nonnull obj, NSError * _Nonnull e) {
    }];
}



+ (void)likeArticle:(BOOL)like withUUID:(NSString *)uuid block:(nonnull void (^)(NSError * _Nonnull))finished
{
    NSDictionary* kv = @{@"liked":@(like),@"likedTime":like?[NSDate date]:[NSNull null]};
    [[RPDataManager sharedManager] updateClass:@"EntityFeedArticle" queryKey:@"uuid" queryValue:uuid keysAndValues:kv modify:^id _Nonnull(id  _Nonnull key, id  _Nonnull value) {
        return value;
    } finish:^(__kindof NSManagedObject * _Nonnull obj, NSError * _Nonnull e) {
        if (finished) {
            finished(e);
        }
    }];
}

+ (void)readLaterArticle:(BOOL)readerLater withUUID:(NSString *)uuid block:(void (^)(NSError * _Nonnull))finished
{
    NSDictionary* kv = @{@"readlater":@(readerLater)};
    if (readerLater) {
        kv = @{@"readlater":@(readerLater),@"readlatertime":[NSDate date]};
    }
    [[RPDataManager sharedManager] updateClass:@"EntityFeedArticle" queryKey:@"uuid" queryValue:uuid keysAndValues:kv modify:^id _Nonnull(id  _Nonnull key, id  _Nonnull value) {
        return value;
    } finish:^(__kindof NSManagedObject * _Nonnull obj, NSError * _Nonnull e) {
        if (finished) {
            finished(e);
        }
    }];
}

+ (void)_insert:(id)obj keys:(NSArray*)k feed:(EntityFeedInfo*)info context:(NSManagedObjectContext*)c
{
    [[RPDataManager sharedManager] insertClass:@"EntityFeedArticle" model:obj keys:k context:c modify:^id _Nonnull(id  _Nonnull key, id  _Nonnull value) {
        if ([key isEqualToString:@"date"] || [key isEqualToString:@"updateTime"]) {
            return [obj valueForKey:key];
        }
        
        if ([key isEqualToString:@"enclosures"]) {
            if (value) {
                NSData* d =  [NSJSONSerialization dataWithJSONObject:value options:kNilOptions error:nil];
                return [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
            }
            return nil;
        }
        else if([key isEqualToString:@"categories"])
        {
            if ([value isKindOfClass:[NSArray class]]) {
                return [(NSArray*)value componentsJoinedByString:@","];
            }
            return nil;
        }
        else if([key isEqualToString:@"feed"])
        {
            return info;
        }
        return value;
    } finish:^(__kindof NSManagedObject * _Nonnull obj, NSError * _Nonnull e) {
        
    }];
}

+ (NSInteger)exist:(id)obj feed:(EntityFeedInfo*)info;
{
    RRFeedArticleModel* m = obj;
    // FIXED: 这里很奇怪，判断条件顺序变化，会导致结果变化
    // 修改Predicate，优化重复判断条件
//    NSPredicate * p = [NSPredicate predicateWithFormat:@"(title = %@ or link = %@) and feed.uuid = %@",m.title,m.link,info.uuid];
    NSPredicate* p1  =[NSPredicate predicateWithFormat:@"title = %@",m.title];
    NSPredicate* p2  =[NSPredicate predicateWithFormat:@"link = %@",m.link];
    NSPredicate* p3  =[NSPredicate predicateWithFormat:@"identifier = %@",m.identifier];
    
    NSCompoundPredicate* c1 = m.identifier? [NSCompoundPredicate orPredicateWithSubpredicates:@[p1,p2,p3]]: [NSCompoundPredicate orPredicateWithSubpredicates:@[p1,p2]];
    
    
    NSPredicate* p4 = [NSPredicate predicateWithFormat:@"feed.uuid = %@",info.uuid];
    
    NSCompoundPredicate* c2 = [NSCompoundPredicate andPredicateWithSubpredicates:@[c1,p4]];
//    //NSLog(@"%@",c2);
    
    NSNumber* c = [[RPDataManager sharedManager] getCount:@"EntityFeedArticle" predicate:c2 key:nil value:nil sort:nil asc:YES];
    return [c integerValue];
}

+ (NSInteger)existFeed:(MWFeedInfo*)info
{
    NSPredicate* p = [NSPredicate predicateWithFormat:@"url = %@",info.url];
    NSNumber* c = [[RPDataManager sharedManager] getCount:@"EntityFeedInfo" predicate:p key:nil value:nil sort:nil asc:YES];
    return [c integerValue];
}


+ (void)preloadImages:(NSString *)uuid
{
    return;
    EntityFeedArticle* a = [[RPDataManager sharedManager] getFirst:@"EntityFeedArticle" predicate:nil key:@"uuid" value:uuid sort:nil asc:YES];
    [[self class] preloadEntityImages:a];
}

+ (void)showCookie
{
    WKWebsiteDataStore* store = [WKWebsiteDataStore defaultDataStore];
    [store.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *  _Nonnull a) {
        [a enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //NSLog(@"%@",obj);
        }];
    }];
}

+ (void)pre
{
//    WKWebsiteDataStore* store = [WKWebsiteDataStore defaultDataStore];
}

+ (void)preloadEntityImages:(EntityFeedArticle *)article
{
    return;
    NSString* temp = article.content.length>30?article.content:article.summary;
    NSArray* imgs = [temp componentsMatchedByRegex:@"(?<=<img).*?(?=\\>)"];
    [imgs enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* url = [obj componentsMatchedByRegex:@"(?<=src=\").*?(?=\")"].firstObject;
        if (!url) {
            url = [obj componentsMatchedByRegex:@"(?<=data-original=\").*?(?=\")"].firstObject;
        }
//        ////NSLog(@"11 %@",url);
        if ([url hasPrefix:@"//"]) {
            url = [@"http:" stringByAppendingString:url];
        }
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
        }];
    }];
}



+ (void)insertArticle:(NSArray*)article withFeed:(EntityFeedInfo*)info finish:(void (^)(NSUInteger))finish
{
    NSArray* copy = [article copy];
    @try {
        article = [[self class] removeSame:article];
    } @catch (NSException *exception) {
        article = copy;
    } @finally {
        
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        __block NSUInteger c = 0;
        [article enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray* ps = [[obj ob_propertys] mutableCopy];
            [ps removeObject:@"feedEntity"];
            NSUInteger i = [RRFeedAction exist:obj feed:info];
            if (i == 0) {
                c++;
//                //NSLog(@"添加 %@",[obj title]);
                [RRFeedAction _insert:obj keys:ps feed:info context:localContext];
            }
            else {
//                //NSLog(@"%@ | %@ | %@  有 %@",[obj title],[obj link],[obj identifier],@(i));
            }
        }];
        if (finish) {
//            NSError*e;
//            [rc save:&e];
//            if (e) {
//                //NSLog(@"%@",e);
//            }
            finish(c);
        }
    }];
    ////NSLog(@"一共增加%ld篇文章",c);
}

+ (void)insertFeedInfo:(MWFeedInfo*)info finish:(void (^)(void))finish
{
    NSInteger count = [[self class] existFeed:info];
    if(count > 0)
    {
        if (finish) {
            finish();
        }
    }
    else {
        NSMutableDictionary* d = [NSMutableDictionary dictionary];
        [[info ob_propertys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [info valueForKey:obj];
            if (value) {
                [d setObject:value forKey:obj];
            }
        }];
        if ([d valueForKey:@"ttl"]) {
            [d setValue:@(YES) forKey:@"usettl"];
        }
        else
        {
            [d setValue:@(NO) forKey:@"usettl"];
        }
        NSDate* ddate = [d valueForKey:@"lastBuildDate"];
        if (ddate) {
//            //NSLog(@"%@",@([ddate timeIntervalSinceNow]));
            if ([ddate timeIntervalSinceNow] > -3600*24*3) {
                [d setObject:@(YES) forKey:@"useautoupdate"];
            }
            else {
                [d setObject:@(NO) forKey:@"useautoupdate"];
            }
        }
        else {
            [d setObject:@(NO) forKey:@"useautoupdate"];
        }
        [d setObject:@(NO) forKey:@"usesafari"];
        NSDate* ddd = [d valueForKey:@"lastBuildDate"]?[d valueForKey:@"lastBuildDate"]:[d valueForKey:@"pubDate"];
        if (ddd) {
            [d setObject:ddd forKey:@"updateDate"];
        }
        [d removeObjectForKey:@"lastBuildDate"];
        [d removeObjectForKey:@"pubDate"];
        [[RPDataManager sharedManager] insertClass:@"EntityFeedInfo" keysAndValues:d modify:^id _Nonnull(id  _Nonnull key, id  _Nonnull value) {
            return value;
        } finish:^(__kindof NSManagedObject * _Nonnull obj, NSError * _Nonnull e) {
            if (finish) {
                finish();
            }
        }];
    }
}

+ (void)insertArticle:(NSArray*)article finish:(void (^)(NSUInteger))finish
{
//    //NSLog(@"Before %@",@(article.count));
    NSArray* copy = [article copy];
    @try {
        article = [[self class] removeSame:article];
    } @catch (NSException *exception) {
        article = copy;
    } @finally {
        
    }
//    //NSLog(@"After %@",@(article.count));
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        __block NSUInteger c = 0;
        [article enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray* ps = [[obj ob_propertys] mutableCopy];
            id info = [obj valueForKey:@"feedEntity"];
            [ps removeObject:@"feedEntity"];
            NSUInteger i = [RRFeedAction exist:obj feed:info];
            if (i == 0) {
                c++;
                [RRFeedAction _insert:obj keys:ps feed:info context:localContext];
            }
        }];
        if (finish) {
            finish(c);
        }
    }];
    ////NSLog(@"一共增加%ld篇文章",c);
}

//插入数据库前先做一次排重
+ (NSArray*)removeSame:(NSArray*)article
{
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithCapacity:10];
    article = [article filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EntityFeedArticle*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
//        //NSLog(@"%@",evaluatedObject);
//        //NSLog(@"%@",bindings);
        NSString* title = evaluatedObject.title?evaluatedObject.title:@"";
        if (!evaluatedObject.link) {
            //NSLog(@"No link %@ %@",evaluatedObject.title,evaluatedObject.feed);
        }
        NSString* key = [title stringByAppendingString:evaluatedObject.link?evaluatedObject.link:@""]._md5String;
        if (!key) {
            return NO;
        }
        if (d[key]) {
            return NO;
        }
        d[key] = @(1);
        return YES;
    }]];
    return article;
}

+ (void)readArticle:(NSString *)articleUUID
{
    [[self class] readArticle:articleUUID onlyMark:NO];
}

+ (void)readArticle:(NSString *)articleUUID onlyMark:(BOOL)onlymark
{
    NSDictionary* kv = @{@"lastread":[NSDate date],@"readed":@(YES)};
    if (onlymark) {
        kv = @{@"readed":@(YES)};
    }
    [[RPDataManager sharedManager] updateClass:@"EntityFeedArticle" queryKey:@"uuid" queryValue:articleUUID keysAndValues:kv modify:^id _Nonnull(id  _Nonnull key, id  _Nonnull value) {
        return value;
    } finish:^(__kindof NSManagedObject * _Nonnull obj, NSError * _Nonnull e) {
        if (e) {
            ////NSLog(@"%s %@",__func__,e);
        }
        ////NSLog(@"%@",obj);
    }];
}

+ (void)recordArticle:(NSString*)articleUUID position:(CGFloat)position;
{
    NSString* key = [NSString stringWithFormat:@"POS_%@",articleUUID];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MVCKeyValue setFloat:position forKey:key];
    });
}

+ (CGFloat)loadPositionWithArticle:(NSString*)articleUUID;
{
    NSString* key = [NSString stringWithFormat:@"POS_%@",articleUUID];
    return [MVCKeyValue getFloatforKey:key];
}

+ (void)delFeed:(EntityFeedInfo*)info view:(nonnull UIViewController *)view item:(id)sender arrow:(UIPopoverArrowDirection)arrow finish:(nonnull void (^)(void))finishBlock
{
    NSSet* s = [info.articles filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"liked = YES"]];
    NSString* m = [NSString stringWithFormat:@"共有%ld篇文章",info.articles.count];
    if (s.count > 0) {
        m = [NSString stringWithFormat:@"共有%ld篇文章，其中有%ld篇收藏不会删除",info.articles.count,s.count];
    }
    
    UIAlertController* alert =
    UI_ActionSheet();
    if (!sender) {
        alert = UI_Alert();
    }
    alert
    .titled([NSString stringWithFormat:@"确认删除「%@」?",info.title])
    .descripted(m)
    .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
        
    })
    .recommend(@"删除", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [RRFeedAction delFeedInfo:info view:view finish:finishBlock];
    });
    
    if ([UIDevice currentDevice].iPad()) {
        if (sender) {
              [view showAsProver:alert view:[view view] item:sender arrow:arrow];
        }
        else {
            alert.show(view);
        }
    }
    else {
        alert.show(view);
    }
}



+ (void)delFeedInfo:(EntityFeedInfo*)info view:(UIViewController*)view  finish:(void (^)(void))finishBlock;
{
    // step 1 删除文章
 
    NSPredicate* p = [NSPredicate predicateWithFormat:@"feed = %@ and liked = NO",info];
    [[RPDataManager sharedManager] delData:@"EntityFeedArticle" predicate:p key:nil value:nil beforeDel:^BOOL(__kindof NSManagedObject * _Nonnull o) {
        return YES;
    } finish:^(NSUInteger count, NSError * _Nonnull e) {
        ////NSLog(@"delete %ld articles",count);
        if (!e) {
            [RRFeedAction delFeedInfoStep2:info view:view finish:finishBlock];
        }
    }];
}

+ (void)delFeedInfoStep2:(EntityFeedInfo*)info view:(UIViewController*)view  finish:(void (^)(void))finishBlock;
{
    // step 2 删除订阅源
    [[RPDataManager sharedManager] delData:info relationKey:nil beforeDel:^BOOL(__kindof NSManagedObject * _Nonnull o) {
        
        return YES;
    } finish:^(NSUInteger count, NSError * _Nonnull e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!e) {
                [view hudSuccess:@"删除成功"];
//                [view mvp_popViewController:nil];
                if (finishBlock) {
                    finishBlock();
                }
            }
            else {
                [view hudFail:@"删除失败"];
            }
        });
    }];
}

@end
