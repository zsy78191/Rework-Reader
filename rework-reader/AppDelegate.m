//
//  AppDelegate.m
//  rework-reader
//
//  Created by 张超 on 2019/1/15.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+Ext.h"

@interface AppDelegate () <SDWebImageManagerDelegate,UISplitViewControllerDelegate,CDEPersistentStoreEnsembleDelegate>
{
    CDEPersistentStoreEnsemble *ensemble;
    CDEICloudFileSystem *cloudFileSystem;
}

@end

@implementation AppDelegate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RRCasNeedReload" object:nil];
}

#pragma mark - lifecircle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 加载logger
    [self preload];
    
    // 加载字体
    [self loadFonts];
    
    // 加载数据
    [self loadCoreData];
    BOOL useiCloud = [[NSUserDefaults standardUserDefaults] boolForKey:@"kiCloudSetting"];
    if (useiCloud) {
        NSLog(@"-----iCloud--Auto------");
//        CDESetCurrentLoggingLevel(CDELoggingLevelVerbose);
//        [self loadEnsemble];
    }

    // 加载Classy样式
    [self loadCas];
    
    // 加载额外的样式
    [self loadExtra];
    
    // 加载路由
    [self loadRouter];
    
    // 加载VC
    [self loadPage];
    
    // 配置background fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    //NSLog(@"%@",launchOptions);
    
    int r = arc4random() % 4;
    if (r == 2) {
        [AppleAPIHelper review];
    }
  
    
    return YES;
}

- (void)notiArticle:(NSUInteger)count
{
     __weak typeof(self) weakSelf = self;
    if ([weakSelf kBackgroundFetchNoti]) {
        // Fixbug: 推送要加上当前的数量;
        NSInteger currentBadge = [UIApplication sharedApplication].applicationIconBadgeNumber;
        
        UNMutableNotificationContent* c = [[UNMutableNotificationContent alloc] init];
        if ([weakSelf kBackgroundFetchNotiBadge]) {
            c.badge = @(count + currentBadge);
        }
        c.title = @"新的订阅";
        c.body = [NSString stringWithFormat:@"更新了%ld篇订阅",count];
        c.userInfo = @{@"action":@"noti"};
        UNNotificationRequest* r = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString] content:c trigger:nil];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:r withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                //NSLog(@"%@",error);
            }
        }];
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    __weak typeof(self) weakSelf = self;
    [self updateFeedData:^(NSInteger x) {
        
        if (x> 0) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"openUnread"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [weakSelf notiArticle:x];
        }
        NSLog(@"更新了%ld",x);
        if (x > 0) {
            completionHandler(UIBackgroundFetchResultNewData);
        }
        else
        {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }];
    //NSLog(@"%s",__func__);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [[SDWebImageManager sharedManager].imageCache clearMemory];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [application setApplicationIconBadgeNumber:0];
    
//    UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
//        [self syncWithCompletion:^{
//            [[UIApplication sharedApplication] endBackgroundTask:identifier];
//        }];
//    }];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//    [self syncWithCompletion:NULL];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     [AppleAPIHelper endTestForStore:[ApplePurchaseDelegate sharedOne]];
}

- (BOOL)kBackgroundFetchNoti
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kBackgroundFetchNoti"];
}

- (BOOL)kBackgroundFetchNotiBadge
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kBackgroundFetchNotiBadge"];
}

- (void)loadCoreData
{
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Model"];
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

@end
