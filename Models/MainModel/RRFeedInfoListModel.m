//
//  RRFeedInfoListModel.m
//  rework-reader
//
//  Created by 张超 on 2019/2/21.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedInfoListModel.h"
#import "RRCoreDataModel.h"
@import oc_base;

@implementation RRFeedInfoListModel

- (void)loadFromFeed:(EntityFeedInfo *)feed
{
    NSArray* a = [feed ob_propertys];
    [[self ob_propertys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([a containsObject:obj]) {
            id v = [feed valueForKeyPath:obj];
            if (v) {
                [self setValue:v forKeyPath:obj];
            }
        }
    }];
}

@synthesize canEdit = _canEdit;

- (void)removeFromInputer
{
    [super removeFromInputer];
    
    
}

@end
