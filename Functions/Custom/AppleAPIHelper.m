//
//  AppleReviewHelper.m
//  mframe
//
//  Created by 张超 on 2017/4/13.
//  Copyright © 2017年 orzer. All rights reserved.
//

#import "AppleAPIHelper.h"
//#import <StoreKit/SKStoreReviewController.h>
#import <UserNotifications/UserNotifications.h>
//#import "CocoaAPICheckHelper.h"
//@import custom_ui;
#import <StoreKit/StoreKit.h>
@import StoreKit;

@implementation AppleAPIHelper

+ (void)review
{
    NSInteger reviewd = [[NSUserDefaults standardUserDefaults] integerForKey:@"review"];
    if(reviewd == 3)
    {
        [AppleAPIHelper RequestAppleReview];
    }
    [[NSUserDefaults standardUserDefaults] setInteger:reviewd+1 forKey:@"review"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)RequestAppleReview
{
    [SKStoreReviewController requestReview];
    return YES;
}

+ (void)HapticFeedback:(UIImpactFeedbackStyle)style
{
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: style];
    [generator prepare];
    [generator impactOccurred];
}


+ (void)openAppStore:(NSString *)appId vc:(id<SKStoreProductViewControllerDelegate>)vc complate:(void (^)(BOOL))finish
{
    
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = vc;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error)
     {
         if (result)
         {
             [(UIViewController*)vc presentViewController:storeProductVC animated:YES completion:nil];
             if(finish)
             {
                 finish(YES);
             }
         }
         else {
             if(finish)
             {
                 finish(NO);
             }
         }
     }];
}

+ (void)testForStore:(id<SKPaymentTransactionObserver,SKProductsRequestDelegate>)delegate products:(NSSet*)products
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:delegate];
    SKProductsRequest* r = [[SKProductsRequest alloc] initWithProductIdentifiers:products];
    r.delegate = delegate;
    [r start];
}

+ (void)endTestForStore:(id<SKPaymentTransactionObserver,SKProductsRequestDelegate>)delegate
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:delegate];
}

+ (void)purchaseProduct:(SKProduct *)product
{
    SKPayment* p = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:p];
}

+ (void)restoreProduct;
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


+ (void)setIconname:(nullable NSString *)name {
    
    UIApplication *app = [UIApplication sharedApplication];
    //判断系统是否支持切换icon
    if ([app supportsAlternateIcons]) {
        //切换icon
        [app setAlternateIconName:name completionHandler:^(NSError * _Nullable error) {
            if (error) {
                //NSLog(@"error==> %@",error.localizedDescription);
            }else{
                //NSLog(@"done!!!");
            }
        }];
    }
}


@end
