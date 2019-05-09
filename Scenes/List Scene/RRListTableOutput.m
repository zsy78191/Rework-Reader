//
//  RRListTableOutput.m
//  rework-reader
//
//  Created by 张超 on 2019/4/25.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRListTableOutput.h"
#import "RPFontLoader.h"
@interface RRListTableOutput () <UITableViewDelegate>
@property (nonatomic, assign) CGFloat lineHeight;
@end

@implementation RRListTableOutput

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showDetial = ! [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideArticleDetial"];
        NSNumber* headLine = [RPFontLoader fontSizeWithTextStyle:UIFontTextStyleHeadline];
//        NSNumber* subLine = [RPFontLoader fontSizeWithTextStyle:UIFontTextStyleSubheadline];
        self.lineHeight = 48 + [headLine floatValue] * 2.2 * 2 + 14 * 3 + 5*2 + 12;
        
        self.tableview.estimatedRowHeight = 0;
        self.tableview.estimatedSectionHeaderHeight = 0;
        self.tableview.estimatedSectionFooterHeight = 0;
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    return 0;
    return self.showDetial?self.lineHeight:130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return UITableViewAutomaticDimension;
    return self.showDetial?self.lineHeight:130;;
}

@end
