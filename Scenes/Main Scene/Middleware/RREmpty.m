//
//  RREmpty.m
//  rework-reader
//
//  Created by 张超 on 2019/2/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RREmpty.h"
#import "ClassyKitLoader.h"

@implementation RREmpty

- (NSString *)titleForEmptyTitle
{
    return @"空空如也";
}

- (NSDictionary *)attributesForEmptyTitle
{
//    NSLog(@"%@",[ClassyKitLoader values]);
    NSDictionary* d = [ClassyKitLoader values];
    return @{
             NSFontAttributeName: [UIFont fontWithName:d[@"$main-font"] size:[d[@"$main-font-size"] floatValue]]
             };
}

- (NSString *)buttonTitleForState:(NSUInteger)state
{
    return @"";
//    return @"探索RSS世界";
}

- (NSString *)titleForEmptyDescription
{
    return @"点击下方按钮添加开启订阅";
}

- (NSDictionary *)attributesForEmptyDescription
{
    NSDictionary* d = [ClassyKitLoader values];
    return @{
             NSFontAttributeName: [UIFont fontWithName:d[@"$main-font"] size:[d[@"$sub-font-size"] floatValue]]
             };
}

- (NSDictionary *)buttonTitleAttributesForState:(NSUInteger)state
{
    NSDictionary* d = [ClassyKitLoader values];
    return @{
             NSFontAttributeName: [UIFont fontWithName:d[@"$main-font"] size:[d[@"$main-font-size"] floatValue]]
             };
}

@end
