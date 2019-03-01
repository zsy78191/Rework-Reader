//
//  RRAddModel.m
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRAddModel.h"

@implementation RRAddModel

+ (RRAddModel * _Nonnull (^)(NSString * _Nonnull, id _Nonnull, NSString * _Nonnull, RRAddModelType))model
{
    return ^ (NSString* title,id value,NSString* key,RRAddModelType type) {
        RRAddModel* model = [[RRAddModel alloc] init];
        model.title = title;
        model.value = value;
        model.key = key;
        model.type = type;
        return model;
    };
}

@end
