//
//  RRGetWebIconOperation.m
//  rework-reader
//
//  Created by 张超 on 2019/2/20.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRGetWebIconOperation.h"
@import RegexKitLite;

@implementation RRGetWebIconOperation

- (void)main
{
    if (!self.host) {
        return;
    }
    
    NSURLSessionConfiguration* c = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* s = [NSURLSession sessionWithConfiguration:c];
    NSURLSessionTask* t = [s dataTaskWithURL:self.host completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSString* temp = [str componentsMatchedByRegex:@"(?<=rel=\"shortcut icon\").*?(?=>)|(?<=rel=\"icon\").*?(?=>)"  options:RKLCaseless range:NSMakeRange(0, str.length) capture:0 error:nil].firstObject;
            
            NSString* icon = [temp componentsMatchedByRegex:@"(?<=href=\\\").*?(?=\\\")" options:RKLCaseless range:NSMakeRange(0, temp.length) capture:0 error:nil].firstObject;
            
            if (icon && ![icon hasPrefix:@"http"]) {
                if ([icon hasPrefix:@"./"]) {
                    icon = [NSString stringWithFormat:@"%@://%@/%@",[self.host scheme],[self.host host],[icon substringFromIndex:2]];
                }
                else if([icon hasPrefix:@"//"])
                {
                    icon = [NSString stringWithFormat:@"%@:%@",[self.host scheme],icon];
                }
                else if([icon hasPrefix:@"/"])
                {
                    icon = [NSString stringWithFormat:@"%@://%@/%@",[self.host scheme],[self.host host],[icon substringFromIndex:1]];
                }
               
            }
            
            if (!icon) {
                icon = [NSString stringWithFormat:@"%@://%@/favicon.ico",[self.host scheme],[self.host host]];
            }
            
            NSURLSessionTask* t = [s dataTaskWithURL:[NSURL URLWithString:icon] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                if ([(NSHTTPURLResponse*)response statusCode] >= 300) {
                    return;
                }
                if (error) {
                    return;
                }
                if (self.getIconBlock) {
                    self.getIconBlock(icon);
                }
            }];
            [t resume];
        }
    }];
    [t resume];
}

@end
