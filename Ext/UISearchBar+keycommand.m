//
//  UISearchBar+keycommand.m
//  rework-reader
//
//  Created by 张超 on 2019/6/6.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "UISearchBar+keycommand.h"
#import "RRExtraViewController.h"

#import "UIKeyCommand+iOS13.h"
@implementation UISearchBar (keycommand)

- (NSArray<UIKeyCommand *> *)keyCommands
{
    return @[
        [UIKeyCommand keyCommandWithInput_IOS13:UIKeyInputEscape modifierFlags:0 action:@selector(resignResponeser:) discoverabilityTitle:@"取消"]
             ];
}

- (void)resignResponeser:(id)sender
{
    [self resignFirstResponder];
    id v = [self nextResponder];
    while (![v isKindOfClass:[RRExtraViewController class]]) {
        v = [v nextResponder];
    }
    RRExtraViewController* e = v;
    [e.topViewController becomeFirstResponder];
}


@end
