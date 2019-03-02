//
//  RRWebView.m
//  rework-reader
//
//  Created by 张超 on 2019/2/13.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRWebView.h"
@import WebKit;
@import ui_base;
@import Classy;
@import SVProgressHUD;
@import oc_string;
#import "RRFeedArticleModel.h"
#import "RRFeedLoader.h"
#import "RRWebHandler.h"
@import Fork_MWFeedParser;
@import SafariServices;
@import ReactiveObjC;
@import RegexKitLite;
#import "RRFeedAction.h"
#import "RRPhotoBrowser.h"



@interface RRWebView () <WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,MWPhotoBrowserDelegate>
{
    
}

@property (nonatomic, strong) NSString* originURL;
@property (nonatomic, assign) BOOL isSub;
@property (nonatomic, strong) RRWebHandler* hander;
@property (nonatomic, strong) UIProgressView* progressView;

@property (nonatomic, strong) UIView* upView;
@property (nonatomic, strong) UIView* downView;

@property (nonatomic, assign) BOOL loadFinished;
@property (nonatomic, assign) BOOL hideNaviBar;

@property (nonatomic, strong) UIView* statusCover;

@property (nonatomic, strong) MWFeedInfo* currentFeed;
@property (nonatomic, strong) RRFeedArticleModel* currentArticle;

@property (nonatomic, assign) BOOL canDragPage;
@property (nonatomic, assign) BOOL showToolbar;

@property (nonatomic, assign) CGFloat recordPostion;

@property (nonatomic, strong) NSMutableArray* showImage;

@property (nonatomic, assign) BOOL prepareLoadLast;
@property (nonatomic, assign) BOOL prepareLoadNext;

@property (nonatomic, strong) UIImpactFeedbackGenerator* g;

@property (nonatomic, assign) BOOL openedFeed;

@end

@implementation RRWebView

- (UIImpactFeedbackGenerator *)g
{
    if (!_g) {
        _g = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    return _g;
}

- (UIView *)statusCover
{
    if (!_statusCover) {
        _statusCover = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
        [_statusCover setUserInteractionEnabled:NO];
        _statusCover.cas_styleClass = @"statuCover";
    }
    return _statusCover;
}

- (void)setUpViewText:(NSString*)text
{
    UILabel* l = [self.upView viewWithTag:10001];
    l.text = text;
}

- (UIView *)upView
{
    if (!_upView) {
        _upView = [[UIView alloc] initWithFrame:CGRectMake(0, -50, self.view.frame.size.width, 80)];
//        [_upView setBackgroundColor:[UIColor grayColor]];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        [_upView addSubview:label];
        [label setText:@"上一篇\n千古一片江山红"];
        [label setNumberOfLines:0];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setCas_styleClass:@"TipLabel"];
        [label setTag:10001];
        _upView.alpha = 0;
    }
    return _upView;
}

- (void)setDownViewText:(NSString*)text
{
    UILabel* l = [self.downView viewWithTag:100002];
    l.text = text;
}

- (UIView *)downView
{
    if (!_downView) {
        _downView = [[UIView alloc] initWithFrame:CGRectMake(0, self.webView.scrollView.contentSize.height, self.view.frame.size.width, 80)];
        //        [_upView setBackgroundColor:[UIColor grayColor]];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        [_downView addSubview:label];
        [label setText:@"下一篇\n千古一片江山红"];
        [label setNumberOfLines:0];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setCas_styleClass:@"TipLabel"];
        [label setTag:100002];
        _downView.alpha = 0;
    }
    return _downView;
}



- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    }
    return _progressView;
}
    
- (RRWebHandler*)hander
{
    if (!_hander) {
        _hander = [[RRWebHandler alloc] init];
    }
    return _hander;
}

- (RRWKWebview *)webView
{
    if (!_webView) {
        WKWebViewConfiguration* c = [[WKWebViewConfiguration alloc] init];
        [c setDataDetectorTypes:WKDataDetectorTypeAll];
        [c setURLSchemeHandler:self.hander forURLScheme:@"siyuan"];
//        [c setURLSchemeHandler:self.hander forURLScheme:@"innerhttps"];
        _webView = [[RRWKWebview alloc] initWithFrame:self.view.bounds configuration:c];
        if (@available(iOS 11, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _webView.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 50, 0);
        }
    }
    return _webView;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    NSLog(@"- %f %f" ,scrollView.contentOffset.y,scrollView.contentSize.height-scrollView.frame.size.height);
    
    if (scrollView.contentOffset.y < - 130) {
        [self loadLast];
    }
    
    if (scrollView.contentOffset.y - (scrollView.contentSize.height-scrollView.frame.size.height) > 130)
    {
        [self loadNext];
    }
    
}

- (void)loadLast
{
    if (!self.canDragPage) {
        return;
    }
    if (!self.lastFeed || !self.lastArticle) {
        return;
    }
    if (!self.lastFeed(self.currentArticle) || !self.lastArticle(self.currentArticle)) {
        [self.g impactOccurred];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self recordReadProgress:^{
        UIView* fakeCover = [[weakSelf webView] snapshotViewAfterScreenUpdates:YES];
        [weakSelf.view addSubview:fakeCover];
        
        [weakSelf preloadData:weakSelf.lastArticle(weakSelf.currentArticle) feed:weakSelf.lastFeed(weakSelf.currentArticle)];
        //    [self loadData:self.lastArticle(self.currentArticle) feed:self.lastFeed(self.currentArticle)];
        //    self.webView.transform = CGAffineTransformMakeTranslation(0, -100);
        [UIView animateWithDuration:0.6 animations:^{
            //        [fakeCover setAlpha:0];
            fakeCover.transform = CGAffineTransformMakeTranslation(0, fakeCover.frame.size.height);
            //        self.webView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [fakeCover removeFromSuperview];
        }];
    }];
}


- (void)loadNext
{
    if (!self.canDragPage) {
        return;
    }
    if (!self.nextFeed || !self.nextArticle) {
        return;
    }
    if (!self.nextFeed(self.currentArticle) || !self.nextArticle(self.currentArticle)) {
        [self.g impactOccurred];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self recordReadProgress:^{
        UIView* fakeCover = [[weakSelf webView] snapshotViewAfterScreenUpdates:YES];
        [weakSelf.view addSubview:fakeCover];
        
        [weakSelf preloadData:weakSelf.nextArticle(weakSelf.currentArticle) feed:weakSelf.nextFeed(weakSelf.currentArticle)];
        
        //    [[self.webView scrollView] setContentOffset:CGPointMake(-64, 0)];
        //    [self loadData:self.currentArticle feed:self.currentFeed];
        //    self.webView.transform = CGAffineTransformMakeTranslation(0, 100);
        [UIView animateWithDuration:0.4 animations:^{
            //        [fakeCover setAlpha:0];
            fakeCover.transform = CGAffineTransformMakeTranslation(0, -fakeCover.frame.size.height);
            //        self.webView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [fakeCover removeFromSuperview];
        }];
    }];
   

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.loadFinished = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"(2)%f %d",scrollView.contentOffset.y,self.loadFinished);
    if (scrollView.contentOffset.y > 0 && self.loadFinished) {
        if (!self.hideNaviBar && (self.progressView.progress == 0 || self.progressView.progress == 1)) {
            self.hideNaviBar = YES;
            [UIView animateWithDuration:0.24 animations:^{
                [self.navigationController.navigationBar setAlpha:0];
                self.progressView.alpha = 0;
            }];
        }
    }
    else if(scrollView.contentOffset.y < 50)
    {
        if (self.hideNaviBar) {
            self.hideNaviBar = NO;
            [UIView animateWithDuration:0.24 animations:^{
                [self.navigationController.navigationBar setAlpha:1];
                if ( fabs(self.progressView.progress - 1) > 0.00001 ) {
                    [self.progressView setAlpha:1];
                }
            }];
        }
    }
    
    if (scrollView.contentOffset.y < - 130) {
//        [self loadLast];
        if (!self.prepareLoadLast) {
            self.prepareLoadLast = YES;
//            UIImpactFeedbackGenerator* g;
            if (scrollView.isDragging) {
                [self.g impactOccurred];
            }
            
        }
    }
    else {
        if (self.prepareLoadLast) {
            self.prepareLoadLast = NO;
            if (scrollView.isDragging) {
                 [self.g impactOccurred];
            }
        }
    }
    
    if (scrollView.contentOffset.y - (scrollView.contentSize.height-scrollView.frame.size.height) > 130)
    {
//        [self loadNext];
        if (!self.prepareLoadNext) {
            self.prepareLoadNext = YES;
            if (scrollView.isDragging) {
                 [self.g impactOccurred];
            }
        }
    }
    else {
        if (self.prepareLoadNext) {
            self.prepareLoadNext = NO;
            if (scrollView.isDragging) {
                [self.g impactOccurred];
            }
        }
    }
}


- (Class)mvp_presenterClass
{
    return NSClassFromString(@"RRWebPresenter");
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.height+[UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, 3)];
    
    [self.webView setFrame:self.view.bounds];
}

- (void)setProgress:(CGFloat)progress
{
//    NSLog(@"1 %f",progress);
    [self.progressView setProgress:progress animated:YES];
    if (self.progressView.alpha == 0) {
        [UIView animateWithDuration:0.24 animations:^{
            self.progressView.alpha = 1;
        }];
    }
    else if(self.progressView.alpha == 1)
    {
        if (fabs(progress - 1) < 0.00001) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.24 animations:^{
                    self.progressView.alpha = 0;
                    self.progressView.progress = 0;
                }];
            });
        }
    }
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    [[[self navigationController] navigationBar] setPrefersLargeTitles:NO];
    
    self.prepareLoadLast = NO;
    self.prepareLoadNext = NO;
    self.hideNaviBar = NO;
    self.loadFinished = NO;
    self.canDragPage = NO;
    

    [self.view addSubview:self.webView];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [[self view] addSubview:self.progressView];
    [self.webView.scrollView addSubview:self.upView];
    [self.webView.scrollView addSubview:self.downView];
    
    self.webView.scrollView.delegate = self;
    
    [self.view addSubview:self.statusCover];
//    [self.progressView setProgress:0.5];
    
    __weak typeof(self) weakSelf = self;
    [[RACObserve(self.webView, estimatedProgress) takeUntil:[self rac_willDeallocSignal]]  subscribeNext:^(id  _Nullable x) {
        //        NSLog(@"%@",x);
        [weakSelf setProgress:[x doubleValue]];
    }];
    
    
    NSString* filename = model.userInfo[@"name"];
    if (!filename) {
        filename = @"";
    }
    RRFeedArticleModel* m = model.userInfo[@"model"];
    MWFeedInfo* feedInfo = model.userInfo[@"feed"];
    NSURL * url = [[NSBundle mainBundle] URLForResource:[filename stringByDeletingPathExtension] withExtension:[filename pathExtension]];
    if (!m && ![filename hasPrefix:@"http"] && ![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        DDLogWarn(@"文件%@不存在",filename);
        return;
    }
    
    
//    [self.navigationController setToolbarHidden:YES animated:NO];
//    self.navigationController.toolbar.alpha = 0;
    self.showToolbar = NO;
    if ([filename hasPrefix:@"http"]) {
        self.originURL = filename;
        self.isSub = [model.userInfo[@"sub"] boolValue];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:filename]]];
    }
    else if ([filename hasSuffix:@"html"]) {
         [self.webView loadFileURL:url allowingReadAccessToURL:[[NSBundle mainBundle] bundleURL]];
    }
    else if([filename hasSuffix:@"md"])
    {
        NSString* string = [[NSString alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"templete" withExtension:@"html"] encoding:NSUTF8StringEncoding error:nil];
        
        string = [self addMarddownJS:string];
        string = [self addMarddownHTML:string];
        
        NSString* mdString = [[[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        
        if ([self hasPreMark:mdString isMd:YES]) {
            string = [self addHighlight:string];
        }
        else {
            string = [self removeHighlight:string];
        }
        
        string = [string stringByReplacingOccurrencesOfString:@"<#title#>" withString:[filename stringByDeletingPathExtension]];
        
        string = [string stringByReplacingOccurrencesOfString:@"<#useMarkdown#>" withString:@"1"];
        
        string = [string stringByReplacingOccurrencesOfString:@"<#markdown#>" withString:mdString];
        
        
        if ([self hasLatex:string]) {
            NSLog(@"有latex");
            string = [self addLatex:string];
        }
        else {
            NSLog(@"没有latex");
            string = [self removeLatex:string];
        }
        
        [self.webView loadHTMLString:string baseURL:[[NSBundle mainBundle] bundleURL]];
    }
    else {
//        [self.navigationController setToolbarHidden:NO animated:NO];
        [self preloadData:m feed:feedInfo];
        self.showToolbar = YES;
        
        UIBarButtonItem* rb = [self mvp_buttonItemWithSystem:UIBarButtonSystemItemAction actionName:@"openAction:" title:@"更多操作"];
        
        self.navigationItem.rightBarButtonItem = rb;
        
    }
    
    [self.webView setUIDelegate:self];
    [self.webView setNavigationDelegate:self];
    
}


- (void)preloadData:(RRFeedArticleModel*)m feed:(MWFeedInfo*)feedInfo
{
    self.title = @"";
    if ([self.presenter conformsToProtocol:@protocol(RRProvideDataProtocol)]) {
        [(id)self.presenter loadData:m feed:feedInfo];
    }
}

- (void)loadData:(RRFeedArticleModel*)m feed:(MWFeedInfo*)feedInfo
{
    if (!m && ! feedInfo) {
        return;
    }
//    if(0){
        self.webView.alpha = 0;
//    }
    
    self.prepareLoadNext = NO;
    self.prepareLoadLast = NO;
    
    self.currentFeed = feedInfo;
    self.currentArticle = m;
    
    self.recordPostion = 0;
    if (self.currentArticle) {
     
        CGFloat position = [RRFeedAction loadPositionWithArticle:self.currentArticle.uuid];
        if (position != 0) {
            self.recordPostion = position;
        }
    }
    
    NSString* string = [[NSString alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"templete" withExtension:@"html"] encoding:NSUTF8StringEncoding error:nil];
    
    string = [self removeMarddownJS:string];
    string = [self removeMarddownHTML:string];
    
    string = [string stringByReplacingOccurrencesOfString:@"<#useMarkdown#>" withString:@"0"];
    
    if (m.title) {
        string = [string stringByReplacingOccurrencesOfString:@"<#title#>" withString:m.title];
    }
    else {
        string = [string stringByReplacingOccurrencesOfString:@"<#title#>" withString:@"无标题"];
    }
    
    if (m.content) {
        string = [string stringByReplacingOccurrencesOfString:@"<#html#>" withString:m.content];
    }
    else if(m.summary)
    {
        string = [string stringByReplacingOccurrencesOfString:@"<#html#>" withString:m.summary];
    }
    else {
        string = [string stringByReplacingOccurrencesOfString:@"<#html#>" withString:@"无内容"];
    }
    
    if ([self hasPreMark:string isMd:NO]) {
        NSLog(@"有Pre");
        string = [self addHighlight:string];
    }
    else {
        NSLog(@"没有Pre");
        string = [self removeHighlight:string];
    }
    
    NSDate* d = m.date?m.date : m.updated;
    if(d){
        string = [string stringByReplacingOccurrencesOfString:@"<#subtitle#>" withString:[NSString stringWithFormat:@"%@ · %@",![feedInfo isKindOfClass:[NSNull class]]?feedInfo.title:@"无订阅源",[[RRFeedLoader sharedLoader].shrotDateAndTimeFormatter stringFromDate:d]]];
    }
    else{
        string = [string stringByReplacingOccurrencesOfString:@"<#subtitle#>" withString:[NSString stringWithFormat:@"%@",![feedInfo isKindOfClass:[NSNull class]]?feedInfo.title:@"无订阅源"]];
    }
    
    //        NSLog(@"%@",m.link);
    if (m.link) {
        string = [string stringByReplacingOccurrencesOfString:@"<#url#>" withString:[NSString stringWithFormat:@"safari%@",m.link]];
    }
    
    if ([self hasLatex:string]) {
        NSLog(@"有latex");
        string = [self addLatex:string];
    }
    else {
        NSLog(@"没有latex");
        string = [self removeLatex:string];
    }
    
    string = [string stringByReplacingOccurrencesOfString:@"src=\"//" withString:@"src=\"http://"];
    
    //        NSURL* url = [NSURL URLWithString:m.link];
    //        NSURL* base = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@",[url scheme],[url host]]];
    [self.webView loadHTMLString:string baseURL:[[NSBundle mainBundle] bundleURL]];
}

- (BOOL)hasPreMark:(NSString*)html isMd:(BOOL)isMd
{
    if (isMd) {
        return [html rangeOfRegex:@"```.*?```"].location != NSNotFound || [html rangeOfString:@"<pre>"].location != NSNotFound;
    }
    return [html rangeOfString:@"<pre>"].location != NSNotFound;
}

- (NSString*)addHighlight:(NSString*)html
{
    html = [html stringByReplacingOccurrencesOfString:@"<#highlight#>" withString:@"<script src=\"h.js\"></script>\
            <script>hljs.initHighlightingOnLoad();</script>"];
    return html;
}

- (NSString*)removeHighlight:(NSString*)html
{
    html = [html stringByReplacingOccurrencesOfString:@"<#highlight#>" withString:@""];
    return html;
}

- (NSString*)addMarddownJS:(NSString*)html
{
    html = [html stringByReplacingOccurrencesOfString:@"<#mardownjs#>" withString:@"<script src=\"marked.js\"></script>"];
    return html;
}

- (NSString*)removeMarddownJS:(NSString*)html
{
    html = [html stringByReplacingOccurrencesOfString:@"<#mardownjs#>" withString:@""];
    return html;
}


- (NSString*)addMarddownHTML:(NSString*)html
{
    html = [html stringByReplacingOccurrencesOfString:@"<#markdownhtml#>" withString:@"document.getElementById('markdown-body').innerHTML = marked('<#markdown#>');"];
    return html;
}

- (NSString*)removeMarddownHTML:(NSString*)html
{
    html = [html stringByReplacingOccurrencesOfString:@"<#markdownhtml#>" withString:@""];
    return html;
}


- (NSString*)removeLatex:(NSString*)html
{
    html = [html stringByReplacingOccurrencesOfString:@"<#latex#>" withString:@""];
    return html;
}

- (NSString*)addLatex:(NSString*)html
{
    html = [html stringByReplacingOccurrencesOfString:@"<#latex#>" withString:@"<link rel=\"dns-prefetch\" href=\"//cdn.mathjax.org\" /> \
            <script src=\"https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js?config=TeX-MML-AM_CHTML\" async></script>"];
    return html;
}

- (BOOL)hasLatex:(NSString*)text
{
    NSRange r = [text rangeOfRegex:@"\\$\\$.*?\\$\\$"];
    return r.location != NSNotFound;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.openedFeed) {
        [self mvp_popViewController:nil];
    }
    
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    [self configToolBar];
    [[[self navigationController] navigationBar] setPrefersLargeTitles:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    [self hudDismiss];
    [self resetToolBar];
    [[[self navigationController] navigationBar] setPrefersLargeTitles:YES];
    
    [self.navigationController.navigationBar setAlpha:1];
    self.hideNaviBar = NO;
    
    [self recordReadProgress:^{
        
    }];
}

- (void)recordReadProgress:(void (^)(void))finish
{
    if (self.currentArticle) {
        __weak typeof(self) weakSelf = self;
        [[self webView] evaluateJavaScript:@"document.body.scrollTop" completionHandler:^(id _Nullable x, NSError * _Nullable error) {
            NSLog(@"当前滚动位置 %@ %@",x,weakSelf.currentArticle);
            
            [RRFeedAction recordArticle:weakSelf.currentArticle.uuid position:[x doubleValue]];
            
            if (finish) {
                finish();
            }
        }];
    }
}

- (void)resetToolBar
{
    self.navigationController.toolbar.hidden = NO;
}

- (void)configToolBar
{
    if (self.showToolbar) {
        self.navigationController.toolbar.hidden = NO;
    }
    else {
        self.navigationController.toolbar.hidden = YES;
        [[self.webView scrollView] setContentInset:({
            UIEdgeInsets i = self.webView.scrollView.contentInset;
            i.bottom = 0;
            i;
        })];
//        [[self.webView scrollView] setScrollIndicatorInsets:({
//            UIEdgeInsets i = self.webView.scrollView.scrollIndicatorInsets;
//            i.bottom = 0;
//            i;
//        })];
    }
}

- (UIBarButtonItem*)fixedItem
{
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return b;
}

- (NSArray*)barItems
{
    UIBarButtonItem* loadLastItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_shang"] style:UIBarButtonItemStylePlain target:self action:@selector(loadLast)];
    loadLastItem.title = @"上一篇";
    loadLastItem.accessibilityLabel = @"上一篇";
    UIBarButtonItem* loadNextItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_xia"] style:UIBarButtonItemStylePlain target:self action:@selector(loadNext)];
    loadNextItem.title = @"下一篇";
    loadNextItem.accessibilityLabel = @"下一篇";
    return @[[self fixedItem],loadLastItem,[self fixedItem],loadNextItem,[self fixedItem]];
}

- (void)mvp_configOther
{
    __weak typeof(self) weakSelf = self;
    
    [self.presenter mvp_bindBlock:^(id view, id value) {
//        NSLog(@"---- %@",value);
        BOOL hasModel = [[weakSelf.presenter mvp_valueWithSelectorName:@"hasModel"] boolValue];
        UIViewController* v = view;
        if (![value boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (hasModel) {
                    UIBarButtonItem* favItem = [(id)view mvp_buttonItemWithActionName:@"favIt" title:@"收藏"];
                    favItem.image = [UIImage imageNamed:@"icon_fav"];
                    v.toolbarItems = [@[[self fixedItem],favItem] arrayByAddingObjectsFromArray:[weakSelf barItems]];
                }
                else {
                    v.toolbarItems = [weakSelf barItems];
                }
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                 if (hasModel) {
                     UIBarButtonItem* favItem = [(id)view mvp_buttonItemWithActionName:@"unfavIt" title:@"取消收藏"];
                     favItem.image = [UIImage imageNamed:@"icon_faved"];
                     v.toolbarItems = [@[[self fixedItem],favItem] arrayByAddingObjectsFromArray:[weakSelf barItems]];
                 }
                 else {
                     v.toolbarItems = [weakSelf barItems];
                 }
            });
        }
    } keypath:@"articleLiked"];
    
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
//    NSLog(@"1 %@",navigationAction.request.URL.absoluteString);
    NSString* url = navigationAction.request.URL.absoluteString;
    if (![self.originURL isEqualToString:url]) {
        
        if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
            if (self.isSub) {
                 decisionHandler(WKNavigationActionPolicyAllow);
            }
            else {
                [self openURL:url];
                decisionHandler(WKNavigationActionPolicyCancel);
            }
        }
        else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
    
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
//    NSLog(@"2 %@",navigationResponse.response.URL.absoluteString);
//    NSLog(@"%@",navigationResponse.response);
//    NSLog(@"%@",navigationResponse.response.MIMEType);
//    NSLog(@"%@",navigationResponse.response.textEncodingName);
    
    if ([navigationResponse.response.MIMEType rangeOfString:@"xml"].location != NSNotFound || [navigationResponse.response.MIMEType rangeOfString:@"rss"].location != NSNotFound || [navigationResponse.response.MIMEType rangeOfString:@"atom"].location != NSNotFound) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self hudDismiss];
//            [self mvp_popViewController:nil];
            self.openedFeed = YES;
            [self loadFeed:navigationResponse.response.URL.absoluteString];
        });
        decisionHandler(WKNavigationResponsePolicyCancel);
        
    }
    else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
    
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    NSString* html = navigationAction.request.URL.absoluteString;
    [self openURL:html];
    return nil;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
//    [self hudWait:@"加载中"];

}

- (NSString*)cutString:(NSString*)str
{
    if (str.length < 24) {
        return str;
    }
    return [NSString stringWithFormat:@"%@...",[str substringToIndex:24] ];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (self.recordPostion > 0) {
        NSString* js = [NSString stringWithFormat:@"document.body.scrollTop = %@;",@(self.recordPostion)];
        [webView evaluateJavaScript:js completionHandler:^(id _Nullable x, NSError * _Nullable error) {
            
        }];
    }
    if (self.currentArticle) {
        [RRFeedAction readArticle:self.currentArticle.uuid];
    }
    [self hudDismiss];
    
//    if(0){
        [UIView animateWithDuration:0.4 animations:^{
            webView.alpha = 1;
        }];
//    }
    
    [webView evaluateJavaScript:@"document.title;" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        self.title = title;
    }];
    
//    NSLog(@"%f",webView.scrollView.contentSize.height);
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable h, NSError * _Nullable error) {
//        NSLog(@"%@",h);
        self.downView.frame = ({
            CGRect r = self.downView.frame;
            r.origin.y = [h doubleValue];
            r;
        });
        
        // RRTODOIt:非订阅源打开情况，关闭上下翻文章的功能
        if (!self.currentArticle || !self.currentFeed) {
            
        }
        else {
            self.canDragPage = YES;
            if (self.lastFeed && self.lastArticle) {
                RRFeedArticleModel* m = self.lastArticle(self.currentArticle);
                MWFeedInfo* feed = self.lastFeed(self.currentArticle);
//                NSLog(@"1 %@ %@",m,feed);
                if (m && feed) {
                    [self setUpViewText:[NSString stringWithFormat:@"%@\n%@",[self cutString:m.title],feed.title]];
                }
                else {
                    [self setUpViewText:@"没有更多了"];
                }
            }
            else {
                [self setUpViewText:@""];
            }
            if (self.nextFeed && self.nextArticle) {
                RRFeedArticleModel* m = self.nextArticle(self.currentArticle);
                MWFeedInfo* feed = self.nextFeed(self.currentArticle);
//                NSLog(@"2 %@ %@",m,feed);
                if (m && feed) {
                    [self setDownViewText:[NSString stringWithFormat:@"%@\n%@",[self cutString:m.title],feed.title]];
                }
                else {
                    [self setDownViewText:@"没有更多了"];
                }
            }
            else {
                [self setDownViewText:@""];
            }
        }
    }];
   
}

- (void)setCanDragPage:(BOOL)canDragPage
{
    _canDragPage = canDragPage;
    if (canDragPage) {
        [self.downView setAlpha:1];
        [self.upView setAlpha:1];
    }
    else {
        [self.downView setAlpha:0];
        [self.upView setAlpha:0];
    }
}

- (void)openURLWithSafari:(NSString*)url
{
    if ([url hasPrefix:@"http"]) {
        NSURLSessionConfiguration* c = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* s = [NSURLSession sessionWithConfiguration:c];
        NSURLSessionDataTask* d = [s dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([response.MIMEType rangeOfString:@"xml"].location != NSNotFound || [response.MIMEType rangeOfString:@"rss"].location != NSNotFound || [response.MIMEType rangeOfString:@"atom"].location != NSNotFound ) {
                [self loadFeed:url];
//                self.openedFeed = YES;
                [self mvp_dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
            else {
                
            }
        }];
        [d resume];
    }

    if ([url hasPrefix:@"http"]) {
        SFSafariViewController* ss = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
        [self mvp_presentViewController:ss animated:YES completion:nil];
    }
    else {
        NSURL * u = [NSURL URLWithString:url];
        if ([[UIApplication sharedApplication] canOpenURL:u]) {
            [[UIApplication sharedApplication] openURL:u options:@{} completionHandler:^(BOOL success) {
                
            }];
        }
    }
}

- (void)openURL:(NSString*)url
{
    if ([url hasPrefix:@"inner"]) {
        url = [url substringFromIndex:5];
        id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":url,@"sub":@(1)}];
        [self mvp_pushViewController:vc];
        return;
    }
    else if([url hasPrefix:@"safari"])
    {
        [self openURLWithSafari:[url substringFromIndex:6]];
    }
    else {
//        id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":url,@"sub":@(1)}];
//        [self mvp_pushViewController:vc];
        [self openURLWithSafari:url];
        return;
    }
    
  
}

- (BOOL)navigationShouldPopOnBackButton
{
    if (self.webView.backForwardList.backItem) {
        [self.webView goBack];
//        [self addCloseBtn];
        return NO;
    }
    return YES;
}

- (void)addCloseBtn
{
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [btn setImage:[UIImage imageNamed:@"Chevron"] forState:UIControlStateNormal];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    btn.cas_styleClass = @"RRBackBtn";
    UIBarButtonItem* ff = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closePage)];
    self.navigationItem.leftBarButtonItems = @[ff,b];
}

- (void)backOrClose
{
    if ([self navigationShouldPopOnBackButton]) {
        [self mvp_popViewController:nil];
    }
}

- (void)closePage
{
    [self mvp_popViewController:nil];
}


- (void)dealloc
{
    NSLog(@"%s",__func__);
}

- (void)loadFeed:(NSString*)url
{
    __weak typeof(self) weakself = self;
    id vc = [[RRFeedLoader sharedLoader] feedItem:url errorBlock:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself hudFail:error.localizedDescription];
        });
    } finishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself hudDismiss];
        });
    }];
    if (vc) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [self mvp_pushViewController:vc];
        });
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    if ([message hasPrefix:@"openimage:"]) {
        __weak typeof(self) weakSelf = self;
        NSInteger idx = [[message substringFromIndex:10] integerValue];
        [webView evaluateJavaScript:@"images" completionHandler:^(id _Nullable x, NSError * _Nullable error) {
            NSLog(@"%@",x);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showImage:x index:idx];
            });
        }];
    }
    else {
        UI_Alert().descripted(message).cancel(@"确认", ^(UIAlertAction * _Nonnull action) {
            
        }).show(self);
    }
//    NSLog(@"%@",message);
    completionHandler();
}


@synthesize lastArticle = _lastArticle;
@synthesize lastFeed = _lastFeed;
@synthesize nextFeed = _nextFeed;
@synthesize nextArticle = _nextArticle;


- (NSMutableArray *)showImage
{
    if (!_showImage) {
        _showImage = [[NSMutableArray alloc] init];
    }
    return _showImage;
}

- (void)showImage:(NSArray*)imgs index:(NSUInteger)idx
{
    //    NSLog(@"%@",imgs);
    if (idx >= imgs.count || imgs.count == 0) {
        return;
    }
    
    [self.showImage removeAllObjects];
    
    
    NSArray* temp =
    imgs.filter(^BOOL(id  _Nonnull x) {
        return [x isKindOfClass:[NSString class]];
    });
    
    [self.showImage addObjectsFromArray:temp.map(^id _Nonnull(NSString* url) {
        return [MWPhoto photoWithURL:[NSURL URLWithString:url]];
    })];
    
    RRPhotoBrowser *browser = [[RRPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = YES; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    
    browser.autoPlayOnAppear = NO; // Auto-play first video
    
    // Customise selection images to change colours if required
    browser.customImageSelectedIconName = @"ImageSelected.png";
    browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
    
    // Optionally set the current visible photo before displaying
//    [browser setCurrentPhotoIndex:idx];
    
    // Present
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        [self.navigationController pushViewController:browser animated:YES];
        [self mvp_pushViewController:browser];
    }
    else{
        UINavigationController* n = [[UINavigationController alloc] initWithRootViewController:browser];
        [self.navigationController.splitViewController presentViewController:n animated:YES completion:nil];
    }
    
    // Manipulate
    //    [browser showNextPhotoAnimated:YES];
    [browser showPreviousPhotoAnimated:YES];
    [browser setCurrentPhotoIndex:idx];
}


- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.showImage.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.showImage.count) {
        return [self.showImage objectAtIndex:index];
    }
    return nil;
}



- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < self.showImage.count) {
        return [self.showImage objectAtIndex:index];
    }
    return nil;
}


@end
