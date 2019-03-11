//
//  RRIconSettingModel.h
//  rework-reader
//
//  Created by 张超 on 2019/3/7.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface RRIconSettingModel : MVPModel

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* subtitle;
@property (nonatomic, strong) NSString* icon;

@property (nonatomic, strong) NSString* fontStyle;

@property (nonatomic, assign) BOOL isTitle;

@end

NS_ASSUME_NONNULL_END
