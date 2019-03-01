//
//  RRFeedPresenter.h
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;
#import "MVPViewLoadProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface RRFeedPresenter : MVPPresenter <MVPViewLoadProtocol>
{
    
}
@property (nonatomic, strong) NSString* title;
@end

NS_ASSUME_NONNULL_END
