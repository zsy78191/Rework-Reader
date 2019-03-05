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
@import ui_base;
@interface RRAddFeedPresenter ()
{
    
}
@property (nonatomic, strong) RRAddInputer* inputer;
@property (nonatomic, strong) RRAddModel* inputModel;

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
    RRAddModel* m = RRAddModel.model(@"订阅源URL", @"", @"url", RRAddModelTypeInput);
    m.placeholder = @"请输入订阅源URL";
    NSString* t = [[UIPasteboard generalPasteboard] string];
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
//    __weak typeof(self) weakself = self;
    
    switch (path.section*10 + path.row) {
        case 2: {
            NSString* x = self.inputModel.value;
            if (![x hasPrefix:@"http://"] && ![x hasPrefix:@"https://"]) {
                [(UIViewController*)self.view hudInfo:@"订阅源URL无效"];
                return;
            }
            
            __weak UIViewController<MVPViewProtocol>* vv = (UIViewController<MVPViewProtocol>*)self.view;
            id vc = [[RRFeedLoader sharedLoader] feedItem:x errorBlock:^(NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [vv mvp_popViewController:nil];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [vv hudInfo:@"订阅源URL无效"];
                    });
                });
            } cancelBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [vv hudDismiss];
                });
            } finishBlock:^{
                
            }];
            [[self view] mvp_pushViewController:vc];
            break;
        }
        default:
            break;
    }
}

@end
