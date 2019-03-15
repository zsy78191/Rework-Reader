//
//  RRBtnCell.m
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRBtnCell.h"
#import "RRAddModel.h"
@implementation RRBtnCell

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
   
    if ([model isKindOfClass:[RRAddModel class]]) {
        RRAddModel* m = model;
        self.btnLabel.text = m.title;
    }
}

@end
