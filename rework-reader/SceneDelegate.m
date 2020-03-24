#import "SceneDelegate.h"
#import "SceneDelegate+Ext.h"
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
#import "OPMLDocument.h"
@import ReactiveObjC;

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)){
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//    NSLog(@"%s",__func__);
    [self loadCas];
    
    [self loadPage];
}


- (void)sceneDidDisconnect:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    [AppleAPIHelper endTestForStore:[ApplePurchaseDelegate sharedOne]];
}


- (void)sceneDidBecomeActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    if (@available(iOS 13.0, *)) {
          BOOL userSystemDarkMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoThemeDarkMode"];
             if(userSystemDarkMode) {
                 BOOL same = [self iOS13SystemDark];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (!same) {
                         [self notiReloadCas:@[self.window]];
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"RRWebNeedReload" object:nil];
                     }
                 });
          }
      }
}


- (void)sceneWillResignActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    [[SDWebImageManager sharedManager].imageCache clearMemory];
}


- (void)sceneWillEnterForeground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    BOOL autoCheck = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoTheme"];
    if (autoCheck) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkThemeWithScreenLight];
        });
    }
}


- (void)sceneDidEnterBackground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (BOOL)iOS13SystemDark
{
    RRReadMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"kRRReadMode"];
    BOOL same = YES;
     
     if (@available(iOS 12.0, *)) {
         if (self.window.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
             same = mode == RRReadModeDark;
             mode = RRReadModeDark;
             [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:@"kRRReadMode"];
             [[NSUserDefaults standardUserDefaults] synchronize];
         } else if(self.window.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
             same = mode == RRReadModeLight;
             mode = RRReadModeLight;
             [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:@"kRRReadMode"];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
     } else {
         // Fallback on earlier versions
     }
    return same;
}

- (void)notiReloadCas:(id)windows
{
    RRReadMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"kRRReadMode"];

    RRReadLightSubMode subMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"kRRReadModeLight"];
    RRReadDarkSubMode darkMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"kRRReadModeDark"];
    
    switch (mode) {
        case RRReadModeDark:
        {
            switch (darkMode) {
                case RRReadDarkSubModeDefalut:
                {
                    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style_dark" windows:windows];
                    break;
                }
                case RRReadDarkSubModeGray:
                {
                    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style_dark_1" windows:windows];
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case RRReadModeLight:
        {
            switch (subMode) {
                case RRReadLightSubModeDefalut:
                {
                    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style" windows:windows];
                    break;
                }
                case RRReadLightSubModeMice:
                {
                    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style_1" windows:windows];
                    break;
                }
                case RRReadLightSubModeSafariMice:
                {
                    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style_2" windows:windows];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    NSDictionary* style = [[NSUserDefaults standardUserDefaults] valueForKey:@"style"];
    
    NSDictionary* d = @{
                        NSFontAttributeName:[UIFont fontWithName:style[@"$main-font"] size:[style[@"$sub-font-size"] floatValue]],
                        NSForegroundColorAttributeName:UIColor.hex(style[@"$main-text-color"])
                        };
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"搜索" attributes:d];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setAttributedPlaceholder:attributedString];
    UITextField* t = [UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]];
    [t setDefaultTextAttributes:d];
}

- (void)updateStyle
{
    [ClassyKitLoader needReload];
    [self notiReloadCas:@[self.window]];
}


- (void)checkThemeWithScreenLight
{
    CGFloat value = [UIScreen mainScreen].brightness;
    if (value < 0.3) {
        [self switchTheme:RRReadModeDark];
    }
    else {
        [self switchTheme:RRReadModeLight];
    }
}

- (void)switchTheme:(RRReadMode)mode
{
    [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:@"kRRReadMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self notiReloadCas:@[self.window]];
    [self notiReloadCas:@[self.window]];
//    [self notiReloadCas];
    [self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RRWebNeedReload" object:nil];
    
}


- (void)loadCas
{
    [ClassyKitLoader cleanStyleFiles]; // 删除本地cas文件
    [ClassyKitLoader copyStyleFile]; // 拷贝cas文件
    BOOL autoCheck = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoTheme"];
    BOOL userSystemDarkMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoThemeDarkMode"];
    if(@available(iOS 13.0, *)) {
        
    } else {
        userSystemDarkMode = false;
    }
    if (!autoCheck) {
        if(userSystemDarkMode) {
            [self iOS13SystemDark];
        }
        [self notiReloadCas:UIApplication.sharedApplication.windows];
    } else if(userSystemDarkMode) {
        [self iOS13SystemDark];
        [self notiReloadCas:UIApplication.sharedApplication.windows];
    } else {
        [self checkThemeWithScreenLight];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStyle) name:@"RRCasNeedReload" object:nil];
}

- (void)windowScene:(UIWindowScene *)windowScene performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
API_AVAILABLE(ios(13.0)){
    NSLog(@"__))))0000");
    if([shortcutItem.type isEqualToString:@"search"])
    {
        NSString* urlStr = (NSString*)shortcutItem.userInfo[@"scheme"];
        if (urlStr) {
            [self handleScheme:[NSURL URLWithString:urlStr]];
        }
    }
}


- (void)handleScheme:(NSURL*)url
{
    __block NSString* keyword = nil;
    if ([[url host] isEqualToString:@"search"]) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:url.absoluteString];
        [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            if ([obj.name isEqualToString:@"keyword"]) {
                keyword = obj.value;
            }
        }];
    }
    if (!keyword) {
        [SVProgressHUD showErrorWithStatus:@"缺少keyword参数"];
        return;
    }
    
    NSString* searchText = keyword;
    RRFeedInfoListOtherModel* mSearch = [RRFeedInfoListOtherModel searchModel:searchText];
    UIViewController* view = [MVPRouter viewForURL:@"rr://list" withUserInfo:@{@"model":mSearch}];
    if (view) {
        [[self topVC] pushViewController:view animated:YES];
    }
    else {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"不支持URLScheme:\n%@",[url absoluteString]._urlDecodeString]];
    }
}


- (UINavigationController*)topVC
{
    UINavigationController* n = nil;
    if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* split = (UISplitViewController*)self.window.rootViewController;
        UIViewController* v = [split.viewControllers firstObject];
        //        //NSLog(@"%@",v);
        if ([v isKindOfClass:[UINavigationController class]]) {
            n = (UINavigationController*)v;
        }
    }
    else {
        if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
            n = (UINavigationController*)self.window.rootViewController;
        }
    }
    return n;
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts
API_AVAILABLE(ios(13.0)){
    NSLog(@"%@",URLContexts);
    [URLContexts enumerateObjectsUsingBlock:^(UIOpenURLContext * _Nonnull obj, BOOL * _Nonnull stop) {
        [self handleURL:obj.URL];
    }];
}


- (void)handleURL: (NSURL*) url {
      if ([[url absoluteString] hasPrefix:@"readerprime"]) {
            [self handleScheme:url];
            return ;
        }
        if (![[url path] hasSuffix:@"opml"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"仅支持OPML文件"];
            });
            return ;
        }
        
    //    //NSLog(@"%@",self.window.rootViewController);
        UINavigationController* n = nil;
        if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]]) {
            UISplitViewController* split = (UISplitViewController*)self.window.rootViewController;
            UIViewController* v = [split.viewControllers firstObject];
    //        //NSLog(@"%@",v);
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
                    [SVProgressHUD showErrorWithStatus:@"文件导入失败"];
                }
            });
        }];
}





@end
