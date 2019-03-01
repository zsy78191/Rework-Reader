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
                return @"feedCell";
                break;
            default:
                break;
        }
    }
    return @"cell";
}


@end
