//
//  SceneDelegate+Ext.m
//  rework-reader
//
//  Created by 张超 on 2020/3/19.
//  Copyright © 2020 orzer. All rights reserved.
//

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

@implementation SceneDelegate (Ext)

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



- (id)initialVCWith:(id)vc
{
    RRExtraViewController* nv2 = [[RRExtraViewController alloc] initWithRootViewController:vc];
    nv2.handleTrait = YES;
    return nv2;
}

@end
