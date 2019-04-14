//
//  RRSettingPresenter.h
//  rework-reader
//
//  Created by 张超 on 2019/1/28.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN
@class RRSetting;

@interface RRSettingPresenter : MVPPresenter

@property (nonatomic, strong) NSString* title;

@property (nonatomic, weak) RRSetting* notiSetting;
@property (nonatomic, weak) RRSetting* badgeSetting;
@property (nonatomic, weak) RRSetting* enterUnreadSetting;
@property (nonatomic, weak) RRSetting* iCloudSetting;
@property (nonatomic, weak) RRSetting* toolBackSetting;
@property (nonatomic, weak) RRSetting* articleDetialSetting;


@end

NS_ASSUME_NONNULL_END
