//
//  RRMainPageAddPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/3/19.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRMainPageAddPresenter.h"
#import "RRWebSettingInputer.h"
#import "RRIconSettingModel.h"

@interface RRMainPageAddPresenter()
{
    
}
@property (nonatomic, strong) RRWebSettingInputer* inputer;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSBlockOperation* o1;
@property (nonatomic, strong) NSBlockOperation* o2;
@property (nonatomic, strong) NSBlockOperation* o3;
@end

@implementation RRMainPageAddPresenter

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    self.title = @"";
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"通过URL添加";
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"添加推荐订阅源";
        m;
    })];
    
    [self.inputer mvp_addModel:({
        RRIconSettingModel* m = [[RRIconSettingModel alloc] init];
        m.title = @"添加网友推荐源";
        m;
    })];
    
    self.o1 = model.userInfo[@"action1"];
    self.o2 = model.userInfo[@"action2"];
    self.o3 = model.userInfo[@"action3"];
}

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

- (void)mvp_action_selectItemAtIndexPath:(NSIndexPath *)path
{
    [self.view mvp_dismissViewControllerAnimated:YES completion:^{
        switch (path.row) {
            case 0:
            {
//                [self addRSS];
                if (self.o1) {
                    [self.o1 start];
                }
                break;
            }
            case 1:
            {
//                [self recommand];
                if (self.o2) {
                    [self.o2 start];
                }
                break;
            }
            case 2:
            {
                if (self.o3) {
                    [self.o3 start];
                }
                break;
            }
            default:
                break;
        }
    }];
}


@end
