//
//  ApplePurchaseDelegate.m
//  mframe
//
//  Created by 张超 on 2017/8/30.
//  Copyright © 2017年 orzer. All rights reserved.
//

#import "ApplePurchaseDelegate.h"
@import StoreKit;

@interface ApplePurchaseDelegate()
@property (nonatomic, strong) NSArray* products;
@end

@implementation ApplePurchaseDelegate

+ (instancetype)sharedOne
{
    static ApplePurchaseDelegate* _sh_delegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sh_delegate = [[ApplePurchaseDelegate alloc] init];
    });
    return _sh_delegate;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads
{
    NSLog(@"%s",__func__);
    NSLog(@"%@",downloads);
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    NSLog(@"%s",__func__);
//    NSLog(@"%@",transactions);
    [self anylsisTranstions:transactions];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"%s",__func__);
    [self anylsisTranstions:queue.transactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"%s",__func__);
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    //    NSLog(@"AAPI %@",);
    self.products = [response.products copy];
    
    [response.products enumerateObjectsUsingBlock:^(SKProduct * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",obj.localizedTitle);
        NSLog(@"%@",obj.localizedDescription);
        NSLog(@"%@",obj.price);
        NSLog(@"%@",obj.productIdentifier);
        NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
        [f setLocale:obj.priceLocale];
        [f setNumberStyle:NSNumberFormatterCurrencyPluralStyle];
        //        [f setCurrencyCode:obj.priceLocale.currencyCode];
        NSLog(@"%@",[f stringFromNumber:obj.price]);
    }];
}

- (void)anylsisTranstions:(NSArray<SKPaymentTransaction*>*)transactions
{
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@ %@ %@",obj.payment.productIdentifier,obj.transactionDate,obj.error);
        
        if (self.purchasedBlock) {
            self.purchasedBlock(obj);
        }
        switch (obj.transactionState) {
            case SKPaymentTransactionStateFailed:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:obj];
                NSLog(@"SKPaymentTransactionStateFailed");
                break;
            }
            case SKPaymentTransactionStateDeferred:
            {
                NSLog(@"SKPaymentTransactionStateDeferred");
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:obj];
                NSLog(@"SKPaymentTransactionStateRestored");
                break;
            }
            case SKPaymentTransactionStatePurchased:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:obj];
                NSLog(@"SKPaymentTransactionStatePurchased");
                break;
            }
            case SKPaymentTransactionStatePurchasing:
            {
                NSLog(@"SKPaymentTransactionStatePurchasing");
                break;
            }
            default:
                break;
        }
    }];
}

@end
