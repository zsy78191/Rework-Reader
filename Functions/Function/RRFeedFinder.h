//
//  RRFeedFinder.h
//  rework-reader
//
//  Created by 张超 on 2019/4/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRFeedFinder : NSObject

+ (void)findItem:(NSString *)url result:(void(^)(BOOL,NSString*))result;

@end

NS_ASSUME_NONNULL_END
