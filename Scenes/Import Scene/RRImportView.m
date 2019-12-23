//
//  RRImportView.m
//  rework-reader
//
//  Created by 张超 on 2019/3/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRImportView.h"
#import "OPMLDocument.h"
#import "RRImportApper.h"
@import ui_base;
@import SVProgressHUD;

@interface RRImportView ()
{
}
@property (nonatomic, weak) OPMLDocument* handleDocument;
@end

@implementation RRImportView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (Class)mvp_outputerClass
{
    return NSClassFromString(@"RRImportOutput");
}

- (Class)mvp_presenterClass
{
    return NSClassFromString(@"RRImportPresenter");
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    OPMLDocument* d = model.userInfo[@"model"];
    self.handleDocument = d;
}

- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];
//    MVPTableViewOutput* o = self.outputer;
    
    [self.outputer setRegistBlock:^(MVPTableViewOutput* output) {
        [output registNibCell:@"RRMutiSelectCell" withIdentifier:@"cell"];
        [output registNibCell:@"RRTitleCell" withIdentifier:@"titleCell"];
    }];
    
//    [o mvp_registerNib:[UINib nibWithNibName:@"RRMutiSelectCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
//    [o mvp_registerNib:[UINib nibWithNibName:@"RRTitleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"titleCell"];
    self.appear = [[RRImportApper alloc] init];
    
    [self.presenter mvp_bindBlock:^(RRImportView* view, id value) {
        NSUInteger c = [[view.presenter mvp_valueWithSelectorName:@"allCounts"] integerValue];
        [view configTool:[value integerValue] isAll:c==[value integerValue]];
    } keypath:@"selectCount"];
}

- (void)mvp_bindData
{
    [self.presenter mvp_bindBlock:^(RRImportView* view, id value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [view setTitle:value];
        });
    } keypath:@"title"];
}

- (void)configTool:(NSUInteger)count isAll:(BOOL)isall
{
    UIBarButtonItem* all = [self mvp_buttonItemWithActionName:@"selectAll" title:@"选择全部"];
    if (isall) {
        all = [self mvp_buttonItemWithActionName:@"deselectAll" title:@"取消选择全部"];
    }
    UIBarButtonItem* import = [self mvp_buttonItemWithActionName:@"importOpml" title:[NSString stringWithFormat:@"导入(%@)",@(count)]];
    if (count == 0) {
        import = [self mvp_buttonItemWithActionName:@"importOpml" title:[NSString stringWithFormat:@"导入"]];
        import.enabled = NO;
    }
    UIBarButtonItem* fixable = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[all,fixable,import];
}

- (void)dealloc
{
    //NSLog(@"%s",__func__);
    [self.handleDocument closeWithCompletionHandler:^(BOOL success) {
        
    }];
}

- (void)enableAllButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.toolbarItems enumerateObjectsUsingBlock:^(__kindof UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setEnabled:YES];
        }];
    });
}

- (void)disableAllButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.toolbarItems enumerateObjectsUsingBlock:^(__kindof UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setEnabled:NO];
        }];
    });
}

- (void)selectAll
{
    MVPTableViewOutput* o = (id)self.outputer;
    NSArray* all = [o.inputer allModels];
    __block NSUInteger count = 0;
    [all enumerateObjectsUsingBlock:^(OPMLOutline*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.subOutlines.count == 0) {
            count ++;
            NSIndexPath* path = [o.inputer mvp_indexPathWithModel:obj];
            [[o tableview] selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }];
    [self.presenter mvp_runAction:@"selectChanged:" value:[[o tableview] indexPathsForSelectedRows]];
//    [self configTool:count isAll:YES];
}

- (void)deselectAll
{
    MVPTableViewOutput* o = (id)self.outputer;
    [[[o tableview] indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[o tableview] deselectRowAtIndexPath:obj
                                     animated:YES];
    }];
    [self.presenter mvp_runAction:@"selectChanged:" value:[[o tableview] indexPathsForSelectedRows]];
//    [self configTool:0 isAll:NO];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.presenter mvp_runAction:@"cancelAll"];
}

- (BOOL)navigationShouldPopOnBackButton
{
    [self hudDismiss];
    __weak typeof(self) weakSelf = self;
    id value = [self.presenter mvp_valueWithSelectorName:@"canReturn"];
    if (![value boolValue]) {
        UI_Alert().
        titled(@"导入操作尚未完成，是否放弃？")
        .recommend(@"放弃", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
            [[weakSelf presenter] mvp_runAction:@"resumeHUD"];
            [weakSelf mvp_popViewController:nil];
        })
        .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
            [[weakSelf presenter] mvp_runAction:@"resumeHUD"];
        })
        .show(self);
        return NO;
    }
    return YES;
}



@end
