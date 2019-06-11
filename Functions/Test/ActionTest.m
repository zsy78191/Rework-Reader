//
//  ActionTest.m
//  rework-reader
//
//  Created by 张超 on 2019/4/10.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "ActionTest.h"
#import "RRFeedAction.h"
#import "RRFeedManager.h"
@import oc_string;
#import "RRCoreDataModel.h"
@import MagicalRecord;
@implementation ActionTest

- (void)hub
{
//    [RRFeedAction pre];
    
    NSLog(@"%@", [RRFeedManager allHubs].map(^id _Nonnull(RRFeedHub*  _Nonnull x) {
        return x.name;
    }));
    [[RRFeedManager allHubs] enumerateObjectsUsingBlock:^(RRFeedHub * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSLog(@"%@",obj.feeds.map(^id _Nonnull(EntityFeedInfo*  _Nonnull x) {
            return x.title;
        }));
    }];
    
    [[EntityFeedInfo MR_findAll] enumerateObjectsUsingBlock:^(__kindof EntityFeedInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",[obj.hub anyObject].title);
    }];
}

- (void)test
{
    UIAccessibilityElement* a;
}

@end
