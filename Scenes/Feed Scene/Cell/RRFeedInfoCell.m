//
//  RRFeedInfoCell.m
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedInfoCell.h"
#import "RRFeedInfoModel.h"

@implementation RRFeedInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
    self.valueLabel.text = m.value;
}

@end
