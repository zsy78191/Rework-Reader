//
//  RRSplitViewController.m
//  rework-reader
//
//  Created by 张超 on 2019/3/21.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSplitViewController.h"

@interface RRSplitViewController ()

@end

@implementation RRSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.restorationIdentifier = @"RRSplitViewController";
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [[self.viewControllers firstObject] preferredStatusBarStyle];
}

@end
