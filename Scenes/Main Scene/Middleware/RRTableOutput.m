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
#import "RRFeedInputer.h"
@interface RRTableOutput ()  <UITableViewDelegate>
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
//    //NSLog(@"%@",model);
    if ([model conformsToProtocol:@protocol(RRCanEditProtocol)]) {
        id<RRCanEditProtocol>m = model;
        return m.canEdit;
    }
    return YES;
}

- (Class)tableviewClass
{
    return NSClassFromString(@"RRTableView");
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    id model = [self.inputer mvp_modelAtIndexPath:indexPath];
//    if ([model isKindOfClass:[RRFeedInfoListModel class]]) {
//        //        RRFeedInfoListModel* m = model;
//        return 60;
//    }
//    else if([model isKindOfClass:[RRFeedInfoListOtherModel class]])
//    {
//        RRFeedInfoListOtherModel* m = model;
//        if (m.type == RRFeedInfoListOtherModelTypeTitle) {
//            return 40;
//        }
//        return 60;
//    }
//    return 0;
//}


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
            
//            CGRect r = [tableView rectForRowAtIndexPath:indexPath];
//            r = [tableView convertRect:r toView:nil];
//            r.origin.x += 0.9 * r.size.width;
//            r.origin.y += 0.5 * r.size.height;
//            r.size.width = 0;
//            r.size.height = 0;
            [RRFeedAction delFeed:m.feed view:(id)self.presenter.view item:nil arrow:UIPopoverArrowDirectionRight finish:^{
                 [(id)weakSelf.presenter loadData];
            }];
        }
    }
}

- (void)loadData
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        if (self.newOffsetBlock) {
            self.newOffsetBlock(scrollView.contentOffset.y);
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.newOffsetBlock) {
        self.newOffsetBlock(scrollView.contentOffset.y);
    }
}

@end
