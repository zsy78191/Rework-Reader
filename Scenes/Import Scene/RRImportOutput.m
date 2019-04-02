//
//  RRImportOutput.m
//  rework-reader
//
//  Created by 张超 on 2019/3/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRImportOutput.h"

@interface RRImportOutput ()  

@end

@implementation RRImportOutput

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.presenter mvp_runAction:@"selectChanged:" value:[tableView indexPathsForSelectedRows]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.presenter mvp_runAction:@"selectChanged:" value:[tableView indexPathsForSelectedRows]];
}

@end
