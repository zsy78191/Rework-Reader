//
//  AppDelegate+Ext.h
//  rework-reader
//
//  Created by 张超 on 2019/3/30.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "AppDelegate.h"
#import "ClassyKitLoader.h"
#import "RRExtraViewController.h"
#import "RPFontLoader.h"
@import mvc_base;
@import ui_base;
@import MagicalRecord;
#import "RRFeedAction.h"
#import "RPDataManager.h"
@import oc_string;
#import "RRFeedInfoListModel.h"
@import oc_util;
#import "RRFeedLoader.h"
@import DateTools;
@import UserNotifications;
#import "RRFeedInfoListOtherModel.h"
@import SDWebImage;
@import MMKV;
@import SVProgressHUD;
#import "RRWebStyleModel.h"
#import "RRImageRender.h"
#import "RRReadMode.h"
#import "RRSplitViewController.h"
#import "AppleAPIHelper.h"
#import "ApplePurchaseDelegate.h"
#import "RRDataBackuper.h"
//@import Ensembles;

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (Ext) <UISplitViewControllerDelegate>

- (void)loadCas;
- (void)preload;
- (void)loadFonts;
- (void)loadExtra;
- (void)loadRouter;
- (void)loadPage;
- (void)updateFeedData:(void (^)(NSInteger x))finished;
- (BOOL)iOS13SystemDark;
- (void)notiReloadCas:(id)windows;
- (void)checkThemeWithScreenLight;
@end

NS_ASSUME_NONNULL_END
