//
//  RRFeedInfoListCell.m
//  rework-reader
//
//  Created by 张超 on 2019/2/21.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedInfoListCell.h"
#import "RRFeedInfoListModel.h"
#import "RRFeedInfoListOtherModel.h"
#import "RRCoreDataModel.h"

@import SDWebImage;
@implementation RRFeedInfoListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadModel:(id<MVPModelProtocol,RRCanEditProtocol>)model
{
    if ([model isKindOfClass:[RRFeedInfoListModel class]]) {
        RRFeedInfoListModel* m = model;
        self.titleLabel.text = m.title;
        if (m.icon) {
            [self.iconView sd_setImageWithURL:[NSURL URLWithString:m.icon] placeholderImage:[UIImage imageNamed:@"favicon"]];
        }
        else {
            [self.iconView setImage:[UIImage imageNamed:@"favicon"]];
        }
        self.subLabel.text = m.summary;
        self.countLabel.text = [NSString stringWithFormat:@"%ld",m.feed.articles.count];
    }
    else if([model isKindOfClass:[RRFeedInfoListOtherModel class]])
    {
        RRFeedInfoListOtherModel* m = model;
        self.titleLabel.text = m.title;
        if (m.icon) {
            [self.iconView setImage:[UIImage imageNamed:m.icon]];
        }
        self.subLabel.text = m.subtitle;
        self.countLabel.text = [NSString stringWithFormat:@"%ld",m.count];
    }
    
}

@end
