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
#import "RRCoreDataModel.h"
@import oc_string;
@import ui_base;

@implementation RRFeedListPresenter (FeedHUB)

- (void)addHUB
{
    if (self.selectArray.count == 0) {
        [[self view] hudInfo:@"请先选择订阅源"];
        return;
    }
    
    NSArray* a =
    self.selectArray.map(^id _Nonnull(id  _Nonnull x) {
        return [self.complexInput mvp_modelAtIndexPath:x];
    });
    
    NSArray* hubs =
    a.map(^id _Nonnull(RRFeedInfoListModel*  _Nonnull x) {
        return x.thehub;
    });
    
    if (hubs.count>0) {
        [self addHUBWithName:@""];
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
    NSArray* a =
    self.selectArray.map(^id _Nonnull(id  _Nonnull x) {
        return [self.complexInput mvp_modelAtIndexPath:x];
    });
    
    NSArray* hubs =
    a.map(^id _Nonnull(RRFeedInfoListModel*  _Nonnull x) {
        return x.thehub;
    });
    
    NSArray* b = a.map(^id _Nonnull(RRFeedInfoListModel*  _Nonnull x) {
        return x.feed;
    });
    
    if (hubs.count == 0) {
        RRFeedHub* hub = [RRFeedManager hubWithName:name];
        hub.named(name);
        [self addFeed:b hub:hub];
    }
    else if (hubs.count == 1) {
        RRFeedHub* h = [RRFeedHub hubWithEntity:[hubs lastObject]];
        [self addFeed:b hub:h];
    }
    else if (hubs.count > 1)
    {
        __weak typeof(self) weakSelf = self;
        UIAlertController* alert = UI_Alert()
        .titled(@"请选择将源添加进哪一个分类");
        [hubs enumerateObjectsUsingBlock:^(EntityHub*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            alert.action(obj.title, ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
                RRFeedHub* h = [RRFeedHub hubWithEntity:obj];
                [weakSelf addFeed:b hub:h];
            });
        }];
        alert.cancel(@"取消", nil);
        alert.show((id)self.view);
    }
    
//    NSLog(@"%@",a);
 
}

- (void)addFeed:(NSArray*)feeds hub:(RRFeedHub*)hub
{
    __weak typeof(self) weakself = self;
    hub.insertFeeds(feeds)
    .save(^(BOOL s) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (s) {
                [weakself.view hudSuccess:@"添加成功"];
                [(UIViewController*)[weakself view] setEditing:NO animated:YES];
            }
            else {
                [weakself.view hudFail:@"添加失败"];
            }
        });
    });
}

@end
