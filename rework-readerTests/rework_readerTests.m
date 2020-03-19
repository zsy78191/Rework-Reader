//
//  rework_readerTests.m
//  rework-readerTests
//
//  Created by 张超 on 2019/1/15.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RRWebView.h"
#import "RPDataManager.h"
#import "RRCoreDataModel.h"
#import "RRFeedArticleModel.h"
#import "RRFeedManager.h"

@import MagicalRecord;

@import Fork_MWFeedParser;
@interface rework_readerTests : XCTestCase

@end

@implementation rework_readerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [RRFeedManager removeAllHUBs];
    RRFeedHub* hub = [RRFeedManager hubWithName:@"IT"];
    
    hub.save(^(BOOL s) {
        //NSLog(@"save 1 %@",@(s));
    });
    NSUInteger c = [RRFeedManager allHubs].count;
    NSAssert(c == 1, @"一个");
    NSAssert([hub.name isEqualToString:@"IT"], @"名字");
    
    RRFeedHub* hub2 = [RRFeedManager hubWithName:@"体育"];
    hub2
    .named(@"Sport")
    .icond(@"123")
    .save(^(BOOL s) {
        //NSLog(@"save 2 %@",@(s));
    });
    
    EntityFeedInfo* i1 = [EntityFeedInfo MR_findFirst];
    hub2.insertFeed(i1);
    
    NSAssert(hub2.feeds.count == 1, @"数量");
    
    NSArray* all = [EntityFeedInfo MR_findAll];
    
    hub2.insertFeeds(all).save(^(BOOL s) {
         //NSLog(@"save 3 %@",@(s));
    });
    
    //NSLog(@"all %@",@(hub2.feeds.count));
    
    //NSLog(@"%@",hub2.name);
    //NSLog(@"%@",hub2.icon);
}

- (void)atestPerformanceExample {
    // This is an example of a performance test case.
    RRWebView* v = [[RRWebView alloc] initWithUserInfo:@{}];
    NSArray* a = [[RPDataManager sharedManager] getAll:@"EntityFeedArticle" predicate:nil key:nil value:nil sort:@"sort" asc:YES];
    
    
    MWFeedInfo* info = [[MWFeedInfo alloc] init];
    info.title = @"";

    [self measureBlock:^{
        [a enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RRFeedArticleModel* m = [[RRFeedArticleModel alloc] initWithEntity:obj];
            [v loadData:m feed:info];
        }];
    }];
}

@end
