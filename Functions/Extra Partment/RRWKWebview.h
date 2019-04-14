//
//  RRWKWebview.h
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRWKWebview : WKWebView
- (UIImage *)imageRepresentation;
- (NSData *)PDFData;
@end

NS_ASSUME_NONNULL_END
