//
//  RRWebHandler.m
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRWebHandler.h"
@import SDWebImage;
@implementation RRWebHandler
//这里拦截到URLScheme为customScheme的请求后，读取本地图片test.jpg，并返回给WKWebView显示
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask;
{
    NSString *urlString = urlSchemeTask.request.URL.relativeString;
   
//    NSLog(@"-- %@",urlString);
    __block NSData *data = nil;
    
//    UIImage* i = [[[SDWebImageManager sharedManager] imageCache] imageFromMemoryCacheForKey:[urlString substringFromIndex:5]];
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[urlString substringFromIndex:5]] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        
        data = UIImageJPEGRepresentation(image, 1);
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:@"image/jpeg" expectedContentLength:data.length textEncodingName:nil];
        [urlSchemeTask didReceiveResponse:response];
        
        [urlSchemeTask didReceiveData:data];
        [urlSchemeTask didFinish];
    }];
}

- (void)t
{
    id <WKURLSchemeTask> urlSchemeTask;
    NSString* urlString;
    NSData* data;
    if([urlString containsString:@"siyuan"]) {
        
        if ([urlString hasSuffix:@"otf"]) {
            NSString *fontUrl = [[NSBundle mainBundle] pathForResource:@"SourceHanSerifCN-Regular" ofType:@"otf"];
            data = [NSData dataWithContentsOfFile:fontUrl];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:@"application/x-font-truetype" expectedContentLength:data.length textEncodingName:nil];
            [urlSchemeTask didReceiveResponse:response];
            
        }
        else if([urlString hasSuffix:@"js"])
        {
            NSURL* url = urlSchemeTask.request.URL;
            NSArray* jsArr = [url.host componentsSeparatedByString:@"."];
            data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:jsArr[0] ofType:jsArr[1]]];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:@"application/x-javascript" expectedContentLength:data.length textEncodingName:nil];
            [urlSchemeTask didReceiveResponse:response];
            
        }
        else if([urlString hasPrefix:@"innerhttps"])
        {
            
        }
    }
    
}

- (void)webView:(WKWebView *)webVie stopURLSchemeTask:(id)urlSchemeTask {
//    urlSchemeTask = nil;
}
@end
