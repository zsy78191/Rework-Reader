//
//  RRAddInputCell.h
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface RRAddInputCell : MVPContentCell <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputField;

@end

NS_ASSUME_NONNULL_END
