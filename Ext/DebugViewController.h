//
//  DebugViewController.h
//  rework-reader
//
//  Created by 张超 on 2019/11/25.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DebugViewController : UIViewController
@property (nonatomic, strong) void (^ actionBlock)(NSInteger selection);
@property (nonatomic, assign) BOOL hideFirst;
@end

NS_ASSUME_NONNULL_END
