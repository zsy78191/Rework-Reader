//
//  RRSafariViewController.m
//  rework-reader
//
//  Created by 张超 on 2019/3/24.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSafariViewController.h"
#import "ClassyKitLoader.h"
@import ui_base;

@interface RRSafariViewController () <SFSafariViewControllerDelegate>

@end

@implementation RRSafariViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.handleTrait = YES;
    
    NSDictionary* d = [ClassyKitLoader values];
    self.preferredBarTintColor = UIColor.hex(d[@"$bar-tint-color"]);
    self.preferredControlTintColor = UIColor.hex(d[@"$main-tint-color"]);
    // Do any additional setup after loading the view.
    
//    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    self.delegate = self;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
//    //NSLog(@"111 %@",self.navigationController);
//    //NSLog(@"222 %@",self.navigationController.navigationController);
//    if (self.navigationController.navigationController) {
//        [self.navigationController.navigationController setNavigationBarHidden:YES animated:NO];
//        [self.navigationController.navigationController setToolbarHidden:YES animated:NO];
//    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// 当SizeClass发生变化后调用
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    
    if (!self.handleTrait) {
        return;
    }
    // 判断当前的SizeClass,如果为width compact&height regular 则说明正在分屏
    BOOL isTrait = (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) && (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular);
    
    if (isTrait) {
        // 正在分屏
        //NSLog(@"SF正在分屏");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RRSplit"];
    }else {
        
        //NSLog(@"SF没有分屏");
        ;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"RRSplit"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
//    self.navigationItem.leftBarButtonItem = self.navigationController.splitViewController.displayModeButtonItem;
//    self.navigationItem.leftItemsSupplementBackButton = YES;
}

@end
