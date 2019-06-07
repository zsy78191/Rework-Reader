
//
//  IconSelectPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/6/4.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "IconSelectPresenter.h"
#import "IconModel.h"
#import "IconInput.h"
@import oc_string;

@interface IconSelectPresenter ()
{
    
}
@property (nonatomic, strong) IconInput* input;
@property (nonatomic, strong) void (^ selectIconBlock)(NSString* icon);
@end

@implementation IconSelectPresenter

- (IconInput *)input
{
    if (!_input) {
        _input = [[IconInput alloc] init];
    }
    return _input;
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    id callback = model.userInfo[@"callback"];
    if (callback) {
        self.selectIconBlock = model.userInfo[@"callback"];
    }
    
    
    NSMutableArray* all = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 10; i++) {
        [all addObject:@(i)];
    }
    NSArray* models = all.map(^id _Nonnull(id  _Nonnull x) {
        return [NSString stringWithFormat:@"icons/%@",x];
    }).map(^id _Nonnull(id  _Nonnull x) {
        IconModel* model = [[IconModel alloc] init];
        model.name = x;
        return model;
    });
    
    NSMutableArray* all2 = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 70; i++) {
        [all2 addObject:@(i)];
    }
    NSArray* models2 = all2.map(^id _Nonnull(id  _Nonnull x) {
        return [NSString stringWithFormat:@"icons/i%02ld",[x integerValue]];
    }).map(^id _Nonnull(id  _Nonnull x) {
        IconModel* model = [[IconModel alloc] init];
        model.name = x;
        return model;
    });
    
    [[models arrayByAddingObjectsFromArray:models2] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.input mvp_addModel:obj];
    }];
}

- (id)mvp_inputerWithOutput:(id<MVPOutputProtocol>)output
{
    return self.input;
}

- (void)mvp_action_selectItemAtIndexPath:(NSIndexPath *)path
{
    IconModel* m = [self.input mvp_modelAtIndexPath:path];
    if (self.selectIconBlock) {
        self.selectIconBlock(m.name);
    }
}

@end
