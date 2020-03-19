//
//  RRFeedArticleCell.m
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedArticleCell.h"
#import "RRFeedArticleModel.h"
#import "RRFeedLoader.h"
#import "EntityFeedArticle+Ext.h"
@import DateTools;
@import SDWebImage;
@import oc_string;
#import "RRCoreDataModel.h"
@import RegexKitLite;
@import Classy;
#import "NSString+HTML.h"
//@import YYKit;
@implementation RRFeedArticleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.i1.image = [UIImage new];
    self.i2.image = [UIImage new];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    //NSLog(@"%@",@(selected));
    // Configure the view for the selected state
}

- (void)loadModel:(id<MVPModelProtocol>)model
{
    [super loadModel:model];
    
    if ([model isKindOfClass:[RRFeedArticleModel class]]) {
        RRFeedArticleModel* m = (id)model;
        self.titleLabel.text = [[m.title stringByDecodingHTMLEntities] stringByAppendingString:@"\n"];
        NSDate* date = m.date;
        NSString* des = @"";
        if (date) {
            des = [NSString stringWithFormat:@"%@ · %@  · ",[date timeAgoSinceNow],[[RRFeedLoader sharedLoader].shortDateAndTimeFormatter stringFromDate:date]];
        }
        
        if (m.summary.length > 30 || m.content.length > 30) {
            NSString* temp = m.content.length > 30 ? m.content : m.summary;
            temp = [temp stringByConvertingHTMLToPlainText];
            //        ////NSLog(@"%@ %@",@(temp.length),temp);
            des = [des stringByAppendingFormat:@"%.1f分钟", (float)temp.length/300];
        }
        self.dateLabel.text = des;
        
        if (m.feed) {
            self.feedLabel.text = m.feed.title;
            
            if (m.feed.icon) {
                if ([m.feed.icon hasPrefix:@"http"]) {
                    [self.iconView sd_setImageWithURL:[NSURL URLWithString:m.feed.icon] placeholderImage:[UIImage imageNamed:@"favicon"]];
                }
                else {
                    [self.iconView setImage:[UIImage imageNamed:m.feed.icon]];
                }
            }
            else {
                [self.iconView setImage:[UIImage imageNamed:@"favicon"]];
            }
        }
        else if(m.feedEntity)
        {
            self.feedLabel.text = m.feedEntity.title;
            
            if (m.feedEntity.icon) {
                if ([m.feedEntity.icon hasPrefix:@"http"]) {
                    [self.iconView sd_setImageWithURL:[NSURL URLWithString:m.feedEntity.icon] placeholderImage:[UIImage imageNamed:@"favicon"]];
                }
                else {
                   [self.iconView setImage:[UIImage imageNamed:m.feedEntity.icon]];
                }
            }
            else {
                [self.iconView setImage:[UIImage imageNamed:@"favicon"]];
            }
        }
    }
    else if([model isKindOfClass:[EntityFeedArticle class]])
    {
        EntityFeedArticle* m = model;
        self.titleLabel.text = [[m.title stringByDecodingHTMLEntities] stringByAppendingString:@"\n"];
        NSDate* date = m.date;
        ////NSLog(@"%@ %@",m.date,m.updated);
        NSString* des = @"";
        if (date) {
//            des = [NSString stringWithFormat:@"%@ · %@  · ",[date timeAgoSinceNow],[[RRFeedLoader sharedLoader].shrotDateAndTimeFormatter stringFromDate:date]];
            des = [NSString stringWithFormat:@"%@ · ",[date timeAgoSinceNow]];
        }
        
        NSString* temp = [m showContent];
        des = [des stringByAppendingFormat:@"%.1f分钟", (float)temp.length/300];
        self.dateLabel.text = des;
        
        if (m.feed) {
            self.feedLabel.text = [m.feed.title stringByDecodingHTMLEntities];
            
            if (m.feed.icon) {
                if ([m.feed.icon hasPrefix:@"http"]) {
                    [self.iconView sd_setImageWithURL:[NSURL URLWithString:m.feed.icon] placeholderImage:[UIImage imageNamed:@"favicon"]];
                }
                else {
                     [self.iconView setImage:[UIImage imageNamed:m.feed.icon]];
                }
            }
            else {
                [self.iconView setImage:[UIImage imageNamed:@"favicon"]];
            }
        }
        else {
            [self.iconView setImage:[UIImage imageNamed:@"favicon"]];
            self.feedLabel.text = @"无订阅源";
        }
        
        [self configUnreadAndLiked:m];
        
        [self mvp_bindModel:model withProperties:@[@"liked",@"readed"]];
        
        if (self.detialLabel) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideArticleDetial"]) {
                self.detialLabel.text = @"";
            }
            else {
               self.detialLabel.text = temp;
            }
        }
    }
}

- (void)mvp_value:(id)value updateForKeypath:(NSString *)keypath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configUnreadAndLiked:[self valueForKey:@"model"]];
    });
}

- (void)configUnreadAndLiked:(EntityFeedArticle*)m
{
    if (m.liked) {
        self.i1.image = [UIImage imageNamed:@"icon_i3"];
    }
    else {
        self.i1.image = [UIImage new];
    }
    
    if (!m.readed) {
        if (m.liked) {
            [self.i2 setImage:[UIImage imageNamed:@"icon_i2"]];
        }
        else {
            [self.i1 setImage:[UIImage imageNamed:@"icon_i2"]];
        }
        
    }
    else {
        
        if (m.liked) {
            [self.i2 setImage:[UIImage new]];
        }
        else {
            [self.i1 setImage:[UIImage new]];
        }
    }
    if (!m.lastread) {
        self.titleLabel.cas_styleClass = @"MainLabel";
    }
    else {
        self.titleLabel.cas_styleClass = @"MainLabelReaded";
    }
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.i1.image = [UIImage new];
    self.i2.image = [UIImage new];
}

@end
