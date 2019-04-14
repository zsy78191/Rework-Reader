//
//  RRSettingPresenter+Swith.m
//  rework-reader
//
//  Created by 张超 on 2019/4/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSettingPresenter+Swith.h"
@import UserNotifications;
#import "RRModelItem.h"
@import ui_base;

@implementation RRSettingPresenter (Swith)


- (void)changeNoti:(UISwitch*)sender
{
    if (![sender isKindOfClass:[UISwitch class]]) {
        return;
    }
    //    //NSLog(@"%@",sender);
    if (sender.on == NO) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:self.notiSetting.switchkey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    
    __weak typeof(self) weakSelf = self;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        if (!granted) {
            //            //NSLog(@"%@",weakSelf.badgeSetting);
            weakSelf.notiSetting.switchValue = @(NO);
            //            //NSLog(@"%@",self.badgeSetting.switchValue);
            UI_Alert().
            titled(@"请在系统「设置」中开启Reader的通知功能")
            .recommend(@"前往「设置」", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                }
            })
            .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
                
            })
            .show((id)weakSelf.view);
            
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:weakSelf.notiSetting.switchkey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    
}

- (void)changeNotiBadge:(UISwitch*)sender
{
    if (![sender isKindOfClass:[UISwitch class]]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:self.badgeSetting.switchkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)changeEnterUnread:(UISwitch*)sender
{
    if (![sender isKindOfClass:[UISwitch class]]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:self.enterUnreadSetting.switchkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)changeiCloud:(UISwitch*)sender
{
    if (![sender isKindOfClass:[UISwitch class]]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:self.iCloudSetting.switchkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)changeToolBack:(UISwitch*)sender
{
    if (![sender isKindOfClass:[UISwitch class]]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:self.toolBackSetting.switchkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)changeArticleDetial:(UISwitch*)sender
{
    if (![sender isKindOfClass:[UISwitch class]]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:self.articleDetialSetting.switchkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
