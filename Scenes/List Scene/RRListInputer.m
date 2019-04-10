//
//  RRListInputer.m
//  rework-reader
//
//  Created by 张超 on 2019/2/22.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRListInputer.h"
#import "RRCoreDataModel.h"


@import DateTools;


@implementation RRListInputer

- (Class)mvp_modelClass
{
    return NSClassFromString(@"EntityFeedArticle");
}

- (NSArray<NSSortDescriptor *> *)sortDescriptors
{
    if (self.model.readStyle) {
        return [self.model.readStyle sort];
    }
    
    NSSortDescriptor* d1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSSortDescriptor* d0 = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
//    NSSortDescriptor* d2 = [[NSSortDescriptor alloc] initWithKey:@"updateTime" ascending:NO];
    return @[d1,d0];
}

- (NSPredicate *)predicate
{
    if (self.style) {
        return [self.style predicate];
    }
    if (self.model) {
        self.model.readStyle.feed = self.feed;
        self.style = self.model.readStyle;
        return [self.model.readStyle predicate];
    }
    else if(self.feed){
        RRReadStyle* s = [[RRReadStyle alloc] init];
        self.style = s;
        s.feed = self.feed;
        return [s predicate];
    }
    return nil;
}

- (NSUInteger)fetchLimitCount
{
    if(self.model)
    {
        return self.model.readStyle.countlimit;
    }
    return 0;
}

- (NSString *)mvp_identifierForModel:(id<MVPModelProtocol>)model
{
    return @"articleCell";
}



@end
