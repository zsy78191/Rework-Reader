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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [self.inputer mvp_modelAtIndexPath:indexPath];
    if ([model conformsToProtocol:@protocol(RRCanEditProtocol)]) {
        id<RRCanEditProtocol>m = model;
        return m.canMove;
    }
    return self.canMove;
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [self.inputer mvp_modelAtIndexPath:indexPath];
    //    //NSLog(@"%@",model);
    if ([model conformsToProtocol:@protocol(RRCanEditProtocol)]) {
        id<RRCanEditProtocol>m = model;
        if (!tableView.editing) {
            return UITableViewCellEditingStyleNone;
        }
        if (m.editType == RRCEEditTypeInsert) {
            return UITableViewCellEditingStyleInsert;
        }
        else if(m.editType == RRCEEditTypeDelete)
        {
            return UITableViewCellEditingStyleDelete;
        }
    }
    if (self.canMutiSelect) {
        return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.canMutiSelect || !tableView.editing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([self.presenter respondsToSelector:@selector(mvp_action_selectItemAtIndexPath:)]) {
            [self.presenter mvp_action_selectItemAtIndexPath:indexPath];
        }
    }
    else {
        if([self.presenter respondsToSelector:NSSelectorFromString(@"updateSelections:")])
        {
            [self.presenter mvp_runAction:@"updateSelections:" value:[tableView indexPathsForSelectedRows]];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.canMutiSelect || !tableView.editing) {
        
    }
    else {
        if([self.presenter respondsToSelector:NSSelectorFromString(@"updateSelections:")])
        {
            [self.presenter mvp_runAction:@"updateSelections:" value:[tableView indexPathsForSelectedRows]];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [self.inputer mvp_modelAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.inputer mvp_deleteModelAtIndexPath:indexPath];
        if ([model isKindOfClass:[RRFeedInfoListModel class]]) {
            
            RRFeedInfoListModel* m = model;
            __weak typeof(self) weakSelf = self;
            [RRFeedAction delFeed:m.feed view:(id)self.presenter.view item:nil arrow:UIPopoverArrowDirectionRight finish:^{
                 [(id)weakSelf.presenter loadData];
            }];
        }
        else if([model isKindOfClass:[RRFeedInfoListOtherModel class]]){
//            NSLog(@"%@",[model class]);
            RRFeedInfoListOtherModel* m = model;
            m.editType = RRCEEditTypeInsert;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert)
    {
        if([model isKindOfClass:[RRFeedInfoListOtherModel class]]){
            //            NSLog(@"%@",[model class]);
            RRFeedInfoListOtherModel* m = model;
            m.editType = RRCEEditTypeDelete;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    id model = [self.inputer mvp_modelAtIndexPath:indexPath];
//    if([model isKindOfClass:[RRFeedInfoListOtherModel class]]){
//        //            NSLog(@"%@",[model class]);
//        RRFeedInfoListOtherModel* m = model;
//        if (m.type == RRCEEditTypeInsert) {
//            return 0;
//        }
//    }
//    
//    return UITableViewAutomaticDimension;
//}


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


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.startScroll) {
        self.startScroll();
    }
}


@end
