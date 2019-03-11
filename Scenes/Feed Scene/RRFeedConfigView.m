//
//  RRFeedConfigView.m
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedConfigView.h"
#import "RREmptyStyleOne.h"

@import ui_base;
@interface RRFeedConfigView ()
{
    
}
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) BOOL feeded;
@property (nonatomic, weak) UIBarButtonItem* feedBarItem;
@end

@implementation RRFeedConfigView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self view];
    
   
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    self.isLoading = YES;
    self.canceled = NO;
    
    [self.presenter mvp_bindBlock:^(RRFeedConfigView* view, id value) {
        if (![value boolValue]) {
            return;
        }
        
        [[view presenter] mvp_bindBlock:^(RRFeedConfigView* view2, id value2) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([value2 boolValue]) {
                    [view2 showDissubcribeButton];
                }
                else {
                    [view2 showSubcribeButton];
                }
            });
        } keypath:@"cancelFeed"];
       
    } keypath:@"finished"];
 
}

- (Class)mvp_presenterClass
{
    return NSClassFromString(@"RRFeedPresenter");
}

- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];
    MVPTableViewOutput* o = self.outputer;
    [o mvp_registerNib:[UINib nibWithNibName:@"RRFeedInfoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"infoCell"];
    [o mvp_registerNib:[UINib nibWithNibName:@"RRFeedArticleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"articleCell"];
    [o mvp_registerNib:[UINib nibWithNibName:@"RRTitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"titleCell"];
    [o mvp_registerNib:[UINib nibWithNibName:@"RRSwitchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"switchCell"];
    
    RREmptyStyleOne* one =  [[RREmptyStyleOne alloc] init];
    self.empty = one;
    __weak typeof(self) weakSelf = self;
    [one setAction:^{
        [weakSelf mvp_popViewController:nil];
    }];
}

- (void)mvp_bindData
{
    [[self presenter] mvp_bindBlock:^(id view, id value) {
        [view setTitle:value];
    } keypath:@"title"];
}

- (void)showSubcribeButton
{
    UIBarButtonItem* item = [self mvp_buttonItemWithActionName:@"feedit:" title:@"订阅"];
    self.feedBarItem = item;
    
    item.enabled = [[self.presenter mvp_valueWithSelectorName:@"canFeed"] boolValue];
    UIBarButtonItem* sp = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[sp,item];
    self.feeded = NO;
}

- (void)showDissubcribeButton
{
    UIBarButtonItem* item = [self mvp_buttonItemWithActionName:@"unfeedit:" title:@"取消订阅"];
    UIBarButtonItem* sp = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[sp,item];
    self.feeded = YES;
}

- (BOOL)navigationShouldPopOnBackButton
{
    if (![[self.presenter mvp_valueWithSelectorName:@"canFeed"] boolValue]) {
        return YES;
    }
    
    if (self.feeded) {
        return YES;
    }
    
    UIAlertController* a = [self alert:@"是否放弃订阅？" recommend:@"继续订阅" action:nil cancel:@"放弃" block:^(NSInteger idx, __kindof UIViewController *vc) {
//        //NSLog(@"%@",@(idx));
        if (idx == 0) {
            [[vc navigationController] popViewControllerAnimated:YES];
        }
    }];
    a.show(self);
    
    return NO;
}

- (void)loadData:(id)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.presenter conformsToProtocol:@protocol(MVPViewLoadProtocol)]) {
            [(id)self.presenter loadData:data];
        }
    });
}

- (void)loadError:(NSError *)error
{
 
    
    if ([self.presenter respondsToSelector:@selector(loadError:)]) {
        [(id)self.presenter loadError:error];
    }
}

- (void)loadIcon:(NSString *)icon
{
//    //NSLog(@"%@",icon);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.presenter conformsToProtocol:@protocol(MVPViewLoadProtocol)]) {
            [(id)self.presenter loadIcon:icon];
        }
        [self hudDismiss];
    });
    
}

- (void)loadFinish
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.presenter conformsToProtocol:@protocol(MVPViewLoadProtocol)]) {
            [(id)self.presenter loadFinish];
        }
        [self hudDismiss];
        
        
        RREmptyStyleOne* e = (RREmptyStyleOne*)self.empty;
        e.shouldDisplay = YES;
        
        
//        id exist_value = [self.presenter mvp_valueWithSelectorName:@"isFeedExist"];
//        //NSLog(@"%@",exist_value);
        
        //Fixed bug
//        self.feedBarItem.enabled = YES;

    });
    
    self.isLoading = NO;
    
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isLoading) {
        [self hudWait:@"加载中"];
    }
    else {
        [self hudDismiss];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self hudDismiss];
    if (self.isLoading) {
        [self cancelit];
    }
//    [[self navigationController] setToolbarHidden:YES animated:animated];
 
}

- (void)cancelit
{
    self.canceled = YES;
    if ([self.presenter conformsToProtocol:@protocol(MVPViewLoadProtocol)]) {
        [(id)self.presenter cancelit];
    }
    [self hudDismiss];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

@synthesize cancelBlock = _cancelBlock;
 
@end
