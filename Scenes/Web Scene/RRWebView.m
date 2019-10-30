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
@import SDWebImage;
#import "RRWebStyleModel.h"
#import "RRSafariViewController.h"
@import oc_util;
@import TYSnapshotScroll;
@import MessageUI;
@import MagicalRecord;
#import "RRCoreDataModel.h"
#import "targetconditionals.h"
@import Masonry;
#import "MVPView+iOS13.h"

@interface RRWebView () <WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,MWPhotoBrowserDelegate,WKScriptMessageHandler,MFMailComposeViewControllerDelegate>
{
    
}

@property (nonatomic, assign) BOOL voiceover;

@property (nonatomic, strong) NSString* originURL;
@property (nonatomic, assign) BOOL isSub;
@property (nonatomic, strong) RRWebHandler* hander;
@property (nonatomic, strong) UIProgressView* progressView;

@property (nonatomic, strong) UIView* upView;
@property (nonatomic, strong) UIView* downView;

@property (nonatomic, assign) BOOL loadFinished;
@property (nonatomic, assign) BOOL hideNaviBar;
@property (nonatomic, assign) BOOL startDraging;
@property (nonatomic, assign) CGPoint startOffset;

@property (nonatomic, strong) UIView* statusCover;

@property (nonatomic, strong) MWFeedInfo* currentFeed;
@property (nonatomic, strong) RRFeedArticleModel* currentArticle;

@property (nonatomic, assign) BOOL canDragPage;
@property (nonatomic, assign) BOOL showToolbar;

@property (nonatomic, assign) CGFloat recordPostion;

@property (nonatomic, strong) NSMutableArray* showImage;
@property (nonatomic, strong) NSMutableArray* tumblrImage;

@property (nonatomic, assign) BOOL prepareLoadLast;
@property (nonatomic, assign) BOOL prepareLoadNext;

@property (nonatomic, strong) UIImpactFeedbackGenerator* g;

@property (nonatomic, assign) BOOL openedFeed;

@property (nonatomic, assign) BOOL articleLiked;
@property (nonatomic, assign) BOOL articleReadLatered;

@end

@implementation RRWebView

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionBegan:motion withEvent:event];
    if (motion == UIEventSubtypeMotionShake) {
        [self.presenter mvp_runAction:@"openAction2:" value:self];
    }
}

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
        CGRect sf = [self statusframe];
        _statusCover = [[UIView alloc] initWithFrame: sf];
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
//TODO
        _upView = [[UIView alloc] initWithFrame:CGRectMake(0, -100, self.view.frame.size.width, 80)];
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
        _downView = [[UIView alloc] initWithFrame:CGRectMake(0, self.webView.scrollView.contentSize.height + 50, self.view.frame.size.width, 80)];
        //        [_upView setBackgroundColor:[UIColor grayColor]];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        [_downView addSubview:label];
        [label setText:@""];
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
//        RRWebStyleModel* m = [RRWebStyleModel currentStyle];
        WKWebViewConfiguration* c = [[WKWebViewConfiguration alloc] init];
        WKUserContentController* u = [[WKUserContentController alloc] init];
        NSString* js = [NSString stringWithFormat:@"\
                        "];
        WKUserScript* s = [[WKUserScript alloc] initWithSource:js  injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [u addUserScript:s];
        c.userContentController = u;
        [c setDataDetectorTypes:WKDataDetectorTypeAll];
        [c setURLSchemeHandler:self.hander forURLScheme:@"innerhttp"];
        [c setURLSchemeHandler:self.hander forURLScheme:@"innerhttps"];
        [c setURLSchemeHandler:self.hander forURLScheme:@"local"];
//        [c setURLSchemeHandler:self.hander forURLScheme:@"innerhttps"];
        
        _webView = [[RRWKWebview alloc] initWithFrame:self.view.bounds configuration:c];
    }
    return _webView;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    
    //NSLog(@"prompt %@",prompt);
    //NSLog(@" defaultText%@",defaultText);
    RRWebStyleModel* m = [RRWebStyleModel currentStyle];
    if ([prompt isEqualToString:@"getFontSize"]) {
        completionHandler([NSString stringWithFormat:@"%@",@(m.fontSize)]);
    }
    else if([prompt isEqualToString:@"getLineHeight"])
    {
        completionHandler([NSString stringWithFormat:@"%@",@(m.lineHeight)]);
    }
    else if([prompt isEqualToString:@"getAlign"])
    {
        completionHandler(m.align);
    }
    else if([prompt isEqualToString:@"getFont"])
    {
        completionHandler(m.font);
    }
    else {
        completionHandler(defaultText);
    }
}

- (void)loadLast
{
 
    if (!self.canDragPage && !self.voiceover) {
        return;
    }
    if (!self.lastFeed || !self.lastArticle) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"没有上一篇文章");
        });
        return;
    }
    if (!self.lastFeed(self.currentArticle) || !self.lastArticle(self.currentArticle)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"没有上一篇文章");
        });
        [self.g impactOccurred];
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,[self.currentArticle title]);
    });
    if (self.voiceover) {
        [self.g impactOccurred];
    }
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
            [weakSelf readedIt];
        }];
    }];
}

- (void)loadNext
{
 
    if (!self.canDragPage && !self.voiceover) {
        return;
    }
    if (!self.nextFeed || !self.nextArticle) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"没有下一篇文章");
        });
        return;
    }
    if (!self.nextFeed(self.currentArticle) || !self.nextArticle(self.currentArticle)) {
        [self.g impactOccurred];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"没有下一篇文章");
        });
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (self.currentArticle) {
        [self cleanReadProgress];
    }
    
    UIView* fakeCover = [[weakSelf webView] snapshotViewAfterScreenUpdates:YES];
    [weakSelf.view addSubview:fakeCover];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,[self.currentArticle title]);
    });
    if (self.voiceover) {
        [self.g impactOccurred];
    }
    [weakSelf preloadData:weakSelf.nextArticle(weakSelf.currentArticle) feed:weakSelf.nextFeed(weakSelf.currentArticle)];

    [UIView animateWithDuration:0.4 animations:^{
        //        [fakeCover setAlpha:0];
        fakeCover.transform = CGAffineTransformMakeTranslation(0, -fakeCover.frame.size.height);
        //        self.webView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [fakeCover removeFromSuperview];
        [weakSelf readedIt];
    }];

}

- (void)pageUp
{
    CGFloat y = self.webView.scrollView.contentOffset.y - 100> 0? self.webView.scrollView.contentOffset.y - 100 : 0;
    [[self.webView scrollView] setContentOffset:CGPointMake(self.webView.scrollView.contentOffset.x, y) animated:YES];
}
- (void)pageDown
{
//    NSLog(@"%@",@(self.webView.scrollView.contentSize.height));
     CGFloat y = self.webView.scrollView.contentOffset.y + 100 < self.webView.scrollView.contentSize.height - self.webView.scrollView.frame.size.height? self.webView.scrollView.contentOffset.y + 100 : self.webView.scrollView.contentSize.height - self.webView.scrollView.frame.size.height;
    [[self.webView scrollView] setContentOffset:CGPointMake(self.webView.scrollView.contentOffset.x, y) animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self voiceover]) {
        return;
    }
    #if !TARGET_OS_MACCATALYST
    if (self.startDraging) {
        if (self.startOffset.y - scrollView.contentOffset.y > 60) {
            if (self.hideNaviBar) {
                self.hideNaviBar = NO;
                [UIView animateWithDuration:0.24 animations:^{
                    [self.navigationController.navigationBar setAlpha:1];
                    [self.navigationController.toolbar setAlpha:1];
                    if ( fabs(self.progressView.progress - 1) > 0.00001 ) {
                        [self.progressView setAlpha:1];
                    }
                }];
            }
        }
        if (self.startOffset.y - scrollView.contentOffset.y < -60) {
            if (!self.hideNaviBar && (self.progressView.progress == 0 || self.progressView.progress == 1)) {
                self.hideNaviBar = YES;
                [UIView animateWithDuration:0.24 animations:^{
                    [self.navigationController.navigationBar setAlpha:0];
                    [self.navigationController.toolbar setAlpha:0];
                    self.progressView.alpha = 0;
                }];
            }
        }
    }
    #endif
    
//    NSLog(@"%@",@(scrollView.contentOffset.y));
    if (scrollView.contentOffset.y < - 130) {
        
        CGFloat da = fabs(scrollView.contentOffset.y + 130) / 100;
        self.upView.alpha = da;
        
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
        
        self.upView.alpha = 0;
        if (self.prepareLoadLast) {
            self.prepareLoadLast = NO;
            if (scrollView.isDragging) {
                [self.g impactOccurred];
            }
        }
    }
    
    if (scrollView.contentOffset.y - (scrollView.contentSize.height-scrollView.frame.size.height) > 130)
    {
        
        CGFloat da = fabs(scrollView.contentOffset.y - 130) / 100;
        self.downView.alpha = da;
        
        //        [self loadNext];
        if (!self.prepareLoadNext) {
            self.prepareLoadNext = YES;
            if (scrollView.isDragging) {
                [self.g impactOccurred];
            }
        }
    }
    else {
        
        self.downView.alpha = 0;
        if (self.prepareLoadNext) {
            self.prepareLoadNext = NO;
            if (scrollView.isDragging) {
                [self.g impactOccurred];
            }
        }
    }
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.voiceover) {
        return;
    }
    
    if (self.splitViewController) {
        UIViewController* vc = [[self.splitViewController viewControllers] firstObject];
        while ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController*)vc topViewController];
        }
        [vc becomeFirstResponder];
    }
    
    self.startDraging = NO;
    
    if (scrollView.contentOffset.y < - 130) {
        [self loadLast];
    }
    
    if (scrollView.contentOffset.y - (scrollView.contentSize.height-scrollView.frame.size.height) > 130)
    {
        [self loadNext];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.loadFinished = YES;
    self.startDraging = YES;
    self.startOffset = scrollView.contentOffset;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.voiceover = UIAccessibilityIsVoiceOverRunning();
    self.view.cas_styleClass = @"bgView";
    self.restorationIdentifier = @"RRWebRestoreView";
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.currentArticle forKey:@"article"];
    if ([self.currentFeed isKindOfClass:[MWFeedInfo class]]) {
        [coder encodeObject:self.currentFeed forKey:@"feed"];
    }
    else if([self.currentFeed isKindOfClass:[EntityFeedInfo class]])
    {
        [coder encodeObject:self.currentFeed.url forKey:@"url"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    self.currentArticle = [coder decodeObjectForKey:@"article"];
    NSURL* url = [coder decodeObjectForKey:@"url"];
    MWFeedInfo* info = [coder decodeObjectForKey:@"feed"];
    if (info) {
        self.currentFeed = info;
    }
    else if(url)
    {
        self.currentFeed = (id)[EntityFeedInfo MR_findFirstByAttribute:@"url" withValue:url];
    }
    
    if (self.currentArticle && self.currentFeed) {
        [self preloadData:self.currentArticle feed:self.currentFeed];
    }
}




- (Class)mvp_presenterClass
{
    return NSClassFromString(@"RRWebPresenter");
}



- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    return;
    CGRect sf = [self statusframe];
       
//    NSLog(@"%@",@(self.navigationController.navigationBar.height));
//    NSLog(@"%@",@(sf.size.height));
    #if !TARGET_OS_MACCATALYST
        [self.progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.height+sf.size.height, self.view.frame.size.width, 2)];
    #else
        [self.progressView setFrame:CGRectMake(0, 10, self.view.frame.size.width, 2)];
    #endif
    
//    NSLog(@"%@",NSStringFromCGRect(self.progressView.frame));
//    [self.webView setFrame:self.view.bounds];
    CGFloat toolHeight = [self.navigationController toolbar].frame.size.height + sf.size.height;

    self.upView.frame = CGRectMake(0, -toolHeight, self.view.frame.size.width, 80);
    [[self.upView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setFrame:self.upView.bounds];
    }];
    self.downView.frame = ({
        CGRect r = self.downView.frame;
        r.size.width = self.view.frame.size.width;
        r;
    });
    [[self.downView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setFrame:self.downView.bounds];
        
    }];
}

- (void)setProgress:(CGFloat)progress
{
//    if (progress > 0.8 && self.webView.alpha == 0) {
//        [UIView animateWithDuration:0.8 animations:^{
//            self. webView.alpha = 1;
//        }];
//    }
//    //NSLog(@"1 %f",progress);
    if (fabs(progress - 1) < 0.00001 || fabs(progress) < 0.00001) {
        if (self.navigationController.navigationBar.alpha == 0) {
            self.navigationController.navigationBar.alpha = 1;
            self.navigationController.toolbar.alpha = 1;
        }
    }
    
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

- (void)setFontSize:(NSInteger)size
{
    NSString* js = [NSString stringWithFormat:@"setFontSize(%@);",@(size)];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable x, NSError * _Nullable error) {
    }];
}

- (void)setLineHeight:(double)lineHeight
{
    NSString* js = [NSString stringWithFormat:@"setLineHeight(%@);",@(lineHeight)];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable x, NSError * _Nullable error) {
    }];
}

- (void)setAlign:(NSString*)align
{
    NSString* js = [NSString stringWithFormat:@"setAlign(\"%@\");",align];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable x, NSError * _Nullable error) {
    }];
}

- (void)setFont:(NSString*)font
{
    NSString* js = [NSString stringWithFormat:@"setFont(\"%@\");",font];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable x, NSError * _Nullable error) {
    }];
}

- (void)setTitleFontSize:(NSInteger)size
{
    
}

- (void)mvp_initFromModel:(MVPInitModel *)model
{
    [[self presenter] mvp_bindBlock:^(RRWebView* view, id value) {
        [view setFontSize:[value integerValue]];
        [view resetDownView];
    } keypath:@"webStyle.fontSize"];
    
    [[self presenter] mvp_bindBlock:^(RRWebView* view, id value) {
        [view setLineHeight:[value doubleValue]];
        [view resetDownView];
    } keypath:@"webStyle.lineHeight"];

    [[self presenter] mvp_bindBlock:^(RRWebView* view, id value) {
        [view setAlign:value];
        [view resetDownView];
    } keypath:@"webStyle.align"];
    
    [[self presenter] mvp_bindBlock:^(RRWebView* view, id value) {
        [view setFont:value];
        [view resetDownView];
    } keypath:@"webStyle.font"];
    
    [[[self navigationController] navigationBar] setPrefersLargeTitles:NO];
    
    self.prepareLoadLast = NO;
    self.prepareLoadNext = NO;
    self.hideNaviBar = NO;
    self.loadFinished = NO;
    self.canDragPage = NO;
    
    
    [self.view addSubview:self.webView];
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(padding);
    }];
    
//#if TARGET_OS_MACCATALYST
//    [self setAdditionalSafeAreaInsets:UIEdgeInsetsMake(50, 0, 0, 0)];
//#endif
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [[self view] addSubview:self.progressView];
//    NSLog(@"%@",self.webView.scrollView);

    self.webView.scrollView.delegate = self;
    if ([self isVoiceoverRunning]) {
        
    }
    else{
        #if !TARGET_OS_MACCATALYST
        [self.webView.scrollView addSubview:self.upView];
        [self.webView.scrollView addSubview:self.downView];
        #endif
    }
//    [self.webView.scrollView setDirectionalLockEnabled:YES];
//    [self.webView.scrollView setAlwaysBounceHorizontal:NO];
    
    [self.webView setUIDelegate:self];
    [self.webView setNavigationDelegate:self];
    [self.view addSubview:self.statusCover];
//    [self.progressView setProgress:0.5];
    
    __weak typeof(self) weakSelf = self;
    [[RACObserve(self.webView, estimatedProgress) takeUntil:[self rac_willDeallocSignal]]  subscribeNext:^(id  _Nullable x) {
        //        //NSLog(@"%@",x);
        [weakSelf setProgress:[x doubleValue]];
    }];
    
    NSString* filename = model.userInfo[@"name"];
    if (!filename) {
        filename = @"";
    }
    RRFeedArticleModel* m = model.userInfo[@"model"];
    MWFeedInfo* feedInfo = model.userInfo[@"feed"];
    
    [self loadContent:filename model:m initial:model feed:feedInfo];
}

- (void)loadContent:(NSString*)filename model:(RRFeedArticleModel*)m initial:(MVPInitModel*)model feed:(MWFeedInfo*)feedInfo
{
    NSURL * url = [[NSBundle mainBundle] URLForResource:[filename stringByDeletingPathExtension] withExtension:[filename pathExtension]];
    if (!m && ![filename hasPrefix:@"http"] && ![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
//        DDLogWarn(@"文件%@不存在",filename);
        return;
    }
    
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
        
        //        NSDictionary* style = [[NSUserDefaults standardUserDefaults] valueForKey:@"style"];
        string = [self preloadSystemCSSStyle:string];
        
        string = [string stringByReplacingOccurrencesOfString:@"<#title#>" withString:[filename stringByDeletingPathExtension]];
        
        string = [string stringByReplacingOccurrencesOfString:@"<#useMarkdown#>" withString:@"1"];
        
        string = [string stringByReplacingOccurrencesOfString:@"<#markdown#>" withString:mdString];
        
        string = [string stringByReplacingOccurrencesOfString:@"<#host#>" withString:@""];
        
        
        if ([self hasLatex:string]) {
            //NSLog(@"有latex");
            string = [self addLatex:string];
        }
        else {
            //NSLog(@"没有latex");
            string = [self removeLatex:string];
        }
        
        [self.webView loadHTMLString:string baseURL:[[NSBundle mainBundle] resourceURL]];
//        [self.webView loadHTMLString:string baseURL:nil];
    }
    else {
        //        [self.navigationController setToolbarHidden:NO animated:NO];
        [self preloadData:m feed:feedInfo];
        self.showToolbar = YES;
        
        UIBarButtonItem* rb = [self mvp_buttonItemWithActionName:@"openActionText:" title:@"阅读字体与排版设置"];
        rb.image = [UIImage imageNamed:@"icon_text"];
        
        self.navigationItem.rightBarButtonItem = rb;
        
    }
}

- (NSString*)preloadSystemCSSStyle:(NSString*)string
{
    NSDictionary* style = [[NSUserDefaults standardUserDefaults] valueForKey:@"style"];
    string = [string stringByReplacingOccurrencesOfString:@"<#main-tint-color#>" withString:style[@"$main-tint-color"]];
    string = [string stringByReplacingOccurrencesOfString:@"<#bgColor#>" withString:style[@"$main-bg-color"]];
    string = [string stringByReplacingOccurrencesOfString:@"<#main-color#>" withString:style[@"$main-text-color"]];
    string = [string stringByReplacingOccurrencesOfString:@"<#sub-color#>" withString:style[@"$sub-text-color"]];
    string = [string stringByReplacingOccurrencesOfString:@"<#sub-bg-color#>" withString:style[@"$sub-bg-color"]];
    return string;
}

- (void)preloadData:(RRFeedArticleModel*)m feed:(MWFeedInfo*)feedInfo
{
    //FIXBUG 切换位移bug
    [self.navigationController.navigationBar setAlpha:1];
    [self.navigationController.toolbar setAlpha:1];
    self.title = @"";
    __weak typeof(self) weakSelf = self;
    [self.webView stopLoading];
    [self.webView evaluateJavaScript:@"document.body.style.visibility=\"hidden\";" completionHandler:^(id _Nullable x, NSError * _Nullable error) {

    }];
    if ([weakSelf.presenter conformsToProtocol:@protocol(RRProvideDataProtocol)]) {
        [(id)weakSelf.presenter loadData:m feed:feedInfo];
    }
}

- (void)loadData:(RRFeedArticleModel*)m feed:(MWFeedInfo*)feedInfo
{
    if (!m && ! feedInfo) {
        return;
    }
   
    [self.webView stopLoading];
    [[SDWebImageManager sharedManager].imageCache clearMemory];
//    if(0){
//        self.webView.alpha = 0;
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
    string = [self preloadSystemCSSStyle:string];
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
        string = [self addHighlight:string];
    }
    else {
        string = [self removeHighlight:string];
    }
    
    NSDate* d = m.date;
    if(d){
        string = [string stringByReplacingOccurrencesOfString:@"<#subtitle#>" withString:[NSString stringWithFormat:@"%@ · %@",![feedInfo isKindOfClass:[NSNull class]]?feedInfo.title:@"无订阅源",[[RRFeedLoader sharedLoader].shortDateAndTimeFormatter stringFromDate:d]]];
    }
    else{
        string = [string stringByReplacingOccurrencesOfString:@"<#subtitle#>" withString:[NSString stringWithFormat:@"%@",![feedInfo isKindOfClass:[NSNull class]]?feedInfo.title:@"无订阅源"]];
    }
    if (m.link) {
        NSString* url = m.link;
        if ([m.link hasPrefix:@"//"]) {
            url = [@"http:" stringByAppendingString:url];
        }
        
        string = [string stringByReplacingOccurrencesOfString:@"<#url#>" withString:[NSString stringWithFormat:@"safari%@",url]];
    }
    if ([self hasLatex:string]) {
        string = [self addLatex:string];
    }
    else {
        string = [self removeLatex:string];
    }
    string = [string stringByReplacingOccurrencesOfString:@"src=\"//" withString:@"src=\"http://"];
    NSURL* u = [NSURL URLWithString:m.link];
    string = [string stringByReplacingOccurrencesOfString:@"<#host#>" withString:[NSString stringWithFormat:@"%@://%@",u.scheme,u.host]];
    
    [self.webView loadHTMLString:string baseURL:[[NSBundle mainBundle] resourceURL]];
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
    
    
    __weak typeof(self) weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11, *)) {
            weakSelf.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            CGRect sf = [self statusframe];
            CGFloat height = sf.size.height + weakSelf.navigationController.navigationBar.frame.size.height;
            CGFloat toolHeight = [weakSelf.navigationController toolbar].frame.size.height;
            weakSelf.webView.scrollView.contentInset = UIEdgeInsetsMake(height, 0, toolHeight, 0);
        }
        
    });
    CGRect sf = [self statusframe];
    CGFloat toolHeight = [weakSelf.navigationController toolbar].frame.size.height + sf.size.height;
    self.upView.frame = CGRectMake(0, -toolHeight, self.view.frame.size.width, 80);
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getFontSize"];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"RRWebNeedReload" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf loadData:weakSelf.currentArticle feed:weakSelf.currentFeed];
        });
    }];
    
//    NSLog(@"1 %@",self.navigationController.splitViewController);
//    NSLog(@"2 %@",self.splitViewController);
    if (self.navigationController.splitViewController) {
        if ([self.navigationController.splitViewController.viewControllers firstObject] == self.navigationController) {
            
        }
        else {
            self.navigationItem.leftBarButtonItem = self.navigationController.splitViewController.displayModeButtonItem;
            self.navigationItem.leftItemsSupplementBackButton = YES;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    [self hudDismiss];
    [self resetToolBar];
    [[[self navigationController] navigationBar] setPrefersLargeTitles:YES];
    
    
    #if !TARGET_OS_MACCATALYST
    [self.navigationController.navigationBar setAlpha:1];
    [self.navigationController.toolbar setAlpha:1];
    self.hideNaviBar = NO;
    #endif

    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getFontSize"];
    [self recordReadProgress:^{
        
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RRWebNeedReload" object:nil];
}

- (void)cleanReadProgress
{
    [RRFeedAction recordArticle:self.currentArticle.uuid position:0];
}

- (void)recordReadProgress:(void (^)(void))finish
{
    if (self.currentArticle) {
        __weak typeof(self) weakSelf = self;
        [[self webView] evaluateJavaScript:@"document.body.scrollTop" completionHandler:^(id _Nullable x, NSError * _Nullable error) {
            //NSLog(@"当前滚动位置 %@ %@",x,weakSelf.currentArticle);
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
    
     UIBarButtonItem* rb = [self mvp_buttonItemWithSystem:UIBarButtonSystemItemAction actionName:@"openAction:" title:@"更多操作"];

    UIBarButtonItem* test = [self mvp_buttonItemWithActionName:@"testf" title:@"测试"];
    [test setTarget:self];
    [test setAction:@selector(likedItem)];
    
    return @[[self fixedItem],loadLastItem,[self fixedItem],loadNextItem,[self fixedItem],rb,[self fixedItem]];
}

- (void)mvp_configOther
{
//    __weak typeof(self) weakSelf = self;
    [self.presenter mvp_bindBlock:^(RRWebView* view, id value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            view.articleLiked = [value boolValue];
            [view reloadItems];
        });
    } keypath:@"articleLiked"];
    
    [self.presenter mvp_bindBlock:^(RRWebView* view, id value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            view.articleReadLatered = [value boolValue];
            [view reloadItems];
        });
    } keypath:@"articleReadLaterd"];
}

- (void)reloadItems
{
    NSMutableArray* items = [NSMutableArray array];
    BOOL hide = [[NSUserDefaults standardUserDefaults] boolForKey:@"kToolBackBtn"];
    BOOL isSplited =  [[NSUserDefaults standardUserDefaults] boolForKey:@"RRSplit"];
    if (!hide && (![UIDevice currentDevice].iPad() || isSplited)) {
        UIBarButtonItem* favItem = [self mvp_buttonItemWithActionName:@"acBack" title:@"返回"];
        favItem.image = [UIImage imageNamed:@"icon_zuo"];
        [items addObject:favItem];
        [items addObject:[self fixedItem]];
    }

    [items addObjectsFromArray:[self likedItem]];
    if (items.count>0) {
        [items insertObject:[self fixedItem] atIndex:0];
        [items addObject:[self fixedItem]];
    }
    [items addObjectsFromArray:[self readerLaterItem]];
    [items addObjectsFromArray:[self barItems]];
    [self setToolbarItems:items animated:NO];
}

- (NSArray*)readerLaterItem
{
    __weak typeof(self) weakSelf = self;
    BOOL hasModel = [[weakSelf.presenter mvp_valueWithSelectorName:@"hasModel"] boolValue];
    if (!hasModel) {
        return @[];
    }
    NSMutableArray* result = [NSMutableArray array];
    if (self.articleReadLatered) {
        UIBarButtonItem* favItem = [self mvp_buttonItemWithActionName:@"cancelReadLater" title:@"取消稍后"];
        favItem.image = [UIImage imageNamed:@"icon_bookmarked"];
        [result addObject:favItem];
    }
    else {
        UIBarButtonItem* favItem = [self mvp_buttonItemWithActionName:@"readLater" title:@"稍后阅读"];
        favItem.image = [UIImage imageNamed:@"icon_bookmark"];
        [result addObject:favItem];
    }
    return result;
}

- (void)switchReadlater
{
    if (self.articleReadLatered) {
        [self.presenter mvp_runAction:@"cancelReadLater"];
    }
    else {
        [self.presenter mvp_runAction:@"readLater"];
    }
    [self reloadItems];
}

- (NSArray*)likedItem
{
    __weak typeof(self) weakSelf = self;
    BOOL hasModel = [[weakSelf.presenter mvp_valueWithSelectorName:@"hasModel"] boolValue];
    if (!hasModel) {
        return @[];
    }
    NSMutableArray* result = [NSMutableArray array];
    if (self.articleLiked) {
        UIBarButtonItem* favItem = [self mvp_buttonItemWithActionName:@"unfavIt" title:@"取消收藏"];
        favItem.image = [UIImage imageNamed:@"icon_faved"];
        [result addObject:favItem];
    }
    else {
        UIBarButtonItem* favItem = [self mvp_buttonItemWithActionName:@"favIt" title:@"收藏"];
        favItem.image = [UIImage imageNamed:@"icon_fav"];
        [result addObject:favItem];
    }
    return result;
}

- (void)switchFavorite
{
    if (self.articleLiked) {
        [self.presenter mvp_runAction:@"unfavIt"];
    }
    else {
        [self.presenter mvp_runAction:@"favIt"];
    }
    [self reloadItems];
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
//    //NSLog(@"1 %@",navigationAction.request.URL.absoluteString);
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
//    //NSLog(@"2 %@",navigationResponse.response.URL.absoluteString);
//    //NSLog(@"%@",navigationResponse.response);
//    //NSLog(@"%@",navigationResponse.response.MIMEType);
//    //NSLog(@"%@",navigationResponse.response.textEncodingName);
    
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
    if ([UIDevice currentDevice].iPad()) {
        return str;
    }
    if (str.length < 24) {
        return str;
    }
    return [NSString stringWithFormat:@"%@...",[str substringToIndex:24] ];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    __weak typeof(self) weakSelf = self;
//    if (@available(iOS 11, *)) {
//        weakSelf.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height + weakSelf.navigationController.navigationBar.frame.size.height;
//        CGFloat toolHeight = [weakSelf.navigationController toolbar].frame.size.height;
//        weakSelf.webView.scrollView.contentInset = UIEdgeInsetsMake(height, 0, toolHeight, 0);
//    }
    
    NSLog(@"Record Postion: %@",@(self.recordPostion));
    if (self.recordPostion > 100) {
        NSString* js = [NSString stringWithFormat:@"document.body.scrollTop = %@;",@(self.recordPostion)];
        [webView evaluateJavaScript:js completionHandler:^(id _Nullable x, NSError * _Nullable error) {

        }];
    }
    
    [self readedIt];
    [self hudDismiss];
    
//    if(0){
    
//    }
//    __weak typeof(self) weakSelf = self;
    [webView evaluateJavaScript:@"document.title;" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        weakSelf.title = title;
    }];
    
//    //NSLog(@"%f",webView.scrollView.contentSize.height);
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable h, NSError * _Nullable error) {
//        //NSLog(@"%@",h);
        weakSelf.downView.frame = ({
            CGRect r = weakSelf.downView.frame;
            r.origin.y = [h doubleValue] < [webView frame].size.height ? [webView frame].size.height - 30 : [h doubleValue] + 50;
            r;
        });
        
        // RRTODOIt:非订阅源打开情况，关闭上下翻文章的功能
        if (!weakSelf.currentArticle || !weakSelf.currentFeed) {
            
        }
        else {
            weakSelf.canDragPage = YES;
            if (weakSelf.lastFeed && weakSelf.lastArticle) {
                RRFeedArticleModel* m = weakSelf.lastArticle(weakSelf.currentArticle);
                MWFeedInfo* feed = weakSelf.lastFeed(weakSelf.currentArticle);
//                //NSLog(@"1 %@ %@",m,feed);
                if (m && feed) {
                    [weakSelf setUpViewText:[NSString stringWithFormat:@"%@\n%@",[weakSelf cutString:m.title],feed.title]];
                    [RRFeedAction preloadImages:m.uuid];
                }
                else {
                    [weakSelf setUpViewText:@"没有更多了"];
                }
            }
            else {
                [weakSelf setUpViewText:@""];
            }
            if (weakSelf.nextFeed && weakSelf.nextArticle) {
                RRFeedArticleModel* m = weakSelf.nextArticle(weakSelf.currentArticle);
                MWFeedInfo* feed = weakSelf.nextFeed(weakSelf.currentArticle);
//                //NSLog(@"2 %@ %@",m,feed);
                if (m && feed) {
                    [weakSelf setDownViewText:[NSString stringWithFormat:@"%@\n%@",[weakSelf cutString:m.title],feed.title]];
                    [RRFeedAction preloadImages:m.uuid];
                }
                else {
                    [weakSelf setDownViewText:@"没有更多了"];
                }
            }
            else {
                [weakSelf setDownViewText:@""];
            }
        }
    }];
   
}

- (void)resetDownView
{
    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable h, NSError * _Nullable error) {
//        NSLog(@"**()@%@",h);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.downView.frame = ({
                CGRect r = weakSelf.downView.frame;
                r.origin.y = [h doubleValue];
                r;
            });
        });
    }];
}

- (void)setCanDragPage:(BOOL)canDragPage
{
    if ([self isVoiceoverRunning]) {
        _canDragPage = NO;
    }
    else {
        _canDragPage = canDragPage;
    }
    if (canDragPage) {
        [self.downView setAlpha:0];
        [self.upView setAlpha:0];
    }
    else {
        [self.downView setAlpha:0];
        [self.upView setAlpha:0];
    }
}

- (void)openURLWithSafari:(NSString*)url
{
    if ([url hasPrefix:@"http"]) {
        __weak typeof(self) weakSelf = self;
        NSURLSessionConfiguration* c = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* s = [NSURLSession sessionWithConfiguration:c];
        NSURLSessionDataTask* d = [s dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([response.MIMEType rangeOfString:@"xml"].location != NSNotFound || [response.MIMEType rangeOfString:@"rss"].location != NSNotFound || [response.MIMEType rangeOfString:@"atom"].location != NSNotFound ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf loadFeed:url];
                    [weakSelf mvp_dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                });
            }
            else {
                
            }
        }];
        [d resume];
    }

    if ([url hasPrefix:@"http"]) {
        RRSafariViewController* ss = [[RRSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
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
    if ([url hasPrefix:@"innerweb"]) {
        url = [url substringFromIndex:8];
        id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":url,@"sub":@(1)}];
//        TODOFIX
        [self mvp_pushViewController:vc];
        return;
    }
    if ([url hasPrefix:@"inner"]) {
        url = [url substringFromIndex:5];
//        id vc = [MVPRouter viewForURL:@"rr://web" withUserInfo:@{@"name":url,@"sub":@(1)}];
//        [self mvp_pushViewController:vc];
        //TODOFIX
 
        id vc = [[RRFeedLoader sharedLoader] feedItem:url errorBlock:^(NSError * _Nonnull error) {
            
        } cancelBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hudDismiss];
            });
        } finishBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hudDismiss];
            });
        }];
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
    BOOL isTrait = [[NSUserDefaults standardUserDefaults] boolForKey:@"RRSplit"];
    if (self.splitViewController && !isTrait) {
//        NSLog(@"123123");
    }
    
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
            if (self.splitViewController) {
                BOOL split = [[NSUserDefaults standardUserDefaults] boolForKey:@"RRSplit"];
                if (split) {
                    [self mvp_pushViewController:vc];
                }
                else {
                    id vv = [[self.splitViewController viewControllers] firstObject];
                    if ([vv isKindOfClass:[UINavigationController class]]) {
                        UINavigationController* nvc = vv;
                        [nvc pushViewController:vc animated:YES];
                    }
                    else {
                        UI_Alert()
                        .titled(@"理论上不应该出现这种错误，清将此页面截图发送给开发者，谢谢您。")
                        .cancel(@"关闭", ^(UIAlertAction * _Nonnull action) {
                            
                        })
                        .show(self);
                    }
                }
            }
            else {
                [self mvp_pushViewController:vc];
            }
        });
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    if ([message hasPrefix:@"openimage:"]) {
        __weak typeof(self) weakSelf = self;
        NSInteger idx = [[message substringFromIndex:10] integerValue];
        [webView evaluateJavaScript:@"images" completionHandler:^(id _Nullable x, NSError * _Nullable error) {
            //NSLog(@"%@",x);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showImage:x index:idx];
            });
        }];
    }
    else {
        UI_Alert().descripted(message).cancel(@"确认", ^(UIAlertAction * _Nonnull action) {
            
        }).show(self);
    }
//    //NSLog(@"%@",message);
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

- (NSMutableArray *)tumblrImage
{
    if (!_tumblrImage) {
        _tumblrImage = [[NSMutableArray alloc] init];
    }
    return _tumblrImage;
}

- (void)showImage:(NSArray*)imgs index:(NSUInteger)idx
{
    //    //NSLog(@"%@",imgs);
    if (idx >= imgs.count || imgs.count == 0) {
        return;
    }
    
    [self.showImage removeAllObjects];
    [self.tumblrImage removeAllObjects];
    
    NSArray* temp =
    imgs.filter(^BOOL(id  _Nonnull x) {
        return [x isKindOfClass:[NSString class]];
    });
    
    [self.tumblrImage addObjectsFromArray:temp.map(^id _Nonnull(NSString* url) {
//        url = [@"thumb" stringByAppendingString:url];
        return [MWPhoto photoWithURL:[NSURL URLWithString:url]];
    })];
    
    [self.showImage addObjectsFromArray:temp.map(^id _Nonnull(NSString* url) {
        NSLog(@"%@",url);
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
    if (index < self.tumblrImage.count) {
        return [self.tumblrImage objectAtIndex:index];
    }
    return nil;
}

- (void)exportPic
{
    GCDQuene* q = [GCDQuene queneWithName:@"MySpecialQuene"];
    GCDQuene* m = [GCDQuene mainQueneInstance];
    __weak typeof(self) weakSelf = self;
    [self hudWait:@"处理中"];
    [self.webView screenSnapshot:^(UIImage *snapShotImage) {
        q.async(^{
            NSData* d = UIImageJPEGRepresentation(snapShotImage, 1.0);
            NSString* file = [[[UIApplication sharedApplication].doucumentDictionary() URLByAppendingPathComponent:@"export_img.jpg"] path];
            BOOL result = [d writeToFile:file atomically:NO];
            if (!result) {
                m.async(^{
                    [weakSelf hudFail:@"存储失败"];
                });
            }
            else {
                m.async(^{
                    [weakSelf hudDismiss];
                    NSDictionary* t = @{
                                        @"file":file,
                                        @"sender":weakSelf.toolbarItems.lastObject
                                        };
                    [weakSelf.presenter mvp_runAction:@"shareFile:" value:t];
                });
            }
        });
    }];
}

- (void)exportPDF
{
    GCDQuene* q = [GCDQuene queneWithName:@"MySpecialQuene"];
    GCDQuene* m = [GCDQuene mainQueneInstance];
    __weak typeof(self) weakSelf = self;
//    [self hudWait:@"处理中"];
    [self hudWait:@"处理中"];
    m.async(^{
        NSData* d = [self.webView PDFData];
        q.async(^{
            //异步操作
            NSDateFormatter* f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"yy-MM-dd_HH-mm-ss"];
            NSString* file = [[[UIApplication sharedApplication].doucumentDictionary() URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.pdf",weakSelf.title,[f stringFromDate:[NSDate date]]]] path];
            BOOL result = [d writeToFile:file atomically:NO];
            if (!result) {
                m.async(^{
                    [weakSelf hudFail:@"存储失败"];
                });
            }
            else {
                m.async(^{
                    [weakSelf hudDismiss];
                    NSDictionary* t = @{
                                        @"file":file,
                                        @"sender":weakSelf.toolbarItems[weakSelf.toolbarItems.count-2]
                                        };
                    [weakSelf.presenter mvp_runAction:@"shareFile:" value:t];
                });
            }
        });
    });
}

- (void)exportEmail
{
    __weak typeof(self) weakSelf = self;
    //    [self hudWait:@"处理中"];
    [weakSelf.webView emailString:^(NSString * _Nonnull x) {
        UI_Alert()
        .titled(@"是否在Email中使用Prime的HTML样式?")
        .recommend(@"使用", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
            [weakSelf emailString:x useCss:YES];
        })
        .action(@"不使用", ^(UIAlertAction * _Nonnull action, UIAlertController * _Nonnull alert) {
            [weakSelf emailString:x useCss:NO];
        })
        .cancel(@"取消", ^(UIAlertAction * _Nonnull action) {
            
        })
        .show(weakSelf);
    }];
}

- (void)emailString:(NSString*)str useCss:(BOOL)useCss
{
    MFMailComposeViewController* c = [[MFMailComposeViewController alloc] init];
    if (!c) {
        // 在设备还没有添加邮件账户的时候mailViewController为空，
        // 下面的present view controller会导致程序崩溃，这里要作出判断
        [self hudInfo:@"设备没有设置邮件帐户"];
        return;
    }
    c.mailComposeDelegate = self;
    [c setSubject:self.title];
    if (useCss) {
        NSString* cssFile = [[NSBundle mainBundle] pathForResource:@"style1" ofType:@"css"];
        NSString* cssFileContent = [[NSString alloc] initWithContentsOfFile:cssFile encoding:NSUTF8StringEncoding error:nil];
        NSString* cssStyle = [[NSString alloc] initWithFormat:@"<style>%@</style>",cssFileContent];
        str = [str stringByReplacingOccurrencesOfString:@"<link rel=\"stylesheet\" href=\"style1.css\" type=\"text/css\">" withString:cssStyle];
    }
    [c setMessageBody:str isHTML:YES];
    [self presentViewController:c animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
        {
            [self hudSuccess:@"已发送"];
            break;
        }
        case MFMailComposeResultSaved:
        {
            [self hudSuccess:@"已保存"];
            break;
        }
        case MFMailComposeResultFailed:
        case MFMailComposeResultCancelled:
        {
            break;
        }
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)readedIt
{
    if (self.currentArticle && !self.currentArticle.lastread) {
        [RRFeedAction readArticle:self.currentArticle.uuid];
    }
}

- (BOOL)isVoiceoverRunning
{
    return self.voiceover;
}


@end
