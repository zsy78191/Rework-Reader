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

@interface RRFeedListPresenter()
{
    
}
@property (nonatomic, strong) MVPComplexInput* complexInput;
@property (nonatomic, strong) RRFeedInputer* inputer;
@property (nonatomic, strong) RRFeedReaderStyleInputer* readStyleInputer;
@property (nonatomic, assign) BOOL needUpdate;
@end

@implementation RRFeedListPresenter

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
        self.title = @"Reader Special";
        self.needUpdate = YES;
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
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    [[RPDataNotificationCenter defaultCenter] registEntityChange:@"EntityFeedInfo" observer:self sel:@selector(needUpdateData)];
    
    [[RPDataNotificationCenter defaultCenter] registEntityChange:@"EntityFeedArticle" observer:self sel:@selector(needUpdateData)];
}

- (void)loadData
{
    [self.complexInput mvp_cleanAll];
    
    {
        RRFeedInfoListOtherModel* m = [[RRFeedInfoListOtherModel alloc] init];
        m.title = @"阅读规则";
        m.canEdit = NO;
        m.type = RRFeedInfoListOtherModelTypeTitle;
        [self.readStyleInputer mvp_addModel:m];
    }
    
    {
        RRFeedInfoListOtherModel* (^model)(NSString* title,NSString* icon, NSString* subtitle, NSString* key) = ^(NSString* title,NSString* icon, NSString* subtitle, NSString* key){
            RRFeedInfoListOtherModel* m = [[RRFeedInfoListOtherModel alloc] init];
            m.title = title;
            m.icon = icon;
            m.subtitle = subtitle;
            m.key = key;
            m.type = RRFeedInfoListOtherModelTypeItem;
            return m;
        };
        
        RRFeedInfoListOtherModel* mUnread = model(@"未读订阅",@"favicon",@"三日内的未读文章",@"unread");
        mUnread.canRefresh = YES;
        mUnread.canEdit = NO;
        mUnread.readStyle = ({
            RRReadStyle* s = [[RRReadStyle alloc] init];
            s.onlyUnread = YES;
            s.daylimit = 3;
            s.liked = NO;
            s;
        });
        
        NSNumber* count = [[RPDataManager sharedManager] getCount:@"EntityFeedArticle" predicate:[mUnread.readStyle predicate] key:nil value:nil sort:nil asc:YES];
        mUnread.count = [count intValue];
        
        [self.readStyleInputer mvp_addModel:mUnread];
        
        RRFeedInfoListOtherModel* mFavourite = model(@"收藏",@"favicon",@"收藏的文章",@"favourite");
        mFavourite.canRefresh = NO;
        mFavourite.canEdit = NO;
        mFavourite.readStyle = ({
            RRReadStyle* s = [[RRReadStyle alloc] init];
            s.onlyUnread = NO;
            s.daylimit = 0;
            s.liked = YES;
            s;
        });
        
        NSNumber* count2 = [[RPDataManager sharedManager] getCount:@"EntityFeedArticle" predicate:[mFavourite.readStyle predicate] key:nil value:nil sort:nil asc:YES];
        mFavourite.count = [count2 intValue];
        
        if ([count2 integerValue] > 0) {
            [self.readStyleInputer mvp_addModel:mFavourite];
        }
        
        {
            RRFeedInfoListOtherModel* mLast = model(@"最近阅读",@"favicon",@"近期阅读的文章",@"last");
            mLast.canRefresh = NO;
            mLast.canEdit = NO;
            mLast.readStyle = ({
                RRReadStyle* s = [[RRReadStyle alloc] init];
                s.onlyReaded = YES;
                s;
            });
            
            NSNumber* count3 = [[RPDataManager sharedManager] getCount:@"EntityFeedArticle" predicate:[mLast.readStyle predicate] key:nil value:nil sort:nil asc:YES];
            mLast.count = [count3 intValue];
            
            if ([count3 integerValue] > 0) {
                [self.readStyleInputer mvp_addModel:mLast];
            }
        }
    }
    
    {
        RRFeedInfoListOtherModel* m = [[RRFeedInfoListOtherModel alloc] init];
        m.title = @"订阅源";
        m.canEdit = NO;
        m.type = RRFeedInfoListOtherModelTypeTitle;
        [self.readStyleInputer mvp_addModel:m];
    }
    
    
    NSArray* a = [[RPDataManager sharedManager] getAll:@"EntityFeedInfo" predicate:nil key:nil value:nil sort:@"sort" asc:YES];
    
    [a enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RRFeedInfoListModel* m = [[RRFeedInfoListModel alloc] init];
        [m loadFromFeed:obj];
        m.feed = obj;
        m.canEdit = YES;
        [self.inputer mvp_addModel:m];
    }];
    
    
    self.needUpdate = NO;
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
    NSArray* d = [[RPDataManager sharedManager] getAll:@"EntityFeedInfo"  predicate:nil key:nil value:nil sort:nil asc:YES];
    NSLog(@"%@",d);
}

- (void)dealloc
{
    [[RPDataNotificationCenter defaultCenter] unregistEntityChange:@"EntityFeedInfo" observer:self];
}

- (void)refreshData:(UIRefreshControl*)sender
{
    NSArray* all = self.inputer.allModels;
    all =
    all.filter(^BOOL(RRFeedInfoListModel*  _Nonnull x) {
        NSString* key = [NSString stringWithFormat:@"UPDATE_%@",x.url];
        NSInteger lastU = [MVCKeyValue getIntforKey:key];
        if (lastU != 0) {
            NSDate* d = [NSDate dateWithTimeIntervalSince1970:lastU];
            NSLog(@"last %@ %@",d,@([d timeIntervalSinceDate:[NSDate date]]));
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
    
    [[RRFeedLoader sharedLoader] refresh:all endRefreshBlock:^{
        [sender endRefreshing];
    } finishBlock:^(NSUInteger all, NSUInteger error, NSUInteger article) {
        if (article == 0) {
            [PWToastView showText:@"没有更新的订阅"];
        }
        else {
            [self loadData];
            if (error == 0) {
                [PWToastView showText:[NSString stringWithFormat:@"更新了%ld个订阅源，共计%ld篇订阅",all,article]];
            }
            else {
                [PWToastView showText:[NSString stringWithFormat:@"更新了%ld个订阅源，共计%ld篇订阅，%ld个源更新失败",all,article,error]];
            }
        }
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
            NSLog(@"last %@ %@",d,@([d timeIntervalSinceDate:[NSDate date]]));
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
//        NSLog(@"更新%@",info.title);
        
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
 
//        NSLog(@"- %@- %@",info.title, item.title);
    } errorBlock:^(NSError * _Nonnull error) {
        NSLog(@"err %@",error);
        errorCount ++;
        
    } finishBlock:^{
        
        finishCount ++;
        NSLog(@"finish %ld %ld",errorCount,finishCount);
        if (finishCount + errorCount == feedCount) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender endRefreshing];
            });
            
            [RRFeedAction insertArticle:a finish:^(NSUInteger x) {
                NSLog(@"添加 %ld 篇文章",x);
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
    id model = [self.complexInput mvp_modelAtIndexPath:path];
    if ([model isKindOfClass:[RRFeedInfoListModel class]]) {
        id vc = [MVPRouter viewForURL:@"rr://list" withUserInfo:@{@"model":model}];
        [self.view mvp_pushViewController:vc];
    }
    else if([model isKindOfClass:[RRFeedInfoListOtherModel class]])
    {
        id vc = [MVPRouter viewForURL:@"rr://list" withUserInfo:@{@"model":model}];
        [self.view mvp_pushViewController:vc];
    }
   
}

@end
