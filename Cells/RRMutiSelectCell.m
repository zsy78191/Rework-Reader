//
//  RRMutiSelectCell.m
//  rework-reader
//
//  Created by 张超 on 2019/3/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRMutiSelectCell.h"
#import "OPMLDocument.h"
@implementation RRMutiSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the view for the selected state
}

- (void)loadModel:(OPMLOutline*)outline
{
    self.titleLabel.text = outline.title?outline.title:outline.text;
    self.desLabel.text = [outline.text isEqualToString:outline.title]?outline.xmlUrl:outline.text;
}

@end
