//
//  RRFeedInfoInputer.m
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedInfoInputer.h"
#import "RRFeedInfoModel.h"
@implementation RRFeedInfoInputer

- (NSString *)mvp_identifierForModel:(id<MVPModelProtocol>)model
{
    if ([model isKindOfClass:NSClassFromString(@"RRFeedArticleModel")]) {
        return @"articleCell";
    }
    else if([model isKindOfClass:[RRFeedInfoModel class]])
    {
        RRFeedInfoModel* m = model;
        switch (m.type) {
            case RRFeedInfoTypeText:
                return @"infoCell";
                break;
            case RRFeedInfoTypeSwitch:
                return @"switchCell";
                break;
            case RRFeedInfoTypeTitle:
                return @"titleCell";
                break;
            default:
                break;
        }
    }
    return @"infoCell";
}

@end
