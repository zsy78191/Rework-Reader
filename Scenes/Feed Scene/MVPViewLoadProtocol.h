//
//  MVPViewLoadProtocol.h
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MVPViewLoadProtocol <NSObject>

@required

- (void)loadData:(id)data;
- (void)loadIcon:(NSString*)icon;
- (void)loadError:(NSError*)error;
- (void)loadFinish;
- (void)cancelit;

@optional

@property (nonatomic, strong) void (^cancelBlock)(void);

@end

NS_ASSUME_NONNULL_END
