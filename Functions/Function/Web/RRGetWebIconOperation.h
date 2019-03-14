//
//  RRGetWebIconOperation.h
//  rework-reader
//
//  Created by 张超 on 2019/2/20.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRGetWebIconOperation : NSOperation

@property (nonatomic, strong) NSURL* host;

@property (nonatomic, strong) void (^getIconBlock)(NSString* icon);

@end

NS_ASSUME_NONNULL_END
