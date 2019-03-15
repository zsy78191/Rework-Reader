//
//  RRImportPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/3/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRImportPresenter.h"
#import "RRImportInputer.h"
#import "OPMLDocument.h"
#import "RRFeedLoader.h"
@import oc_string;

@interface RRImportPresenter ()
{
    
}
@property (nonatomic, strong) RRImportInputer* inputer;
@property (nonatomic, assign) NSUInteger selectCount;
@property (nonatomic, assign) NSUInteger allCount;
@property (nonatomic, strong) NSArray* selectRows;
@property (nonatomic, strong) NSArray* operations;
@property (nonatomic, strong) void (^setCount)(NSUInteger all,NSUInteger finish);
@property (nonatomic, assign) NSInteger allFeedCount;
@property (nonatomic, assign) NSInteger finishCount;
@property (nonatomic, assign) BOOL hideHUD;
@end


@implementation RRImportPresenter

- (RRImportInputer *)inputer
{
    if (!_inputer) {
        _inputer = [[RRImportInputer alloc] init];
    }
    return _inputer;
}

- (id)mvp_inputerWithOutput:(id<MVPOutputProtocol>)output
{
    return self.inputer;
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    OPMLDocument* d = model.userInfo[@"model"];
    [d.outlines enumerateObjectsUsingBlock:^(OPMLOutline * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [self.inputer mvp_addModel:obj];
        [self appendOutline:obj];
    }];
}

- (void)appendOutline:(OPMLOutline*)outline
{
    if (outline.subOutlines.count == 0) {
        self.allCount ++;
    }
    [self.inputer mvp_addModel:outline];
    [[outline subOutlines] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self appendOutline:obj];
    }];
}

- (void)selectChanged:(NSArray*)rows
{
    self.selectRows = rows;
    self.selectCount = rows.count;
}

- (void)selectAll
{
    [self.view mvp_runAction:@selector(selectAll)];
}

- (void)deselectAll
{
    [self.view mvp_runAction:@selector(deselectAll)];
}

- (NSNumber*)allCounts
{
    return @(self.allCount);
}

- (void)resumeHUD
{
    self.hideHUD = NO;
    self.setCount(self.allFeedCount, self.finishCount);
}

- (void)import
{
    NSArray* all = self.selectRows.map(^id _Nonnull(NSIndexPath*  _Nonnull x) {
        OPMLOutline* o = [self.inputer mvp_modelAtIndexPath:x];
        return o.xmlUrl;
    });
    
    __block NSUInteger allCount  = all.count;
    __block NSUInteger finishCount = 0;
    __block NSUInteger errorCount = 0;
    self.allFeedCount = allCount;
    self.finishCount = 0;
    self.hideHUD = NO;
    
    [self.view mvp_runAction:NSSelectorFromString(@"disableAllButton")];
    [self.view hudWait:@"加载中"];
    
    __weak typeof(self) weakSelf = self;
    __block void (^setCount)(NSUInteger all,NSUInteger finish) = ^(NSUInteger all,NSUInteger finish){
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.allFeedCount = all;
            weakSelf.finishCount = finish;
//             [weakSelf.view hudProgress:(float)finish/all];
            if (!weakSelf.hideHUD) {
                [weakSelf.view hudWait:[NSString stringWithFormat:@"加载 %@/%@",@(finishCount),@(allCount)]];
            }
            if (finishCount == allCount) {
                [weakSelf.view mvp_runAction:NSSelectorFromString(@"enableAllButton")];
                [weakSelf.view hudDismiss];
            }
        });
    };
    self.setCount = setCount;

//    [[RRFeedLoader sharedLoader] setUseMainQuene:YES];
    NSArray* op = [[RRFeedLoader sharedLoader] reloadAll:all infoBlock:^(MWFeedInfo * _Nonnull info) {
        NSLog(@"%@",info);
    } itemBlock:^(MWFeedInfo * _Nonnull info, MWFeedItem * _Nonnull item) {
        
    } errorBlock:^(NSError * _Nonnull error) {
        NSLog(@"error");
        errorCount++;
    } finishBlock:^{
        NSLog(@"finish");
        finishCount++;
        setCount(allCount,finishCount);
    }];
    self.operations = op;
}

- (void)setOperations:(NSArray *)operations
{
    if (_operations) {
        [_operations enumerateObjectsUsingBlock:^(NSOperation*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
    }
    _operations = operations;
}

- (NSNumber*)canReturn
{
    __block BOOL canReturn = YES;
    [self.operations enumerateObjectsUsingBlock:^(NSOperation*   _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        canReturn = canReturn && ([obj isFinished] || [obj isCancelled]);
    }];
    if (!canReturn) {
        self.hideHUD = YES;
    }
    return @(canReturn);
}

- (void)cancelAll
{
    [self.operations enumerateObjectsUsingBlock:^(NSOperation*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    [[self view] hudDismiss];
}


@end
