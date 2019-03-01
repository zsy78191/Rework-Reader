//
//  RRTableOutput.m
//  rework-reader
//
//  Created by 张超 on 2019/2/28.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRTableOutput.h"
#import "RRCanEditProtocol.h"
#import "RRFeedAction.h"
#import "RRFeedInfoListModel.h"
#import "RRFeedInfoListOtherModel.h"
@interface RRTableOutput () 
{
    
}
@end

@implementation RRTableOutput

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.canMove = YES;
    }
    return self;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [self.inputer mvp_modelAtIndexPath:indexPath];
//    NSLog(@"%@",model);
    if ([model conformsToProtocol:@protocol(RRCanEditProtocol)]) {
        id<RRCanEditProtocol>m = model;
        return m.canEdit;
    }
    return YES;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.inputer mvp_deleteModelAtIndexPath:indexPath];
        
        id model = [self.inputer mvp_modelAtIndexPath:indexPath];
        if ([model isKindOfClass:[RRFeedInfoListModel class]]) {
            RRFeedInfoListModel* m = model;
            __weak typeof(self) weakSelf = self;
            [RRFeedAction delFeed:m.feed view:(id)self.presenter.view finish:^{
                [(id)weakSelf.presenter loadData];
            }];
        }
    }
}

- (void)loadData
{
    
}


@end
