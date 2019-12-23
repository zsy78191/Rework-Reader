//
//  RRFeedReaderStyleInputer.m
//  rework-reader
//
//  Created by 张超 on 2019/2/21.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedReaderStyleInputer.h"
#import "RRFeedInfoListOtherModel.h"

@implementation RRFeedReaderStyleInputer

- (NSString *)mvp_identifierForModel:(id<MVPModelProtocol,RRCanEditProtocol>)model
{
    if ([model isKindOfClass:[RRFeedInfoListOtherModel class]]) {
        RRFeedInfoListOtherModel* m = model;
        switch (m.type) {
            case RRFeedInfoListOtherModelTypeTitle:
                return @"titleCell";
                break;
            case RRFeedInfoListOtherModelTypeItem:
                return @"styleCell";
                break;
            default:
                break;
        }
    }
    return @"cell";
}

- (NSMutableArray *)hideItem
{
    if (!_hideItem) {
        _hideItem = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return _hideItem;
}

- (void)hideModel:(id)model
{
    [self.hideItem addObject:model];
    //NSLog(@"hide %@",[model title]);
    [self mvp_deleteModel:model];
}

- (void)showAll{
    NSArray* a = [self allModels];
    //NSLog(@"%@",self.hideItem);
    [self.hideItem sortUsingComparator:^NSComparisonResult(    id<RRCanEditProtocol>  _Nonnull obj1,     id<RRCanEditProtocol>  _Nonnull obj2) {
        return obj2.idx > obj1.idx;
    }];
    
    [self.hideItem enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<RRCanEditProtocol> o1 = obj;
        [a enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop2) {
            id<RRCanEditProtocol> o2 = obj2;
//            //NSLog(@"insert %@",@(o2.idx));
            if (o2.idx > o1.idx) {
//                NSUInteger i = idx2 == 0 ? 0 : idx2 - 1;
                [self mvp_insertModel:obj atIndex:idx2];
                *stop2 = YES;
            }
        }];
    }];
    [self.hideItem removeAllObjects];
}

- (void)reset
{
    [self.hideItem removeAllObjects];
}

@end
