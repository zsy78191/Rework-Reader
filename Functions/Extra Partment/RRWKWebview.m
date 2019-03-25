//
//  RRWKWebview.m
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRWKWebview.h"

@interface RRWKWebview ()
{
    
}
 
@end

@implementation RRWKWebview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
{
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


//- (UIScrollView *)scrollView
//{
//    if (!_theSV) {
//        _theSV = [[RRScrollView alloc] init];
//    }
//    return _theSV;
//}

@end
