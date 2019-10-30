//
//  UIKeyCommand+iOS13.h
//  rework-reader
//
//  Created by 张超 on 2019/10/29.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIKeyCommand (iOS13)
+ (instancetype)keyCommandWithInput_IOS13:(NSString *)input modifierFlags:(UIKeyModifierFlags)modifierFlags action:(SEL)action discoverabilityTitle:(NSString *)discoverabilityTitle;
@end

NS_ASSUME_NONNULL_END
