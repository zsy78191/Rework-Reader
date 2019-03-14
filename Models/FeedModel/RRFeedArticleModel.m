//
//  RRFeedArticleModel.m
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedArticleModel.h"
#import "RRCoreDataModel.h"

//@property (nonatomic, copy) NSString *identifier;
//@property (nonatomic, copy) NSString *title;
//@property (nonatomic, copy) NSString *link;
//@property (nonatomic, copy) NSDate *date;
//@property (nonatomic, copy) NSDate *updated;
//@property (nonatomic, copy) NSString *summary;
//@property (nonatomic, copy) NSString *content;
//@property (nonatomic, copy) NSString *author;
//@property (nonatomic, copy) NSArray *enclosures;

@implementation RRFeedArticleModel

- (instancetype)initWithItem:(MWFeedItem *)item
{
    self = [super init];
    if (self) {
        self.title = item.title;
        self.identifier = item.identifier;
        self.link = item.link;
        self.date = item.date;
        self.updateTime = item.updated;
        self.summary = item.summary;
        self.content = item.content;
        self.author = item.author;
        self.enclosures = item.enclosures;
        self.categories = item.categories;
        self.readed = NO;
        self.liked = NO;
    }
    return self;
}

- (instancetype)initWithEntity:(EntityFeedArticle*)article
{
    self = [super init];
    if (self) {
        self.title = article.title;
        self.identifier = article.identifier;
        self.link = article.link;
        self.date = article.date;
        self.updateTime = article.updateTime;
        self.summary = article.summary;
        self.content = article.content;
        self.author = article.author;
        self.readed = article.readed;
        self.readlater = article.readlater;
        if (article.enclosures) {
            NSData* d = [article.enclosures dataUsingEncoding:NSUTF8StringEncoding];
            self.enclosures = [NSJSONSerialization JSONObjectWithData:d options:kNilOptions error:nil];
        }
//        self.enclosures =
        if (article.categories) {
            self.categories = [article.categories componentsSeparatedByString:@","];
        }
        self.feedEntity = article.feed;
        self.uuid = article.uuid;
        self.liked = article.liked;
        self.lastread = article.lastread;
    }
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"%@ %@ %@",self.title,self.date,self.updateTime];
}

@end
