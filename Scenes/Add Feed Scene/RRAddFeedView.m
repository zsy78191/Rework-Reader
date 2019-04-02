//
//  RRAddFeedView.m
//  rework-reader
//
//  Created by 张超 on 2019/2/15.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRAddFeedView.h"

@interface RRAddFeedView ()

@end

@implementation RRAddFeedView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    self.title = @"添加订阅源";
    
//    UIBarButtonItem* item = [self mvp_buttonItemWithActionName:@"recommand" title:@"推荐订阅源"];
//    UIBarButtonItem* sp = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    self.toolbarItems = @[sp,item];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:NO animated:animated];
}
    

- (Class)mvp_presenterClass
{
    return NSClassFromString(@"RRAddFeedPresenter");
}

- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];
//    MVPTableViewOutput* outputer = self.outputer;
    
    [self.outputer setRegistBlock:^(id output) {
        [output registNibCell:@"RRAddInputCell" withIdentifier:@"inputCell"];
        [output registNibCell:@"RRSwitchCell" withIdentifier:@"switchCell"];
        [output registNibCell:@"RRBtnCell" withIdentifier:@"buttonCell"];
        [output registNibCell:@"RRTitleCell" withIdentifier:@"titleCell"];
    }];
//    [outputer mvp_registerNib:[UINib nibWithNibName:@"RRAddInputCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"inputCell"];
//    [outputer mvp_registerNib:[UINib nibWithNibName:@"RRSwitchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"switchCell"];
//    [outputer mvp_registerNib:[UINib nibWithNibName:@"RRBtnCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"buttonCell"];
//    [outputer mvp_registerNib:[UINib nibWithNibName:@"RRTitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"titleCell"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
