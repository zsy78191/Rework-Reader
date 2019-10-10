//
//  RRAddFeedPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/2/15.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRAddFeedPresenter.h"
#import "RRAddInputer.h"
#import "RRAddModel.h"
#import "RRFeedLoader.h"
#import "RRFeedFinder.h"
@import ui_base;
@import oc_string;
@interface RRAddFeedPresenter ()
{
    
}
@property (nonatomic, strong) RRAddInputer* inputer;
@property (nonatomic, strong) RRAddModel* inputModel;
@property (nonatomic, assign) BOOL feeding;

@end

@implementation RRAddFeedPresenter

- (RRAddInputer *)inputer
{
    if (!_inputer) {
        _inputer = [[RRAddInputer alloc] init];
    }
    return _inputer;
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    RRAddModel* m = RRAddModel.model(@"订阅源或网页URL", @"", @"url", RRAddModelTypeInput);
    m.placeholder = @"请输入订阅源或网页URL";
    NSString* t = [[[UIPasteboard generalPasteboard] string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (t && [t hasPrefix:@"http"]) {
        m.value = t;
    }
    
    NSURL* u = [[UIPasteboard generalPasteboard] URL];
    if (u) {
        m.value = [u absoluteString];
    }
    
    m.inputType = RRAddModelInputTypeURL;
    self.inputModel = m;
    [self.inputer mvp_addModel:m];
    
//    {
//        RRAddModel* m1 = RRAddModel.model(@"同意隐私协议", @"保护用户隐私是我们的底线。", @"privacy", RRAddModelTypeSwitch);
//        m1.switchValue = @(YES);
//        [self.inputer mvp_addModel:m1];
//    }
    
    {
        RRAddModel* m2 = RRAddModel.model(@"", @"", @"", RRAddModelTypeTitle);
        [self.inputer mvp_addModel:m2];
        
        RRAddModel* m1 = RRAddModel.model(@"订阅", @"", @"", RRAddModelTypeBtn);
        [self.inputer mvp_addModel:m1];
    }
    
}

- (id)mvp_inputerWithOutput:(id<MVPOutputProtocol>)output
{
    return self.inputer;
}

- (void)mvp_action_selectItemAtIndexPath:(NSIndexPath *)path
{
    [[(UIViewController*)self.view view] endEditing:YES];
    __weak typeof(self) weakself = self;
    
    switch (path.section*10 + path.row) {
        case 2: {
            if (self.feeding) {
                return;
            }
            self.feeding = YES;
            [self.view hudWait:@"加载中"];
            NSString* x = self.inputModel.value;
            if ([x hasPrefix:@"inner"]) {
                x = [x substringFromIndex:5];
            }
            if (![x hasPrefix:@"http://"] && ![x hasPrefix:@"https://"]) {
                [(UIViewController*)self.view hudInfo:@"订阅源或网页URL无效"];
                return;
            }
//            NSString * e = [x._urlEncodeString stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
//            //NSLog(@"%@",e);
            x = [x stringByReplacingOccurrencesOfString:@"%" withString:@"..BFH.."];
            NSString* e = [x stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            
            if (x.length != e.length) {
                x = e;
            }
            
            x = [x stringByReplacingOccurrencesOfString:@"..BFH.." withString:@"%"];
            
//            RRFeedFinder* f = [[RRFeedFinder alloc] init];
            [RRFeedFinder findItem:x result:^(BOOL isRSS, NSString * _Nonnull url) {
//                NSLog(@"--- %@",url);
                
                if (isRSS) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself loadRSS:x];
                    });
                }
                else {
                    if (url) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakself loadRSS:url];
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                              [(UIViewController*)self.view hudInfo:@"订阅源或网页URL无效"];
                        });
                    }
                }
                weakself.feeding = NO;
            }];
            
            break;
        }
        default:
            break;
    }
}

- (void)loadRSS:(NSString*)url
{
    __weak UIViewController<MVPViewProtocol>* vv = (UIViewController<MVPViewProtocol>*)self.view;
    id vc = [[RRFeedLoader sharedLoader] feedItem:url errorBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@",error);
    } cancelBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [vv hudDismiss];
        });
    } finishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [vv hudDismiss];
        });
    }];
    [[self view] mvp_pushViewController:vc];
}

@end
