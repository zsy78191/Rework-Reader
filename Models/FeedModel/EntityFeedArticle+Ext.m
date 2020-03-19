//
//  EntityFeedArticle+Ext.m
//  rework-reader
//
//  Created by 张超 on 2020/3/18.
//  Copyright © 2020 orzer. All rights reserved.
//

#import "EntityFeedArticle+Ext.h"
@import Foundation;
@import oc_string;
#import "NSString+HTML.h"
@import RegexKitLite;

@implementation EntityFeedArticle (Ext)

- (NSString *)showContent
{
    NSString* temp = self.content.length > 30 ? self.content : self.summary;
    temp = [temp stringByDecodingHTMLEntities];
    temp = [temp stringByConvertingHTMLToPlainText];
    temp = [temp stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    temp = [temp stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@" "];
    return temp;
}

- (CGFloat)titleHeightWithFont:(id)font width:(CGFloat)width
{
    return [self title:self.title HeightWithFont:font width:width];
}


- (CGFloat)title:(NSString*)title HeightWithFont:(id)font width:(CGFloat)width
{
    return [title boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.height;
}

@end
