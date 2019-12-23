//
//  RRTest.m
//  rework-reader
//
//  Created by 张超 on 2019/1/28.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRTest.h"
#import "RRFeedLoader.h"
#import "RRGetWebIconOperation.h"
@import NaturalLanguage;
@import ui_base;
#import "RPDataManager.h"
#import "RRCoreDataModel.h"
@import SDWebImage;
#import "OPMLDocument.h"
@import ReactiveObjC;
#import "RRFeedManager.h"
#import "RRFeedArticleModel.h"
@import MagicalRecord;

@implementation RRTest

- (void)feed
{
    [[RRFeedLoader sharedLoader] loadOfficalWithInfoBlock:^(MWFeedInfo * _Nonnull info) {
        
    } itemBlock:^(MWFeedItem * _Nonnull item) {
        ////NSLog(@"%@",item);
    } errorBlock:^(NSError * _Nonnull error) {
        
    } finishBlock:^{
        
    }];
}

- (void)nl
{
    
    if (@available(iOS 12.0, *)) {
        
        // 语言种类判断
        NLLanguageRecognizer * r = [[NLLanguageRecognizer alloc] init];
        [r processString:@"困死了去睡觉了"];
//        NLLanguage l = r.dominantLanguage;
        ////NSLog(@"%@",l);
//        NSDictionary* d = [r languageHypothesesWithMaximum:2];
        ////NSLog(@"%@",d);
        
        // 分词
        NLTokenizer* tokenizer = [[NLTokenizer alloc] initWithUnit:NLTokenUnitWord];
        NSString* str = @"我困死了，我要去睡觉了";
//        NSRange range = NSMakeRange(0, str.length);
        tokenizer.string = str;
//        NSArray* allWords = [tokenizer tokensForRange:range];
        ////NSLog(@"%@",allWords);
        
        // 文本标签
        NLLanguageRecognizer * r2 = [[NLLanguageRecognizer alloc] init];
        NLTagger* tagger = [[NLTagger alloc] initWithTagSchemes:@[NLTagSchemeNameType]];
        NSString* str2 = @"Prince Harry and Meghan have an apple and a TV.";
        [r2 processString:str2];
        NLLanguage l2 = r2.dominantLanguage;
        NSRange range2 = NSMakeRange(0, str2.length);
        tagger.string = str2;
        [tagger setLanguage:l2 range:range2];
//        NSArray* tags = [tagger tagsInRange:range2 unit:NLTokenUnitWord scheme:NSLinguisticTagSchemeNameType options:NLTaggerOmitWhitespace tokenRanges:nil];
//        [tags enumerateObjectsUsingBlock:^(NLTag*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//        }];
        [tagger enumerateTagsInRange:range2 unit:NLTokenUnitWord scheme:NLTagSchemeNameType options:NLTaggerOmitWhitespace|NLTaggerJoinNames usingBlock:^(NLTag  _Nullable tag, NSRange tokenRange, BOOL * _Nonnull stop) {
            ////NSLog(@"%@",[str2 substringWithRange:tokenRange]);
            ////NSLog(@"%@",tag);
            ////NSLog(@"--");
        }];
    }
}


- (void)icon
{
    RRGetWebIconOperation* o = [[RRGetWebIconOperation alloc] init];
    o.host = [NSURL URLWithString:@"https://www.cnblogs.com/lijIT/p/8980348.html"];
    [o setGetIconBlock:^(NSString * _Nonnull icon) {
        ////NSLog(@"%@",icon);
    }];
    [o start];
}


- (void)allArticle
{
   NSArray* x = [[RPDataManager sharedManager] getAll:@"EntityFeedArticle" predicate:nil key:nil value:nil sort:@"sort" asc:YES];
 
    [x enumerateObjectsUsingBlock:^(EntityFeedArticle*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ////NSLog(@"%@ %@ %@",obj.title,obj.lastread,obj.uuid);
    }];
}

- (void)allFeed
{
    NSArray* x = [[RPDataManager sharedManager] getAll:@"EntityFeedInfo" predicate:nil key:nil value:nil sort:@"sort" asc:YES];
    
    [x enumerateObjectsUsingBlock:^(EntityFeedInfo*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //NSLog(@"%@ %@ %@",obj.title,obj.uuid,obj.url);
    }];
}

- (void)del_all_article
{
    [[RPDataManager sharedManager] delData:@"EntityFeedArticle" predicate:nil key:nil value:nil beforeDel:^BOOL(__kindof NSManagedObject * _Nonnull o) {
        return YES;
    } finish:^(NSUInteger count, NSError * _Nonnull e) {
        ////NSLog(@"del %@",@(count));
    }];
}

- (void)font_test
{
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"SourceHanSerifCN-Light" ofType:@"otf"];
    ////NSLog(@"%@",path);
    ////NSLog(@"%@",@([[NSFileManager defaultManager] fileExistsAtPath:path]));
    
}

- (void)cleanSDWebImageCache
{
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        //NSLog(@"1");
    }];
}

- (void)exportOPML
{
    NSURL* u = [[UIApplication sharedApplication].doucumentDictionary() URLByAppendingPathComponent:@"export.opml"];
    OPMLDocument* d = [[OPMLDocument alloc] initWithFileURL:u];
    [d addOutlineWithText:@"1" title:@"2" type:@"rss" xmlUrl:@"123" htmlUrl:@"321"];
    [d saveToURL:u forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        
//        UIActivityViewController* a = [[UIActivityViewController alloc] initWithActivityItems:@[u] applicationActivities:nil];
        
    }];
    
}

- (void)objectivec
{
    RACSignal* s = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
       
        //NSLog(@"i1");
        [subscriber sendNext:@"1"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
    
    RACSignal* s2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        //NSLog(@"i2");
        [subscriber sendNext:@"2"];
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
    
    RACSignal* n = [s concat:s2];
    [n subscribeNext:^(id  _Nullable x) {
        //NSLog(@"11 %@",x);
    }];
    
    
}

- (void)feedhubtest
{
    [RRFeedManager hubWithName:@"123"];
}



@end
