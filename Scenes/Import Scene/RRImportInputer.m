//
//  RRImportInputer.m
//  rework-reader
//
//  Created by 张超 on 2019/3/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRImportInputer.h"
#import "OPMLDocument.h"
@implementation RRImportInputer

- (NSString *)mvp_identifierForModel:(id<MVPModelProtocol>)model
{
    OPMLOutline* o = model;
    if (o.subOutlines.count > 0) {
        return @"titleCell";
    }
    return @"cell";
}

@end
