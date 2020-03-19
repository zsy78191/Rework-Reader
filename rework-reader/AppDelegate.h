//
//  AppDelegate.h
//  rework-reader
//
//  Created by 张超 on 2019/1/15.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KSCrashInstallationQuincy;
@class KSCrashInstallationEmail;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) KSCrashInstallationQuincy* ci1;
@property (nonatomic, strong) KSCrashInstallationEmail* ci2;

@end

