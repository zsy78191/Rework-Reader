//
//  RRFeedFinder.m
//  rework-reader
//
//  Created by 张超 on 2019/4/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedFinder.h"
@import oc_string;
@import RegexKitLite;
@implementation RRFeedFinder

+ (void)findItem:(NSString *)url result:(void(^)(BOOL,NSString*))result
{
//    __weak typeof(self) weakSelf = self;
    [self findItemFinal:url result:^(BOOL a, NSString * u) {
        if (!a) {
            [[self class] findItemOther:[url stringByAppendingPathComponent:@"rss"] result:^(BOOL b , NSString * i) {
                if (!b) {
                    [[self class] findItemOther:[url stringByAppendingPathComponent:@"feed"] result:result];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        result(b,i);
                    });
                }
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(a,u);
            });
        }
    }];
}

+ (void)findItemWithContent:(NSString *)content url:(NSString*)url result:(void(^)(BOOL,NSString*))result
{
    NSArray* all = [content componentsMatchedByRegex:@"<link.*?>"];
    all = all.filter(^BOOL(NSString*  _Nonnull x) {
        BOOL ok = [x componentsMatchedByRegex:@"type=\"application/atom\\+xml\""].count > 0 || [x componentsMatchedByRegex:@"type=\"application/xml\""].count > 0 || [x componentsMatchedByRegex:@"type=\"application/rss\\+xml\""].count > 0;
        //                   NSLog(@"%@",@(ok));
        return ok;
    }).map(^id _Nonnull(NSString*   _Nonnull x) {
        return [x componentsMatchedByRegex:@"(?<=href=\").*?(?=\")"].firstObject;
    });
    //               NSLog(@"%@",all);
    
    if (all.count>0) {
        
        NSString* f = all.firstObject;
        if ([f hasPrefix:@"http"]) {
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    result(NO,f);
                });
            }
        }
        else {
            NSURL* u = [NSURL URLWithString:url];
            NSString* f = all.firstObject;
            f = [NSString stringWithFormat:@"%@://%@%@",u.scheme,u.host,f];
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    result(NO,f);
                });
            }
        }
    }
    else {
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(NO,nil);
            });
        }
    }
}

+ (void)findItemFinal:(NSString *)url result:(void(^)(BOOL,NSString*))result
{
    //    NSLog(@"find %@",url);
    NSURLSession* s = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask* t = [s dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([response.MIMEType rangeOfString:@"xml"].location != NSNotFound || [response.MIMEType rangeOfString:@"rss"].location != NSNotFound || [response.MIMEType rangeOfString:@"atom"].location != NSNotFound) {
            
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    result(YES,url);
                });
            }
        }
        else
        {
            NSString* s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [[self class] findItemWithContent:s url:url result:result];
        }
    }];
    [t resume];
}

+ (void)findItemOther:(NSString *)url result:(void(^)(BOOL,NSString*))result
{
    //    NSLog(@"find %@",url);
    NSURLSession* s = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask* t = [s dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([response.MIMEType rangeOfString:@"xml"].location != NSNotFound || [response.MIMEType rangeOfString:@"rss"].location != NSNotFound || [response.MIMEType rangeOfString:@"atom"].location != NSNotFound) {
            
            //            NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            
            if (result) {
                result(NO,url);
            }
        }
        else
        {
            if (result) {
                result(NO,nil);
            }
        }
    }];
    [t resume];
}

@end
