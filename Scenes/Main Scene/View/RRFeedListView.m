//
//  RRFeedListView.m
//  rework-reader
//
//  Created by 张超 on 2019/1/28.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedListView.h"
@import ui_util;
#import "RREmpty.h"
#import "RRReadMode.h"
@import ReactiveObjC;
@import DZNEmptyDataSet;
#import "RRTableOutput.h"

@interface RRFeedListView () <UIViewControllerPreviewingDelegate>

@end

@implementation RRFeedListView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (Class)mvp_presenterClass
{
    return NSClassFromString(@"RRFeedListPresenter");
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    
}

- (void)reloadEmpty
{
    dispatch_async(dispatch_get_main_queue(), ^{
       BOOL hasData = [[self.presenter mvp_valueWithSelectorName:@"hasData"] boolValue];
        if (!hasData) {
            [[[self navigationController] navigationBar] setPrefersLargeTitles:YES];
            MVPTableViewOutput* o = (id)self.outputer;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [o.tableview reloadEmptyDataSet];
            });
        }
    });
}

- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];
    
    [self.presenter mvp_bindBlock:^(RRFeedListView* view, id value) {
        MVPTableViewOutput* output = (id)view.outputer;
        dispatch_async(dispatch_get_main_queue(), ^{
            double height = [UIApplication sharedApplication].statusBarFrame.size.height + view.navigationController.navigationBar.frame.size.height;
            [[output tableview] setContentOffset:CGPointMake(0, [value doubleValue]-height) animated:NO];
        });
    } keypath:@"offsetY"];
 
//    MVPTableViewOutput* o = self.outputer;
    __weak typeof(self) weakSelf = self;
    [self.outputer setRegistBlock:^(MVPTableViewOutput* output) {
        [weakSelf registerForPreviewingWithDelegate:weakSelf sourceView:output.tableview];
        [output registNibCell:@"RRFeedInfoListCell" withIdentifier:@"feedCell"];
        [output registNibCell:@"RRTitleCell" withIdentifier:@"titleCell"];
        [output mvp_bindTableRefreshActionName:@"refreshData:"];
        
//        __weak typeof(self) weakSelf = self;
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
        
     
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [output.tableview reloadEmptyDataSet];
//        });
//        [output.tableview reloadEmptyDataSet];
        RREmpty* e = [[RREmpty alloc] init];
        weakSelf.empty = e;
        [e setActionBlock:^{
//            [output.tableview reloadEmptyDataSet];
            [weakSelf.presenter mvp_runAction:@"recommand"];
        }];
    }];
  
    RRTableOutput* output = (id)self.outputer;
    
    [output setNewOffsetBlock:^(CGFloat offsetY) {
         double height = [UIApplication sharedApplication].statusBarFrame.size.height + weakSelf.navigationController.navigationBar.frame.size.height;
        [[weakSelf presenter] mvp_runAction:@"updateOffsetY:" value:@(offsetY+height)];
    }];
//    [o mvp_registerNib:[UINib nibWithNibName:@"RRFeedInfoListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"feedCell"];
//    [o mvp_registerNib:[UINib nibWithNibName:@"RRTitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"titleCell"];
    
    
//    [o mvp_bindTableRefreshActionName:@"refreshData:"];
}

- (void)mvp_bindData
{
    [self.presenter mvp_bindBlock:^(__kindof UIViewController* view, id value) {
        view.title = value;
    } keypath:@"title"];
}

- (Class)mvp_outputerClass
{
    return NSClassFromString(@"RRTableOutput");
}

- (void)mvp_configOther
{
    UIBarButtonItem* bSetting = [self mvp_buttonItemWithActionName:@"openSetting" title:@"更多内容"];
    bSetting.image = [UIImage imageNamed:@"icon_set"];
    self.navigationItem.leftBarButtonItem = bSetting;
    
    UIBarButtonItem* bSearch = [self mvp_buttonItemWithSystem:UIBarButtonSystemItemSearch actionName:@"openSearch" title:@"搜索"];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//     UIBarButtonItem* item2 = [self mvp_buttonItemWithActionName:@"recommand2" title:@"推荐测试"];
    
//    UIBarButtonItem* item = [self mvp_buttonItemWithActionName:@"recommand" title:@"推荐订阅源"];
    
    UIBarButtonItem* item3 = [self mvp_buttonItemWithActionName:@"switchReadMode" title:@"阅读模式切换"];
    item3.image = [UIImage imageNamed:@"icon_yue"];
    
    
    [self.presenter mvp_bindBlock:^(id view, id value) {
        NSInteger mode = [value integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (mode) {
                case RRReadModeLight:
                {
                    item3.image = [UIImage imageNamed:@"icon_yue"];
                    break;
                }
                case RRReadModeDark:
                {
                    item3.image = [UIImage imageNamed:@"icon_ri"];
                    break;
                }
                default:
                    break;
            }
        });
    } keypath:@"mode"];
    
    
//    UIBarButtonItem* bAddRss = [self mvp_buttonItemWithActionName:@"addRSS" title:@"添加订阅源"];
    UIBarButtonItem* bAdd = [self mvp_buttonItemWithSystem:UIBarButtonSystemItemAdd actionName:@"openActionText:" title:@"添加订阅源"];
    
//    UIBarButtonItem* bAddHub = [self mvp_buttonItemWithActionName:@"addHub" title:@"添加阅读规则"];
    UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[item3,space,bAdd];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:1 target:nil action:nil];
    
    
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionBegan:motion withEvent:event];
    if (motion == UIEventSubtypeMotionShake) {
#ifdef DEBUG
        [UUTest showInView:self];
#endif
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];

    if ([self.presenter respondsToSelector:@selector(viewWillAppear:)]) {
        [(id)self.presenter viewWillAppear:animated];
    }
    
//    MVPTableViewOutput* o  = (id)self.outputer;
//    [o.tableview reloadEmptyDataSet];
    
//    [self.navigationController.navigationBar setPrefersLargeTitles:NO];
//    [self reloadEmpty];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self mvp_pushViewController:viewControllerToCommit];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
