//
//  RRFeedInfoListOtherModel.m
//  rework-reader
//
//  Created by 张超 on 2019/2/21.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedInfoListOtherModel.h"

//@property (nonatomic, assign) RRFeedInfoListOtherModelType type;
//@property (nonatomic, strong) NSString* title;
//@property (nonatomic, assign) NSUInteger count;
//@property (nonatomic, strong) NSString* subtitle;
//@property (nonatomic, strong) NSString* icon;
//@property (nonatomic, strong, nullable) NSString* key;
//@property (nonatomic, assign) BOOL canRefresh;
//
//@property (nonatomic, strong, nullable) RRReadStyle* readStyle;


RRFeedInfoListOtherModel* (^GetRRFeedInfoListOtherModel)(NSString* title,NSString* icon, NSString* subtitle, NSString* key) = ^(NSString* title,NSString* icon, NSString* subtitle, NSString* key){
    @autoreleasepool{
        RRFeedInfoListOtherModel* m = [[RRFeedInfoListOtherModel alloc] init];
        m.title = title;
        m.icon = icon;
        m.subtitle = subtitle;
        m.key = key;
        m.type = RRFeedInfoListOtherModelTypeItem;
        return m;
    }
};

@implementation RRFeedInfoListOtherModel

@synthesize canEdit = _canEdit;
@synthesize editType = _editType;
@synthesize canMove = _canMove;
@synthesize idx = _idx;
@end
