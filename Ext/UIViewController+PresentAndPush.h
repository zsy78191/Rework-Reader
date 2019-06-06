//
//  UIViewController+PresentAndPush.h
//  rework-reader
//
//  Created by 张超 on 2019/6/4.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (PresentAndPush)

- (void)presentOrPushViewController:(__kindof UIViewController*)controller;
- (void)dismissOrPopViewController;
@end

NS_ASSUME_NONNULL_END
