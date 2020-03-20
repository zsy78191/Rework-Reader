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

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)){
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    NSLog(@"%s",__func__);
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
                         [self notiReloadCas];
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

- (void)notiReloadCas
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
                    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style_dark"];
                    break;
                }
                case RRReadDarkSubModeGray:
                {
                    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style_dark_1"];
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
                    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style"];
                    break;
                }
                case RRReadLightSubModeMice:
                {
                    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style_1"];
                    break;
                }
                case RRReadLightSubModeSafariMice:
                {
                    [ClassyKitLoader loadWithStyle:@"rrstyle" variables:@"style_2"];
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
    [self notiReloadCas];
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
    [self notiReloadCas];
    [self notiReloadCas];
    [self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RRWebNeedReload" object:nil];
    
}

@end
