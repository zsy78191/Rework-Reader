//
//  RRImageRender.h
//  rework-reader
//
//  Created by 张超 on 2019/3/18.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreImage;

NS_ASSUME_NONNULL_BEGIN

@interface RRImageRender : NSObject

+ (instancetype) sharedRender;
- (void)preloadFilters;

- (UIImage*)imageApplyFilters:(UIImage*)origin;

@end

NS_ASSUME_NONNULL_END
