//
//  RRListTableOutput.m
//  rework-reader
//
//  Created by 张超 on 2019/4/25.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRListTableOutput.h"
#import "RPFontLoader.h"
#import "EntityFeedArticle+CoreDataClass.h"
#import "EntityFeedArticle+Ext.h"

@interface RRListTableOutput () <UITableViewDelegate>
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat singleLineHeight;
@property (nonatomic, strong) UIFont* titleFont;
@property (nonatomic, assign) CGFloat oneLineHeight;
@end

@implementation RRListTableOutput

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showDetial = ! [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideArticleDetial"];
        NSNumber* headLine = [RPFontLoader fontSizeWithTextStyle:UIFontTextStyleHeadline];
        self.singleLineHeight = [headLine doubleValue];
//        self.lineHeight = 48 + [headLine floatValue] * 2.2 * 2 + 14 * 3 + 5*2 + 12;
        self.lineHeight = 145;
        self.titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.tableview.estimatedRowHeight = 0;
        self.oneLineHeight = -1;
        self.tableview.estimatedSectionHeaderHeight = 0;
        self.tableview.estimatedSectionFooterHeight = 0;
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [self.inputer mvp_modelAtIndexPath:indexPath];
    EntityFeedArticle* m = model;
    
    if(self.oneLineHeight == -1) {
        self.oneLineHeight = [m title:@"1" HeightWithFont:self.titleFont width:tableView.frame.size.width - 38];
    }
    NSInteger lineCount = [m titleHeightWithFont:self.titleFont width:tableView.frame.size.width - 38] / self.oneLineHeight;
    NSInteger noHeight = 100 + (lineCount-1)*self.singleLineHeight;
    NSString* ide = [self.inputer mvp_identifierForModel:model];
    if ([ide isEqualToString:@"articleCell2"]) {
        return noHeight;
    }
    CGFloat h =  self.lineHeight + lineCount*self.singleLineHeight;
//    NSLog(@"%@",@(h));
    return self.showDetial? h :noHeight;
}

@end
