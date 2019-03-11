//
//  RRSettingView.m
//  rework-reader
//
//  Created by 张超 on 2019/1/28.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRSettingView.h"

@interface RRSettingView ()

@end

@implementation RRSettingView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (Class)mvp_presenterClass
{
    return NSClassFromString(@"RRSettingPresenter");
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
  
}

- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];
    
    [self.presenter mvp_bindBlock:^(__kindof UIViewController* view, id value) {
        view.title = value;
    } keypath:@"title"];
    
    MVPTableViewOutput* outputer = self.outputer;
    [outputer mvp_registerNib:[UINib nibWithNibName:@"RRSettingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"settingBaseCell"];
    [outputer mvp_registerNib:[UINib nibWithNibName:@"RRTitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"titleCell"];
    [outputer mvp_registerNib:[UINib nibWithNibName:@"RRSwitchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"switchCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.presenter mvp_runAction:@"cancelAllOperations"];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc
{
    //NSLog(@"%s",__func__);
}

@end
