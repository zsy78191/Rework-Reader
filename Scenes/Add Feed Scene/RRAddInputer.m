//
//  RRAddInputer.m
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRAddInputer.h"
#import "RRAddModel.h"
@implementation RRAddInputer

- (NSString *)mvp_identifierForModel:(id<MVPModelProtocol>)model
{
    if ([model isKindOfClass:[RRAddModel class]]) {
        RRAddModel* m = model;
        switch (m.type) {
            case RRAddModelTypeInput:
                return @"inputCell";
                break;
            case RRAddModelTypeInfo:
                break;
            case RRAddModelTypeSwitch:
                return @"switchCell";
                break;
            case RRAddModelTypeBtn:
                return @"buttonCell";
                break;
            case RRAddModelTypeTitle:
                return @"titleCell";
                break;
            default:
                break;
        }
    }
    return @"cell";
}

@end
