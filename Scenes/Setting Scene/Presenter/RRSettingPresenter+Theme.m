//
//  RRSettingPresenter+Theme.m
//  rework-reader
//
//  Created by 张超 on 2019/4/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSettingPresenter+Theme.h"
#import "RRReadMode.h"
#import "DebugViewController.h"
#import "AppDelegate.h"
@import KSCrash;
 
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

- (void)report: (id)sender
{
    DebugViewController* d = [[DebugViewController alloc] initWithNibName:@"DebugViewController" bundle:nil];
    d.hideFirst = YES;
    [self.view mvp_pushViewController:d];
    __weak typeof(self) wss = self;
    AppDelegate* ws = (AppDelegate*)[UIApplication sharedApplication].delegate;
     [d setActionBlock:^(NSInteger selection) {
                switch (selection) {
                    case 1:
                    {
                        [ws.ci1 sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!completed) {
                                    [wss.view hudFail:@"发送失败"];
                                } else {
                                    if (filteredReports.count == 0) {
                                        [wss.view hudSuccess:@"没有可以发送的报告"];
                                    } else {
                                        [wss.view hudSuccess:@"发送成功，感谢"];
                                    }
                                }
                            });
                        }];
                        break;
                    }
                        case 2:
                    {
                        [ws.ci2 sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                                               if (!completed) {
                                          [wss.view hudFail:@"发送失败"];
                                      } else {
                                         if (filteredReports.count == 0) {
                                              [wss.view hudSuccess:@"没有可以发送的报告"];
                                          } else {
                                              [wss.view hudSuccess:@"发送成功，感谢"];
                                          }
                                      }
                            });
                        }];
                        break;
                    }
                    default:
                        break;
                }
            }];
}



@end
