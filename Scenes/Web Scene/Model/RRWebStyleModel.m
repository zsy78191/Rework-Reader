//
//  RRWebStyleModel.m
//  rework-reader
//
//  Created by 张超 on 2019/3/7.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRWebStyleModel.h"

NSString* const kWebFontSize = @"kWebFontSize";
NSString* const kWebTitleFontSize = @"kWebTitleFontSize";
NSString* const kWebLineHeight = @"kWebLineHeight";
NSString* const kWebAlign = @"kWebAlign";
NSString* const kWebFont = @"kWebFont";


@implementation RRWebStyleModel

- (void)syncToCurrentStyle
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:self.fontSize forKey:kWebFontSize];
    [ud setInteger:self.titleFontSize forKey:kWebTitleFontSize];
    [ud setDouble:self.lineHeight forKey:kWebLineHeight];
    [ud setObject:self.align forKey:kWebAlign];
    [ud setObject:self.font forKey:kWebFont];
    [ud synchronize];
}

+ (instancetype)currentStyle
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    RRWebStyleModel * m = [[RRWebStyleModel alloc] init];
    m.titleFontSize = [ud integerForKey:kWebTitleFontSize];
    m.fontSize = [ud integerForKey:kWebFontSize];
    m.lineHeight = [ud doubleForKey:kWebLineHeight];
    m.align = [ud stringForKey:kWebAlign];
    m.font = [ud stringForKey:kWebFont];
    
    return m;
}

+ (void)setupDefalut
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kWebFontSize:@(18),kWebTitleFontSize:@(24),kWebLineHeight:@(1.8),kWebAlign:@"left",kWebFont:@"PingFangSC-Light"}];
}

@end
