//
//  RRFeedListPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/1/28.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedListPresenter.h"
#import "RRFeedInputer.h"
#import "RPDataManager.h"
#import "RRFeedInfoListModel.h"
#import "RPDataNotificationCenter.h"
#import "RRFeedInfoListOtherModel.h"
#import "RRFeedReaderStyleInputer.h"
@import oc_string;
#import "RRFeedLoader.h"
#import "RRFeedAction.h"
@import oc_util;
#import "RPDataManager.h"
#import "RRFeedArticleModel.h"
#import "PWToastView.h"

@import DateTools;
#import "RRExtraViewController.h"
@import ui_base;
@import oc_util;
#import "RRFeedListPresenter+FeedHUB.h"
#import "RRFeedManager.h"

NSString* const kOffsetMainList = @"kOffsetMainList";
NSString* const kMainListItemSetting = @"kOffsetMainList";
NSString* const kShowUnread = @"kShowUnread";
NSString* const kShowFav = @"kShowFav";
NSString* const kShowLater = @"kShowLater";
NSString* const kShowRecent = @"kShowRecent";

@interface RRFeedListPresenter() <UIPopoverPresentationControllerDelegate>
{
    
}

@end

@implementation RRFeedListPresenter

- (void)updateSelections:(NSArray*)indexPaths
{
    self.selectArray = indexPaths;
    self.selectMoreThanOne = self.selectArray.count > 0;
}

- (void)themeUpdate
{
    self.mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"kRRReadMode"];
}

- (void)switchReadMode
{
    if (self.mode == RRReadModeDark) {
        self.mode = RRReadModeLight;
    }
    else if(self.mode == RRReadModeLight)
    {
        self.mode = RRReadModeDark;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [@"已切换至" stringByAppendingString:self.mode == RRReadModeDark?@"暗色主题":@"亮色主题"]);
    });
    [[NSUserDefaults standardUserDefaults] setInteger:self.mode forKey:@"kRRReadMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"RRCasNeedReload" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RRWebNeedReload" object:nil];
    
    [[(UIViewController*)self.view navigationController] setNeedsStatusBarAppearanceUpdate];
}

- (RRFeedInputer *)inputer
{
    if (!_inputer) {
        _inputer  = [[RRFeedInputer alloc] init];
    }
    return _inputer;
}

- (RRFeedReaderStyleInputer *)readStyleInputer
{
    if (!_readStyleInputer) {
        _readStyleInputer = [[RRFeedReaderStyleInputer alloc] init];
    }
    return _readStyleInputer;
}

- (MVPComplexInput *)complexInput
{
    if (!_complexInput) {
        _complexInput = [[MVPComplexInput alloc] init];
        [_complexInput addInput:self.readStyleInputer];
        [_complexInput addInput:self.inputer];
    }
    return _complexInput;
}

- (id)mvp_inputerWithOutput:(id<MVPOutputProtocol>)output
{
    return self.complexInput;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.firstEnter = YES;
        self.title = @"Reader Prime";
        self.needUpdate = YES;
        self.needUpdateFeed = NO;
        self.mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"kRRReadMode"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateData) name:@"RRMainListNeedUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataMain) name:@"RRMainListUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeUpdate) name:@"RRWebNeedReload" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        
        NSDictionary* itemsSetting = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kMainListItemSetting];
        if (!itemsSetting) {
            itemsSetting = @{
                             kShowUnread:@(YES),
                             kShowFav:@(YES),
                             kShowLater:@(YES),
                             kShowRecent:@(YES)
                             };
            [[NSUserDefaults standardUserDefaults] setObject:itemsSetting forKey:kMainListItemSetting];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        self.listItemSetting = [itemsSetting mutableCopy];
    }
    return self;
}



- (void)needUpdateData
{
    self.needUpdate = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.needUpdate) {
        [self loadData];
    }
    
    if (self.needUpdateFeed) {
        self.needUpdateFeed = NO;
        [self refreshData:nil];
    }
    
    self.offsetY = [MVCKeyValue getFloatforKey:kOffsetMainList];
    //    self.offsetY = 100;
//    NSLog(@"main offset %@",@(self.offsetY));
    self.mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"kRRReadMode"];
    [[(UIViewController*)self.view toolbarItems] firstObject].enabled = YES;
}

- (void)updateOffsetY:(NSNumber*)offsetY
{
    [MVCKeyValue setFloat:[offsetY doubleValue] forKey:kOffsetMainList];
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    self.needUpdateFeed = YES;
    
    [[RPDataNotificationCenter defaultCenter] registEntityChange:@"EntityFeedInfo" observer:self sel:@selector(needUpdateData)];
    
    [[RPDataNotificationCenter defaultCenter] registEntityChange:@"EntityHub" observer:self sel:@selector(needUpdateData)];

    [[RPDataNotificationCenter defaultCenter] registEntityChange:@"EntityFeedArticle" observer:self sel:@selector(needUpdateData)];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    self.editing = editing;
    if (editing) {
//        [self.readStyleInputer mvp_deleteModelAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.readStyleInputer showAll];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endEditing];
        });
       
    }
}

- (void)endEditing
{
    [[self.readStyleInputer allModels] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id <RRCanEditProtocol> o = obj;
        if (o.editType == RRCEEditTypeInsert) {
            [self.readStyleInputer hideModel:o];
        }
    }];
    
    NSLog(@"-- %@",@(self.recentModel != nil));
    NSLog(@"-- %@",@(self.laterModel != nil));
    NSLog(@"-- %@",@(self.favModel != nil));
    NSLog(@"-- %@",@(self.unreadModel != nil));
    
    if (self.recentModel) {
        self.listItemSetting[kShowRecent] = @(self.recentModel.editType == RRCEEditTypeDelete);
    }
    if (self.favModel) {
        self.listItemSetting[kShowFav] = @(self.favModel.editType == RRCEEditTypeDelete);
    }
    if (self.laterModel) {
       self.listItemSetting[kShowLater] = @(self.laterModel.editType == RRCEEditTypeDelete);
    }
    if (self.unreadModel) {
        self.listItemSetting[kShowUnread] = @(self.unreadModel.editType == RRCEEditTypeDelete);
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:self.listItemSetting forKey:kMainListItemSetting];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.68 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.editing) {
            [self loadData];
        }
    });
}

- (void)removeAll
{
    [self.complexInput mvp_cleanAll];
}

- (void)loadDataMain
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeAll];
        [self loadData];
    });
}

- (NSInteger)unreadCount
{
    NSNumber* count = [[RPDataManager sharedManager] getCount:@"EntityFeedArticle" predicate:[self.unreadModel.readStyle predicate] key:nil value:nil sort:nil asc:YES];

    return [count integerValue];
}

- (void)updateUnreadCount
{
    self.unreadModel.count = [self unreadCount];
}

- (void)loadData
{
    NSArray* a = [[RPDataManager sharedManager] getAll:@"EntityFeedInfo" predicate:nil key:nil value:nil sort:@"sort" asc:YES];
    if (a.count == 0 && self.firstEnter) {
        self.firstEnter = NO;
        return;
    }
    self.firstEnter = NO;
    
    
    [self.complexInput mvp_cleanAll];
    [self.readStyleInputer reset];
//
//    RRFeedInfoListOtherModel* mTitle = [[RRFeedInfoListOtherModel alloc] init];
//    mTitle.title = @"阅读规则";
//    mTitle.canEdit = NO;
//    mTitle.idx = 0;
//    mTitle.type = RRFeedInfoListOtherModelTypeTitle;
//    [self.readStyleInputer mvp_addModel:mTitle];
    
    {
        RRFeedInfoListOtherModel* mUnread = GetRRFeedInfoListOtherModel(@"未读订阅",@"favicon",@"三日内的未读文章",@"unread");
        mUnread.canRefresh = YES;
        mUnread.canEdit = YES;
        mUnread.idx = 0;
        mUnread.editType = [self.listItemSetting[kShowUnread] boolValue] ? RRCEEditTypeDelete : RRCEEditTypeInsert;
        mUnread.readStyle = ({
            RRReadStyle* s = [[RRReadStyle alloc] init];
            s.onlyUnread = YES;
            s.daylimit = 3;
            s.liked = NO;
            s;
        });
        self.unreadModel = mUnread;
        mUnread.count = [self unreadCount];
        
        if (mUnread.count != 0) {
            [self.readStyleInputer mvp_addModel:mUnread];
            if (![self.listItemSetting[kShowUnread] boolValue]) {
                [self.readStyleInputer hideModel:mUnread];
            }
        }
        else {
            [self.readStyleInputer hideModel:mUnread];
        }
      
        {
            RRFeedInfoListOtherModel* mLater = GetRRFeedInfoListOtherModel(@"稍后阅读",@"favicon_4",@"想看还没有看的文章",@"readlater");
            mLater.canRefresh = NO;
            mLater.canEdit = YES;
            mLater.idx = 1;
            mLater.editType = [self.listItemSetting[kShowLater] boolValue] ? RRCEEditTypeDelete : RRCEEditTypeInsert;
            self.laterModel = mLater;
            mLater.readStyle = ({
                RRReadStyle* s = [[RRReadStyle alloc] init];
//                s.onlyReaded = YES;
//                s.countlimit = 20;
                s.readlater = YES;
                s;
            });
            
            NSNumber* count3 = [[RPDataManager sharedManager] getCount:@"EntityFeedArticle" predicate:[mLater.readStyle predicate] key:nil value:nil sort:nil asc:YES];
            mLater.count = [count3 integerValue];
            
            if ([count3 integerValue] > 0) {
                [self.readStyleInputer mvp_addModel:mLater];
                if (![self.listItemSetting[kShowLater] boolValue]) {
                    [self.readStyleInputer hideModel:mLater];
                }
            }
            else {
                [self.readStyleInputer hideModel:mLater];
            }
          
        }
        
        RRFeedInfoListOtherModel* mFavourite = GetRRFeedInfoListOtherModel(@"收藏",@"favicon_1",@"收藏的文章",@"favourite");
        mFavourite.canRefresh = NO;
        mFavourite.canEdit = YES;
        mFavourite.idx = 2;
        mFavourite.editType = [self.listItemSetting[kShowFav] boolValue] ? RRCEEditTypeDelete : RRCEEditTypeInsert;
        self.favModel = mFavourite;

        mFavourite.readStyle = ({
            RRReadStyle* s = [[RRReadStyle alloc] init];
            s.onlyUnread = NO;
            s.daylimit = 0;
            s.liked = YES;
            s;
        });
        
        NSNumber* count2 = [[RPDataManager sharedManager] getCount:@"EntityFeedArticle" predicate:[mFavourite.readStyle predicate] key:nil value:nil sort:nil asc:YES];
        mFavourite.count = [count2 integerValue];
        
        if ([count2 integerValue] > 0) {
            [self.readStyleInputer mvp_addModel:mFavourite];
            if (![self.listItemSetting[kShowFav] boolValue]) {
                [self.readStyleInputer hideModel:mFavourite];
            }
        }
        else {
            [self.readStyleInputer hideModel:mFavourite];
        }
     
        
        {
            RRFeedInfoListOtherModel* mLast = GetRRFeedInfoListOtherModel(@"最近阅读",@"favicon_3",@"近期阅读的30篇文章",@"last");
            mLast.canRefresh = NO;
            mLast.canEdit = YES;
            mLast.idx = 3;
            mLast.editType = [self.listItemSetting[kShowRecent] boolValue] ? RRCEEditTypeDelete : RRCEEditTypeInsert;;
            mLast.readStyle = ({
                RRReadStyle* s = [[RRReadStyle alloc] init];
                s.onlyReaded = YES;
                s.countlimit = 30;
                s.withOutNotReadlyRead = YES;
                s;
            });
            self.recentModel = mLast;
            
            NSNumber* count3 = [[RPDataManager sharedManager] getCount:@"EntityFeedArticle" predicate:[mLast.readStyle predicate] key:nil value:nil sort:nil asc:YES];
            mLast.count = [count3 integerValue] > mLast.readStyle.countlimit ? mLast.readStyle.countlimit : [count3 integerValue];
            
            if ([count3 integerValue] > 0) {
                [self.readStyleInputer mvp_addModel:mLast];
                if (![self.listItemSetting[kShowRecent] boolValue]) {
                    [self.readStyleInputer hideModel:mLast];
                }
            }
            else {
                [self.readStyleInputer hideModel:mLast];
            }
          
        }
    }
    
//    if ([self.readStyleInputer mvp_count] == 1) {
//        [self.readStyleInputer mvp_deleteModel:mTitle];
//    }
    
    {
        RRFeedInfoListOtherModel* m = [[RRFeedInfoListOtherModel alloc] init];
        m.title = @"订阅源";
        m.canEdit = NO;
        m.idx = 4;
        m.type = RRFeedInfoListOtherModelTypeTitle;
        
        if (a.count>0) {
            [self.readStyleInputer mvp_addModel:m];
        }
        
        NSMutableArray* allFeedAndHub = [NSMutableArray arrayWithCapacity:10];
        
        NSArray* hubs = [[RPDataManager sharedManager] getAll:@"EntityHub" predicate:nil key:nil value:nil sort:@"sort" asc:YES];
        [hubs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RRFeedInfoListModel* m = [[RRFeedInfoListModel alloc] init];
            [m loadFromFeed:obj];
            m.thehub = obj;
            m.canEdit = YES;
            m.canMove = YES;
            [allFeedAndHub addObject:m];
        }];
        
        [a enumerateObjectsUsingBlock:^(EntityFeedInfo*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.hub.count > 0) {
                
            }
            else {
                RRFeedInfoListModel* m = [[RRFeedInfoListModel alloc] init];
                [m loadFromFeed:obj];
                m.feed = obj;
                m.canEdit = YES;
                m.canMove = YES;
                [allFeedAndHub addObject:m];
            }
        }];
        
        [allFeedAndHub sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES]]];
        
        [allFeedAndHub enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.inputer mvp_addModel:obj];
        }];
       
    }
    
    self.hasDatas = YES;
    if([self.complexInput mvp_count]==0)
    {
        self.hasDatas = NO;
        [self.view mvp_runAction:NSSelectorFromString(@"reloadEmpty")];
    }
    
    self.needUpdate = NO;
}

- (NSNumber*)hasData
{
    return @(self.hasDatas);
}

- (void)openSetting
{
    id view = [MVPRouter viewForURL:@"rr://setting" withUserInfo:nil];
    [self.view mvp_pushViewController:view];
}

- (void)addRSS
{
    id vc = [MVPRouter viewForURL:@"rr://addfeed" withUserInfo:nil];
    [self.view mvp_pushViewController:vc];
}

- (void)addHub
{
//    NSArray* d = [[RPDataManager sharedManager] getAll:@"EntityFeedInfo"  predicate:nil key:nil value:nil sort:nil asc:YES];
    //NSLog(@"%@",d);
}

- (void)openSearch:(NSString*)searchText
{
    RRFeedInfoListOtherModel* mSearch = [RRFeedInfoListOtherModel searchModel:searchText];
    id vc = [MVPRouter viewForURL:@"rr://list" withUserInfo:@{@"model":mSearch}];
    [self.view mvp_pushViewController:vc];
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIAccessibilityPageScrolledNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RRMainListNeedUpdate" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RRMainListUpdate" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RRWebNeedReload" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[RPDataNotificationCenter defaultCenter] unregistEntityChange:@"EntityFeedInfo" observer:self];
    
    [[RPDataNotificationCenter defaultCenter] unregistEntityChange:@"EntityHub" observer:self];
    
    [[RPDataNotificationCenter defaultCenter] unregistEntityChange:@"EntityFeedArticle" observer:self];
}

- (void)refreshData:(UIRefreshControl*)sender
{
    self.refresher = sender;
    if (self.editing) {
        [self.refresher endRefreshing];
        return;
    }
    if (self.updating) {
        return;
    }
    self.updating = YES;
    
    NSArray* all = self.inputer.allModels;
    all = all.map(^id _Nonnull(RRFeedInfoListModel*   _Nonnull x) {
        if (x.thehub) {
            NSArray* infos = [x.thehub.infos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES]]];
            return infos.map(^id _Nonnull(EntityFeedInfo*  _Nonnull x) {
                RRFeedInfoListModel* l = [[RRFeedInfoListModel alloc] init];
                [l loadFromFeed:x];
                l.feed = x;
                return l;
            });
        }
        else {
            return x;
        }
    }).flatten(1);
    
//    [all enumerateObjectsUsingBlock:^(RRFeedInfoListModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"%@",obj.title);
//    }];
//
    // RRTODO:这部分也需要拆分，目前已经有三个地方用到了
    all =
    all.filter(^BOOL(RRFeedInfoListModel*  _Nonnull x) {
        NSString* key = [NSString stringWithFormat:@"UPDATE_%@",x.url];
        NSInteger lastU = [MVCKeyValue getIntforKey:key];
        if (lastU != 0) {
            NSDate* d = [NSDate dateWithTimeIntervalSince1970:lastU];
            //NSLog(@"last %@ %@",d,@([d timeIntervalSinceDate:[NSDate date]]));
            if ([d timeIntervalSinceDate:[NSDate date]] > - 60) {
                return NO;
            }
        }
        
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
  
    
    __weak typeof(self) weakSelf = self;
    [[RRFeedLoader sharedLoader] refresh:all endRefreshBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf.refresher endRefreshing];
        });
    } progress:^(NSUInteger current, NSUInteger all) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.title = [@"更新" stringByAppendingFormat:@"(%ld/%ld)",current,all];
        });
    }  finishBlock:^(NSUInteger all, NSUInteger error, NSUInteger article) {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            
            weakSelf.updating = NO;
            weakSelf.title = @"Reader Prime";
            if (article == 0) {
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"更新结束，没有更新的订阅");
//                [PWToastView showText:@"没有更新的订阅"];
            }
            else {
                [weakSelf loadDataMain];
                if (error == 0) {
                    NSString* tip = [NSString stringWithFormat:@"更新了%ld个订阅源，共计%ld篇订阅",all,article];
                    [PWToastView showText:tip];
                    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"更新了%ld篇订阅",article]);
                }
                else {
                    [PWToastView showText:[NSString stringWithFormat:@"更新了%ld个订阅源，共计%ld篇订阅，%ld个源更新失败",all,article,error]];
                    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"更新了%ld篇订阅",article]);
                }
            }
        });
    }];
}

- (void)refreshData2:(UIRefreshControl*)sender
{
    // ReadyTODO:刷新
//    NSArray* all =
    NSArray* all = self.inputer.allModels;
    all =
    all.filter(^BOOL(RRFeedInfoListModel*  _Nonnull x) {
        NSString* key = [NSString stringWithFormat:@"UPDATE_%@",x.url];
        NSInteger lastU = [MVCKeyValue getIntforKey:key];
        if (lastU != 0) {
            NSDate* d = [NSDate dateWithTimeIntervalSince1970:lastU];
            //NSLog(@"last %@ %@",d,@([d timeIntervalSinceDate:[NSDate date]]));
            if ([d timeIntervalSinceDate:[NSDate date]] > - 60 * 10) {
                return NO;
            }
        }
        
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
    
    if (all.count == 0) {
        [sender endRefreshing];
        [PWToastView showText:@"没有更新的订阅"];
        return;
    }
    
    NSUInteger feedCount = all.count;
    __block NSUInteger finishCount = 0;
//    __block NSUInteger articleCount = 0;
    __block NSUInteger errorCount = 0;
    
    NSMapTable* dd = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:10];
    NSMutableArray* a = [[NSMutableArray alloc] init];
    
    [[RRFeedLoader sharedLoader] reloadAll:all infoBlock:^(MWFeedInfo * _Nonnull info) {
//        //NSLog(@"更新%@",info.title);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* key = [NSString stringWithFormat:@"UPDATE_%@",info.url];
            [MVCKeyValue setInt:[[NSDate date] timeIntervalSince1970] forKey:key];
        });
        
    } itemBlock:^(MWFeedInfo * _Nonnull info, MWFeedItem * _Nonnull item) {
        RRFeedArticleModel* m = [[RRFeedArticleModel alloc] initWithItem:item];
        EntityFeedInfo* i = [dd objectForKey:info];
        if (!i)
        {
            i = [[RPDataManager sharedManager] getFirst:@"EntityFeedInfo" predicate:nil key:@"url" value:info.url sort:nil asc:YES];
            [dd setObject:i forKey:info];
        }
        m.feedEntity = i;
        [a addObject:m];
 
//        //NSLog(@"- %@- %@",info.title, item.title);
    } errorBlock:^(NSString * _Nonnull infoURL, NSError * _Nonnull error) {
 
        errorCount ++;
        
    } finishBlock:^{
        
        finishCount ++;
        //NSLog(@"finish %ld %ld",errorCount,finishCount);
        if (finishCount + errorCount == feedCount) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender endRefreshing];
            });
            
            [RRFeedAction insertArticle:a finish:^(NSUInteger x) {
                //NSLog(@"添加 %ld 篇文章",x);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (x == 0) {
                        [PWToastView showText:@"没有更新的订阅"];
                    }
                    else {
                        [self loadData];
                        if (errorCount == 0) {
                            [PWToastView showText:[NSString stringWithFormat:@"更新了%ld个订阅源，共计%ld篇订阅",finishCount,x]];
                        }
                        else {
                            [PWToastView showText:[NSString stringWithFormat:@"更新了%ld个订阅源，共计%ld篇订阅，%ld个源更新失败",finishCount,x,errorCount]];
                        }
                    }
                });
            }];
        }
    }];
}

- (void)mvp_action_selectItemAtIndexPath:(NSIndexPath *)path
{
    id vc = [self viewControllerAtIndexPath:path];
    [self.view mvp_pushViewController:vc];
}

- (id)viewControllerAtIndexPath:(NSIndexPath*)path
{
    id model = [self.complexInput mvp_modelAtIndexPath:path];
    if ([model isKindOfClass:[RRFeedInfoListModel class]]) {
        id vc = [MVPRouter viewForURL:@"rr://list" withUserInfo:@{@"model":model}];
//        [self.view mvp_pushViewController:vc];
        return vc;
    }
    else if([model isKindOfClass:[RRFeedInfoListOtherModel class]])
    {
        RRFeedInfoListOtherModel* m = model;
        if (m.type == RRFeedInfoListOtherModelTypeItem) {
            id vc = [MVPRouter viewForURL:@"rr://list" withUserInfo:@{@"model":model}];
//            [self.view mvp_pushViewController:vc];
            return vc;
        }
    }
    return nil;
}

- (void)recommand
{
    id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":@"推荐订阅源.md"}];
    [[self view] mvp_pushViewController:vc];
}

- (void)recommand2
{
    id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":@"网友推荐源.md"}];
    [[self view] mvp_pushViewController:vc];
}

- (void)openActionText:(UIBarButtonItem*)sender
{
    __weak typeof(self) weakSelf = self;
    NSBlockOperation* action1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf addRSS];
    }];
    
    NSBlockOperation* action2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf recommand];
    }];
    
    NSBlockOperation* action3 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf recommand2];
    }];
    
    UIViewController* vc = [MVPRouter viewForURL:@"rr://websetting?p=RRMainPageAddPresenter" withUserInfo:@{@"action1":action1,@"action2":action2,@"action3":action3}];
    RRExtraViewController* nv = [[RRExtraViewController alloc] initWithRootViewController:vc];
    vc.preferredContentSize = CGSizeMake(200, 94);
    [nv.view setBackgroundColor:[UIColor clearColor]];
    nv.modalPresentationStyle = UIModalPresentationPopover;
    nv.popoverPresentationController.barButtonItem = sender;
    nv.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    nv.popoverPresentationController.delegate = self;
//    nv.popoverPresentationController.popoverLayoutMargins = UIEdgeInsetsMake(15,15,15,15);
    NSDictionary* style = [[NSUserDefaults standardUserDefaults] valueForKey:@"style"];
    nv.popoverPresentationController.backgroundColor = UIColor.hex(style[@"$bar-tint-color"]);
    [(UIViewController*)self.view presentViewController:nv animated:YES completion:^{
        
    }];
    
    [[(UIViewController*)self.view toolbarItems] firstObject].enabled = NO;
    
}



#pragma mark --  实现代理方法
//默认返回的是覆盖整个屏幕，需设置成UIModalPresentationNone。
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

//点击蒙版是否消失，默认为yes；

-(BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;
}

//弹框消失时调用的方法
-(void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    //NSLog(@"弹框已经消失");
    [[(UIViewController*)self.view toolbarItems] firstObject].enabled = YES;
}


- (void)cleanAll
{
    __weak typeof(self) weakSelf = self;
    if (self.selectArray.count == 0) {
        NSPredicate* p = [NSPredicate predicateWithFormat:@"readed = false"];
        [[RPDataManager sharedManager] updateDatas:@"EntityFeedArticle" predicate:p modify:^(EntityFeedArticle*  _Nonnull obj) {
            obj.readed = YES;
        } finish:^(NSArray * _Nonnull results, NSError * _Nonnull e) {
            NSLog(@"%@",e);
            if (!e) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hudSuccess:@"全部标记成功"];
                    [weakSelf updateSelections:@[]];
//                    NSInteger c = [self unreadCount];
//                    if (c == 0) {
//                        if ([self.readStyleInputer mvp_indexPathWithModel:self.unreadModel]) {
//                            [self.readStyleInputer mvp_deleteModel:self.unreadModel];
//                        }
//
//                    }
                    [weakSelf updateUnreadCount];
                    [[weakSelf view] mvp_reloadData];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hudFail:@"标记失败"];
                });
            }
        }];
    }
    else {
        [self.selectArray enumerateObjectsUsingBlock:^(NSIndexPath*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EntityFeedInfo* i = [self.complexInput mvp_modelAtIndexPath:obj];
//            NSLog(@"%@",i);
            NSPredicate* p = [NSPredicate predicateWithFormat:@"feed.uuid = %@",i.uuid];
            [[RPDataManager sharedManager] updateDatas:@"EntityFeedArticle" predicate:p modify:^(EntityFeedArticle*  _Nonnull obj) {
                obj.readed = YES;
            } finish:^(NSArray * _Nonnull results, NSError * _Nonnull e) {
                NSLog(@"%@",e);
                if (!e) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view hudSuccess:@"标记成功"];
                        [weakSelf updateSelections:@[]];
//                        NSInteger c = [weakSelf unreadCount];
//                        if (c == 0) {
//                            if ([weakSelf.readStyleInputer mvp_indexPathWithModel:weakSelf.unreadModel]) {
//                                [weakSelf.readStyleInputer mvp_deleteModel:weakSelf.unreadModel];
//                            }
//                        }
                        [weakSelf updateUnreadCount];
                        [[weakSelf view] mvp_reloadData];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view hudFail:@"标记失败"];
                    });
                }
            }];
            
        }];
    }
}

- (void)makeItCopyed:(id)sender
{
    RRFeedInfoListModel* m = (id)[self.complexInput mvp_modelAtIndexPath:sender];
    if (m.feed) {
        [[UIPasteboard generalPasteboard] setURL:m.feed.url];
        [self.view hudSuccess:@"复制成功"];
    }
}

- (void)makeItDelete:(id)sender
{
//    NSLog(@"%@",sender);
    __weak typeof(self) weakSelf = self;
    RRFeedInfoListModel* m = (id)[self.complexInput mvp_modelAtIndexPath:sender];
    if (m.feed) {
        [RRFeedAction delFeed:m.feed view:(id)self.view item:nil arrow:UIPopoverArrowDirectionRight finish:^{
            [weakSelf loadData];
        }];
    }
    else if(m.thehub)
    {
        NSArray* feeds = [m.thehub.infos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES]]];
        UIAlertController* alert = UI_Alert().
        titled(@"请选择要取消的源");
        [feeds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            alert.action([obj title], ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
                [RRFeedAction delFeed:obj view:(id)self.view item:nil arrow:UIPopoverArrowDirectionRight finish:^{
                    [weakSelf loadData];
                }];
            });
        }];
        alert.cancel(@"取消", nil);
        alert.show((id)self.view);
    }
}

- (void)makeHubDelete:(id)sender
{
    __weak typeof(self) weakSelf = self;
    RRFeedInfoListModel* m = (id)[self.complexInput mvp_modelAtIndexPath:sender];
    if (m.thehub) {
        UI_Alert()
        .titled([NSString stringWithFormat:@"确认删除分类「%@」",m.thehub.title])
        .recommend(@"删除", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
            [RRFeedManager removeHUB:m.thehub complete:^(BOOL s) {
                if (s) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view hudSuccess:@"操作成功"];
                        [weakSelf loadData];
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
}

- (void)makeItRead:(id)sender
{
//    NSLog(@"%@",sender);
    __weak typeof(self) weakSelf = self;
    RRFeedInfoListModel* m = (id)[self.complexInput mvp_modelAtIndexPath:sender];
    NSPredicate* p;
    if (m.feed) {
        p = [NSPredicate predicateWithFormat:@"feed.uuid = %@",m.feed.uuid];
    }
    else if(m.thehub){

        NSMutableArray* pa = [[NSMutableArray alloc] init];
        [m.thehub.infos enumerateObjectsUsingBlock:^(EntityFeedInfo * _Nonnull obj, BOOL * _Nonnull stop) {
            [pa addObject:[NSPredicate predicateWithFormat:@"feed.uuid = %@",obj.uuid]];
        }];
        p = [NSCompoundPredicate orPredicateWithSubpredicates:pa];
    }
    
    [[RPDataManager sharedManager] updateDatas:@"EntityFeedArticle" predicate:p modify:^(EntityFeedArticle*  _Nonnull obj) {
        obj.readed = YES;
    } finish:^(NSArray * _Nonnull results, NSError * _Nonnull e) {
        if (!e) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateSelections:@[]];
//                NSInteger c = [weakSelf unreadCount];
//                weakSelf.unreadModel.count = c;
//                if (c == 0) {
//                    if ([weakSelf.readStyleInputer mvp_indexPathWithModel:weakSelf.unreadModel]) {
//                        [weakSelf.readStyleInputer mvp_deleteModel:weakSelf.unreadModel];
//                    }
//                }
                [weakSelf updateUnreadCount];
                [[weakSelf view] mvp_reloadData];
            });
        }
        else {
        }
    }];
}

@end
