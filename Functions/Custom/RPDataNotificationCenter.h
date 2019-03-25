//
//  RPDataNotificationCenter.h
//  rework-password
//
//  Created by 张超 on 2019/1/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPDataNotificationCenter : NSObject

+ (instancetype)defaultCenter;

- (void)registEntityChange:(NSString*)entityClassName observer:(id)observer sel:(SEL)selector;
- (void)unregistEntityChange:(NSString*)entityClassName observer:(id)observer;

- (void)notificateWithEntityClass:(NSString*)entityClassName;

@end

NS_ASSUME_NONNULL_END
