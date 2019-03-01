//
//  RPDataLocker.h
//  rework-password
//
//  Created by 张超 on 2019/1/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPDataLocker : NSObject


+ (NSData*)lockString:(NSString*)string;
+ (NSString*)unlockString:(NSData*)data;


@end

NS_ASSUME_NONNULL_END
