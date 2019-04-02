//
//  RRWebSettingPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/3/7.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRWebSettingPresenter.h"
#import "RRWebSettingInputer.h"
#import "RRIconSettingModel.h"
#import "RRWebStyleModel.h"
@import ui_base;
#import "RPFontLoader.h"

@interface RRWebSettingPresenter ()
{
    
}
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) RRWebSettingInputer* inputer;
@property (nonatomic, weak) RRWebStyleModel* style;
@end

@implementation RRWebSettingPresenter

- (RRWebSettingInputer *)inputer
{
    if (!_inputer) {
        _inputer = [[RRWebSettingInputer alloc] init];
    }
    return _inputer;
}

- (id)mvp_inputerWithOutput:(id<MVPOutputProtocol>)output
{
    return self.inputer;
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    self.title = @"阅读设置";
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"文字大小";
        m.isTitle = YES;
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"减小字号";
        m.icon = @"icon_f-";
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"增大字号";
        m.icon = @"icon_f+";
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"行间距";
        m.isTitle = YES;
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"减小行间距";
        m.icon = @"icon_p-";
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"增加行间距";
        m.icon = @"icon_p+";
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"对齐方式";
        m.isTitle = YES;
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"左对齐";
        m.icon = @"icon_l";
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"两端对齐";
        m.icon = @"icon_j";
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"字体";
        m.isTitle = YES;
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"苹方细体";
        m.fontStyle = @"F1";
        m.icon = @"icon_f";
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"苹方标准体";
        m.fontStyle = @"F2";
        m.icon = @"icon_f";
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"思源宋体细体";
        m.fontStyle = @"F3";
        m.icon = @"icon_f";
        m;
    })];

    self.style = model.userInfo[@"model"];
}

- (void)mvp_action_selectItemAtIndexPath:(NSIndexPath *)path
{
    switch (path.section * 10 + path.row) {
        case 1:
        {
            if (self.style.fontSize > 14) {
                self.style.fontSize --;
            }
            else {
                [self.view hudInfo:@"不能再小了,再小影响视力"];
            }
            break;
        }
        case 2:
        {
            if (self.style.fontSize < 32) {
                self.style.fontSize ++;
            }
            else {
                [self.view hudInfo:@"已是最大字号"];
            }
            break;
        }
        case 4:
        {
            if (self.style.lineHeight > 1) {
                self.style.lineHeight -= 0.1;
            }
            else {
                [self.view hudInfo:@"已是最小行间距"];
            }
            break;
        }
        case 5:
        {
            if (self.style.lineHeight < 3) {
                self.style.lineHeight += 0.1;
            }
            else {
                [self.view hudInfo:@"已是最大行间距"];
            }
            break;
        }
        case 7:
        {
            self.style.align = @"left";
            break;
        }
        case 8:
        {
            self.style.align = @"justify";
            break;
        }
        case 10:
        {
            self.style.font = @"PingFangSC-Light";
            break;
        }
        case 11:
        {
            self.style.font = @"PingFangSC-Regular";
            break;
        }
        case 12:
        {
            [self style].font = @"SourceHanSerifCN";
            break;
        }
        default:
            break;
    }
    
    [self.style syncToCurrentStyle];
}

- (BOOL)loadFont:(NSString*)name
{
    NSURL* path = [[NSBundle mainBundle] URLForResource:[name componentsSeparatedByString:@"."].firstObject withExtension:[name componentsSeparatedByString:@"."].lastObject];
    BOOL x = [RPFontLoader registerFontsAtPath:[path path]];
    return x;
}

- (BOOL)checkFontExist:(NSString*)fontName
{
    __block BOOL e = NO;
    [[UIFont familyNames] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray* b= [UIFont fontNamesForFamilyName:obj];
        //NSLog(@"%@",b);
        if ([b containsObject:fontName]) {
            e = YES;
            *stop = YES;
        }
    }];
    
    return e;
}

- (void)downloadFontExtra:(NSString*)ext finish:(void(^)(void))finish
{
    [self.view hudWait:@"加载中"];
    __weak typeof(self) weakSelf = self;
    NSSet* set = [NSSet setWithObject:ext];
    NSBundleResourceRequest* r = [[NSBundleResourceRequest alloc] initWithTags:set];
    [r beginAccessingResourcesWithCompletionHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [weakSelf.view hudFail:@"加载失败，请重试"];
            }
            else{
                if (finish) {
                    finish();
                }
            }
        });
        [r endAccessingResources];
    }];
}

@end
