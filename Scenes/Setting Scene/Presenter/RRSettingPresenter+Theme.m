//
//  RRSettingPresenter+Theme.m
//  rework-reader
//
//  Created by 张超 on 2019/4/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSettingPresenter+Theme.h"
#import "RRReadMode.h"
@implementation RRSettingPresenter (Theme)

- (void)setTheme0
{
    [[NSUserDefaults standardUserDefaults] setInteger:RRReadModeLight forKey:@"kRRReadMode"];
    [[NSUserDefaults standardUserDefaults] setInteger:RRReadLightSubModeDefalut forKey:@"kRRReadModeLight"];
    [self resetTheme];
}

- (void)setTheme1
{
    [[NSUserDefaults standardUserDefaults] setInteger:RRReadModeLight forKey:@"kRRReadMode"];
    [[NSUserDefaults standardUserDefaults] setInteger:RRReadLightSubModeMice forKey:@"kRRReadModeLight"];
    [self resetTheme];
}

- (void)setTheme2
{
    [[NSUserDefaults standardUserDefaults] setInteger:RRReadModeLight forKey:@"kRRReadMode"];
    [[NSUserDefaults standardUserDefaults] setInteger:RRReadLightSubModeSafariMice forKey:@"kRRReadModeLight"];
    [self resetTheme];
}

- (void)setTheme0d
{
    [[NSUserDefaults standardUserDefaults] setInteger:RRReadModeDark forKey:@"kRRReadMode"];
    [[NSUserDefaults standardUserDefaults] setInteger:RRReadDarkSubModeDefalut forKey:@"kRRReadModeDark"];
    [self resetTheme];
}

- (void)setTheme1d
{
    [[NSUserDefaults standardUserDefaults] setInteger:RRReadModeDark forKey:@"kRRReadMode"];
    [[NSUserDefaults standardUserDefaults] setInteger:RRReadDarkSubModeGray forKey:@"kRRReadModeDark"];
    [self resetTheme];
}

- (void)resetTheme
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RRCasNeedReload" object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RRWebNeedReload" object:nil];
        
        [[(UIViewController*)self.view navigationController] setNeedsStatusBarAppearanceUpdate];
    });
}

@end
