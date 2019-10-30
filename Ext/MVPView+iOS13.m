//
//  MVPView+iOS13.m
//  rework-reader
//
//  Created by 张超 on 2019/10/29.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "MVPView+iOS13.h"

@implementation MVPView (iOS13)

- (CGRect)statusframe
{
    if (@available(iOS 13.0, *)) {
        id scene =  [[UIApplication sharedApplication].connectedScenes anyObject];
        if(scene && [scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene* ws = scene;
            return ws.statusBarManager.statusBarFrame;
        }
    } else {
       #if !TARGET_OS_MACCATALYST
           return [UIApplication sharedApplication].statusBarFrame;
       #endif
    }
    return CGRectZero;
}

@end
