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

@interface AppDelegate ()

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
//    NSLog(@"font load %@ %@",@(a1),@(a2));

}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (void)loadExtra
{
    self.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setHUDStyle];
    
//    NSLog(@"%@",[UIApplication sharedApplication].bundleID());
    
}

- (void)loadRouter
{
    [MVPRouter registView:NSClassFromString(@"RRFeedListView") forURL:@"rr://feedlist"];
    [MVPRouter registView:NSClassFromString(@"RRSettingView") forURL:@"rr://setting"];
    [MVPRouter registView:NSClassFromString(@"RRWebView") forURL:@"rr://web"];
    [MVPRouter registView:NSClassFromString(@"RRFeedConfigView") forURL:@"rr://feed"];
    [MVPRouter registView:NSClassFromString(@"RRAddFeedView") forURL:@"rr://addfeed"];
    [MVPRouter registView:NSClassFromString(@"RRListView") forURL:@"rr://list"];
    
}

- (void)loadPage
{
    id vc = [MVPRouter viewForURL:@"rr://feedlist" withUserInfo:nil];
    RRExtraViewController* nv = [[RRExtraViewController alloc] initWithRootViewController:vc];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nv;
    [self.window makeKeyAndVisible];
}

#pragma mark - lifecircle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [MagicalRecord setupCoreDataStackWithiCloudContainer:[@"iCloud." stringByAppendingString:[UIApplication sharedApplication].bundleID()] localStoreNamed:@"Model"];
    
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
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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


@end
