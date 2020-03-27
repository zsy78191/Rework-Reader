//
//  RRListPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/2/21.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRListPresenter.h"
#import "RRFeedInfoListModel.h"
#import "RRFeedInfoListOtherModel.h"
#import "RPDataManager.h"
@import ui_base;
#import "RRCoreDataModel.h"
#import "RRFeedArticleCell.h"
#import "RRFeedArticleModel.h"
#import "RRFeedInfoInputer.h"
#import "RRProvideDataProtocol.h"
#import "RRListInputer.h"
#import "RRFeedLoader.h"
#import "RRFeedAction.h"
#import "PWToastView.h"
@import SafariServices;
@import oc_string;
@import oc_util;
@import DateTools;
#import "RRListView.h"
#import "RRSafariViewController.h"
@import MagicalRecord;
#import "RRExtraViewController.h"
@import ReactiveObjC;
#import "UIViewController+PresentAndPush.h"
#import "RRFeedManager.h"
#import "SceneDelegate.h"

static NSString * const kShortcutItemsKey = @"kShortcutItemsKey";

typedef struct  {
    NSUInteger page1;
    NSUInteger page2;
    NSUInteger page3;
    NSUInteger page4;
} PageState;

typedef struct  {
    BOOL page1;
    BOOL page2;
    BOOL page3;
    BOOL page4;
} LoadState;

@interface RRListPresenter ()
{
    
}

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* modelTitle;
@property (nonatomic, strong) NSNumber* segmentOrigin;

@property (nonatomic, strong) RRFeedInfoListModel* infoModel;
@property (nonatomic, strong) RRFeedInfoListOtherModel* styleModel;

@property (nonatomic, strong) RRFeedInfoInputer* inputer;
@property (nonatomic, strong) RRListInputer* inputerCoreData;

@property (nonatomic, strong) NSMutableArray* hashTable;
@property (nonatomic, assign) NSUInteger currentIdx;
@property (nonatomic, assign) BOOL refreshing;

@property (nonatomic, assign) BOOL isTrait;
@property (nonatomic, assign) BOOL loadedAll;

@property (nonatomic, assign) double t1OffesetY;
@property (nonatomic, assign) double t2OffesetY;
@property (nonatomic, assign) double t3OffesetY;
@property (nonatomic, assign) double t4OffesetY;

@property (nonatomic, assign) PageState pageState;
@property (nonatomic, assign) LoadState loadState;


@end

@implementation RRListPresenter

- (void)setInitailOffset:(NSNumber*)y
{
    self.t1OffesetY = self.t2OffesetY = self.t3OffesetY = self.t4OffesetY = [y doubleValue];
}

- (NSNumber*)currentOffset
{
    switch (self.currentIdx) {
        case 0:
        {
            return @(self.t1OffesetY);
            break;
        }
        case 1:
        {
            return @(self.t2OffesetY);
            break;
        }
        case 2:
        {
            return @(self.t3OffesetY);
            break;
        }
        case 3:
        {
            return @(self.t4OffesetY);
            break;
        }
        default:
            break;
    }
    return @(self.t1OffesetY);
}

- (void)newOffset:(NSNumber*)offsetY
{
    switch (self.currentIdx) {
        case 0:
        {
            self.t1OffesetY = [offsetY doubleValue];
            break;
        }
        case 1:
        {
            self.t2OffesetY = [offsetY doubleValue];
            break;
        }
        case 2:
        {
            self.t3OffesetY = [offsetY doubleValue];
            break;
        }
        case 4:
        {
           self.t4OffesetY = [offsetY doubleValue];
           break;
        }
        default:
            break;
    }
}

- (void)trait
{
    self.isTrait = YES;
}

- (void)notTrait
{
    self.isTrait = NO;
}

- (NSMutableArray *)hashTable
{
    if (!_hashTable) {
        _hashTable = [[NSMutableArray alloc] init];
    }
    return _hashTable;
}


//- (void)viewDidDisappear:(BOOL)animated
//{
//    [self reloadHashData];
//}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadHashData];
}

- (void)reloadHashData
{
    [self.hashTable removeAllObjects];
    [self.hashTable addObjectsFromArray:self.inputerCoreData.allModels];
}


- (void)reloadHashDataWithouClean
{
    [(NSArray*)self.inputerCoreData.allModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![self.hashTable containsObject:obj]) {
            [self.hashTable addObject:obj];
        }
    }];
}

- (void)updateHashData
{
    // BUGFIXED
    NSArray* a = self.inputerCoreData.allModels;
    a = a.reverse.filter(^BOOL(id  _Nonnull x) {
        return [self.hashTable indexOfObject:x] == NSNotFound;
    });
    [a enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.hashTable insertObject:obj atIndex:0];
    }];
    
//    [self.hashTable removeAllObjects];
//    [self.hashTable addObjectsFromArray:self.inputerCoreData.allModels];
}

- (RRFeedInfoInputer *)inputer
{
    if (!_inputer) {
        _inputer = [[RRFeedInfoInputer alloc] init];
    }
    return _inputer;
}

- (RRListInputer *)inputerCoreData
{
    if (!_inputerCoreData) {
        _inputerCoreData = [[RRListInputer alloc] init];

    }
    return _inputerCoreData;
}

- (id)mvp_inputerWithOutput:(id<MVPOutputProtocol>)output
{
    return self.inputerCoreData;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    self.refreshing = NO;
    PageState state = {1,1,1,1};
    self.pageState = state;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHashData) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    id m = model.userInfo[@"model"];
    if (!m) {
        return;
    }
    if ([m isKindOfClass:[RRFeedInfoListModel class]]) {
        RRFeedInfoListModel* mm = m;
        self.modelTitle = self.title = mm.title;
        self.infoModel = mm;
    
        if (mm.thehub) {
//            mm.thehub.slider = 3;
            self.inputerCoreData.hub = mm.thehub;
            [self.inputerCoreData predicate];
            [self changeTypeByType:mm.thehub.slider];
            self.segmentOrigin = @(mm.thehub.slider);
        } else if (mm.feed) {
//            mm.feed.slider = 3;
            self.inputerCoreData.feed = mm.feed;
            [self.inputerCoreData predicate];
            [self changeTypeByType:mm.feed.slider];
            self.segmentOrigin = @(mm.feed.slider);
        }
    }
    else if([m isKindOfClass:[RRFeedInfoListOtherModel class]])
    {
        RRFeedInfoListOtherModel* mm = m;
        self.modelTitle = self.title = mm.title;
        self.styleModel = mm;
        self.inputerCoreData.model = mm;
        
    }
}

- (void)forSearch:(id)sender
{
    __weak typeof(self) weakself = self;
    UIAlertController* a = UI_ActionSheet()
    .titled(@"快捷方式")
    .recommend(@"拷贝URLScheme", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
//        //NSLog(@"%@",self.styleModel.readStyle.keyword);
        NSString* scheme = [NSString stringWithFormat:@"readerprime://search?keyword=%@",weakself.styleModel.readStyle.keyword._urlEncodeString];
        [[UIPasteboard generalPasteboard] setString:scheme];
        [weakself.view hudSuccess:@"已复制到剪切板"];
    });
    if (![UIDevice currentDevice].iPad()) {
        a.action(@"增加到3D Touch快捷菜单", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
            NSString* scheme = [NSString stringWithFormat:@"readerprime://search?keyword=%@",weakself.styleModel.readStyle.keyword._urlEncodeString];
            [self insertShortcutItems:scheme name:weakself.styleModel.readStyle.keyword];
        })
        .action(@"重置3D Touch菜单", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
            [self resetShortcutItems];
        });
    }
    a.cancel(@"取消", nil);
    
    if ([UIDevice currentDevice].iPad()) {
        [[self view] showAsProver:a view:[(UIViewController*)[self view] view] item:sender arrow:UIPopoverArrowDirectionDown];
    }
    else {
        a.show((id)self.view);
    }
}

- (void)insertShortcutItems:(NSString*)scheme name:(NSString*)keyword
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSArray* allShort = [ud arrayForKey:kShortcutItemsKey];
    if (!allShort) {
        allShort = @[];
    }
    NSMutableArray* shorts = [allShort mutableCopy];
    __block BOOL has = false;
    [shorts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"keyword"] isEqualToString:keyword]) {
            has = YES;
            *stop = YES;
        }
    }];
    
    if (has) {
        [self.view hudInfo:[NSString stringWithFormat:@"已经添加过「%@」关键词了",keyword]];
        return;
    }
    [shorts addObject:@{
                        @"scheme":scheme,
                        @"keyword":keyword
                        }];
    [ud setObject:shorts forKey:kShortcutItemsKey];
    [ud synchronize];
    [self.view hudSuccess:@"添加成功"];
    [self reloadShortcutItems];
}

- (void)resetShortcutItems
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@[] forKey:kShortcutItemsKey];
    [ud synchronize];
    [self reloadShortcutItems];
    [[self view] hudSuccess:@"重置成功"];
}

- (void)reloadShortcutItems
{
    [UIApplication sharedApplication].shortcutItems = [self generateShortCutForAppIcon];
}

- (NSArray*)generateShortCutForAppIcon
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSArray* allShort = [ud arrayForKey:kShortcutItemsKey];
    if (!allShort) {
        allShort = @[];
    }
//    return allShort.ma;
    return allShort.map(^id _Nonnull(NSDictionary*  _Nonnull x) {
        return [[UIApplicationShortcutItem alloc] initWithType:@"search" localizedTitle:[NSString stringWithFormat:@"搜索「%@」",x[@"keyword"]] localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"search"] userInfo:x];
    });
}

- (void)removeIt:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self configFeeds:sender selected:^(EntityFeedInfo * en) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            EntityHub* hub = [weakSelf.infoModel.thehub MR_inContext:localContext];
            EntityFeedInfo* target = [en MR_inContext:localContext];
            [hub removeInfosObject:target];
        } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
            if (contextDidSave) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[weakSelf view] hudSuccess:@"移除完成"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RRMainListNeedUpdate" object:nil];
                     [(id)weakSelf.view mvp_popViewController:nil];
                });
            }
        }];
    }];
}

- (void)deleteIt:(id)sender
{
    if (self.infoModel.thehub) {
        [self deleteHub:sender];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [RRFeedAction delFeed:self.infoModel.feed view:(id)self.view item:sender arrow:UIPopoverArrowDirectionDown finish:^{
        [(id)weakSelf.view mvp_popViewController:nil];
    }];
}

- (void)deleteHub:(id)sender
{
    RRFeedInfoListModel* m = self.infoModel;
    
    __weak typeof(self) weakSelf = self;
    UI_Alert()
    .titled([NSString stringWithFormat:@"确认删除分类「%@」",m.thehub.title])
    .recommend(@"删除", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [RRFeedManager removeHUB:m.thehub complete:^(BOOL s) {
            if (s) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hudSuccess:@"操作成功"];
//                    [weakSelf loadData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RRMainListNeedUpdate" object:nil];
                    [(id)weakSelf.view mvp_popViewController:nil];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hudSuccess:@"操作失败"];
                });
            }
        }];
    }).cancel(@"取消", nil)
    .show((id)self.view);
}

- (void)deleteIt2:(id)sender
{
    NSSet* s = [self.infoModel.feed.articles filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"liked = YES"]];
    NSString* m = [NSString stringWithFormat:@"共有%ld篇文章",self.infoModel.feed.articles.count];
    if (s.count > 0) {
        m = [NSString stringWithFormat:@"共有%ld篇文章，其中有%ld篇收藏不会删除",self.infoModel.feed.articles.count,s.count];
    }
    
    UI_ActionSheet()
    .titled([NSString stringWithFormat:@"确认删除「%@」?",self.infoModel.feed.title])
    .descripted(m)
    .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
        
    })
    .recommend(@"删除", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [self delFeedInfo:self.infoModel.feed];
    })
    .show((id)self.view);
}

- (void)delFeedInfo:(EntityFeedInfo*)info
{
    // step 1 删除文章
    __weak typeof(self) weakSelf = self;
    NSPredicate* p = [NSPredicate predicateWithFormat:@"feed = %@ and liked = NO",info];
    [[RPDataManager sharedManager] delData:@"EntityFeedArticle" predicate:p key:nil value:nil beforeDel:^BOOL(__kindof NSManagedObject * _Nonnull o) {
        return YES;
    } finish:^(NSUInteger count, NSError * _Nonnull e) {
        ////NSLog(@"delete %ld articles",count);
        if (!e) {
            [weakSelf delFeedInfoStep2:info];
        }
    }];
}

- (void)delFeedInfoStep2:(EntityFeedInfo*)info
{
    // step 2 删除订阅源
    [[RPDataManager sharedManager] delData:info relationKey:nil beforeDel:^BOOL(__kindof NSManagedObject * _Nonnull o) {
        
        return YES;
    } finish:^(NSUInteger count, NSError * _Nonnull e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!e) {
                [(id)self.view hudSuccess:@"删除成功"];
                [(id)self.view mvp_popViewController:nil];
            }
            else {
                [(id)self.view hudFail:@"删除失败"];
            }
        });
    }];
}

- (void)refreshData:(UIRefreshControl*)sender
{
    if (self.refreshing) {
        return;
    }
    self.refreshing = YES;
    
    __weak typeof(self) weakSelf = self;
    [self updateFeedData:^(NSInteger x) {
        weakSelf.refreshing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (x == 0) {
                [PWToastView showText:@"没有更新的订阅了"];
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"更新结束，没有更新的订阅");
            }
            else {
                [PWToastView showText:[NSString stringWithFormat:@"更新了%ld篇订阅",x]];
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"更新了%ld篇订阅",x]);
            }
            [sender endRefreshing];
            [weakSelf updateHashData];
        });
    }];
   
}

- (void)updateFeedData:(void (^)(NSInteger x))finished
{
    __weak typeof(self) ws = self;
    if (self.infoModel) {
        if (self.infoModel.feed) {
            //单订阅源更新
            __block NSMutableArray* temp = [[NSMutableArray alloc] init];
            [[RRFeedLoader sharedLoader] loadFeed:[self.infoModel.feed.url absoluteString] infoBlock:^(MWFeedInfo * _Nonnull info) {
            } itemBlock:^(MWFeedItem * _Nonnull item) {
                // AllReadyTODO:新增文章
                RRFeedArticleModel* m = [[RRFeedArticleModel alloc] initWithItem:item];
                [temp addObject:m];
            } errorBlock:^(NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ws.view hudFail:[error localizedDescription]];
                });
            } finishBlock:^{
                [RRFeedAction insertArticle:temp withFeed:self.infoModel.feed finish:^(NSUInteger x) {
                    if (finished) {
                        finished(x);
                    }
                }];
            } needUpdateIcon:NO];
        }
        else if(self.infoModel.thehub){
            //订阅源集合更新
            __block NSInteger finishCount = 0;
            __block NSInteger allArticleCount = 0;
            __block NSInteger allCount = self.infoModel.thehub.infos.count;
            [self.infoModel.thehub.infos enumerateObjectsUsingBlock:^(EntityFeedInfo * _Nonnull obj, BOOL * _Nonnull stop) {
                __block NSMutableArray* temp = [[NSMutableArray alloc] init];
                [[RRFeedLoader sharedLoader] loadFeed:[obj.url absoluteString] infoBlock:^(MWFeedInfo * _Nonnull info) {
                } itemBlock:^(MWFeedItem * _Nonnull item) {
                    ////NSLog(@"%@",item.title);
                    // AllReadyTODO:新增文章
                    RRFeedArticleModel* m = [[RRFeedArticleModel alloc] initWithItem:item];
                    [temp addObject:m];
                } errorBlock:^(NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                      [ws.view hudFail:[error localizedDescription]];
                   });
                } finishBlock:^{
                    [RRFeedAction insertArticle:temp withFeed:obj finish:^(NSUInteger x) {
                        finishCount ++;
                        allArticleCount += x;
                        if (finishCount == allCount) {
                            if (finished) {
                                finished(allArticleCount);
                            }
                        }
                    }];
                } needUpdateIcon:NO];
            }];
            
        }
       
    }
    else if(self.styleModel)
    {
        //RRALTODO: 为了适配更多更新方式，这里要优化
        [self updateFeedData2:finished];
    }
}


- (void)updateFeedData2:(void (^)(NSInteger x))finished
{
    NSArray* all = [self.styleModel.readStyle.feeds allObjects];
    if (!all) {
        all = [[RPDataManager sharedManager] getAll:@"EntityFeedInfo" predicate:nil key:nil value:nil sort:@"sort" asc:YES];
    }
    all =
    all.filter(^BOOL(RRFeedInfoListModel*  _Nonnull x) {
//        NSString* key = [NSString stringWithFormat:@"UPDATE_%@",x.url];
//        NSInteger lastU = [MVCKeyValue getIntforKey:key];
//        if (lastU != 0) {
//            NSDate* d = [NSDate dateWithTimeIntervalSince1970:lastU];
//            ////NSLog(@"last %@ %@",d,@([d timeIntervalSinceDate:[NSDate date]]));
//            if ([d timeIntervalSinceDate:[NSDate date]] > - 10) {
//                return NO;
//            }
//        }
        
        if (x.usettl) {
            NSUInteger ttl = [x.ttl integerValue];
            NSDate* d = [x.updateDate dateByAddingMinutes:ttl];
            if ([d timeIntervalSinceDate:[NSDate date]] > 0) {
                return NO;
            }
        }
        return YES;
    })
    .map(^id _Nonnull(RRFeedInfoListModel*  _Nonnull x) {
        return [x.url absoluteString];
    });
    
    [[RRFeedLoader sharedLoader] refresh:all endRefreshBlock:^{
//        [sender endRefreshing];
//        if (finished) {
//            finished(0);
//        }
    } finishBlock:^(NSUInteger all, NSUInteger error, NSUInteger article) {
        if (finished) {
            finished(article);
        }
    }];
}


- (UIViewController*)viewControllerAtIndexPath:(NSIndexPath*)path
{
    id model = [[self inputerCoreData] mvp_modelAtIndexPath:path];
    return [self loadArticle:model];
}

- (void)mvp_action_selectItemAtIndexPath:(NSIndexPath *)path
{
    UIViewController* c = (id)self.view;
    if (c.editing) {
        return;
    }
    
    id model = [[self inputerCoreData] mvp_modelAtIndexPath:path];
    id vc = nil;
    if ([model isKindOfClass:[RRFeedArticleModel class]]) {
        vc = [self loadArticle:model];
    }
    else if([model isKindOfClass:[EntityFeedArticle class]])
    {
//        RRFeedArticleModel* mm = [[RRFeedArticleModel alloc] initWithEntity:model];
//        mm.feedEntity = [(EntityFeedArticle*)model feed];
        vc = [self loadArticle:model];
    }
    if (vc) {
//        if ([UIDevice currentDevice].iPad() && self.isTrait) {
//            UIViewController* v = (id)self.view;
//
//        }
        UIViewController* v = (id)self.view;
        BOOL isTrait = [[NSUserDefaults standardUserDefaults] boolForKey:@"RRSplit"];
        if (@available(iOS 13.0, *)) {
            UIView* view = [(UIViewController*)self.view view];
            SceneDelegate* sceneDelegate = (SceneDelegate*)view.window.windowScene.delegate;
            isTrait =  sceneDelegate.isSplit;
       } else {
           
       }
        
//        //NSLog(@"%@",v.splitViewController.viewControllers);
        if (v.splitViewController && !isTrait) {
            
            RRExtraViewController* n = [[RRExtraViewController alloc] initWithRootViewController:vc];
            n.handleTrait = YES;
            if ([vc isKindOfClass:[SFSafariViewController class]]) {
//                [n setNavigationBarHidden:YES animated:NO];
//                [n setToolbarHidden:YES];
                NSArray* vcArray = @[v.navigationController,vc];
                 [v.splitViewController setViewControllers:vcArray];
            }
            else {
                NSArray* vcArray = @[v.navigationController,n];
                [v.splitViewController setViewControllers:vcArray];
            }
        }
        else {
            if ([vc isKindOfClass:[SFSafariViewController class]]) {
                [self.view mvp_presentViewController:vc animated:YES completion:^{
                    
                }];
            }
            else {
                [self.view mvp_showViewController:vc];
            }
        }
    }
}

- (UIViewController*)loadArticle:(id)model
{
    id feed = nil;
 
    if ([model isKindOfClass:[RRFeedArticleModel class]]) {
        feed = [model feedEntity];
//        RRFeedArticleModel* m = model;
    }
    else if([model isKindOfClass:[EntityFeedArticle class]])
    {
        feed = [model feed];
        EntityFeedInfo* i = feed;
        EntityFeedArticle* a = model;

        if (i.usesafari) {

            [RRFeedAction readArticle:a.uuid];
            
            NSString* link = a.link;
            if ([a.link hasPrefix:@"//"]) {
                link = [@"http:" stringByAppendingString:link];
            }
            
            NSURL* u = [NSURL URLWithString:link];
            
            if (!u) {
                [[self view] hudFail:@"链接不可用"];
                return nil;
            }
            
            SFSafariViewControllerConfiguration* c = [[SFSafariViewControllerConfiguration alloc] init];
            c.entersReaderIfAvailable = i.usereadmode;
            RRSafariViewController* s = [[RRSafariViewController alloc] initWithURL:u configuration:c];
//            [self.view mvp_presentViewController:s animated:YES completion:^{
//            }];
            return s;
        }
    }
    
    if (!feed) {
        feed = [NSNull null];
    }
    id web = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"model":model,@"feed":feed}];
    if([web conformsToProtocol:@protocol(RRProvideDataProtocol)])
    {
        id <RRProvideDataProtocol> webView = web;
        __weak typeof(self) weakSelf = self;
        [webView setLastArticle:^id _Nullable(id  _Nonnull current) {
            return [weakSelf last:current];
        }];
        [webView setLastFeed:^id _Nullable(id  _Nonnull current) {
            return [weakSelf lastFeed:current];
        }];
        [webView setNextFeed:^id _Nullable(id  _Nonnull current) {
            return [weakSelf nextFeed:current];
        }];
        [webView setNextArticle:^id _Nullable(id  _Nonnull current) {
            return [weakSelf next:current];
        }];
    }
//    [self.view mvp_pushViewController:web];
    return web;
}



- (id)lastFeed:(id)current
{
    id data = [self last:current];
    if ([data isKindOfClass:[RRFeedArticleModel class]]) {
        return [data feedEntity];
    }
    else if([data isKindOfClass:[EntityFeedArticle class]])
    {
        return [data feed];
    }
    return nil;
}

- (id)nextFeed:(id)current
{
    id data = [self next:current];
    if ([data isKindOfClass:[RRFeedArticleModel class]]) {
        return [data feedEntity];
    }
    else if([data isKindOfClass:[EntityFeedArticle class]])
    {
        return [data feed];
    }
    return nil;
}

- (id)last:(id)current
{
//    NSArray* all = [self.inputerCoreData allModels];
//    NSArray* all = [self.hashTable allObjects];
    NSArray* all = self.hashTable;
    NSUInteger x = [all indexOfObject:current];
    //    ////NSLog(@"%@ %ld" ,current,x);
    if (x == 0 || x == NSNotFound) {
        return nil;
    }
    NSInteger lastidx = x-1;
    id last = [all objectAtIndex:lastidx];
    if ([last isKindOfClass:[RRFeedArticleModel class]] || [last isKindOfClass:[EntityFeedArticle class]]) {
        return last;
    }
    return nil;
}

- (id)next:(id)current
{
//    NSArray* all = [self.inputerCoreData allModels];
//    NSArray* all = [self.hashTable allObjects];
    NSArray* all = self.hashTable;
    NSInteger x = [all indexOfObject:current];
    //    ////NSLog(@"%@ %ld" ,current,x);
    if (x == all.count - 1 || x == NSNotFound) {
        return nil;
    }
    NSInteger lastidx = x+1;
    if (lastidx > all.lenght -1) {
        return nil;
    }
    id last = [all objectAtIndex:lastidx];
    if ([last isKindOfClass:[RRFeedArticleModel class]] || [last isKindOfClass:[EntityFeedArticle class]]) {
        return last;
    }
    return nil;
}


- (void)changeFeedValue:(id)value forKey:(NSString*)key feed:(EntityFeedInfo*)feed void:(void (^)(NSError*e))finish
{
    __weak typeof(self) weakSelf = self;
    id target = nil;
    NSString* className = @"EntityFeedInfo";
    if (feed) {
        target = feed;
    }
    else if (self.infoModel.feed) {
        EntityFeedInfo* feed = self.infoModel.feed;
        target = feed;
    }
    else if(self.infoModel.thehub)
    {
        target = self.infoModel.thehub;
        className = @"EntityHub";
    }
    [[RPDataManager sharedManager] updateClass:className queryKey:@"uuid" queryValue:[target uuid] keysAndValues:@{key:value} modify:^id _Nonnull(id  _Nonnull key, id  _Nonnull value) {
        return value;
    } finish:^(__kindof NSManagedObject * _Nonnull obj, NSError * _Nonnull e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController* v = (id)weakSelf.view;
            if (e) {
                [v hudFail:@"修改失败"];
            }
            else {
                [v hudSuccess:@"修改成功"];
            }
            if (finish) {
                finish(e);
            }
        });
    }];
}

- (void)configHub:(id)sender
{
    EntityHub* hub = self.infoModel.thehub;
    __weak typeof(self) weakSelf = self;
    UIAlertController* a = UI_ActionSheet()
    .titled(@"设置")
    .recommend(@"设置订阅源", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf configFeeds:sender selected:^(EntityFeedInfo * en) {
            [weakSelf configFeed:en sender:sender];
        }];
    })
    .action(@"修改标题", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        UI_Alert()
        .titled(@"修改标题")
        .recommend(@"确定", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
            UITextField* t = alert.textFields[0];
            [weakSelf changeFeedValue:t.text forKey:@"title" feed:nil void:^(NSError *e) {
                if (!e) {
                    weakSelf.title = t.text;
                }
            }];
        })
        .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
            
        })
        .input(@"标题", ^(UITextField * _Nonnull field) {
            field.text = hub.title;
        })
        .show((id)self.view);
    })
    .action(@"修改图标", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [self changeIcon:nil];
    })
    .action(@"删除分类", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf deleteIt:sender];
    })
    .action(@"移除订阅源", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf removeIt:sender];
    })
    .action(@"数据归档", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf zipFeed:nil hub:hub sender:sender];
    })
    .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
    });
    
    if ([UIDevice currentDevice].iPad()) {
        [[self view] showAsProver:a view:[(UIViewController*)[self view] view] item:sender arrow:UIPopoverArrowDirectionDown];
    }
    else {
        a.show((id)self.view);
    }
}

- (void)configit2:(id)sender
{
    id view = [MVPRouter viewForURL:@"rr://tableauto" withUserInfo:@{}];
    [self.view mvp_pushViewController:view];
}


// 废弃
- (void)configit:(id)sender
{
    if (self.infoModel.thehub) {
        [self configHub:sender];
        return;
    }
 
    EntityFeedInfo* feed = self.infoModel.feed;
    [self configFeed:feed sender:sender];
}

- (void)configFeeds:(id)sender selected:(void (^)(EntityFeedInfo*))selected
{
    EntityHub* hub = self.infoModel.thehub;
    UIAlertController* a = UI_ActionSheet()
    .titled(@"选择订阅源");
//     __weak typeof(self) weakSelf = self;
    [hub.infos enumerateObjectsUsingBlock:^(EntityFeedInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        a.action(obj.title, ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
//            [weakSelf configFeed:obj sender:sender];
            if(selected){
                selected(obj);
            }
        });
    }];
    
    a.cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
        
    });
    
    if ([UIDevice currentDevice].iPad()) {
        [[self view] showAsProver:a view:[(UIViewController*)[self view] view] item:sender arrow:UIPopoverArrowDirectionDown];
    }
    else {
        a.show((id)self.view);
    }
}

- (void)zipFeed:(EntityFeedInfo*)feed hub:(EntityHub*)hub sender:(id)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertController* a = UI_ActionSheet();
    a
    .titled([NSString stringWithFormat:@"归档「%@」",feed?feed.title:hub.title])
    .descripted(@"所有操作均不会影响收藏数据")
    .recommend(@"归档一个月之前的数据", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
    
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            NSDate* d = [NSDate dateWithTimeIntervalSinceNow:-3600*24*30];
            NSPredicate* p = nil;
            if(feed) {
                p =  [NSPredicate predicateWithFormat:@"date != nil and date < %@ and liked = false and feed = %@",d,feed];
            }
            if (hub) {
                p = [NSPredicate predicateWithFormat:@"date != nil and date < %@ and liked = false and feed in %@",d,hub.infos];
            }
          
            NSInteger count = [EntityFeedArticle MR_countOfEntitiesWithPredicate:p inContext:localContext];
            UI_Alert().
            titled(@"确认删除")
            .descripted([NSString stringWithFormat:@"共有「%@」篇文章将被删除，请确认",@(count)])
            .action(@"确认", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    [EntityFeedArticle MR_deleteAllMatchingPredicate:p inContext:localContext];
                } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    if (contextDidSave) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.view hudSuccess:@"操作成功"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"RRMainListNeedUpdate" object:nil];
                            [(id)weakSelf.view mvp_popViewController:nil];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.view hudSuccess:@"操作失败"];
                        });
                    }
                }];
            })
            .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
                
            })
            .show((id)weakSelf.view);
        }];
    })
    .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
        
    });
    
    if ([UIDevice currentDevice].iPad()) {
        [[self view] showAsProver:a view:[(UIViewController*)[self view] view] item:sender arrow:UIPopoverArrowDirectionDown];
    }
    else {
        a.show((id)self.view);
    }
}

- (void)configFeed:(EntityFeedInfo*)feed sender:(id)sender {
    BOOL usetll = feed.usettl;
    BOOL useauto = feed.useautoupdate;
    BOOL usesafari = feed.usesafari;
    BOOL usereadmode = feed.usereadmode;
    
    __weak typeof(self) weakSelf = self;
    UIAlertController* a = UI_ActionSheet()
    .titled([NSString stringWithFormat:@"设置「%@」",feed.title])
    .recommend(@"修改标题", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        UI_Alert()
        .titled(@"修改标题")
        .recommend(@"确定", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
            UITextField* t = alert.textFields[0];
            [weakSelf changeFeedValue:t.text forKey:@"title" feed:feed void:^(NSError *e) {
                if (!e) {
                    if (!weakSelf.infoModel.thehub) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.title = t.text;
                        });
                    }
                }
            }];
        })
        .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
            
        })
        .input(@"标题", ^(UITextField * _Nonnull field) {
            field.text = feed.title;
        })
        .show((id)self.view);
    })
    .action(@"修改图标", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [self changeIcon:feed];
    })
    .action(@"复制订阅源URL", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [[UIPasteboard generalPasteboard] setURL:feed.url];
        [self.view hudSuccess:@"复制成功"];
    })
    .action(usetll?@"关闭缓存期内更新":@"开启缓存期内更新", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf changeFeedValue:@(!usetll) forKey:@"usettl" feed:feed void:^(NSError *e) {
        }];
    })
    .action(useauto?@"关闭自动更新文章":@"开启自动更新文章", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf changeFeedValue:@(!useauto) forKey:@"useautoupdate" feed:feed void:^(NSError *e) {
        }];
    })
    .action(usesafari?@"关闭直接阅读原文":@"开启直接阅读原文", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf changeFeedValue:@(!usesafari) forKey:@"usesafari" feed:feed void:^(NSError *e) {
        }];
    })
    .action(usereadmode?@"关闭自动进入阅读模式":@"开启自动进入阅读模式", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf changeFeedValue:@(!usereadmode) forKey:@"usereadmode" feed:feed void:^(NSError *e) {
        }];
    })
    .action(@"删除订阅源", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf deleteIt:sender];
    })
    .action(@"数据归档", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
        [weakSelf zipFeed:feed hub:nil sender:sender];
    })
    .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
    });
    
    if ([UIDevice currentDevice].iPad()) {
        //        [[self view] showAsProver:a view:[(UIViewController*)self.view view] rect:r arrow:UIPopoverArrowDirectionUp];
        [[self view] showAsProver:a view:[(UIViewController*)[self view] view] item:sender arrow:UIPopoverArrowDirectionDown];
    }
    else {
        a.show((id)self.view);
    }
}

- (void)changeTypeByType:(NSInteger)type {
     switch (type) {
            case 1: {
                self.inputerCoreData.style.onlyUnread = NO;
                self.inputerCoreData.style.onlyReaded = NO;
                self.inputerCoreData.style.liked = NO;
                self.inputerCoreData.currentPage = self.pageState.page2;
                self.loadedAll = self.loadState.page2;
                break;
            }
            case 0:
            {
                self.inputerCoreData.style.onlyUnread = YES;
                self.inputerCoreData.style.onlyReaded = NO;
                self.inputerCoreData.style.liked = NO;
                self.inputerCoreData.currentPage = self.pageState.page1;
                self.loadedAll = self.loadState.page1;
                break;
            }
            case 2:
            {
                self.inputerCoreData.style.onlyUnread = NO;
                self.inputerCoreData.style.onlyReaded = YES;
                self.inputerCoreData.style.liked = NO;
                self.inputerCoreData.currentPage = self.pageState.page3;
                self.loadedAll = self.loadState.page3;
                break;
            }
            case 3:
            {
                self.inputerCoreData.style.onlyUnread = NO;
                self.inputerCoreData.style.onlyReaded = NO;
                self.inputerCoreData.style.liked = YES;
                self.inputerCoreData.currentPage = self.pageState.page4;
                self.loadedAll = self.loadState.page4;
                break;
            }
            default:
                break;
        }
        [self.inputerCoreData rebuildFetch];
        [self reloadHashData];
        [self.view mvp_reloadData];
}

- (void)loadMore {
    if(self.loadedAll) return;
    NSLog(@"load more");
    [self addPage];
    [self.inputerCoreData rebuildFetch];
    [self reloadHashDataWithouClean];
    [self.view mvp_reloadData];
    
    self.loadedAll = self.inputerCoreData.mvp_count == self.inputerCoreData.countAll;
    LoadState s = self.loadState;
    switch (self.currentIdx) {
            case 0: {
                s.page1 = self.loadedAll;
                break;
            }
            case 1: {
                s.page2 = self.loadedAll;
                break;
            }
            case 2: {
                s.page3 = self.loadedAll;
                break;
            }
            case 3: {
                s.page4 = self.loadedAll;
                break;
            }
    }
    self.loadState = s;
}

- (void)addPage {
    PageState p = self.pageState;
    switch (self.currentIdx) {
            case 0: {
                p.page1++;
                self.inputerCoreData.currentPage = p.page1;
                break;
            }
            case 1: {
                p.page2++;
                self.inputerCoreData.currentPage = p.page2;
                break;
            }
            case 2: {
                p.page3++;
                self.inputerCoreData.currentPage = p.page3;
                break;
            }
            case 3: {
                p.page4++;
                self.inputerCoreData.currentPage = p.page4;
                break;
            }
        default:
            break;
    }
    self.pageState = p;
}

- (void)changeType:(UISegmentedControl*)sender
{
//    //NSLog(@"%@",sender);
    NSInteger i = sender.selectedSegmentIndex;
    self.currentIdx = sender.selectedSegmentIndex;
    [self changeTypeByType:self.currentIdx];
    if(self.inputerCoreData.hub) {
        NSPredicate* p = [NSPredicate predicateWithFormat:@"uuid = %@",[self.inputerCoreData.hub valueForKey:@"uuid"]];
        [[RPDataManager sharedManager] updateDatas:@"EntityHub" predicate:p modify:^(EntityHub*  _Nonnull obj) {
            obj.slider = i;
        } finish:^(NSArray * _Nonnull results, NSError * _Nonnull e) {
//             //NSLog(@"-- %@",e);
        }];
    } else if(self.inputerCoreData.feed) {
        NSPredicate* p = [NSPredicate predicateWithFormat:@"uuid = %@",[self.inputerCoreData.feed valueForKey:@"uuid"]];
       [[RPDataManager sharedManager] updateDatas:@"EntityFeedInfo" predicate:p modify:^(EntityFeedInfo*  _Nonnull obj) {
           obj.slider = i;
       } finish:^(NSArray * _Nonnull results, NSError * _Nonnull e) {
//           //NSLog(@"-- %@",e);
       }];
    }
}

- (void)maskAllReaded:(id)sender
{
    
}

- (void)maskAllReaded2
{
//    __weak typeof(self) weakSelf = self;
    UI_Alert()
    .titled(@"全部标记已读")
    .recommend(@"已读", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
//        [[weakSelf.inputerCoreData allModels] enumerateObjectsUsingBlock:^(EntityFeedArticle*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [RRFeedAction readArticle:obj.uuid onlyMark:YES];
//        }];
        [self markAllAsReaded];
    })
    .cancel(@"取消", nil)
    .show((id)self.view);
}

- (void)markAllAsReaded
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    BOOL tipOfShake = [ud boolForKey:@"kTipOfShake"];
    
    NSPredicate* p = [self.inputerCoreData.style predicate];
    __weak typeof(self) weakself = self;
    [[RPDataManager sharedManager] updateDatas:@"EntityFeedArticle" predicate:p modify:^(EntityFeedArticle*  _Nonnull obj) {
        obj.readed = YES;
    } finish:^(NSArray * _Nonnull results, NSError * _Nonnull e) {
        //NSLog(@"%@",e);
        if(!e) {
            if([UIDevice currentDevice].iPad()) {
                
            } else {
                if(tipOfShake){
                   [[weakself view] hudSuccess:@"标记成功"];
                } else {
                    [[weakself view] hudInfo:@"试试晃动手机"];
                }
            }
        }
    }];
    

}

- (void)markAsReaded:(NSIndexPath*)path
{
    EntityFeedArticle* model = (id)[self.inputerCoreData mvp_modelAtIndexPath:path];
    [RRFeedAction readArticle:model.uuid onlyMark:YES];
//    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
//        EntityFeedArticle* a = [model MR_inContext:localContext];
//        a.readed = YES;
//    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
////        //NSLog(@"save %@")
//    }];
}

- (void)markAsReadLater:(NSIndexPath*)path
{
    EntityFeedArticle* model = (id)[self.inputerCoreData mvp_modelAtIndexPath:path];
    [RRFeedAction readLaterArticle:!model.readlater withUUID:model.uuid block:^(NSError * _Nonnull e) {
        if (!e) {
             [RRFeedAction readArticle:model.uuid onlyMark:YES];
        }
    }];
}

- (void)markAsFavourite:(NSIndexPath*)path
{
    EntityFeedArticle* model = (id)[self.inputerCoreData mvp_modelAtIndexPath:path];
    [RRFeedAction likeArticle:!model.liked withUUID:model.uuid block:^(NSError * _Nonnull e) {
        if (!e) {
            [RRFeedAction readArticle:model.uuid onlyMark:YES];
        }
    }];
}

- (void)changeIcon:(EntityFeedInfo*)feed
{
    __weak typeof(self) weakself = self;
     UIViewController* v = (UIViewController* )self.view;
    id changeCallback = ^ (NSString* name ){
//        //NSLog(@"%@",name);
        [weakself changeFeedValue:name forKey:@"icon" feed:feed void:^(NSError *e) {
            if (!e) {
                [[weakself view] mvp_reloadData];
                [v dismissOrPopViewController];
            }
        }];
    };
    UIViewController* view = [MVPRouter viewForURL:@"rr://selecticon" withUserInfo:@{
        @"callback" : changeCallback
    }];
   
    [v presentOrPushViewController:view];
}

@end
