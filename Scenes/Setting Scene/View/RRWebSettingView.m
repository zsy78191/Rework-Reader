//
//  RRWebSettingView.m
//  rework-reader
//
//  Created by 张超 on 2019/3/7.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRWebSettingView.h"
#import "RRSettingApperance.h"
@import Classy;
@interface RRWebSettingView ()

@end

@implementation RRWebSettingView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.prefersLargeTitles = NO;
    self.title = @"阅读设置";
//    //NSLog(@"%@",self.view);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];
    
    self.appear = [RRSettingApperance new];
    
//    MVPTableViewOutput* o = self.outputer;
    
    [self.outputer setRegistBlock:^(MVPTableViewOutput* output) {
        [output registNibCell:@"RRIconSettingCell" withIdentifier:@"iconCell"];
        [output registNibCell:@"RRTitleCell" withIdentifier:@"titleCell"];
    }];
}

- (Class)mvp_presenterClass
{
   return NSClassFromString(@"RRWebSettingPresenter");
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
