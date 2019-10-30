//
//  UIKeyCommand+iOS13.m
//  rework-reader
//
//  Created by 张超 on 2019/10/29.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "UIKeyCommand+iOS13.h"


@implementation UIKeyCommand (iOS13)
+ (instancetype)keyCommandWithInput_IOS13:(NSString *)input modifierFlags:(UIKeyModifierFlags)modifierFlags action:(SEL)action discoverabilityTitle:(NSString *)discoverabilityTitle;
{
#if !TARGET_OS_MACCATALYST
    if (@available(iOS 13.0, *)) {
         return [[self class] keyCommandWithInput:input modifierFlags:modifierFlags action:action];
    }
    return [[self class] keyCommandWithInput:input modifierFlags:modifierFlags action:action discoverabilityTitle:discoverabilityTitle];
#else
   return [[self class] keyCommandWithInput:input modifierFlags:modifierFlags action:action];
#endif
}
@end
