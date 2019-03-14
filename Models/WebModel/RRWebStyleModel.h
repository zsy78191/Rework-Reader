//
//  RRWebStyleModel.h
//  rework-reader
//
//  Created by 张超 on 2019/3/7.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface RRWebStyleModel : MVPModel
{
    
}

@property (nonatomic, assign) NSInteger titleFontSize;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) double lineHeight;
@property (nonatomic, strong) NSString* align;
@property (nonatomic, strong) NSString* font;


+ (instancetype)currentStyle;
- (void)syncToCurrentStyle;

+ (void)setupDefalut;


@end

NS_ASSUME_NONNULL_END
