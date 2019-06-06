//
//  RRFeedListPresenter+FeedHUB.m
//  rework-reader
//
//  Created by 张超 on 2019/6/6.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedListPresenter+FeedHUB.h"
#import "RRFeedManager.h"
#import "RRFeedInfoListModel.h"
@import oc_string;
@import ui_base;

@implementation RRFeedListPresenter (FeedHUB)

- (void)addHUB
{
    if (self.selectArray.count == 0) {
        [[self view] hudInfo:@"请先选择订阅源"];
        return;
    }
    __weak typeof(self) weakself = self;
    UI_Alert()
    .titled(@"请输入分类标题")
    .recommend(@"确定", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        UITextField* t = alert.textFields[0];
        [weakself addHUBWithName:t.text];
    })
    .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
        
    })
    .input(@"标题", ^(UITextField * _Nonnull field) {
        
    })
    .show((id)self.view);
}

- (void)addHUBWithName:(NSString*)name
{
    RRFeedHub* hub = [RRFeedManager hubWithName:name];
    NSArray* a =
    self.selectArray.map(^id _Nonnull(id  _Nonnull x) {
        return [self.complexInput mvp_modelAtIndexPath:x];
    }).map(^id _Nonnull(RRFeedInfoListModel*  _Nonnull x) {
        return x.feed;
    });
//    NSLog(@"%@",a);
    __weak typeof(self) weakself = self;
    hub.insertFeeds(a)
    .named(name)
    .save(^(BOOL s) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (s) {
                [weakself.view hudSuccess:@"添加成功"];
            }
            else {
                [weakself.view hudFail:@"添加失败"];
            }
        });
    });
}

@end
