//
//  RRSwitchCell.h
//  rework-reader
//
//  Created by 张超 on 2019/2/15.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface RRSwitchCell : MVPContentCell
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *opener;

@end

NS_ASSUME_NONNULL_END
