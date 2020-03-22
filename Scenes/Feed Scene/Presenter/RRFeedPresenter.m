//
//  RRFeedPresenter.m
//  rework-reader
//
//  Created by 张超 on 2019/2/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRFeedPresenter.h"
#import "RRFeedInfoInputer.h"
#import "RRFeedInfoModel.h"
#import "RRFeedArticleModel.h"
#import "RRFeedLoader.h"
@import DateTools;
//@import Fork_MWFeedParser;
#import "NSString+HTML.h"
#import "MWFeedItem.h"
#import "MWFeedInfo.h"
#import "RRCoreDataModel.h"
#import "RPDataManager.h"
@import ui_base;
#import "RRProvideDataProtocol.h"
@import oc_string;
@import oc_base;
#import "RRFeedAction.h"
@import RegexKitLite;
#import "AppleAPIHelper.h"
#import "RRExtraViewController.h"
#import "SceneDelegate.h"

@interface RRFeedPresenter ()
{
    
}
@property (nonatomic, strong) RRFeedInfoInputer* inputer;
@property (nonatomic, weak) RRFeedInfoModel* directOpenSwitch;
@property (nonatomic, weak) RRFeedInfoModel* tllSwitch;
@property (nonatomic, weak) RRFeedInfoModel* autoFeedSwitch;
@property (nonatomic, assign) CGFloat count;
@property (nonatomic, assign) CGFloat allWords;
@property (nonatomic, assign) CGFloat allImgs;
@property (nonatomic, strong) NSDate* lastedArticleDate;
@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, strong) MWFeedInfo* feedInfo;
@property (nonatomic, strong) NSString* ttl;

@property (nonatomic, assign) BOOL cancelFeed;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL feedError;

@end

@implementation RRFeedPresenter

- (RRFeedInfoInputer *)inputer
{
    if (!_inputer) {
        _inputer = [[RRFeedInfoInputer alloc] init];
    }
    return _inputer;
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    self.count = 0;
    self.allWords = 0;
    self.canceled = NO;
    self.feedError = YES;
    self.finished = NO;
//    self.cancelFeed = YES;
}

- (id)mvp_inputerWithOutput:(id<MVPOutputProtocol>)output
{
    return self.inputer;
}

- (void)loadError:(NSError *)error
{
//    self.feedError = YES;
    NSLog(@"%@",error);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view hudFail:[error localizedDescription]];
    });
}

- (NSNumber*)canFeed
{
    return @(!self.feedError);
}

- (void)loadData:(id)data
{
    if (self.canceled) {
        return;
    }
    
    RRFeedInfoModel* (^ model)(NSString*,NSString*,NSString*) = ^(NSString* t,NSString* k,NSString* v){
      
        RRFeedInfoModel* model = [[RRFeedInfoModel alloc] init];
        model.title = t;
        model.key = k;
        model.value = v;
        model.origin_value = v;
        return model;
    };
    
    if ([data isKindOfClass:[MWFeedInfo class]]) {
        MWFeedInfo* info = data;
        self.feedInfo = info;
        self.title = info.title;
        self.feedError = NO;
       
        id x = [[RPDataManager sharedManager] getFirst:@"EntityFeedInfo" predicate:nil key:@"url" value:self.feedInfo.url sort:@"sort" asc:YES];
        
        self.cancelFeed = x != nil;
        
        if (info.title && info.title.length > 0) {
            [self.inputer mvp_addModel:model(@"名称",@"title",info.title)];
        }
        
        if (info.summary && info.summary.length > 0) {
            [self.inputer mvp_addModel:model(@"摘要",@"summary",info.summary)];
        }
       
        if (info.link && info.link.length > 0) {
            [self.inputer mvp_addModel:model(@"网址",@"link",info.link)];
        }
        
        if (info.url && info.url.absoluteString.length > 0) {
            [self.inputer mvp_addModel:model(@"RSS地址",@"url",[info.url absoluteString])];
        }
        
        if (info.language && info.language.length > 0) {
            [self.inputer mvp_addModel:model(@"语言",@"language",info.language)];
        }
        
        if (info.pubDate || info.lastBuildDate) {
            NSDate* d = info.pubDate ? info.pubDate : info.lastBuildDate;
            RRFeedInfoModel* m = model(@"更新时间",@"updateDate",[NSString stringWithFormat:@"%@ · %@",[d timeAgoSinceNow],[[RRFeedLoader sharedLoader].shortDateFormatter stringFromDate:d]]);
            [self.inputer mvp_addModel:m];
            m.origin_value = d;
        }
        
        if (info.copyright && info.copyright.length > 0) {
            [self.inputer mvp_addModel:model(@"版权",@"copyright",info.copyright)];
        }
        
        if (info.managingEditor && info.managingEditor.length > 0) {
            [self.inputer mvp_addModel:model(@"联系邮箱",@"managingEditor",info.managingEditor)];
        }
        
        if (info.generator && info.generator.length > 0) {
            [self.inputer mvp_addModel:model(@"生成器",@"generator",info.generator)];
        }
        
        if (info.ttl) {
            RRFeedInfoModel* m2 = model(@"缓存期内不更新",@"usettl",[NSString stringWithFormat:@"此源缓存更新时长为%@分钟，开启后缓存未过期前不更新此源文章，建议开启。",info.ttl]);
            m2.type = RRFeedInfoTypeSwitch;
            m2.switchValue = @(YES);
            self.tllSwitch = m2;
            [self.inputer mvp_addModel:m2];
            
            self.ttl = info.ttl;
        }
        
        RRFeedInfoModel* m1 = model(@"直接阅读原文",@"usesafari",@"开启后浏览此订阅源的时候将直接使用内置浏览器访问原始网页");
        m1.type = RRFeedInfoTypeSwitch;
        m1.switchValue = @(NO);
        self.directOpenSwitch = m1;
        
        [self.inputer mvp_addModel:m1];
        
        RRFeedInfoModel* m3 = model(@"自动更新文章",@"useautoupdate",@"建议更新频率较高的订阅源开启此功能，程序将在后台更新此订阅源的文章。");
        m3.type = RRFeedInfoTypeSwitch;
        m3.switchValue = @(YES);
        self.autoFeedSwitch = m3;
        
        if (info.pubDate || info.lastBuildDate) {
            NSDate* d = info.pubDate ? info.pubDate : info.lastBuildDate;
            if ([d daysAgo]>7) {
                m3.switchValue = @(NO);
                m3.value = [m3.value stringByAppendingString:@"\n此源已经超过一周没有更新，建议关闭自动更新"];
            }
        }
        else {
            m3.switchValue = @(NO);
        }
        
        [self.inputer mvp_addModel:m3];
        
        RRFeedInfoModel* m = model(@"文章",@"",@"");
        m.type = RRFeedInfoTypeTitle;
        
        [self.inputer mvp_addModel:m];
        
    }
    else if([data isKindOfClass:[MWFeedItem class]])
    {
        RRFeedArticleModel* m = [[RRFeedArticleModel alloc] initWithItem:data];
        m.feed = self.feedInfo;
        NSString* temp = m.content.length>30?m.content:m.summary;
        NSArray* imgs = [temp componentsMatchedByRegex:@"(?<=<img).*?(?=\\>)"];
        temp = [temp stringByConvertingHTMLToPlainText];
        self.count ++;
        self.allWords += temp.length;
        self.allImgs += imgs.count;
        [self.inputer mvp_addModel:m];
        
        if (m.date || m.updateTime) {
            NSDate* up = m.date;
            if ([self.lastedArticleDate timeIntervalSinceDate:up] < 0) {
                self.lastedArticleDate = up;
            }
        }
        
        
//        ////NSLog(@"%@",m);
    }
}

- (void)cancelit
{
    self.canceled = YES;
    
}

- (NSDate *)lastedArticleDate
{
    if (!_lastedArticleDate) {
        _lastedArticleDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return _lastedArticleDate;
}

- (void)loadIcon:(NSString *)icon
{
    self.feedInfo.icon = icon;
}

- (void)loadFinish
{
    if (self.canceled) {
        return;
    }
    
    self.finished = YES;
    
    
//    ////NSLog(@"%@",@());
    CGFloat avg = self.allWords/self.count;
    CGFloat imgavg = self.allImgs/self.count;
//    ////NSLog(@"avg %@",@(avg));
    if (avg > 250 || imgavg > 3) {
        self.directOpenSwitch.switchValue = @(NO);
    }
    else {
        self.directOpenSwitch.switchValue = @(YES);
        self.directOpenSwitch.value = [@"开启后浏览此订阅源的时候将直接使用内置浏览器访问原始网页" stringByAppendingString:@"此订阅源文章平均字数少于250字,平均图片少于3张，建议开启原文阅读"];
        NSIndexPath* p = [self.inputer mvp_indexPathWithModel:self.directOpenSwitch];
        if (p) {
            [self.inputer mvp_updateModel:self.directOpenSwitch atIndexPath:p];
        }
    }
    
//    ////NSLog(@"%@",self.lastedArticleDate);
    
    if (![self.autoFeedSwitch.switchValue boolValue]) {
        if (self.lastedArticleDate) {
            if ([self.lastedArticleDate daysAgo]>7) {
                self.autoFeedSwitch.switchValue = @(NO);
            }
            else {
                self.autoFeedSwitch.switchValue = @(YES);
            }
        }
    }
}

- (void)mvp_action_selectItemAtIndexPath:(NSIndexPath *)path
{
    id model = [[self inputer] mvp_modelAtIndexPath:path];
    if ([model isKindOfClass:[RRFeedArticleModel class]]) {
        RRFeedArticleModel* m = model;
        [self loadArticle:m];
    }
}

- (NSNumber*)feeded
{
    return @(self.cancelFeed);
}

- (MWFeedInfo*)lastFeed:(id)current
{
    return self.feedInfo;
}

- (MWFeedInfo*)nextFeed:(id)current
{
    return self.feedInfo;
}

- (RRFeedArticleModel*)last:(id)current
{
    NSArray* all = [self.inputer allModels];
    NSInteger x = [all indexOfObject:current];
//    ////NSLog(@"%@ %ld" ,current,x);
    if (x == 0) {
        return nil;
    }
    NSInteger lastidx = x-1;
    id last = [all objectAtIndex:lastidx];
    if ([last isKindOfClass:[RRFeedArticleModel class]]) {
        return last;
    }
    return nil;
}

- (RRFeedArticleModel*)next:(id)current
{
    NSArray* all = [self.inputer allModels];
    NSInteger x = [all indexOfObject:current];
    //    ////NSLog(@"%@ %ld" ,current,x);
    if (x == all.count - 1) {
        return nil;
    }
    NSInteger lastidx = x+1;
    id last = [all objectAtIndex:lastidx];
    if ([last isKindOfClass:[RRFeedArticleModel class]]) {
        return last;
    }
    return nil;
}


- (void)loadArticle:(RRFeedArticleModel*)model
{
    id web = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"model":model,@"feed":self.feedInfo}];
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
    
    UIViewController* v = (id)self.view;
    BOOL isTrait = [[NSUserDefaults standardUserDefaults] boolForKey:@"RRSplit"];
    if (@available(iOS 13.0, *)) {
          UIView* view = [(UIViewController*)self.view view];
          SceneDelegate* sceneDelegate = (SceneDelegate*)view.window.windowScene.delegate;
          isTrait =  sceneDelegate.isSplit;
     } else {
         
     }
    if (v.splitViewController && !isTrait) {
        RRExtraViewController* n = [[RRExtraViewController alloc] initWithRootViewController:web];
        n.handleTrait = YES;
        NSArray* vcArray = @[v.navigationController,n];
        [v.splitViewController setViewControllers:vcArray];
    }
    else
    {
        [self.view mvp_pushViewController:web];
    }
}

- (void)unfeedit:(id)sender
{
    if (!self.feedInfo) {
        return;
    }
    EntityFeedInfo* x = [[RPDataManager sharedManager] getFirst:@"EntityFeedInfo" predicate:nil key:@"url" value:self.feedInfo.url sort:@"sort" asc:YES];
    
    __weak typeof(self) weakSelf = self;
    UIBarButtonItem* i = sender;
    CGRect r =({
        CGRect r = [[i valueForKeyPath:@"view.frame"] CGRectValue];
        r.origin.x -= r.size.width/4;
        r.origin.y += r.size.height/2;
        r;
    });
   
    r = [[[(UIViewController*)self.view navigationController] toolbar] convertRect:r toView:nil];
    r.origin.x += r.size.width/2;
    r.origin.y -= r.size.height;
    r.size.width = 0;
    r.size.height = 0;
    [RRFeedAction delFeed:x view:(id)self.view  item:sender arrow:UIPopoverArrowDirectionDown finish:^{
         weakSelf.cancelFeed = NO;
    }];
}

- (void)feedit:(UIBarButtonItem*)sender
{
    sender.enabled = NO;
    NSMutableDictionary* d = [[[RPDataManager sharedManager] dictionaryWithModels:self.inputer.allModels getKeys:@[@"title",@"summary",@"link",@"url",@"language",@"updateDate",@"managingEditor",@"ttl",@"copyright",@"icon",@"generator",@"usettl",@"usesafari",@"useautoupdate"] getModel:NO] mutableCopy];
    
//    ////NSLog(@"%@",d);
    d[@"icon"] = self.feedInfo.icon;
    d[@"ttl"] = self.ttl;
    
//    return;
    
    [[RPDataManager sharedManager] insertClass:@"EntityFeedInfo" keysAndValues:d modify:^id _Nonnull(id  _Nonnull key, id  _Nonnull value) {
        if ([key isEqualToString:@"url"]) {
            return [NSURL URLWithString:value];
        }
        return value;
    } finish:^(__kindof NSManagedObject * _Nonnull obj, NSError * _Nonnull e) {
        
//        NSArray* articles = [
        NSArray* a = self.inputer.allModels;
        a = a.filter(^BOOL(id  _Nonnull x) {
            return [x isKindOfClass:[RRFeedArticleModel class]];
        });
//        [self insertArticle:a withFeed:obj];
        [RRFeedAction insertArticle:a withFeed:obj finish:^(NSUInteger x) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [(UIViewController*)self.view hudSuccess:@"成功订阅"];
                [self.view mvp_popViewController:nil];
                sender.enabled = YES;
                [AppleAPIHelper review];
            });
        }];
    }];
}

 


@end
