//
//  AppDelegate+Crash.m
//  rework-reader
//
//  Created by 张超 on 2019/11/20.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "AppDelegate+Crash.h"
 
@import KSCrash;

@implementation AppDelegate (Crash)

- (void)crashReporterSetup
{
//    KSCrashInstallationEmail* installation = [KSCrashInstallationEmail sharedInstance];
//    installation.recipients = @[@"nsstring@qq.com"];
//
//    // Optional (Email): Send Apple-style reports instead of JSON
//    [installation setReportStyle:KSCrashEmailReportStyleApple useDefaultFilenameFormat:YES];
//
//    // Optional: Add an alert confirmation (recommended for email installation)
//    [installation addConditionalAlertWithTitle:@"程序停止运行" message:@"是否需要向开发者发送一份报告？" yesAnswer:@"发送" noAnswer:@"不了"];
    KSCrashInstallationQuincy* installation = [KSCrashInstallationQuincy sharedInstance];
    installation.url = [NSURL URLWithString:@"http://p.gerinn.com/test/report/crash_v300.php"];
    
    [installation install];
    
    self.ci1 = installation;
 
    KSCrashInstallationEmail* i2 = [KSCrashInstallationEmail sharedInstance];
    i2.recipients = @[@"nsstring@qq.com"];
    [i2 setReportStyle:KSCrashEmailReportStyleApple useDefaultFilenameFormat:YES];
    [i2 addConditionalAlertWithTitle:@"您的App在运行时产生了错误" message:@"是否需要向开发者发送一份报告？" yesAnswer:@"发送" noAnswer:@"不了"];
    [i2 install];
    
    self.ci2 = i2;
    
  
}

@end
