//
//  RRPhotoBrowser.m
//  rework-reader
//
//  Created by 张超 on 2019/2/27.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRPhotoBrowser.h"
@import Classy;
@interface RRPhotoBrowser ()
{
}
@property (nonatomic, assign) BOOL originPrefersLargeTitles;
@property (nonatomic, assign) BOOL originShowToolbar;
@end

@implementation RRPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"%@",obj);
        if ([obj isKindOfClass:[UIToolbar class]]) {
            obj.cas_styleClass = @"PhotoToolBar";
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.originPrefersLargeTitles = self.navigationController.navigationBar.prefersLargeTitles;
    [self.navigationController.navigationBar setPrefersLargeTitles:NO];
    self.originShowToolbar = self.navigationController.isToolbarHidden;
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setPrefersLargeTitles:self.originPrefersLargeTitles];
    [self.navigationController setToolbarHidden:self.originShowToolbar animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
