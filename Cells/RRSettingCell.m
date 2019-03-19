//
//  RRSettingCell.m
//  rework-reader
//
//  Created by 张超 on 2019/2/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSettingCell.h"
#import "RRModelItem.h"

@implementation RRSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadModel:(RRSetting*)item
{
    self.titleLabel.text = item.title;
    if ([item.type intValue] == 1) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([item.type integerValue] != RRSettingTypeSubSetting) {
        self.subLabel.text = item.value;
    }
    else {
        self.subLabel.text = @"";
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}


@end
