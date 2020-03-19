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
#import "RRImageRender.h"
#import "NSString+HTML.h"
@import oc_string;
//@import Fork_MWFeedParser;
@import Classy;

@import SDWebImage;
@implementation RRFeedInfoListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imageView.clipsToBounds = YES;
//    self.imageView.layer.cornerRadius = 50;
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.cas_styleClass = @"selectView";
//    self.selectedBackgroundView.backgroundColor = [UIColor redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadModel:(id<MVPModelProtocol,RRCanEditProtocol>)model
{
    if ([model isKindOfClass:[RRFeedInfoListModel class]]) {
        RRFeedInfoListModel* m = model;
        self.titleLabel.text = [m.title stringByDecodingHTMLEntities];
        if (m.feed && !m.lastUpdateResult) {
            self.titleLabel.text = [self.titleLabel.text stringByAppendingString:@" (更新失败)"];
        }
        if (m.icon) {
            if ([m.icon hasPrefix:@"http"]) {
                [self.iconView sd_setImageWithURL:[NSURL URLWithString:m.icon] placeholderImage:[UIImage imageNamed:@"favicon"]];
            }
            else {
                [self.iconView setImage:[UIImage imageNamed:m.icon]];
            }
        }
        else {
            [self.iconView setImage:[UIImage imageNamed:@"favicon"]];
        }
        if (m.thehub) {
            NSString* summary = [[m.thehub infos] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES]]].map(^id _Nonnull(EntityFeedInfo*  _Nonnull x) {
                return x.title;
            }).join(@",");
            self.subLabel.text = summary;
        }
        else {
            self.subLabel.text = m.summary;
        }
        
        if (m.useachieve) {
            NSSet* t = [m.feed.articles filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"readed = false"]];
            self.countLabel.text = [NSString stringWithFormat:@"%ld",t.count];
        }
        else {
            if (m.feed) {
                self.countLabel.text = [NSString stringWithFormat:@"%ld",m.feed.articles.count];
            }
            else if(m.thehub)
            {
                __block NSUInteger sum = 0;
                [m.thehub.infos enumerateObjectsUsingBlock:^(EntityFeedInfo * _Nonnull obj, BOOL * _Nonnull stop) {
                    if (obj.useachieve) {
                        sum += [obj.articles filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"readed = false"]].count;
                    }
                    else {
                        sum += obj.articles.count;
                    }
                }];
                self.countLabel.text = [NSString stringWithFormat:@"%ld",sum];
            }
        }
    }
    else if([model isKindOfClass:[RRFeedInfoListOtherModel class]])
    {
        RRFeedInfoListOtherModel* m = model;
        self.titleLabel.text = [m.title stringByDecodingHTMLEntities];
        if (m.icon) {
            [self.iconView setImage:[UIImage imageNamed:m.icon]];
        }
        self.subLabel.text = m.subtitle;
        self.countLabel.text = [NSString stringWithFormat:@"%ld",m.count];
    }
}

@end
