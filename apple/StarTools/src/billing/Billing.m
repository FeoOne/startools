//
//  Billing.m
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Prefix.h"
#import "Product.h"
#import "BillingResponder.h"

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

-(void)_registerProductIdentifier:(NSString *)identifier andType:(NSInteger)type;
-(void)_launch;
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
		_products = [NSMutableDictionary new];
		
		_state = kLaunchState_NotLaunched;
		
		[SKPAYMENTQUEUE addTransactionObserver:self];
	}
	return self;
}

#pragma mark - Public

-(void)registerProductIdentifier:(NSString *)identifier andType:(NSInteger)type
{
	@synchronized (self) {
		[self _registerProductIdentifier:identifier andType:type];
	}
}

-(void)launch
{
	@synchronized (self) {
		[self _launch];
	}
}

-(void)purchase:(NSString *)identifier
{
	@synchronized (self) {
		[self _purchase:identifier];
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

-(void)_registerProductIdentifier:(NSString *)identifier andType:(NSInteger)type
{
	if (_state != kLaunchState_NotLaunched) {
		logmsg(@"[startools] Billing launched. Late to drink borjomi.");
		return;
	}
	
	Product *product = [_products objectForKey:identifier];
	if (product == nil) {
		product = [Product productWithIdentifier:identifier andType:(ProductType)type];
		[_products setObject:product forKey:identifier];
		
		logmsg(@"[startools] Added product identifier '%@'.", identifier);
	} else {
		logmsg(@"[startools] Product '%@' already added.", identifier);
	}
}

-(void)_launch
{
	if (_state != kLaunchState_NotLaunched) {
		logmsg(@"[startools] Billing already launched.");
		return;
	}
	
	_state = kLaunchState_InProgress;
	
	DEF_WEAK_SELF;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		DEF_STRONG_SELF;
		
		logmsg(@"[startools] Billing launch started...");
		
		NSSet *identifiers = [NSSet setWithArray:[strongSelf.products allKeys]];
		SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
		[request setDelegate:strongSelf];
		[request start];
	});
}

-(void)_purchase:(NSString *)identifier
{
	if (_state != kLaunchState_Launched) {
		logmsg(@"[startools] Billing did not launched.");
		return;
	}
	
	Product *product = _products[identifier];
	if (product == nil || product.storeKitProduct == nil) {
		logmsg(@"[startools] Can't purchase product '%@'. Identifier not found or StoreKit product doesn't assigned.", identifier);
		return;
	}
	
	SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product.storeKitProduct];
	[SKPAYMENTQUEUE addPayment:payment];
}

-(void)_restorePurchases
{
	if (_state != kLaunchState_Launched) {
		logmsg(@"[startools] Billing did not launched.");
		return;
	}
	
	[SKPAYMENTQUEUE restoreCompletedTransactions];
}

-(BOOL)_canMakePayments
{
	return [SKPaymentQueue canMakePayments];
}

#pragma mark - Payment Transaction

-(void)onPaymentTransactionPurchased:(SKPaymentTransaction *)transaction
{
	logmsg(@"[startools] Purchase '%@' succeeded.", transaction.payment.productIdentifier);
	
	[SKPAYMENTQUEUE finishTransaction:transaction];
	
	Feedback *feedback = [_feedbacks objectForKey:@(kFeedbackKey_PurchaseSucceeded)];
	if (feedback != nil) {
		[feedback respond:[BillingResponder buildPurchaseSucceededResponse:transaction]];
	} else {
		logmsg(@"[startools] Can't respond OnPaymentTransactionPurchased. Feedback not set.");
	}
}

-(void)onPaymentTransactionRestored:(SKPaymentTransaction *)transaction
{
	logmsg(@"[startools] Purchase '%@' restored.", transaction.payment.productIdentifier);
	
	[SKPAYMENTQUEUE finishTransaction:transaction];
	
	Feedback *feedback = [_feedbacks objectForKey:@(kFeedbackKey_PurchaseRestored)];
	if (feedback != nil) {
		[feedback respond:[BillingResponder buildPurchaseRestoredResponse:transaction]];
	} else {
		logmsg(@"[startools] Can't respond OnPaymentTransactionRestored. Feedback not set.");
	}
}

-(void)onPaymentTransactionFailed:(SKPaymentTransaction *)transaction
{
	logmsg(@"[startools] Purchase '%@' failed.", transaction.payment.productIdentifier);
	
	[SKPAYMENTQUEUE finishTransaction:transaction];
	
	NSError *error = transaction.error;
	if (error == nil) {
		logmsg(@"[startools] OnPaymentTransactionFailed internal error.");
		error = [NSError errorWithDomain:StarToolsErrorDomain code:-1 userInfo:nil];
	}
	
	Feedback *feedback = [_feedbacks objectForKey:@(kFeedbackKey_PurchaseFailed)];
	if (feedback != nil) {
		[feedback respond:[BillingResponder buildPurchaseFailedResponse:error]];
	} else {
		logmsg(@"[startools] Can't respond OnPaymentTransactionFailed. Feedback not set.");
	}
}

#pragma mark - SKPaymentTransactionObserver

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchasing: {
				logmsg(@"[startools] SKPaymentTransactionStatePurchasing");
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
	logmsg(@"[startools] Purchases restored with error: %@", error.localizedDescription);
	// todo
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	logmsg(@"[startools] Purchases restored successfully.");
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
	
	logmsg(@"[startools] Start succeded. Received product count: %u, existing product count: %u.",
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
		logmsg(@"[startools] Invalid product identifier: '%@'.", identifier);
		[_products removeObjectForKey:identifier];
	}
	
	Feedback *feedback = [_feedbacks objectForKey:@(kFeedbackKey_LaunchSucceeded)];
	if (feedback != nil) {
		[feedback respond:[BillingResponder buildLaunchSuccessResponse:_products]];
	} else {
		logmsg(@"[startools] Can't respond OnLaunchSucceeded. Feedback not set.");
	}
	
	_state = kLaunchState_Launched;
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	Feedback *feedback = [_feedbacks objectForKey:@(kFeedbackKey_LaunchFailed)];
	if (feedback != nil) {
		[feedback respond:[BillingResponder buildLaunchFailResponse:error]];
	} else {
		logmsg(@"[startools] Can't respond OnLaunchFailed. Feedback not set.");
	}
	
	_state = kLaunchState_NotLaunched;
}

-(void)requestDidFinish:(SKRequest *)request
{
	logmsg(@"[startools] Billing launch finished.");
}

@end
