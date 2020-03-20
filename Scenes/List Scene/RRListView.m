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
#import "RRProvideDataProtocol.h"
#import "MVPView+iOS13.h"
#import "targetconditionals.h"
#import "UIKeyCommand+iOS13.h"

#if !TARGET_OS_MACCATALYST
@interface RRListView () <UIViewControllerPreviewingDelegate>
#else
@interface RRListView () 
#endif
{
}
@property (nonatomic, assign) BOOL showToolBar;
@end

@implementation RRListView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.restorationIdentifier = @"RRListRestoreView";
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    id m = model.userInfo[@"model"];
    if (!m) {
        return;
    }
    if ([m isKindOfClass:[RRFeedInfoListModel class]]) {
//        RRFeedInfoListModel* mm = m;
        
        UIBarButtonItem* item = [self mvp_buttonItemWithActionName:@"maskAllReaded2" title:@"全部已读"];
        self.navigationItem.rightBarButtonItems = @[item];
        
//        UIBarButtonItem* item = [self mvp_buttonItemWithSystem:UIBarButtonSystemItemTrash actionName:@"deleteIt:" title:@"删除"];
//        self.navigationItem.rightBarButtonItems = @[item];
        
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
//        //NSLog(@"%@",mm.key);
        if (mm.readStyle.onlyUnread) {
            UIBarButtonItem* item = [self mvp_buttonItemWithActionName:@"maskAllReaded2" title:@"全部已读"];
            self.navigationItem.rightBarButtonItems = @[item];
        }
        else {
//            self.navigationItem.rightBarButtonItem = self.editButtonItem;
        }
        if (mm.canRefresh) {
//            MVPTableViewOutput* o = self.outputer;
            [self.outputer setRegistBlock:^(id output) {
                [output mvp_bindTableRefreshActionName:@"refreshData:"];
            }];
//            [o mvp_bindTableRefreshActionName:@"refreshData:"];
        }
        self.showToolBar = NO;
        
        
        if ([mm.key isEqualToString:@"search"]) {
            //搜索模式下增加右上角的功能按钮
            [self configSearch];
        }
    }
    

}

- (void)configSearch
{
    UIBarButtonItem* item = [self mvp_buttonItemWithActionName:@"forSearch:" title:@"快捷方式"];
    self.navigationItem.rightBarButtonItems = @[item];
}


- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [[self presenter] mvp_runAction:@"maskAllReaded2"];
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
//        BOOL tipOfShake = [ud boolForKey:@"kTipOfShake"];
        [ud setBool:YES forKey:@"kTipOfShake"];
        [ud synchronize];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.presenter respondsToSelector:@selector(viewWillAppear:)]) {
        [(id)self.presenter viewWillAppear:animated];
    }
    [[self navigationController] setToolbarHidden:!self.showToolBar animated:animated];
//    [self.outputer reloadData];
//    //NSLog(@"%s",__func__);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    //NSLog(@"%s",__func__);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    //NSLog(@"%s",__func__);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.presenter respondsToSelector:@selector(viewDidAppear:)]) {
        [(id)self.presenter viewDidAppear:animated];
    }
//    //NSLog(@"%s",__func__);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        double heigt = self.navigationController.navigationBar.frame.size.height + [self statusframe].size.height;
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
    double heigt = self.navigationController.navigationBar.frame.size.height +  [self statusframe].size.height;
    double contentY = [[self.presenter mvp_valueWithSelectorName:@"currentOffset"] doubleValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        //NSLog(@"cc %@",@([[outputer inputer] mvp_count]));
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
    UISegmentedControl* c = [[UISegmentedControl alloc] initWithItems:@[@"未读",@"全部",@"已读",@"收藏"]];
    UIBarButtonItem* i = [[UIBarButtonItem alloc] initWithCustomView:c];
    [c setSelectedSegmentIndex:3];
    [self mvp_bindAction:UIControlEventValueChanged target:c actionName:@"changeType:"];
    __weak typeof(c) wc = c;
    [self.presenter mvp_bindBlock:^(RRListView*  _Nonnull view, id  _Nonnull value) {
        if (value) {
            [wc setSelectedSegmentIndex:[value integerValue]];
            //NSLog(@"select %@",value);
        }
    } keypath:@"segmentOrigin"];
    
    UIBarButtonItem* item2 = [self mvp_buttonItemWithActionName:@"configit:" title:@"设置"];
    self.toolbarItems = @[t2,i,t,item2];
}



- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];
    
//    //NSLog(@"----:::%f",[[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom);
    
    
    
//    [self mvp_bindSelector:@selector(viewDidDisappear:)];

    RRListEmpty* empty = [[RRListEmpty alloc] init];
    self.empty = empty;
    __weak typeof(self) weakSelf = self;
   
//    MVPTableViewOutput* o = self.outputer;
    [self.outputer setRegistBlock:^(MVPTableViewOutput* output) {
     
       
        output.canMove = NO;
        
        BOOL hideDetial = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideArticleDetial"];
        if (hideDetial) {
            [output registNibCell:@"RRFeedArticleCell3" withIdentifier:@"articleCell"];
            [output registNibCell:@"RRFeedArticleCell3" withIdentifier:@"articleCell2"];
        }
        else {
            [output registNibCell:@"RRFeedArticleCell2" withIdentifier:@"articleCell"];
            [output registNibCell:@"RRFeedArticleCell3" withIdentifier:@"articleCell2"];
        }
#if !TARGET_OS_MACCATALYST
        [weakSelf registerForPreviewingWithDelegate:weakSelf sourceView:output.tableview];
#endif
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
        
        [output setActionArraysBeforeUseBlock:^NSMutableArray * _Nonnull(NSMutableArray * _Nonnull actionsArrays, EntityFeedArticle*  _Nonnull model) {
            if (model.readed) {
//                [actionsArrays removeAllObjects];
                return [@[] mutableCopy];
            }
            return actionsArrays;
        }];
        
        [output setLeadActionsArraysBeforeUseBlock:^NSMutableArray * _Nonnull(NSMutableArray * _Nonnull actionsArrays, EntityFeedArticle*  _Nonnull model) {
            if (model.readlater) {
                MVPCellActionModel* m1 = actionsArrays.firstObject;
                m1.title = @"取消\n稍后阅读";
            }
            else {
                MVPCellActionModel* m1 = actionsArrays.firstObject;
                m1.title = @"稍后阅读";
            }
            if (model.liked) {
                MVPCellActionModel* m2 = actionsArrays.lastObject;
                m2.title = @"取消\n收藏";
            }
            else{
                MVPCellActionModel* m2 = actionsArrays.lastObject;
                m2.title = @"收藏";
            }
            return actionsArrays;
        }];
        
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
        
        __block BOOL loadMore = false;
        void (^checkLoadMoreBlock)(CGPoint) = ^(CGPoint x) {
           CGFloat y1 = x.y + t.frame.size.height;
           CGFloat y2 = t.contentSize.height;
//           NSLog(@"-- %@ %@",@(y1),@(y2));/
           if(fabs(y1 - y2)< t.frame.size.height) {
               if(!loadMore) {
                   loadMore = true;
                   [weakSelf.presenter mvp_runAction:@"loadMore"];
               }
           } else {
               loadMore = false;
           }
        };
        
        [[t rac_valuesForKeyPath:@keypath(t, contentOffset) observer:weakSelf] subscribeNext:^(id  _Nullable x) {
            checkLoadMoreBlock([x CGPointValue]);
        }];
        
        [[t rac_valuesForKeyPath:@keypath(t, contentSize) observer:weakSelf] subscribeNext:^(id  _Nullable x) {
            //NSLog(@"%@",x);
            checkLoadMoreBlock([t contentOffset]);
        }];
        
        
        RRTableOutput* o = (id)output;
        o.canMutiSelect = YES;
//        [o setNewOffsetBlock:^(CGFloat offsetY) {
//            double heigt = weakSelf.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
//            //NSLog(@"-- @(%@)",@(offsetY+heigt));
//
//            [[weakSelf presenter] mvp_runAction:@"newOffset:" value:@(offsetY+heigt)];
//        }];
    }];
//    [o mvp_registerNib:[UINib nibWithNibName:@"RRFeedArticleCell2" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"articleCell"];
   
}

- (Class)mvp_outputerClass
{
    return NSClassFromString(@"RRListTableOutput");
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
#if !TARGET_OS_MACCATALYST
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
#endif
- (void)back:(id)sender
{
    [self mvp_popViewController:nil];
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (NSArray<UIKeyCommand *> *)keyCommands
{
    return @[
              [UIKeyCommand keyCommandWithInput_IOS13:@"s" modifierFlags:UIKeyModifierCommand action:@selector(switchFavorite) discoverabilityTitle:@"收藏/取消收藏"],
                       [UIKeyCommand keyCommandWithInput_IOS13:@"r" modifierFlags:UIKeyModifierCommand action:@selector(switchReadLater) discoverabilityTitle:@"稍后阅读/取消"],
             [UIKeyCommand keyCommandWithInput_IOS13:UIKeyInputLeftArrow modifierFlags:UIKeyModifierCommand action:@selector(allScreen:) discoverabilityTitle:@"全屏"],
             [UIKeyCommand keyCommandWithInput_IOS13:UIKeyInputRightArrow modifierFlags:UIKeyModifierCommand action:@selector(speScreen:) discoverabilityTitle:@"分屏"],
                  [UIKeyCommand keyCommandWithInput_IOS13:UIKeyInputUpArrow modifierFlags:UIKeyModifierCommand action:@selector(lastArticle:) discoverabilityTitle:@"前一篇"],
                  [UIKeyCommand keyCommandWithInput_IOS13:UIKeyInputDownArrow modifierFlags:UIKeyModifierCommand action:@selector(nextArticle:) discoverabilityTitle:@"后一篇"],
             [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:0 action:@selector(pageUp)],
             [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:0 action:@selector(pageDown)],
             
             [UIKeyCommand keyCommandWithInput_IOS13:UIKeyInputEscape modifierFlags:0 action:@selector(back:) discoverabilityTitle:@"返回上一层"]
             ];
}

- (void)allScreen:(id)sender
{
 
    if (self.splitViewController.displayMode == 2) {
        UIBarButtonItem* item = self.splitViewController.displayModeButtonItem;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [[item target] performSelector:item.action];
#pragma clang diagnostic pop
    }

}
- (void)speScreen:(id)sender
{
//    [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAutomatic];
    if (self.splitViewController.displayMode == 1) {
        UIBarButtonItem* item = self.splitViewController.displayModeButtonItem;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [[item target] performSelector:item.action];
#pragma clang diagnostic pop
    }
}

- (id<RRProvideDataProtocol>)speView
{
    id vc = [[self.splitViewController viewControllers] lastObject];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [vc topViewController];
    }
    if ([vc conformsToProtocol:@protocol(RRProvideDataProtocol)]) {
        return vc;
    }
    return nil;
}

- (void)lastArticle:(id)sender
{
    id<RRProvideDataProtocol> vc = [self speView];
    if (vc && [vc respondsToSelector:@selector(loadLast)]) {
        [vc loadLast];
    }
}

- (void)nextArticle:(id)sender
{
    id<RRProvideDataProtocol> vc = [self speView];
    if (vc && [vc respondsToSelector:@selector(loadNext)]) {
        [vc loadNext];
    }
}

- (void)pageUp
{
    id<RRProvideDataProtocol> vc = [self speView];
    if (vc && [vc respondsToSelector:@selector(pageUp)]) {
        [vc pageUp];
    }
}
- (void)pageDown
{
    id<RRProvideDataProtocol> vc = [self speView];
    if (vc && [vc respondsToSelector:@selector(pageDown)]) {
        [vc pageDown];
    }
}

- (void)switchFavorite
{
    id<RRProvideDataProtocol> vc = [self speView];
    if (vc && [vc respondsToSelector:@selector(switchFavorite)]) {
        [vc switchFavorite];
    }
}
- (void)switchReadLater
{
    id<RRProvideDataProtocol> vc = [self speView];
    if (vc && [vc respondsToSelector:@selector(switchReadlater)]) {
        [vc switchReadlater];
    }
}

//- (BOOL)canResignFirstResponder
//{
//    return NO;
//}
@end
