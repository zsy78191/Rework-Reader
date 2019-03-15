//
//  RRAddInputCell.m
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRAddInputCell.h"
#import "RRAddModel.h"
@interface RRAddInputCell()
{
    
}

@property (nonatomic, weak) id<MVPModelProtocol> model;
@end

@implementation RRAddInputCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.inputField setDelegate:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    RRAddModel* m = self.model;
    m.value = textField.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadModel:(id<MVPModelProtocol>)model
{
    [super loadModel:model];
    
    if ([model isKindOfClass:[RRAddModel class]]) {
        RRAddModel* m = model;
        self.titleLabel.text = m.title;
        if (m.placeholder) {
            self.inputField.placeholder = m.placeholder;
        }
        if (m.value) {
            self.inputField.text = m.value;
        }
        
        [self.inputField setClearButtonMode:UITextFieldViewModeWhileEditing];
        switch (m.inputType) {
            case RRAddModelInputTypeURL:
                self.inputField.keyboardType = UIKeyboardTypeURL;
                self.inputField.spellCheckingType = UITextSpellCheckingTypeNo;
                self.inputField.smartQuotesType = UITextSmartQuotesTypeNo;
                self.inputField.smartDashesType = UITextSmartDashesTypeNo;
                self.inputField.autocorrectionType = UITextAutocorrectionTypeNo;
                break;
            case RRAddModelInputTypeText:
                break;
            case RRAddModelInputTypeNumber:
                break;
            case RRAddModelInputTypePasscode:
                break;
            default:
                break;
        }
    }
}

@end
