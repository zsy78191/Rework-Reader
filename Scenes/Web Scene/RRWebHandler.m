//
//  RRWebHandler.m
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRWebHandler.h"
@import SDWebImage;

@interface RRWebHandler ()
{
    
}
@property (nonatomic, strong) NSHashTable* table;
@end

@implementation RRWebHandler

- (NSHashTable *)table
{
    if (!_table) {
        _table = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:10];
    }
    return _table;
}

//这里拦截到URLScheme为customScheme的请求后，读取本地图片test.jpg，并返回给WKWebView显示
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask;
{
    NSString *urlString = urlSchemeTask.request.URL.relativeString;
   
//    ////NSLog(@"-- %@",urlString);
//    __block NSData *data = nil;
    __weak typeof(self) weakSelf = self;
    if ([urlString hasPrefix:@"local"]) {
        
//        //NSLog(@"%@",urlString);
        NSString* name = [urlString substringFromIndex:8];
//        //NSLog(@"%@",name);
      
        UIImage* i  = [UIImage imageNamed:name];
        UIImage* t = [UIImage imageWithCGImage:i.CGImage scale:2 orientation:UIImageOrientationUp];
        [[SDImageCache sharedImageCache] storeImage:t forKey:urlString completion:^{
            
        }];
        NSData* data = UIImagePNGRepresentation(t);
        NSString* mtype = @"application/x-img";
        if (urlSchemeTask) {
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:mtype expectedContentLength:data.length textEncodingName:nil];
            [urlSchemeTask didReceiveResponse:response];
            [urlSchemeTask didReceiveData:data];
            [urlSchemeTask didFinish];
        }
        return;
    }
    
    NSURL* url = [NSURL URLWithString:[urlString substringFromIndex:5]];
    UIImage* image = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:[url absoluteString]];
    if (image) {
        if (weakSelf.table.count > 0) {
            if ([weakSelf.table containsObject:urlSchemeTask]) {
                return;
            }
        }
        
        NSString* mtype = @"application/x-img";
        switch ([image sd_imageFormat]) {
            case SDImageFormatGIF:
            {
                mtype = @"image/gif";
                break;
            }
            case SDImageFormatPNG:
            {
                mtype = @"image/png";
                break;
            }
            case SDImageFormatJPEG:
            {
                mtype = @"image/jpeg";
                break;
            }
            case SDImageFormatWebP:
            {
                mtype = @"application/x-img";
                break;
            }
            case SDImageFormatUndefined:
            {
                mtype = @"text/xml";
                break;
            }
            default:
                break;
        }
        
        NSData* data = [image sd_imageData];
        
        if (urlSchemeTask) {
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:mtype expectedContentLength:data.length textEncodingName:nil];
            [urlSchemeTask didReceiveResponse:response];
            [urlSchemeTask didReceiveData:data];
            [urlSchemeTask didFinish];
        }
    }
    else {
        [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
            if (weakSelf.table.count > 0) {
                if ([weakSelf.table containsObject:urlSchemeTask]) {
                    return;
                }
            }
            
            if (error) {
                ////NSLog(@"%@",error);
                [urlSchemeTask didFailWithError:error];
                return;
            }
            //        data = UIImageJPEGRepresentation(image, 1);
            NSString* mtype = @"application/x-img";
            switch ([image sd_imageFormat]) {
                case SDImageFormatGIF:
                {
                    mtype = @"image/gif";
                    break;
                }
                case SDImageFormatPNG:
                {
                    mtype = @"image/png";
                    break;
                }
                case SDImageFormatJPEG:
                {
                    mtype = @"image/jpeg";
                    break;
                }
                case SDImageFormatWebP:
                {
                    mtype = @"application/x-img";
                    break;
                }
                case SDImageFormatUndefined:
                {
                    mtype = @"text/xml";
                    break;
                }
                default:
                    break;
            }
            
            if (!data && image) {
                //            ////NSLog(@"没有图");
                data = [image sd_imageData];
            }
            
            if (urlSchemeTask) {
                NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:mtype expectedContentLength:data.length textEncodingName:nil];
                [urlSchemeTask didReceiveResponse:response];
                [urlSchemeTask didReceiveData:data];
                [urlSchemeTask didFinish];
            }
        }];
    }
   
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

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id)urlSchemeTask {
//    urlSchemeTask = nil;
//    urlSchemeTask = nil;
//    [urlSchemeTask didFinish];
    [self.table addObject:urlSchemeTask];
}
@end
