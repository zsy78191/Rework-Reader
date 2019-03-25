//
//  AppleReviewHelper.h
//  mframe
//
//  Created by 张超 on 2017/4/13.
//  Copyright © 2017年 orzer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol SKPaymentTransactionObserver;
@protocol SKProductsRequestDelegate;
@protocol SKStoreProductViewControllerDelegate;
@class SKProduct;

@interface AppleAPIHelper : NSObject

+ (void)review;

+ (BOOL)RequestAppleReview;

+ (void)HapticFeedback:(UIImpactFeedbackStyle)style;

+ (void)openAppStore:(NSString *)appId vc:(id<SKStoreProductViewControllerDelegate>)vc complate:(void (^)(BOOL))finish;

+ (void)testForStore:(id<SKPaymentTransactionObserver,SKProductsRequestDelegate>)delegate products:(NSSet*)products;
+ (void)endTestForStore:(id<SKPaymentTransactionObserver,SKProductsRequestDelegate>)delegate;

+ (void)purchaseProduct:(SKProduct*)product;

+ (void)restoreProduct;

@end

NS_ASSUME_NONNULL_END
