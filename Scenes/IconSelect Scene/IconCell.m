//
//  IconCell.m
//  rework-reader
//
//  Created by 张超 on 2019/6/4.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "IconCell.h"
#import "IconModel.h"
@implementation IconCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)loadModel:(id)m
{
    if ([m isKindOfClass:[IconModel class]]) {
        IconModel* model = m;
        self.iconView.image = [UIImage imageNamed:model.name];
    }
}

@end
