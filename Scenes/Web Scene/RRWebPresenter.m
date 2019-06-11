//
//  RRWebPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/2/13.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRWebPresenter.h"
#import "RRWebView.h"
@import WebKit;
@import ui_base;
#import "RPDataManager.h"
#import "RRFeedArticleModel.h"
@import Fork_MWFeedParser;
#import "RRFeedAction.h"
#import "RRExtraViewController.h"
@import Classy;
#import "RRWebStyleModel.h"

@interface RRWebPresenter () <UIPopoverPresentationControllerDelegate>
{
    
}
@property (nonatomic, strong) RRFeedArticleModel* model;
@property (nonatomic, strong) MWFeedInfo* info;

@property (nonatomic, assign) BOOL articleLiked;
@property (nonatomic, assign) BOOL articleReadLaterd;
@property (nonatomic, strong) RRWebStyleModel* webStyle;
@end

@implementation RRWebPresenter

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    RRFeedArticleModel* m = model.userInfo[@"model"];
    MWFeedInfo* feedInfo = model.userInfo[@"feed"];
    self.model = m;
    self.info = feedInfo;
    self.articleLiked = self.model.liked;
    self.articleReadLaterd = self.model.readlater;
//    self.hasModel = self.model!=nil;
    self.webStyle = [RRWebStyleModel currentStyle];
    
    //NSLog(@"%ld %ld",self.webStyle.fontSize,self.webStyle.titleFontSize);
}

- (NSNumber*)hasModel
{
    return @(self.model != nil);
}

- (void)loadData:(RRFeedArticleModel *)m feed:(MWFeedInfo *)feedInfo
{
    self.model = m;
    self.info = feedInfo;
    self.articleLiked = self.model.liked;
    self.articleReadLaterd = self.model.readlater;
    id view = self.view;
    if ([view conformsToProtocol:@protocol(RRProvideDataProtocol)]) {
        [view loadData:m feed:feedInfo];
    }
}

- (void)activeShare:(id)data sender:(id)sender
{
    UIActivityViewController* v = [[UIActivityViewController alloc] initWithActivityItems:@[data] applicationActivities:nil];
    if ([UIDevice currentDevice].iPad()) {
        UIPopoverPresentationController* p = v.popoverPresentationController;
        //            [p setSourceRect:r];
        [p setBarButtonItem:sender];
        //            //NSLog(@"%@",v.popoverPresentationController);
        v.modalPresentationStyle = UIModalPresentationPopover;
        [[self view] mvp_presentViewController:v animated:YES completion:^{
            
        }];
    }
    else
    {
        [self.view mvp_presentViewController:v animated:YES completion:^{
            
        }];
    }
}

- (void)openAction2:(id)sender
{
    if (self.model) {
//        NSLog(@"%@",self.model.link);
        #ifdef DEBUG
            NSLog(@"%@",self.model);
        #else
            [self activeShare:[NSURL URLWithString:self.model.link] sender:sender];
        #endif

    }
    else {
        
    }
}

- (void)openAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
//    UIBarButtonItem* i = sender;
 
    
    UIAlertController* a = UI_ActionSheet()
    .titled(@"更多操作")
//    .action(@"全文HTML输出", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
//        [weakSelf outputHTML];
//    })
    .action(@"分享原文网址", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf openAction2:sender];
    })
//    .action(@"导出长图", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
//        [weakSelf exportPic:sender];
//    })
    .action(@"导出PDF", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf exportPDF:sender];
    })
    .action(@"导出Email", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf exportEmail:sender];
    })
    .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
        
    });
    
    if ([UIDevice currentDevice].iPad()) {
        [self.view showAsProver:a view:[(id)self.view view] item:sender arrow:UIPopoverArrowDirectionDown];
    }
    else
    {
        a.show((id)self.view);
    }
    
}

- (void)exportPic:(id)sender
{
    [self.view mvp_runAction:NSSelectorFromString(@"exportPic")];
}

- (void)exportPDF:(id)sender
{
    [self.view mvp_runAction:NSSelectorFromString(@"exportPDF")];
}

- (void)exportEmail:(id)sender
{
    [self.view mvp_runAction:NSSelectorFromString(@"exportEmail")];
}

- (void)shareFile:(NSDictionary*)t
{
//    NSLog(@"%@",t[@"sender"]);
    [self activeShare:[NSURL fileURLWithPath:t[@"file"]] sender:t[@"sender"]];
}

- (WKWebView*)webView
{
    return [(RRWebView*)self.view webView];
}

- (void)outputHTML
{
    __weak typeof(self) weakSelf = self;
    [[self webView] evaluateJavaScript:@"document.getElementsByTagName('html')[0].innerHTML;" completionHandler:^(NSString* _Nullable all, NSError * _Nullable error) {
        NSURL* u = [[UIApplication sharedApplication].doucumentDictionary() URLByAppendingPathComponent:@"output_temp.html"];
        NSError* e;
        [all writeToURL:u atomically:YES encoding:NSUTF8StringEncoding error:&e];
        if (!e) {
            NSArray* items = @[u];
            NSArray* activies = @[];
            UIActivityViewController* a = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:activies];
            [weakSelf.view mvp_presentViewController:a animated:YES completion:^{
                
            }];
        }
    }];
}

- (void)favIt
{
    __weak typeof(self) weakSelf = self;
    [RRFeedAction likeArticle:YES withUUID:self.model.uuid block:^(NSError * _Nonnull e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (e) {
                [(id)weakSelf.view hudFail:@"收藏失败"];
            }
            else {
                [(id)weakSelf.view hudSuccess:@"收藏成功"];
            }
        });
    }];
    self.articleLiked = YES;
}

- (void)readLater
{
    __weak typeof(self) weakSelf = self;
    [RRFeedAction readLaterArticle:YES withUUID:self.model.uuid block:^(NSError * _Nonnull e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (e) {
                [(id)weakSelf.view hudFail:@"操作失败"];
            }
            else {
                weakSelf.articleReadLaterd = YES;
                [(id)weakSelf.view hudSuccess:@"加入稍后阅读"];
            }
        });
    }];
//    self.articleReadLaterd = YES;
}

- (void)cancelReadLater
{
    __weak typeof(self) weakSelf = self;
    [RRFeedAction readLaterArticle:NO withUUID:self.model.uuid block:^(NSError * _Nonnull e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (e) {
                [(id)weakSelf.view hudFail:@"操作失败"];
            }
            else {
                weakSelf.articleReadLaterd = NO;
//                [(id)weakSelf.view hudSuccess:@"加入稍后阅读"];
            }
        });
    }];
//    self.articleReadLaterd = NO;
}

- (void)testf
{
    self.webStyle.fontSize ++;
}

- (void)unfavIt
{
    __weak typeof(self) weakSelf = self;
    [RRFeedAction likeArticle:NO withUUID:self.model.uuid block:^(NSError * _Nonnull e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (e) {
                [(id)weakSelf.view hudFail:@"取消收藏失败"];
            }
            else {
                [(id)weakSelf.view hudSuccess:@"取消收藏成功"];
            }
        });
    }];
    
    self.articleLiked = NO;
}

- (void)acBack
{
    [self.view mvp_popViewController:nil];
}

- (void)openActionText:(UIBarButtonItem*)sender
{
    UIViewController* vc = [MVPRouter viewForURL:@"rr://websetting" withUserInfo:@{@"model":self.webStyle}];
    RRExtraViewController* nv = [[RRExtraViewController alloc] initWithRootViewController:vc];
    vc.preferredContentSize = CGSizeMake(200, 300);
    [nv.view setBackgroundColor:[UIColor clearColor]];
    nv.modalPresentationStyle = UIModalPresentationPopover;
    nv.popoverPresentationController.barButtonItem = sender;
    nv.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    nv.popoverPresentationController.delegate = self;
    nv.popoverPresentationController.popoverLayoutMargins = UIEdgeInsetsMake(15,15,15,15);
    NSDictionary* style = [[NSUserDefaults standardUserDefaults] valueForKey:@"style"];
    nv.popoverPresentationController.backgroundColor = UIColor.hex(style[@"$bar-tint-color"]);
    [(UIViewController*)self.view presentViewController:nv animated:YES completion:^{
        
    }];
}

#pragma mark --  实现代理方法
//默认返回的是覆盖整个屏幕，需设置成UIModalPresentationNone。
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

//点击蒙版是否消失，默认为yes；

-(BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;
}

//弹框消失时调用的方法
-(void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    
    //NSLog(@"弹框已经消失");
    
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
