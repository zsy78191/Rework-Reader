//
//  UIApplication+iOS13.m
//  rework-reader
//
//  Created by 张超 on 2019/10/29.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "UIApplication+iOS13.h"

@implementation UIApplication (iOS13)

- (UIWindow* _Nullable)keyWindowiOS13
{
    if (@available(iOS 13.0, *)) {
      id scene =  [[UIApplication sharedApplication].connectedScenes anyObject];
      if(scene && [scene isKindOfClass:[UIWindowScene class]]) {
          UIWindowScene* ws = scene;
          return [ws.windows firstObject];
      }
    }
    #if !TARGET_OS_MACCATALYST
         return [self keyWindow];
    #else
        return nil;
    #endif
}

@end
