//
//  RRFeedLoader.m
//  rework-reader
//
//  Created by 张超 on 2019/2/13.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedLoader.h"
//@import Fork_MWFeedParser;

#import "MVPViewLoadProtocol.h"
#import "RRGetWebIconOperation.h"
@import mvc_base;
@import oc_string;
#import "RRFeedInfoListModel.h"
@import oc_util;
@import DateTools;
#import "RRFeedArticleModel.h"
#import "RPDataManager.h"
#import "RRFeedAction.h"
#import "OPMLDocument.h"
@import KissXML;
@import RegexKitLite;
#import "RRCoreDataModel.h"

@interface RRFeedLoader ()
@property (nonatomic, strong) NSOperationQueue* highQuene;
@property (nonatomic, strong) NSOperationQueue* quene;
@property (nonatomic, strong) NSOperationQueue* netQuene;
@property (nonatomic, assign) BOOL isFeeding;
@property (nonatomic, weak) FMFeedParserOperation* currentOperation;
@end

@implementation RRFeedLoader

- (void)setQualityLevel:(NSQualityOfService)service
{
    [self.quene setQualityOfService:service];
    [self.netQuene setQualityOfService:service];
}

+ (instancetype)sharedLoader
{
    static RRFeedLoader* _shared_loader_g = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared_loader_g = [[RRFeedLoader alloc] init];
//        _shared_loader_g.useMainQuene = NO;
        [_shared_loader_g setQualityLevel:NSQualityOfServiceBackground];
    });
    return _shared_loader_g;
}

- (NSOperationQueue *)quene
{
    if (!_quene) {
        _quene = [[NSOperationQueue alloc] init];
        
        [_quene setMaxConcurrentOperationCount:30];
    }
    return _quene;
}

- (NSOperationQueue *)netQuene
{
    if (!_netQuene) {
        _netQuene = [[NSOperationQueue alloc] init];
        _netQuene.qualityOfService = NSQualityOfServiceBackground;
        [_netQuene setMaxConcurrentOperationCount:30];
    }
    return _netQuene;
}

- (NSOperationQueue *)highQuene
{
    if (!_highQuene) {
        _highQuene = [[NSOperationQueue alloc] init];
        [_highQuene setQualityOfService:NSQualityOfServiceBackground];
        [_netQuene setMaxConcurrentOperationCount:30];
    }
    return _highQuene;
}

- (FMFeedParserOperation*)loadOfficalWithInfoBlock:(void (^)(MWFeedInfo * _Nonnull))infoblock itemBlock:(void (^)(MWFeedItem * _Nonnull))itemblock errorBlock:(void (^)(NSError * _Nonnull))errblock finishBlock:(void (^)(void))finishblock
{
    return [self loadFeed:@"http://orzer.zhangzichuan.cn/atom.xml" infoBlock:infoblock itemBlock:itemblock errorBlock:errblock finishBlock:finishblock needUpdateIcon:YES];
}

- (FMFeedParserOperation*)loadFeed:(NSString *)url infoBlock:(void (^)(MWFeedInfo * _Nonnull))infoblock itemBlock:(void (^)(MWFeedItem * _Nonnull))itemblock errorBlock:(void (^)(NSError * _Nonnull))errblock finishBlock:(void (^)(void))finishblock needUpdateIcon:(BOOL)need
{
    FMFeedParserOperation* (^feed)(NSString*,NSString*,NSOperationQueue*) = ^(NSString* name,NSString* url,NSOperationQueue* quene) {
        FMFeedParserOperation* o = [[FMFeedParserOperation alloc] init];
        o.feedURL = [NSURL URLWithString:url];
        o.title = name;
        o.netWorkQuene = quene;
        o.timeout = 4;
        return o;
    };
    
    FMFeedParserOperation* o = feed(@"1",url,self.netQuene);
    [o setParseInfoBlock:^(MWFeedInfo * _Nonnull info) {
        if (need) {
            RRGetWebIconOperation* o = [[RRGetWebIconOperation alloc] init];
            [o setHost:[NSURL URLWithString:info.link]];
            [o setGetIconBlock:^(NSString * _Nonnull icon) {
                info.icon = icon;
            }];
            [o start];
        }
        if (infoblock) {
            infoblock(info);
        }
    }];
    
    [o setParseItemBlock:^(MWFeedItem * _Nonnull item) {
        if (itemblock) {
            itemblock(item);
        }
    }];
    
    [o setParseErrorBlock:^(NSError * _Nonnull error) {
        if (errblock) {
            errblock(error);
        }
    }];
    
    [o setCompletionBlock:^{
        if (finishblock) {
            finishblock();
        }
    }];
    
    //NSLog(@"Add Operation %@",url);
    [self.highQuene addOperation:o];
    return o;
}

- (NSArray*)reloadAll:(NSArray<NSString *> *)feedURIs infoBlock:(void (^)(MWFeedInfo * _Nonnull))infoblock itemBlock:(void (^)(MWFeedInfo * _Nonnull, MWFeedItem * _Nonnull))itemblock errorBlock:(void (^)(NSString * _Nonnull, NSError * _Nonnull))errblock finishBlock:(void (^)(void))finishblock
{
    __block NSMutableArray* operations = [[NSMutableArray alloc] init];
    __block NSMutableArray* feeds = [[NSMutableArray alloc] init];
    [feedURIs enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id o = [self loadFeed:obj infoBlock:^(MWFeedInfo * _Nonnull info) {
            [feeds addObject:info];
            if (infoblock) {
                infoblock(info);
            }
        } itemBlock:^(MWFeedItem * _Nonnull item) {
            if (itemblock) {
                __block id info = nil;
                [feeds enumerateObjectsUsingBlock:^(MWFeedInfo*  _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([[obj2.url absoluteString] isEqualToString:obj]) {
                        info = obj2;
                    }
                }];
                itemblock(info,item);
            }
        } errorBlock:^(NSError * _Nonnull error) {
            if (errblock) {
                errblock(obj,error);
            }
        } finishBlock:^{
            if (finishblock) {
                finishblock();
            }
        } needUpdateIcon:NO];
        [operations addObject:o];
    }];
    return operations;
}

- (void)cancel:(FMFeedParserOperation *)operation
{
    [operation cancel];
}

- (NSDateFormatter *)shortDateFormatter
{
    if (!_shortDateFormatter) {
        _shortDateFormatter = [[NSDateFormatter alloc] init];
        [_shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_shortDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return _shortDateFormatter;
}

- (NSDateFormatter *)shortDateAndTimeFormatter
{
    if (!_shortDateAndTimeFormatter) {
        _shortDateAndTimeFormatter = [[NSDateFormatter alloc] init];
        [_shortDateAndTimeFormatter setDateStyle:NSDateFormatterShortStyle];
        [_shortDateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return _shortDateAndTimeFormatter;
}


- (UIViewController *)feedItem:(NSString *)url errorBlock:(void (^)(NSError * _Nonnull))errblock cancelBlock:(void (^)(void))cancelBlock finishBlock:(void (^)(void))finishblock
{
    if (self.isFeeding) {
        return nil;
    }
    self.isFeeding = YES;
    
    id v = [MVPRouter viewForURL:@"rr://feed" withUserInfo:nil];
    id<MVPViewLoadProtocol> tv = nil;
    if ([v conformsToProtocol:@protocol(MVPViewLoadProtocol)]) {
        tv = v;
    }
    
    __weak typeof(self) weakself = self;
    FMFeedParserOperation* operation = [[RRFeedLoader sharedLoader] loadFeed:url infoBlock:^(MWFeedInfo * _Nonnull info) {
        if (tv) {
            [tv loadData:info];
        }
    } itemBlock:^(MWFeedItem * _Nonnull item) {
        if (tv) {
            [tv loadData:item];
        }
    } errorBlock:^(NSError * _Nonnull error) {
        if (errblock) {
            errblock(error);
        }
        if (tv) {
            [tv loadError:error];
        }
        weakself.isFeeding = NO;
    } finishBlock:^{
        if (tv) {
            [tv loadFinish];
        }
        if (finishblock) {
            finishblock();
        }
        weakself.isFeeding = NO;
    } needUpdateIcon:YES];
    
    if (tv) {
        [tv setCancelBlock:^{
            [weakself canncelCurrentFeed];
            if (cancelBlock) {
                cancelBlock();
            }
        }];
    }
    
    self.currentOperation = operation;
    return v;
}


- (__kindof UIViewController*)feedItem:(NSString*)url errorBlock:(nonnull void (^)(NSError * _Nonnull))errblock finishBlock:(nonnull void (^)(void))finishblock
{
    return [self feedItem:url errorBlock:errblock cancelBlock:^{
        
    } finishBlock:finishblock];
}

- (void)canncelCurrentFeed
{
    if (self.currentOperation) {
        [self.currentOperation cancel];
        self.isFeeding = NO;
    }
}

- (void)refresh:(NSArray*)origin endRefreshBlock:(void (^)(void))endBlock finishBlock:(void (^)(NSUInteger all,NSUInteger error, NSUInteger article))finishBlock;
{
    [self refresh:origin endRefreshBlock:endBlock progress:nil finishBlock:finishBlock];
}

- (void)refresh:(NSArray*)origin endRefreshBlock:(void (^)(void))endBlock progress:(void(^ _Nullable )(NSUInteger current,NSUInteger all))progressblock finishBlock:(void (^)(NSUInteger all,NSUInteger error, NSUInteger article))finishBlock;
{
    if (self.loading) {
        //NSLog(@"End 1");
        if (endBlock) {
           endBlock();
        }
        if (finishBlock) {
            finishBlock(0,0,0);
        }
        return;
    }
    self.loading = true;
    NSArray* all = origin;
    if (all.count == 0) {
         //NSLog(@"End 2");
//        [sender endRefreshing];
//        [PWToastView showText:@"没有更新的订阅"];
        if (endBlock) {
            endBlock();
        }
        if (finishBlock) {
            finishBlock(0,0,0);
        }
        self.loading = false;
        return;
    }
    
    NSUInteger feedCount = all.count;
    __block NSUInteger finishCount = 0;
    //    __block NSUInteger articleCount = 0;
    __block NSUInteger errorCount = 0;
    __weak typeof(self) ws = self;
    NSMapTable* dd = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:10];
    NSMutableArray* a = [[NSMutableArray alloc] init];
    
         //NSLog(@"Step 6");
    [[RRFeedLoader sharedLoader] reloadAll:all infoBlock:^(MWFeedInfo * _Nonnull info) {
                ////NSLog(@"更新%@",info.title);
         //NSLog(@"Info 1 %@",info.title);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString* key = [NSString stringWithFormat:@"UPDATE_%@",info.url];
//            NSString* failedKey = [NSString stringWithFormat:@"FAILED_%@",info.url];
//            [MVCKeyValue setInt:[[NSDate date] timeIntervalSince1970] forKey:key];
//            [MVCKeyValue setBool:NO forKey:failedKey];
//        });
        
    } itemBlock:^(MWFeedInfo * _Nonnull info, MWFeedItem * _Nonnull item) {
//        //NSLog(@"item 1");
        RRFeedArticleModel* m = [[RRFeedArticleModel alloc] initWithItem:item];
        EntityFeedInfo* i = [dd objectForKey:info];
        if (!i)
        {
            i = [[RPDataManager sharedManager] getFirst:@"EntityFeedInfo" predicate:nil key:@"url" value:info.url sort:nil asc:YES];
            [dd setObject:i forKey:info];
        }
        if (!i.lastUpdateResult) {
            @try {
                [RRFeedAction markFeedAsEnable:YES feedUUID:[i uuid]];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
        m.feedEntity = i;
        if(m) {
           [a addObject:m];
        }
        
        //        ////NSLog(@"- %@- %@",info.title, item.title);
    } errorBlock:^(NSString * _Nonnull infoURL, NSError * _Nonnull error) {
             //NSLog(@"Error 1");
        EntityFeedInfo* i = [[RPDataManager sharedManager] getFirst:@"EntityFeedInfo" predicate:nil key:@"url" value:infoURL sort:nil asc:YES];
        //NSLog(@"%@ 更新失败",infoURL);
        //NSLog(@"%@",i.title);
        @try {
            [RRFeedAction markFeedAsEnable:NO feedUUID:[i uuid]];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
     
//        NSDictionary* d = @{}
        ////NSLog(@"err %@",error);
        errorCount ++;
        
    } finishBlock:^{
        
        finishCount ++;
        ////NSLog(@"finish %ld %ld",errorCount,finishCount);
        
        if (progressblock) {
            progressblock(finishCount,feedCount);
        }
        
        if (finishCount == feedCount) {
            //NSLog(@"end block --");
            dispatch_async(dispatch_get_main_queue(), ^{
//                [sender endRefreshing];
                if (endBlock) {
                    endBlock();
                }
            });
            
            [RRFeedAction insertArticle:a finish:^(NSUInteger x) {
                //NSLog(@"添加 %ld 篇文章",x);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finishBlock) {
                        finishBlock(finishCount,errorCount,x);
                    }
                    ws.loading = false;
                    if (x == 0) {
//                        [PWToastView showText:@"没有更新的订阅"];
                       
                    }
                    else {
//                        [self loadData];
                        if (errorCount == 0) {
//                            [PWToastView showText:[NSString stringWithFormat:@"更新了%ld个订阅源，共计%ld篇订阅",finishCount,x]];
                        }
                        else {
//                            [PWToastView showText:[NSString stringWithFormat:@"更新了%ld个订阅源，共计%ld篇订阅，%ld个源更新失败",finishCount,x,errorCount]];
                        }
                        
                    }
                });
            }];
        }
    }];
}

- (OPMLDocument*)loadOPML:(NSURL *)fileURL
{
    OPMLDocument* d = [[OPMLDocument alloc] initWithFileURL:fileURL];
    return d;
}

@end
