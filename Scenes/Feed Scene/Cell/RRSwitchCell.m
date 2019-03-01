//
//  RRSwitchCell.m
//  rework-reader
//
//  Created by 张超 on 2019/2/15.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSwitchCell.h"
#import "RRFeedInfoModel.h"

@interface RRSwitchCell ()
{
    
}
@property (nonatomic, weak) id<MVPModelProtocol> model;
@end

@implementation RRSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [[self opener] addTarget:self action:@selector(actionSwitch:) forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadModel:(id<MVPModelProtocol>)model
{
    [super loadModel:model];
    RRFeedInfoModel* m = model;
    self.titleLabel.text = m.title;
//    self.subLabel.text = m.value;
//    self.opener.on = [m.switchValue boolValue];
    [self mvp_bindModel:model withProperties:@[@"switchValue",@"value"]];
}

- (void)mvp_value:(id)value updateForKeypath:(NSString *)keypath
{
    if ([keypath isEqualToString:@"switchValue"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.opener setOn:[value boolValue]];
        });
    }
    else if([keypath isEqualToString:@"value"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.subLabel.text = value;
            [self.subLabel sizeToFit];
        });
    }
}

- (void)actionSwitch:(UISwitch*)sender
{
    RRFeedInfoModel* m = self.model;
    m.switchValue = @(sender.on);
}
@end
