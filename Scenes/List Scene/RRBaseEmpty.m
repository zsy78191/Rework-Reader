//
//  RRBaseEmpty.m
//  rework-reader
//
//  Created by 张超 on 2019/3/23.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRBaseEmpty.h"
#import "ClassyKitLoader.h"
@implementation RRBaseEmpty

- (NSDictionary *)attributesForEmptyDescription
{
    NSDictionary* d = [ClassyKitLoader values];
    return @{
             NSFontAttributeName: [UIFont fontWithName:d[@"$main-font"] size:[d[@"$sub-font-size"] floatValue]]
             };
}

- (NSDictionary *)attributesForEmptyTitle
{
    //    //NSLog(@"%@",[ClassyKitLoader values]);
    NSDictionary* d = [ClassyKitLoader values];
    return @{
             NSFontAttributeName: [UIFont fontWithName:d[@"$main-font"] size:[d[@"$main-font-size"] floatValue]]
             };
}

//- (NSDictionary *)buttonTitleAttributesForState:(NSUInteger)state
//{
//    NSDictionary* d = [ClassyKitLoader values];
//    return @{
//             NSFontAttributeName: [UIFont fontWithName:d[@"$main-font"] size:[d[@"$main-font-size"] floatValue]]
//             };
//}


- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return NO;
}
//

@end
