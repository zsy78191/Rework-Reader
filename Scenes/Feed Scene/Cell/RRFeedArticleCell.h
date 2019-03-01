//
//  RRFeedArticleCell.h
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface RRFeedArticleCell : MVPContentCell
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *feedLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *i1;
@property (weak, nonatomic) IBOutlet UIImageView *i2;

@end

NS_ASSUME_NONNULL_END
