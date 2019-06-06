//
//  UIViewController+PresentAndPush.m
//  rework-reader
//
//  Created by 张超 on 2019/6/4.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "UIViewController+PresentAndPush.h"
#import "RRExtraViewController.h"
@import ui_base;
@import ReactiveObjC;

@implementation UIViewController (PresentAndPush)

- (void)dismissOrPopViewController
{
     if ([UIDevice currentDevice].iPad()) {
         [self dismissViewControllerAnimated:YES completion:nil];
     }
     else {
         [self navigationController] ? [[self navigationController] popViewControllerAnimated:YES] : [self dismissViewControllerAnimated:YES completion:nil];
     }
}

- (void)presentOrPushViewController:(__kindof UIViewController *)controller
{
    UIViewController* view = controller;
    if ([UIDevice currentDevice].iPad()) {
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
        [self presentViewController:rr animated:YES completion:nil];
    }
    else {
        [self showViewController:view sender:nil];
    }
}

@end
