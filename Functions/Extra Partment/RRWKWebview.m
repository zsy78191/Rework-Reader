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

- (void)dealloc
{
    //NSLog(@"%s",__func__);
}

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


- (UIImage *)imageRepresentation
{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize contentSize = self.scrollView.contentSize;
    CGFloat contentHeight = contentSize.height;
    
    CGPoint offset = self.scrollView.contentOffset;
    
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    
    NSMutableArray *images = [NSMutableArray array];
    while (contentHeight > 0) {
        UIGraphicsBeginImageContextWithOptions(boundsSize, NO, 0.0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [images addObject:image];
        
        CGFloat offsetY = self.scrollView.contentOffset.y;
        [self.scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];
        contentHeight -= boundsHeight;
    }
    
    [self.scrollView setContentOffset:offset];
    
    CGSize imageSize = CGSizeMake(contentSize.width * scale,
                                  contentSize.height * scale);
    UIGraphicsBeginImageContext(imageSize);
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        [image drawInRect:CGRectMake(0,
                                     scale * boundsHeight * idx,
                                     scale * boundsWidth,
                                     scale * boundsHeight)];
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;
}

- (NSData *)PDFData
{
    UIViewPrintFormatter *fmt = [self viewPrintFormatter];
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    [render addPrintFormatter:fmt startingAtPageAtIndex:0];
    
    CGRect page;
    page.origin.x = 0;
    page.origin.y = 0;
    page.size.width = self.frame.size.width;
    page.size.height = self.frame.size.height;
    
    CGRect printable = CGRectInset( page, 0, -16);
    printable.origin.y = 8;
    [render setValue:[NSValue valueWithCGRect:page] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printable] forKey:@"printableRect"];
    
    NSMutableData * pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData( pdfData, printable, nil );
    
    for (NSInteger i=0; i < [render numberOfPages]; i++)
    {
        UIGraphicsBeginPDFPage();
        CGRect bounds = UIGraphicsGetPDFContextBounds();
        [render drawPageAtIndex:i inRect:bounds];
    }
    UIGraphicsEndPDFContext();
    return pdfData;
}

- (void)emailString:(void (^)(NSString* ))htmlString
{
    [self evaluateJavaScript:@"document.getElementsByTagName('html')[0].innerHTML" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if (htmlString) {
            htmlString(data);
        }
    }];
}

@end
