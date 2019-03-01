//
//  RRSettingPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/1/28.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSettingPresenter.h"
#import "RRModelItem.h"
#import "RPSettingInputer.h"
@import SafariServices;
#import "RRFeedLoader.h"
@import ui_base;
#import "MVPViewLoadProtocol.h"
#import "RRGetWebIconOperation.h"

@interface RRSettingPresenter ()
{
    
}
@property (nonatomic, strong) RRModelItem* item;
@property (nonatomic, strong) RPSettingInputer* inputer;
@property (nonatomic, assign) BOOL feeding;
@property (nonatomic, weak) FMFeedParserOperation* currentOperation;

@end

@implementation RRSettingPresenter

- (RPSettingInputer *)inputer
{
    if (!_inputer) {
        _inputer = [[RPSettingInputer alloc] init];
    }
    return _inputer;
}

- (RRModelItem *)item
{
    if (!_item) {
        NSError *error;
        NSError *error2;
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"ModelTypeSetting" withExtension:@"json"];
        NSString* json = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            DDLogError(@"%@",error);
        }
        _item = [RRModelItem fromJSON:json encoding:NSUTF8StringEncoding error:&error2];
        if (error2) {
            DDLogError(@"%@",error2);
        }
    }
    return _item;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"更多内容";
        [[self.item setting] enumerateObjectsUsingBlock:^(RRSetting * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.inputer mvp_addModel:obj];
        }];
    }
    return self;
}


- (id)mvp_inputerWithOutput:(id<MVPOutputProtocol>)output
{
    return self.inputer;
}

- (void)mvp_action_selectItemAtIndexPath:(NSIndexPath *)path
{
    switch (path.section*10 + path.row) {
        case 0:
        {
            [self openVersion];
            break;
        }
        case 1:
        {
            [self openAbout];
            break;
        }
        case 2:
        {
            [self feedOffical];
            break;
        }
        case 3:
        {
            [self openWiki];
            break;
        }
        default:
            break;
    }
}

- (void)openAbout
{
    id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":@"什么是RSS.md"}];
    [[self view] mvp_pushViewController:vc];
}

- (void)openWiki
{
    id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":@"Reader SP说明书.md"}];
    [[self view] mvp_pushViewController:vc];
}

- (void)openVersion
{
    id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":@"Reader 版本.md"}];
    [[self view] mvp_pushViewController:vc];
}




- (void)feedOffical
{
    if (self.feeding) {
        return;
    }
    self.feeding = YES;
    
    UIViewController* vc = (UIViewController*)[self view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc hudWait:@"订阅中"];
    });
    
    id v = [MVPRouter viewForURL:@"rr://feed" withUserInfo:nil];
    id<MVPViewLoadProtocol> tv = nil;
    if ([v conformsToProtocol:@protocol(MVPViewLoadProtocol)]) {
        tv = v;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self view] mvp_pushViewController:v];
    });
    
    __weak typeof(self) weakself = self;
    FMFeedParserOperation* operation = [[RRFeedLoader sharedLoader] loadOfficalWithInfoBlock:^(MWFeedInfo * _Nonnull info) {
        [tv loadData:info];
        
        RRGetWebIconOperation* o = [[RRGetWebIconOperation alloc] init];
        [o setHost:info.url];
        [o setGetIconBlock:^(NSString * _Nonnull icon) {
            [tv loadIcon:icon];
        }];
        [o start];
        
    } itemBlock:^(MWFeedItem * _Nonnull item) {
//        NSLog(@"%@",item);
        [tv loadData:item];
        
    } errorBlock:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc hudFail:@"订阅失败"];
            if (v) {
                [weakself.view mvp_popViewController:nil];
            }
        });
        weakself.feeding = NO;
    } finishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc hudDismiss];
        });
        [tv loadFinish];
        weakself.feeding = NO;
    }];
    
    self.currentOperation = operation;
}

- (void)cancelAllOperations
{
    if (self.currentOperation) {
        [self.currentOperation cancel];
        self.feeding = NO;
    }
    
    UIViewController* vc = (UIViewController*)[self view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc hudDismiss];
    });
}




@end
