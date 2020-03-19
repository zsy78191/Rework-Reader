//
//  RRIconSettingCell.m
//  rework-reader
//
//  Created by 张超 on 2019/3/7.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRIconSettingCell.h"
#import "RRIconSettingModel.h"
@import Classy;
@implementation RRIconSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadModel:(RRIconSettingModel*)model
{
    self.textLabel.text = model.title;
    if (model.icon) {
        self.imageView.image = [UIImage imageNamed:model.icon];
    }
    else {
        self.imageView.image = [UIImage new];
    }
    if (model.fontStyle) {
        [self.textLabel setCas_styleClass:model.fontStyle];
    }
   
//    [self.textLabel cas_setNeedsUpdateStyling];
    self.detailTextLabel.text = model.subtitle;
    
    ////NSLog(@"%@",self.textLabel.cas_styleClass);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.textLabel setCas_styleClass:@"MainLabel"];
//    [self.textLabel cas_setNeedsUpdateStyling];
}

@end
