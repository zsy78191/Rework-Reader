//
//  RRTitleCell.m
//  rework-reader
//
//  Created by 张超 on 2019/2/15.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRTitleCell.h"
#import "RRFeedInfoModel.h"
#import "OPMLDocument.h"
@implementation RRTitleCell

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
    if ([model isKindOfClass:[OPMLOutline class]]) {
        OPMLOutline* o = model;
        self.titleLabel.text = o.title?o.title:o.text;
        return;
    }
    RRFeedInfoModel* m = model;
    self.titleLabel.text = m.title;
}


@end
