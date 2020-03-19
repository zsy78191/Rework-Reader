//
//  RRExtraViewController.m
//  rework-reader
//
//  Created by 张超 on 2019/1/28.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRExtraViewController.h"
#import "RRReadMode.h"
@interface RRExtraViewController ()

@end

@implementation RRExtraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.restorationIdentifier = @"RRExtraViewController";
    // Do any additional setup after loading the view.
    [self.navigationBar setValue:@(YES) forKeyPath:@"hidesShadow"];
//    [self.tabBarController.tabBar setValue:@(YES) forKeyPath:@"hidesShadow"];
    [self.toolbar setValue:@(YES) forKey:@"hidesShadow"];
    [self.navigationBar setPrefersLargeTitles:YES];
    [self setToolbarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if ([self.topViewController isKindOfClass:NSClassFromString(@"MWPhotoBrowser")] && [self.topViewController respondsToSelector:@selector(preferredStatusBarStyle)]) {
        return [self.topViewController preferredStatusBarStyle];
    }
    RRReadMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"kRRReadMode"];
    if (mode == RRReadModeDark) {
          return UIStatusBarStyleLightContent;
    }
    else if(mode == RRReadModeLight)
    {
        if (@available(iOS 13.0, *)) {
            return UIStatusBarStyleDarkContent;
        } else {
            return UIStatusBarStyleDefault;
        };
    }
    return [self.topViewController preferredStatusBarStyle];
}


// 当SizeClass发生变化后调用
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    
    if (!self.handleTrait) {
        return;
    }
    // 判断当前的SizeClass,如果为width compact&height regular 则说明正在分屏
    BOOL isTrait = (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) && (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular);
 
    if (isTrait) {
        // 正在分屏
//        //NSLog(@"正在分屏");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RRSplit"];
    }else {
        
//        //NSLog(@"没有分屏");
        ;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"RRSplit"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
