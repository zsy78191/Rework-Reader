
//
//  RRFeedInputer.m
//  rework-reader
//
//  Created by 张超 on 2019/2/13.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedInputer.h"
#import "RPDataManager.h"
#import "RRCoreDataModel.h"
#import "RRFeedInfoListModel.h"
#import "RRFeedInfoListOtherModel.h"
@import oc_string;

@implementation RRFeedInputer

- (NSString *)mvp_identifierForModel:(id<MVPModelProtocol>)model
{
    return @"feedCell";
}

- (void)mvp_moveModelFromIndexPath:(NSIndexPath *)path1 toPath:(NSIndexPath *)path2
{
    if (path1.section == path2.section) {
        [super mvp_moveModelFromIndexPath:path1 toPath:path2];
        [self recordSort];
    }
}

- (void)recordSort
{
    NSArray<RRFeedInfoListModel*>* all = [self allModels];
    
    [all enumerateObjectsUsingBlock:^(RRFeedInfoListModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.sort = @(idx);
    }];
    
    [[RPDataManager sharedManager] udpateDatas:@"EntityFeedInfo" models:all queryKey:@"uuid" saveKeys:@[@"sort"] modify:nil finish:nil];
}


@end
