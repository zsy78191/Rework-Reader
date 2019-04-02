//
//  RPDataLocker.m
//  rework-password
//
//  Created by 张超 on 2019/1/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPDataLocker.h"
@import oc_string;

@implementation RPDataLocker

+ (NSData*)lockString:(NSString*)string;
{
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)unlockString:(NSData *)data
{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
