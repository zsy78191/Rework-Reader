//
//  RRWebSettingInputer.m
//  rework-reader
//
//  Created by 张超 on 2019/3/7.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRWebSettingInputer.h"
#import "RRIconSettingModel.h"

@implementation RRWebSettingInputer

- (NSString *)mvp_identifierForModel:(id<MVPModelProtocol>)model
{
    RRIconSettingModel* m = model;
    if (m.isTitle) {
        return @"titleCell";
    }
    return @"iconCell";
}

@end
