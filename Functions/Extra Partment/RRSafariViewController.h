//
//  RRSafariViewController.h
//  rework-reader
//
//  Created by 张超 on 2019/3/24.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <SafariServices/SafariServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRSafariViewController : SFSafariViewController
@property (nonatomic, assign) BOOL handleTrait;
@end

NS_ASSUME_NONNULL_END
