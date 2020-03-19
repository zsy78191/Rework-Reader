//
//  IconSelectView.m
//  rework-reader
//
//  Created by 张超 on 2019/6/4.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "IconSelectView.h"
@import Classy;
@interface IconSelectView ()
{
}
@end

@implementation IconSelectView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (Class)mvp_presenterClass
{
    return NSClassFromString(@"IconSelectPresenter");
}

- (Class)mvp_outputerClass
{
    return [MVPCollectViewOutput class];
}

- (void)mvp_configMiddleware
{
    [super mvp_configMiddleware];
    
    self.title = @"请选择图标";
    
    [self.outputer setRegistBlock:^(MVPCollectViewOutput*  _Nonnull output) {
//        //NSLog(@"%@",output.collectionView.backgroundView);
        [output collectionView].backgroundView = [UIView new];
        [output collectionView].backgroundView.cas_styleClass = @"bgView";
        [[output collectionView] setBackgroundColor:[UIColor whiteColor]];
        
        [output registNibCell:@"IconCell" withIdentifier:@"cell"];
        
        UICollectionViewFlowLayout* l = (UICollectionViewFlowLayout*)output.collectionView.collectionViewLayout;
        [l setItemSize:CGSizeMake(52, 52)];
        [l setMinimumLineSpacing:10];
        [l setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
