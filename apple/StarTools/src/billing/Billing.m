//
//  Billing.m
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Core.h"
#import "Prefix.h"
#import "Product.h"
#import "FeedbackResponder.h"

#import "Billing.h"

typedef enum {
	kLaunchState_NotLaunched = 0,
	kLaunchState_InProgress,
	kLaunchState_Launched,
} LaunchState;

NSString * const StarToolsErrorDomain = @"com.feosoftware.startools";

@interface Billing () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property(strong, nonatomic) NSMutableDictionary<NSString *, Product *> *products;

@property(nonatomic, assign) LaunchState state;

-(void)_tryRegisterProductIdentifier:(NSString *)identifier andType:(NSInteger)type;
-(void)_registerProductIdentifier:(NSString *)identifier andType:(NSInteger)type;
-(void)_tryLaunch;
-(void)_launch;
-(void)_tryPurchase:(NSString *)identifier;
-(void)_purchase:(NSString *)identifier;
-(void)_restorePurchases;
-(BOOL)_canMakePayments;

-(void)onPaymentTransactionPurchased:(SKPaymentTransaction *)transaction;
-(void)onPaymentTransactionRestored:(SKPaymentTransaction *)transaction;
-(void)onPaymentTransactionFailed:(SKPaymentTransaction *)transaction;

@end

@implementation Billing

#pragma mark - Setup

-(instancetype)init
{
	if ((self = [super init])) {
		[self setState:kLaunchState_NotLaunched];
		
		_products = [NSMutableDictionary new];
		
		[SKPAYMENTQUEUE addTransactionObserver:self];
	}
	return self;
}

#pragma mark - Public

-(void)registerProductIdentifier:(NSString *)identifier andType:(NSInteger)type
{
	@synchronized (self) {
		[self _tryRegisterProductIdentifier:identifier andType:type];
	}
}

-(void)launch
{
	@synchronized (self) {
		[self _tryLaunch];
	}
}

-(void)purchase:(NSString *)identifier
{
	@synchronized (self) {
		[self _tryPurchase:identifier];
	}
}

-(void)restorePurchases
{
	@synchronized (self) {
		[self _restorePurchases];
	}
}

-(BOOL)canMakePayments
{
	@synchronized (self) {
		return [self _canMakePayments];
	}
}

#pragma mark - Private

-(void)_tryRegisterProductIdentifier:(NSString *)identifier andType:(NSInteger)type
{
	if (_state != kLaunchState_NotLaunched) {
		logmsg(@"Can't register product identifier: already launched.");
	} else {
		[self _registerProductIdentifier:identifier andType:type];
	}
}

-(void)_registerProductIdentifier:(NSString *)identifier andType:(NSInteger)type
{
	Product *product = [_products objectForKey:identifier];
	if (product == nil) {
		product = [Product productWithIdentifier:identifier andType:(ProductType)type];
		[_products setObject:product forKey:identifier];
		logmsg(@"Added product identifier '%@'.", identifier);
	} else {
		logmsg(@"Product '%@' already added.", identifier);
	}
}

-(void)_tryLaunch
{
	if (_state != kLaunchState_NotLaunched) {
		logmsg(@"Can't launch billing: already launched.");
	} else {
		[self _launch];
	}
}

-(void)_launch
{
	_state = kLaunchState_InProgress;
	
	DEF_WEAK_SELF;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		DEF_STRONG_SELF;
		
		logmsg(@"Billing launch started...");
		
		NSSet *identifiers = [NSSet setWithArray:[strongSelf.products allKeys]];
		SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
		[request setDelegate:strongSelf];
		[request start];
	});
}

-(void)_tryPurchase:(NSString *)identifier
{
	if (_state != kLaunchState_Launched) {
		logmsg(@"Billing did not launched.");
	} else {
		[self _purchase:identifier];
	}
}

-(void)_purchase:(NSString *)identifier
{
	Product *product = _products[identifier];
	if (product != nil && product.storeKitProduct != nil) {
		SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product.storeKitProduct];
		[SKPAYMENTQUEUE addPayment:payment];
	} else {
		logmsg(@"Can't purchase product '%@'. Identifier not found or StoreKit product doesn't assigned.", identifier);
	}
}

-(void)_restorePurchases
{
	if (_state == kLaunchState_Launched) {
		[SKPAYMENTQUEUE restoreCompletedTransactions];
	} else {
		logmsg(@"Billing did not launched.");
	}
}

-(BOOL)_canMakePayments
{
	return [SKPaymentQueue canMakePayments];
}

#pragma mark - Payment Transaction

-(void)onPaymentTransactionPurchased:(SKPaymentTransaction *)transaction
{
	logmsg(@"Purchase '%@' succeeded.", transaction.payment.productIdentifier);
	
	[SKPAYMENTQUEUE finishTransaction:transaction];
	
	FEEDBACK_RESPOND(kFeedbackKey_PurchaseSucceeded, [FeedbackResponder buildPurchaseSucceededResponse:transaction])
}

-(void)onPaymentTransactionRestored:(SKPaymentTransaction *)transaction
{
	logmsg(@"Purchase '%@' restored.", transaction.payment.productIdentifier);
	
	[SKPAYMENTQUEUE finishTransaction:transaction];
	
	FEEDBACK_RESPOND(kFeedbackKey_PurchaseRestored, [FeedbackResponder buildPurchaseRestoredResponse:transaction])
}

-(void)onPaymentTransactionFailed:(SKPaymentTransaction *)transaction
{
	logmsg(@"Purchase '%@' failed.", transaction.payment.productIdentifier);
	
	[SKPAYMENTQUEUE finishTransaction:transaction];
	
	NSError *error = transaction.error;
	if (error == nil) {
		logmsg(@"OnPaymentTransactionFailed internal error.");
		error = [NSError errorWithDomain:StarToolsErrorDomain code:-1 userInfo:nil];
	}
	
	FEEDBACK_RESPOND(kFeedbackKey_PurchaseFailed, [FeedbackResponder buildPurchaseFailedResponse:error])
}

#pragma mark - SKPaymentTransactionObserver

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchasing: {
				logmsg(@"SKPaymentTransactionStatePurchasing");
				break;
			}
			case SKPaymentTransactionStateDeferred: {
				// Do not block your UI. Allow the user to continue using your app.
				break;
			}
			case SKPaymentTransactionStatePurchased: {
				[self onPaymentTransactionPurchased:transaction];
				break;
			}
			case SKPaymentTransactionStateRestored: {
				[self onPaymentTransactionRestored:transaction];
				break;
			}
			case SKPaymentTransactionStateFailed: {
				[self onPaymentTransactionFailed:transaction];
				break;
			}
		}
	}
}

-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
	// todo
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	logmsg(@"Purchases restored with error: %@", error.localizedDescription);
	// todo
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	logmsg(@"Purchases restored successfully.");
	// todo
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads
{
	// todo
}

-(BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product
{
	return YES;
}

#pragma mark - SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	uint32_t receivedProductCount = (uint32_t)response.products.count;
	uint32_t existingProductCount = (uint32_t)_products.count;
	
	logmsg(@"Start succeded. Received product count: %u, existing product count: %u.",
		   receivedProductCount,
		   existingProductCount);
	
	// fill products
	for (SKProduct *storeKitProduct in response.products) {
		Product *product = [_products objectForKey:storeKitProduct.productIdentifier];
		if (product != nil) {
			[product setStoreKitProduct:storeKitProduct];
		}
	}
	
	// check invalid identifiers
	for (NSString *identifier in response.invalidProductIdentifiers) {
		logmsg(@"Invalid product identifier: '%@'.", identifier);
		[_products removeObjectForKey:identifier];
	}
	
	FEEDBACK_RESPOND(kFeedbackKey_LaunchSucceeded, [FeedbackResponder buildLaunchSuccessResponse:_products])
	
	_state = kLaunchState_Launched;
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	logmsg(@"Launch failed: %@", error.localizedDescription);
	
	FEEDBACK_RESPOND(kFeedbackKey_LaunchFailed, [FeedbackResponder buildLaunchFailResponse:error])
	
	_state = kLaunchState_NotLaunched;
}

-(void)requestDidFinish:(SKRequest *)request
{
	logmsg(@"Billing launch finished.");
}

@end
