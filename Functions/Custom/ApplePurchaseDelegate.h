//
//  ApplePurchaseDelegate.h
//  mframe
//
//  Created by 张超 on 2017/8/30.
//  Copyright © 2017年 orzer. All rights reserved.
//

@import StoreKit;
@interface ApplePurchaseDelegate : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver>
+ (instancetype)sharedOne;

- (NSArray<SKProduct*>*)products;

@property (nonatomic, weak) void (^ purchasedBlock)(SKPaymentTransaction* t);

@end
