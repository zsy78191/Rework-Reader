//
//  AppDelegate+Ext.m
//  rework-reader
//
//  Created by 张超 on 2019/3/30.
//  Copyright © 2019 orzer. All rights reserved.
//


#import "AppDelegate+Ext.h"
#import "RRDataBackuper.h"
@import ui_base;
@implementation AppDelegate (Ext)

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
        [self notiReloadCas];
    } else if(userSystemDarkMode) {
        [self iOS13SystemDark];
        [self notiReloadCas];
    } else {
        [self checkThemeWithScreenLight];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStyle) name:@"RRCasNeedReload" object:nil];
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



- (void)preload
{
//    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode 控制台
    //    [DDLog addLogger:[DDOSLogger sharedInstance] withLevel:DDLogLevelWarning]; // ASL = Apple System Logs 苹果系统日志
    //    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // 本地文件日志
    //    fileLogger.rollingFrequency = 60 * 60 * 24; // 每24小时创建一个新文件
    //    fileLogger.logFileManager.maximumNumberOfLogFiles = 7; // 最多允许创建7个文件
    //    [DDLog addLogger:fileLogger];
    
    [[RRImageRender sharedRender] preloadFilters];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* string = [[UIApplication sharedApplication].bundleID() stringByAppendingString:@".donate6"];
        [AppleAPIHelper testForStore:[ApplePurchaseDelegate sharedOne] products:[NSSet setWithObject:string]];
    });
    
    [SDWebImageDownloader sharedDownloader].maxConcurrentDownloads = 50;
    [SDWebImageDownloader sharedDownloader].downloadTimeout = 5;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[RRDataBackuper alloc] init] ensureFileDownloaded];
    });
//    //NSLog(@"%@",@(x));
}

- (void)loadFonts
{
    //    BOOL a1 = [RPFontLoader registerFontsAtPath:[[NSBundle mainBundle] pathForResource:@"TsangerXuanSanM-W02" ofType:@"ttf"]];
    //    BOOL a2 = [RPFontLoader registerFontsAtPath:[[NSBundle mainBundle] pathForResource:@"SourceHanSerifCN-Regular" ofType:@"otf"]];
    //    ////NSLog(@"font load %@ %@",@(a1),@(a2));
    
    //加载预设字体大小
    [RRWebStyleModel setupDefalut];
    
    //    [RPFontLoader testShowAllFonts];
}

- (void)loadExtra
{
    self.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setHUDStyle];
    [SVProgressHUD setHapticsEnabled:YES];
    //    ////NSLog(@"%@",[UIApplication sharedApplication].bundleID());
    
    [MMKV setLogLevel:MMKVLogNone];
    
//    [[[SDWebImageManager sharedManager] imageCache] setMaxMemoryCountLimit:50];
//    [[[SDWebImageManager sharedManager] imageCache] setMaxMemoryCost:1024*1024*30];
    
//    [[SDWebImageManager sharedManager] imageDownloader];
}

- (void)loadRouter
{
    [MVPRouter registView:NSClassFromString(@"RRFeedListView") forURL:@"rr://feedlist"];
    [MVPRouter registView:NSClassFromString(@"RRSettingView") forURL:@"rr://setting"];
    [MVPRouter registView:NSClassFromString(@"RRWebView") forURL:@"rr://web"];
    [MVPRouter registView:NSClassFromString(@"RRFeedConfigView") forURL:@"rr://feed"];
    [MVPRouter registView:NSClassFromString(@"RRAddFeedView") forURL:@"rr://addfeed"];
    [MVPRouter registView:NSClassFromString(@"RRListView") forURL:@"rr://list"];
    [MVPRouter registView:NSClassFromString(@"RRPopoverSettingView") forURL:@"rr://websetting"];
    [MVPRouter registView:NSClassFromString(@"RRImportView") forURL:@"rr://import"];
    [MVPRouter registView:NSClassFromString(@"IconSelectView") forURL:@"rr://selecticon"];
    [MVPRouter registView:NSClassFromString(@"TableAutoView") forURL:@"rr://tableauto"];
}


- (void)loadPage
{
    id vc = [MVPRouter viewForURL:@"rr://feedlist" withUserInfo:nil];
    RRExtraViewController* nv = [[RRExtraViewController alloc] initWithRootViewController:vc];
    nv.handleTrait = NO;
    
    BOOL openUnreadAlways = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnterUnread"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"openUnread"] || openUnreadAlways) {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"openUnread"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
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

    if([UIDevice currentDevice].iPad())
    {
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
        
        id nv2 = [self initialVC];
        RRSplitViewController* split = [[RRSplitViewController alloc] init];
        [split setViewControllers:@[nv,nv2]];
        split.delegate = self;
        split.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        split.presentsWithGesture = YES;
        //设置左侧主视图Master Controller的显示模式，现在是一直显示。如果设置为横屏显示竖屏不显示，还可以再设置一下相关的手势属性，如presentsWithGesture
        //        split.maximumPrimaryColumnWidth = 128.0f;
        //调整左侧主视图Master Controller的最大显示宽度
        self.window.rootViewController = split;
    }
    else {
        self.window.rootViewController = nv;
    }
    
    [self.window makeKeyAndVisible];
}


- (id)initialVC
{
    NSInteger homepagetype = [[NSUserDefaults standardUserDefaults] integerForKey:@"kDefaultHomePage"];
    id v2 = NULL;
    if (homepagetype == 0) {
        v2 = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":@"http://orzer.zhangzichuan.cn/",@"isSub":@(NO)}];
    } else if(homepagetype == 1) {
        v2 = [[UIViewController alloc] initWithNibName:@"PlaceholderViewController" bundle:[NSBundle mainBundle]];
    } else if(homepagetype == 2) {
        NSString* path = [[NSUserDefaults standardUserDefaults] stringForKey:@"kDefaultHomePagePath"];
        v2 = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":path,@"isSub":@(NO)}];
    }
    
    if(!v2) {
        v2 = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":@"http://orzer.zhangzichuan.cn/",@"isSub":@(NO)}];
    }
    RRExtraViewController* nv2 = [[RRExtraViewController alloc] initWithRootViewController:v2];
    nv2.handleTrait = YES;
    return nv2;
}

- (id)initialVCWith:(id)vc
{
    RRExtraViewController* nv2 = [[RRExtraViewController alloc] initWithRootViewController:vc];
    nv2.handleTrait = YES;
    return nv2;
}


- (void)updateFeedData:(void (^)(NSInteger x))finished
{
    //NSLog(@"Step 1");
    NSArray* all = nil;
    if (!all) {
        all = [[RPDataManager sharedManager] getAll:@"EntityFeedInfo" predicate:nil key:nil value:nil sort:@"sort" asc:YES];
    }
    all =
    all.filter(^BOOL(RRFeedInfoListModel*  _Nonnull x) {
        if (!x.useautoupdate) {
            return NO;
        }
//        NSString* key = [NSString stringWithFormat:@"UPDATE_%@",x.url];
//        NSInteger lastU = [MVCKeyValue getIntforKey:key];
//        if (lastU != 0) {
//            NSDate* d = [NSDate dateWithTimeIntervalSince1970:lastU];
//            ////NSLog(@"last %@ %@",d,@([d timeIntervalSinceDate:[NSDate date]]));
//            if ([d timeIntervalSinceDate:[NSDate date]] > - 10) {
//                return NO;
//            }
//        }
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
    //NSLog(@"Step 2");
    [[RRFeedLoader sharedLoader] refresh:all endRefreshBlock:^{
        //NSLog(@"Step 3");
    } finishBlock:^(NSUInteger all, NSUInteger error, NSUInteger article) {
        //NSLog(@"Step 4");
        if (finished) {
            finished(article);
        }
    }];
    
}

//split


- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    if ([primaryViewController isKindOfClass:[RRExtraViewController class]]) {
        RRExtraViewController* r = (RRExtraViewController*)primaryViewController;
        id vc = [r topViewController];
        if ([vc isKindOfClass:NSClassFromString(@"RRWebView")]) {
            id pop = [r popViewControllerAnimated:NO];
            id v = [self initialVCWith:pop];
            return v;
        }
        else if([vc isKindOfClass:NSClassFromString(@"SFSafariViewController")])
        {
            return vc;
        }
    }
    id nv2 = [self initialVC];
    return nv2;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController NS_AVAILABLE_IOS(8_0);
{
    return NO;
}

- (nullable UIViewController *)primaryViewControllerForCollapsingSplitViewController:(UISplitViewController *)splitViewController NS_AVAILABLE_IOS(8_0);
{
    NSArray* vcs = [splitViewController viewControllers];
    if(vcs.count < 2)
    {
        return nil;
    }
    RRExtraViewController* ext1 = [vcs firstObject];
    id ext2 = [vcs lastObject];
    if([ext2 isKindOfClass:NSClassFromString(@"SFSafariViewController")])
    {
        [[ext1 navigationBar] setPrefersLargeTitles:NO];
        return nil;
    }
    return ext1;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}


- (void)system {
    

}

@end
