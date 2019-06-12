//
//  RRReadStyle.m
//  rework-reader
//
//  Created by 张超 on 2019/2/22.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRReadStyle.h"
@import DateTools;
@import oc_string;
@implementation RRReadStyle

- (void)setFeed:(EntityFeedInfo *)feed
{
    _feed = feed;
    if (feed.useachieve) {
        self.onlyUnread = YES;
    }
}

- (void)setFeeds:(NSSet<EntityFeedInfo *> *)feeds
{
    _feeds = feeds;
    __block BOOL useAchieve = YES;
    [feeds enumerateObjectsUsingBlock:^(EntityFeedInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        useAchieve = useAchieve && obj.useachieve;
    }];
    if (useAchieve) {
        self.onlyUnread = YES;
    }
}

- (instancetype)initWithEntity:(EntityFeedStyle*)style;
{
    self = [super init];
    if (self) {
        self.title = style.title;
        self.feeds = style.feeds;
        self.daylimit = style.dayLimit;
        self.onlyUnread = style.unread;
        self.liked = style.liked;
        self.countlimit = style.countLimit;
        self.keyword = style.keyword;
    }
    return self;
}

- (NSArray<NSSortDescriptor*>*)sort
{
    NSSortDescriptor* d1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSSortDescriptor* d2 = [[NSSortDescriptor alloc] initWithKey:@"updateTime" ascending:NO];
    NSSortDescriptor* d3 = [[NSSortDescriptor alloc] initWithKey:@"likedTime" ascending:NO];
    NSSortDescriptor* d4 = [[NSSortDescriptor alloc] initWithKey:@"lastread" ascending:NO];
    NSSortDescriptor* d5 = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:NO];
    NSSortDescriptor* d6 = [[NSSortDescriptor alloc] initWithKey:@"readlatertime" ascending:NO];
    
    if (self.feed) {
        return @[d5,d1,d2];
    }
    else {
        if (self.onlyReaded) {
            return @[d4];
        }
        if (self.liked) {
            return @[d3];
        }
        if (self.readlater) {
            return @[d6];
        }
    }
    return @[d1,d5];
}


- (NSPredicate *)predicate
{
    if (self.keyword) {
        NSString* pre = [self.keyword stringByReplacingOccurrencesOfString:@" " withString:@","];
        NSArray* all = [pre componentsSeparatedByString:@","];
        all = all.map(^id _Nonnull(id  _Nonnull x) {
           
            NSString * q = [NSString stringWithFormat:@"title like[c] '*%@*' or summary like[c] '*%@*' or content like[c] '*%@*'",x,x,x];
            NSPredicate* p = [NSPredicate predicateWithFormat:q];
            return p;
        });
//        NSLog(@"%@ %@",p,self.keyword);
        
        NSCompoundPredicate* c = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:all];
        return c;
    }
    
    if (self.feed) {
        if (self.onlyUnread) {
            return [NSPredicate predicateWithFormat:@"feed = %@ and readed = false",self.feed];
        }
        else if(self.onlyReaded)
        {
            if (self.withOutNotReadlyRead) {
                return [NSPredicate predicateWithFormat:@"feed = %@ and readed = true and lastread != nil",self.feed];
            }
            else{
                return [NSPredicate predicateWithFormat:@"feed = %@ and readed = true",self.feed];
            }
            
        }
        else if(self.liked)
        {
            return [NSPredicate predicateWithFormat:@"feed = %@ and liked = true",self.feed];
        }
        return [NSPredicate predicateWithFormat:@"feed = %@",self.feed];
    }
    else {
        NSMutableString* m = [[NSMutableString alloc] init];
        if (self.feeds && self.feeds.count > 0) {
            [m appendString:@"("];
            [self.feeds enumerateObjectsUsingBlock:^(EntityFeedInfo*  _Nonnull obj, BOOL * _Nonnull stop) {
                if (m.length > 1) {
                    [m appendString:@" || "];
                }
                [m appendFormat:@"feed.uuid = '%@'",obj.uuid];
            }];
            [m appendString:@")"];
        }
        if (self.readlater) {
            return [NSPredicate predicateWithFormat:@"readlater = true"];
        }
        if (self.onlyUnread) {
            if (m.length != 0) {
                [m appendString:@" && "];
            }
            [m appendString:@"readed = false"];
           
        }
        if (self.onlyReaded) {
            if (m.length != 0) {
                [m appendString:@" && "];
            }
            [m appendString:@"readed = true"];
            if (self.withOutNotReadlyRead) {
                [m appendString:@"&& lastread != nil"];
            }
        }
        if (self.liked) {
            if (m.length != 0) {
                [m appendString:@" && "];
            }
            [m appendString:@"liked = true"];
        }
        if (self.daylimit > 0) {
            if (m.length != 0) {
                [m appendString:@" && "];
            }
            NSDate* d = [[NSDate date] dateBySubtractingDays:self.daylimit-1];
            [m appendFormat:@"date > %%@"];
            NSPredicate * pp = [NSPredicate predicateWithFormat:m,d];
            return pp;
        }
                NSLog(@"%@",m);
        return [NSPredicate predicateWithFormat:m];
    }
    return [NSPredicate predicateWithFormat:@"feed = %@",self.feed];
}

@end
