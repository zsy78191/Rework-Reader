//
//  RPSettingInputer.m
//  rework-reader
//
//  Created by 张超 on 2019/2/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPSettingInputer.h"
#import "RRModelItem.h"
@implementation RPSettingInputer

- (NSString *)mvp_identifierForModel:(RRSetting*)model
{
    if ([model.type intValue] == RRSettingTypeTitle) {
        return @"titleCell";
    }
    else if([model.type intValue] == RRSettingTypeSwitch)
    {
        return @"switchCell";
    }
    return @"settingBaseCell";
}

@end
