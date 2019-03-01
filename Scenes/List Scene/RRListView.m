//
//  RRListView.m
//  rework-reader
//
//  Created by 张超 on 2019/2/21.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRListView.h"
#import "RRFeedInfoListModel.h"
#import "RRFeedInfoListOtherModel.h"
@interface RRListView ()

@end

@implementation RRListView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
//    self.extendedLayoutIncludesOpaqueBars = YES;
    
    id m = model.userInfo[@"model"];
    if (!m) {
        return;
    }
    if ([m isKindOfClass:[RRFeedInfoListModel class]]) {
        RRFeedInfoListModel* mm = m;
        
        UIBarButtonItem* item = [self mvp_buttonItemWithSystem:UIBarButtonSystemItemTrash actionName:@"deleteIt" title:@"删除"];
        UIBarButtonItem* item2 = [self mvp_buttonItemWithActionName:@"configit" title:@"设置"];
 
        self.navigationItem.rightBarButtonItems = @[item2,item];
        
        MVPTableViewOutput* o = self.outputer;
        [o mvp_bindTableRefreshActionName:@"refreshData:"];
    }
    else if([m isKindOfClass:[RRFeedInfoListOtherModel class]])
    {
        RRFeedInfoListOtherModel* mm = m;
      
//        UIBarButtonItem* item2 = [self mvp_buttonItemWithActionName:@"configit" title:@"设置"];
//        self.navigationItem.rightBarButtonItem = item2;
        
        if (mm.canRefresh) {
            MVPTableViewOutput* o = self.outputer;
            [o mvp_bindTableRefreshActionName:@"refreshData:"];
        }
    }
    
 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    if ([self.presenter respondsToSelector:@selector(viewWillAppear:)]) {
        [(id)self.presenter viewWillAppear:animated];
    }
    //    [self.navigationController.navigationBar setPrefersLargeTitles:NO];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}


- (Class)mvp_presenterClass
{
    return NSClassFromString(@"RRListPresenter");
}

- (void)mvp_bindData
{
    [self.presenter mvp_bindBlock:^(id view, id value) {
        [(id)view setTitle:value];
    } keypath:@"title"];
    
 
}

- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];

    MVPTableViewOutput* o = self.outputer;
    [o mvp_registerNib:[UINib nibWithNibName:@"RRFeedArticleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"articleCell"];
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
