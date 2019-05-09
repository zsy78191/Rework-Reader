//
//  AppDelegate.m
//  rework-reader
//
//  Created by 张超 on 2019/1/15.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+Ext.h"
#import "OttoFPSButton.h"
#import "OPMLDocument.h"
@import ReactiveObjC;
@import ui_base;

@interface AppDelegate () <SDWebImageManagerDelegate,UISplitViewControllerDelegate>
{
//    CDEPersistentStoreEnsemble *ensemble;
//    CDEICloudFileSystem *cloudFileSystem;
}

@end

@implementation AppDelegate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RRCasNeedReload" object:nil];
}

#pragma mark - lifecircle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSDictionary* d = @{@"evatype":@"0",@"PageIndex":@"1",@"PageSize":@"6"};
    NSString* str = [[NSString alloc] initWithData: [NSJSONSerialization dataWithJSONObject:d options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    NSDictionary* param = @{@"id":@"1417505",@"obj":str};
    NSLog(@"%@",param);
    NSString* str2 = [[NSString alloc] initWithData: [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str2);
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
  
#ifdef DEBUG
//    CGRect frame = CGRectMake(0, 300, 80, 30);
//    UIColor *btnBGColor = [UIColor colorWithWhite:0.000 alpha:0.700];
//    OttoFPSButton *btn = [OttoFPSButton setTouchWithFrame:frame titleFont:[UIFont systemFontOfSize:15] backgroundColor:btnBGColor backgroundImage:nil];
//    [self.window addSubview:btn];
#endif
 
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
    BOOL autoCheck = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoTheme"];
    if (autoCheck) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkThemeWithScreenLight];
        });
    }
    
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



- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
//    NSLog(@"%s",__func__);
//    NSLog(@"%@",url);
//    NSLog(@"%@",options);
    if (![[url path] hasSuffix:@"opml"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"仅支持OPML文件"];
        });
        return NO;
    }
    
//    NSLog(@"%@",self.window.rootViewController);
    UINavigationController* n = nil;
    if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* split = (UISplitViewController*)self.window.rootViewController;
        UIViewController* v = [split.viewControllers firstObject];
//        NSLog(@"%@",v);
        if ([v isKindOfClass:[UINavigationController class]]) {
          n = (UINavigationController*)v;
        }
    }
    else {
        if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
            n = (UINavigationController*)self.window.rootViewController;
        }
    }
//
    OPMLDocument* d = [[RRFeedLoader sharedLoader] loadOPML:url];
//    __weak typeof(self) weakSelf = self;
    [d openWithCompletionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                UIViewController* view = [MVPRouter viewForURL:@"rr://import" withUserInfo:@{@"model":d}];
//                                [weakSelf.view mvp_pushViewController:view];
//
                if ([UIDevice currentDevice].iPad()) {
                    if (n) {
                        RRExtraViewController* rr = [[RRExtraViewController alloc] initWithRootViewController:view];
                        __weak UIViewController* weakView = view;
                        view.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:nil action:nil];
                        view.navigationItem.leftBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
                           
                            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                               
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakView dismissViewControllerAnimated:YES completion:nil];
                                });
                                
                                return [RACDisposable disposableWithBlock:^{
                                    
                                }];
                            }];
                        }];
                        [rr setModalPresentationStyle:UIModalPresentationFormSheet];
//                        [view ]
                        [n presentViewController:rr animated:YES completion:nil];
                    }
                }
                else {
                    if (n) {
                        [n pushViewController:view animated:YES];
                    }
                }
                
            }
            else {
                //                [self.view hudFail:@"导入文件失败"];
                [SVProgressHUD showErrorWithStatus:@"文件导入失败"];
            }
        });
    }];

    return YES;
}

@end
