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
         return UIStatusBarStyleDefault;
    }
    return [self.topViewController preferredStatusBarStyle];
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
