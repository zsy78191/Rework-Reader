//
//  OPMLDocument.h
//  rework-reader
//
//  Created by 张超 on 2019/3/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <UIKit/UIKit.h>
@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

@interface OPMLOutline : MVPModel

@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* xmlUrl;
@property (nonatomic, strong) NSString* htmlUrl;

@property (nonatomic, strong) NSArray* subOutlines;

@end


@interface OPMLDocument : UIDocument
@property (nonatomic, strong, nullable) NSMutableArray<OPMLOutline*>* outlines;
@property (nonatomic, strong, nullable) NSString* headTitle;
@end

NS_ASSUME_NONNULL_END
