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
@import ui_base;
@import ReactiveObjC;
#import "RRTableOutput.h"
@import DZNEmptyDataSet;

@interface RRListView () <UIViewControllerPreviewingDelegate>
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
        
//        MVPTableViewOutput* o = self.outputer;
        [self.outputer setRegistBlock:^(id output) {
            [output mvp_bindTableRefreshActionName:@"refreshData:"];
        }];
//        [o mvp_bindTableRefreshActionName:@"refreshData:"];
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
//            MVPTableViewOutput* o = self.outputer;
            [self.outputer setRegistBlock:^(id output) {
                [output mvp_bindTableRefreshActionName:@"refreshData:"];
            }];
//            [o mvp_bindTableRefreshActionName:@"refreshData:"];
        }
        self.showToolBar = NO;
    }
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [[self presenter] mvp_runAction:@"maskAllReaded:"];
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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        double heigt = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        [[self presenter] mvp_runAction:@"setInitailOffset:" value:@(-heigt)];
    });
}

- (Class)mvp_presenterClass
{
    return NSClassFromString(@"RRListPresenter");
}

- (void)mvp_reloadData
{
    MVPTableViewOutput* outputer = (id)self.outputer;
    double heigt = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    double contentY = [[self.presenter mvp_valueWithSelectorName:@"currentOffset"] doubleValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"cc %@",@([[outputer inputer] mvp_count]));
        if ([[outputer inputer] mvp_count] == 0) {
            [[outputer tableview] setContentOffset:CGPointMake(0, contentY-heigt) animated:NO];
        }
        
        [super mvp_reloadData];
    });
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
    UISegmentedControl* c = [[UISegmentedControl alloc] initWithItems:@[@"未读",@"已读",@"收藏"]];
    UIBarButtonItem* i = [[UIBarButtonItem alloc] initWithCustomView:c];
    [c setSelectedSegmentIndex:0];
    [self mvp_bindAction:UIControlEventValueChanged target:c actionName:@"changeType:"];
    
    UIBarButtonItem* item2 = [self mvp_buttonItemWithActionName:@"configit:" title:@"设置"];
    
    self.toolbarItems = @[t2,i,t,item2];
}

- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];

    RRListEmpty* empty = [[RRListEmpty alloc] init];
    self.empty = empty;
    __weak typeof(self) weakSelf = self;
   
//    MVPTableViewOutput* o = self.outputer;
    [self.outputer setRegistBlock:^(MVPTableViewOutput* output) {
        [output registNibCell:@"RRFeedArticleCell2" withIdentifier:@"articleCell"];
        [weakSelf registerForPreviewingWithDelegate:weakSelf sourceView:output.tableview];
        [empty setActionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[output refreshControl] isRefreshing]) {
                    return ;
                }
                [[output refreshControl] beginRefreshing];
                [[weakSelf presenter] mvp_runAction:@"refreshData:" value:[output refreshControl]];
            });
        }];
        
//        [[output tableview] indicatorStyle]
        
        [[output actionsArrays] addObject:MVPCellActionModel.m(^(__kindof MVPCellActionModel * _Nonnull m) {
            m.title = @"已读";
            m.action = @"markAsReaded:";
        })];
        
           NSDictionary* style = [[NSUserDefaults standardUserDefaults] valueForKey:@"style"];
        
        [[output leadActionsArrays] addObject:MVPCellActionModel.m(^(__kindof MVPCellActionModel * _Nonnull m) {
            m.title = @"稍后阅读";
            m.color = UIColor.hex(style[@"$main-tint-color"]);
            m.action = @"markAsReadLater:";
        })];
        
        [[output leadActionsArrays] addObject:MVPCellActionModel.m(^(__kindof MVPCellActionModel * _Nonnull m) {
            m.title = @"收藏";
            m.action = @"markAsFavourite:";
        })];
        
        __weak UITableView* t = output.tableview;
        [[output.tableview rac_signalForSelector:@selector(accessibilityScroll:)] subscribeNext:^(RACTuple * _Nullable x) {
            if ([x[0] integerValue] == UIAccessibilityScrollDirectionUp) {
                if ([t contentOffset].y <= 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.presenter mvp_runAction:@"refreshData:" value:t.refreshControl];
                    });
                }
            }
        }];
        
        RRTableOutput* o = (id)output;
        [o setNewOffsetBlock:^(CGFloat offsetY) {
            double heigt = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
            NSLog(@"-- @(%@)",@(offsetY+heigt));
            
            [[weakSelf presenter] mvp_runAction:@"newOffset:" value:@(offsetY+heigt)];
        }];
    }];
//    [o mvp_registerNib:[UINib nibWithNibName:@"RRFeedArticleCell2" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"articleCell"];
   
}

- (Class)mvp_outputerClass
{
    return NSClassFromString(@"RRTableOutput");
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

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    if ([viewControllerToCommit isKindOfClass:NSClassFromString(@"SFSafariViewController")]) {
        [self mvp_presentViewController:viewControllerToCommit animated:YES completion:^{
            
        }];
    }
    else {
        [self mvp_pushViewController:viewControllerToCommit];
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    MVPTableViewOutput* outPut = (id)self.outputer;
    NSIndexPath* path = [outPut.tableview indexPathForRowAtPoint:location];
    if (!path) {
        return nil;
    }
    //    id vc = [self.presenter mvp_runAction:@"viewControllerAtIndexPath" value:path];
    id vc = [self.presenter mvp_valueWithSelectorName:@"viewControllerAtIndexPath:" sender:path];
    return vc;
}


@end
