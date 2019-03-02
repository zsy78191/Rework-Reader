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


@interface RRWebPresenter ()
{
    
}
@property (nonatomic, strong) RRFeedArticleModel* model;
@property (nonatomic, strong) MWFeedInfo* info;

@property (nonatomic, assign) BOOL articleLiked;

@end

@implementation RRWebPresenter

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    RRFeedArticleModel* m = model.userInfo[@"model"];
    MWFeedInfo* feedInfo = model.userInfo[@"feed"];
    self.model = m;
    self.info = feedInfo;
    self.articleLiked = self.model.liked;
//    self.hasModel = self.model!=nil;
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
    id view = self.view;
    if ([view conformsToProtocol:@protocol(RRProvideDataProtocol)]) {
        [view loadData:m feed:feedInfo];
    }
}

- (void)openAction:(id)sender
{
    if (self.model) {

        UIActivityViewController* v = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:self.model.link]] applicationActivities:nil];
        
        
        if ([UIDevice currentDevice].iPad()) {
            UIPopoverPresentationController* p = v.popoverPresentationController;
//            [p setSourceRect:r];
            [p setBarButtonItem:sender];
//            NSLog(@"%@",v.popoverPresentationController);
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
    else {
        
    }
    
}

- (void)openAction2:(id)sender
{
    UIBarButtonItem* i = sender;
    CGRect r =({
        CGRect r = [[i valueForKeyPath:@"view.superview.frame"] CGRectValue];
        r.origin.x -= r.size.width/4;
        r.origin.y += r.size.height/2;
        r;
    });
    
    UIAlertController* a = UI_ActionSheet()
    .titled(@"更多操作")
    .action(@"全文HTML输出", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [self outputHTML];
    })
    .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
        
    });
    
    if ([UIDevice currentDevice].iPad()) {
        [self.view showAsProver:a view:[(id)self.view view] rect:r arrow:UIPopoverArrowDirectionUp];
    }
    else
    {
        a.show((id)self.view);
    }
    
}

- (WKWebView*)webView
{
    return [(RRWebView*)self.view webView];
}

- (void)outputHTML
{
    [[self webView] evaluateJavaScript:@"document.getElementsByTagName('html')[0].innerHTML;" completionHandler:^(NSString* _Nullable all, NSError * _Nullable error) {
        NSURL* u = [[UIApplication sharedApplication].doucumentDictionary() URLByAppendingPathComponent:@"output_temp.html"];
        NSError* e;
        [all writeToURL:u atomically:YES encoding:NSUTF8StringEncoding error:&e];
        if (!e) {
            NSArray* items = @[u];
            NSArray* activies = @[];
            UIActivityViewController* a = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:activies];
            [self.view mvp_presentViewController:a animated:YES completion:^{
                
            }];
        }
    }];
}

- (void)favIt
{
//    NSLog(@"%d",self.model.liked);
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




@end
