//
//  RRWebView.h
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;
@import WebKit;
#import "RRWKWebview.h"
#import "RRProvideDataProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface RRWebView : MVPView <RRProvideDataProtocol>
@property (nonatomic, strong) RRWKWebview *webView;



@end

NS_ASSUME_NONNULL_END
