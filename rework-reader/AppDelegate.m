//
//  AppDelegate.m
//  rework-reader
//
//  Created by 张超 on 2019/1/15.
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
#import "RRWebStyleModel.h"

@interface AppDelegate () <SDWebImageManagerDelegate>
{
    
}

@end

@implementation AppDelegate

- (void)loadCas
{
    [ClassyKitLoader cleanStyleFiles]; // 删除本地cas文件
    [ClassyKitLoader copyStyleFile]; // 拷贝cas文件
    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style2"]; //加载cas文件
}

- (void)preload
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode 控制台
//    [DDLog addLogger:[DDOSLogger sharedInstance] withLevel:DDLogLevelWarning]; // ASL = Apple System Logs 苹果系统日志
//    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // 本地文件日志
//    fileLogger.rollingFrequency = 60 * 60 * 24; // 每24小时创建一个新文件
//    fileLogger.logFileManager.maximumNumberOfLogFiles = 7; // 最多允许创建7个文件
//    [DDLog addLogger:fileLogger];
}

- (void)loadFonts
{
//    BOOL a1 = [RPFontLoader registerFontsAtPath:[[NSBundle mainBundle] pathForResource:@"TsangerXuanSanM-W02" ofType:@"ttf"]];
//    BOOL a2 = [RPFontLoader registerFontsAtPath:[[NSBundle mainBundle] pathForResource:@"SourceHanSerifCN-Regular" ofType:@"otf"]];
//    //NSLog(@"font load %@ %@",@(a1),@(a2));
    
    //加载预设字体大小
    [RRWebStyleModel setupDefalut];
    
//    [RPFontLoader testShowAllFonts];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (void)loadExtra
{
    self.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setHUDStyle];
    
//    //NSLog(@"%@",[UIApplication sharedApplication].bundleID());
    
    [MMKV setLogLevel:MMKVLogNone];
    
}

- (void)loadRouter
{
    [MVPRouter registView:NSClassFromString(@"RRFeedListView") forURL:@"rr://feedlist"];
    [MVPRouter registView:NSClassFromString(@"RRSettingView") forURL:@"rr://setting"];
    [MVPRouter registView:NSClassFromString(@"RRWebView") forURL:@"rr://web"];
    [MVPRouter registView:NSClassFromString(@"RRFeedConfigView") forURL:@"rr://feed"];
    [MVPRouter registView:NSClassFromString(@"RRAddFeedView") forURL:@"rr://addfeed"];
    [MVPRouter registView:NSClassFromString(@"RRListView") forURL:@"rr://list"];
    [MVPRouter registView:NSClassFromString(@"RRWebSettingView") forURL:@"rr://websetting"];
    
}

- (void)loadPage
{
//    [[NSUserDefaults standardUserDefaults] setValue:url forKey:@"lastUrl"];
//    [[NSUserDefaults standardUserDefaults] setValue:userInfo forKey:@"lastInfo"];
//    id url = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUrl"];
//    id info = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastInfo"];
//    info = [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:info error:nil];
//
    id vc = [MVPRouter viewForURL:@"rr://feedlist" withUserInfo:nil];
    RRExtraViewController* nv = [[RRExtraViewController alloc] initWithRootViewController:vc];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"openUnread"]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"openUnread"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // RRTODO:优化
//        id v2 = []
    
        RRFeedInfoListOtherModel* mUnread = GetRRFeedInfoListOtherModel(@"未读订阅",@"favicon",@"三日内的未读文章",@"unread");
        mUnread.canRefresh = YES;
        mUnread.canEdit = NO;
        mUnread.readStyle = ({
            RRReadStyle* s = [[RRReadStyle alloc] init];
            s.onlyUnread = YES;
            s.daylimit = 3;
            s.liked = NO;
            s;
        });
        
        id v2 = [MVPRouter viewForURL:@"rr://list" withUserInfo:@{@"model":mUnread}];
        [nv pushViewController:v2 animated:NO];
    }
//    if (url) {
//        id vc2 = [MVPRouter viewForURL:url withUserInfo:info];
//        [nv pushViewController:vc2 animated:YES];
//    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nv;
    [self.window makeKeyAndVisible];
}

#pragma mark - lifecircle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[SDWebImageManager sharedManager] setDelegate:self];
    
//    [MagicalRecord isICloudEnabled]
//    if ([MagicalRecord isICloudEnabled]) {
//        [MagicalRecord setupCoreDataStackWithiCloudContainer:[@"iCloud." stringByAppendingString:[UIApplication sharedApplication].bundleID()] localStoreNamed:@"Model"];
//
//        [MagicalRecord setupAutoMigratingCoreDataStack];
//    }
//    else {
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Model"];
//    }
    
   
    
    // 加载logger
    [self preload];
    
    // 加载字体
    [self loadFonts];

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
        //NSLog(@"更新了%ld",x);
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


- (void)updateFeedData:(void (^)(NSInteger x))finished
{
    NSArray* all = nil;
    if (!all) {
        all = [[RPDataManager sharedManager] getAll:@"EntityFeedInfo" predicate:nil key:nil value:nil sort:@"sort" asc:YES];
    }
    all =
    all.filter(^BOOL(RRFeedInfoListModel*  _Nonnull x) {
        
        if (!x.useautoupdate) {
            return NO;
        }
        
        NSString* key = [NSString stringWithFormat:@"UPDATE_%@",x.url];
        NSInteger lastU = [MVCKeyValue getIntforKey:key];
        if (lastU != 0) {
            NSDate* d = [NSDate dateWithTimeIntervalSince1970:lastU];
            //NSLog(@"last %@ %@",d,@([d timeIntervalSinceDate:[NSDate date]]));
            if ([d timeIntervalSinceDate:[NSDate date]] > - 10) {
                return NO;
            }
        }
        
        if (x.usettl) {
            NSUInteger ttl = [x.ttl integerValue];
            NSDate* d = [x.updateDate dateByAddingMinutes:ttl];
            if ([d timeIntervalSinceDate:[NSDate date]] > 0) {
                return NO;
            }
        }
        return YES;
    })
    .map(^id _Nonnull(RRFeedInfoListModel*  _Nonnull x) {
        return [x.url absoluteString];
    });
    
    [[RRFeedLoader sharedLoader] refresh:all endRefreshBlock:^{
        //        [sender endRefreshing];
//        if (finished) {
//            finished(0);
//        }
    } finishBlock:^(NSUInteger all, NSUInteger error, NSUInteger article) {
        if (finished) {
            finished(article);
        }
    }];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [application setApplicationIconBadgeNumber:0];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)kBackgroundFetchNoti
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kBackgroundFetchNoti"];
}

- (BOOL)kBackgroundFetchNotiBadge
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kBackgroundFetchNotiBadge"];
}


@end
