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
#import "RRListEmpty.h"

@interface RRListView ()
{
}
@property (nonatomic, assign) BOOL showToolBar;
@end

@implementation RRListView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    id m = model.userInfo[@"model"];
    if (!m) {
        return;
    }
    if ([m isKindOfClass:[RRFeedInfoListModel class]]) {
        RRFeedInfoListModel* mm = m;
        
        UIBarButtonItem* item = [self mvp_buttonItemWithSystem:UIBarButtonSystemItemTrash actionName:@"deleteIt:" title:@"删除"];
        self.navigationItem.rightBarButtonItems = @[item];
        MVPTableViewOutput* o = self.outputer;
        [o mvp_bindTableRefreshActionName:@"refreshData:"];
        self.showToolBar = YES;
    }
    else if([m isKindOfClass:[RRFeedInfoListOtherModel class]])
    {
        RRFeedInfoListOtherModel* mm = m;
        if (mm.readStyle.onlyUnread) {
            UIBarButtonItem* item = [self mvp_buttonItemWithActionName:@"maskAllReaded:" title:@"全部已读"];
            self.navigationItem.rightBarButtonItems = @[item];
        }
        
        if (mm.canRefresh) {
            MVPTableViewOutput* o = self.outputer;
            [o mvp_bindTableRefreshActionName:@"refreshData:"];
        }
        self.showToolBar = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.presenter respondsToSelector:@selector(viewWillAppear:)]) {
        [(id)self.presenter viewWillAppear:animated];
    }
    [[self navigationController] setToolbarHidden:!self.showToolBar animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.presenter respondsToSelector:@selector(viewDidAppear:)]) {
        [(id)self.presenter viewDidAppear:animated];
    }
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
    
//    UIBarButtonItem* item = [self mvp_buttonItemWithActionName:@"showAchieve" title:@"显示归档文章"];
//    self.toolbarItems = @[item];
    
    UIBarButtonItem* t = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* t2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UISegmentedControl* c = [[UISegmentedControl alloc] initWithItems:@[@"未读",@"归档",@"收藏"]];
    UIBarButtonItem* i = [[UIBarButtonItem alloc] initWithCustomView:c];
    [c setSelectedSegmentIndex:0];
    [self mvp_bindAction:UIControlEventValueChanged target:c actionName:@"changeType:"];
    
    UIBarButtonItem* item2 = [self mvp_buttonItemWithActionName:@"configit:" title:@"设置"];
    
    self.toolbarItems = @[t2,i,t,item2];
}

- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];

    MVPTableViewOutput* o = self.outputer;
    [o mvp_registerNib:[UINib nibWithNibName:@"RRFeedArticleCell2" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"articleCell"];
    RRListEmpty* empty = [[RRListEmpty alloc] init];
    self.empty = empty;
    __weak typeof(self) weakSelf = self;
    [empty setActionBlock:^{
//        [weakSelf mvp_popViewController:nil];
//        [[weakSelf presenter] mvp_runAction:@"refreshData"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[o refreshControl] isRefreshing]) {
                return ;
            }
            [[o refreshControl] beginRefreshing];
            [[weakSelf presenter] mvp_runAction:@"refreshData:" value:[o refreshControl]];
        });
    }];
}

//- (void)reloadData
//{
//    [(id)self.outputer reloadData];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
