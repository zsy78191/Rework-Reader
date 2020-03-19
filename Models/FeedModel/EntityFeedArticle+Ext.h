//
//  EntityFeedArticle+Ext.h
//  rework-reader
//
//  Created by 张超 on 2020/3/18.
//  Copyright © 2020 orzer. All rights reserved.
//

#import "EntityFeedArticle+CoreDataClass.h"
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface EntityFeedArticle (Ext)

- (NSString*)showContent;
- (CGFloat)titleHeightWithFont:(UIFont*)font  width:(CGFloat)width;
- (CGFloat)title:(NSString*)title HeightWithFont:(id)font width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
