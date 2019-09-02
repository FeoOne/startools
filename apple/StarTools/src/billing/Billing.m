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

NSString * const kLaunchSucceededKey 		= @"launch-succeeded";
NSString * const kLaunchFailedKey 			= @"launch-failed";
NSString * const kPurchaseSucceededKey 		= @"purchase-succeeded";
NSString * const kPurchaseFailedKey 		= @"purchase-failed";
NSString * const kPurchaseRestoredKey 		= @"purchase-restored";

@interface Billing () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
}

@property(strong, nonatomic) NSMutableDictionary<NSString *, Product *> *products;
@property(strong, nonatomic) NSMutableDictionary<NSString *, Feedback *> *feedbacks;

@property(nonatomic, assign) LaunchState state;

-(void)_registerProductIdentifier:(NSString *)identifier andType:(NSInteger)type;
-(void)_launch;
-(void)_purchase:(NSString *)identifier;
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
		_feedbacks = [NSMutableDictionary new];
		
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

-(BOOL)canMakePayments
{
	@synchronized (self) {
		return [self _canMakePayments];
	}
}

#pragma mark - Private

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

-(void)_launch
{
	if (_state != kLaunchState_NotLaunched) {
		logmsg(@"Billing already launched.");
		return;
	}
	
	if ([_feedbacks objectForKey:kLaunchSucceededKey] == nil || [_feedbacks objectForKey:kLaunchFailedKey] == nil) {
		logmsg(@"Launch feedbacks did not set.");
		return;
	}
	
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

-(void)_purchase:(NSString *)identifier
{
	if (_state != kLaunchState_Launched) {
		logmsg(@"Billing did not launched.");
		return;
	}
	
	if ([_feedbacks objectForKey:kPurchaseSucceededKey] == nil || [_feedbacks objectForKey:kPurchaseFailedKey] == nil) {
		logmsg(@"Purchase feedbacks did not set.");
		return;
	}
	
	Product *product = _products[identifier];
	if (product == nil || product.storeKitProduct == nil) {
		logmsg(@"Can't purchase product '%@'. Identifier not found or StoreKit product doesn't assigned.", identifier);
		return;
	}
	
	SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product.storeKitProduct];
	[SKPAYMENTQUEUE addPayment:payment];
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
	
	Product *product = [_products objectForKey:transaction.payment.productIdentifier];
	
	
	
	
}

-(void)onPaymentTransactionRestored:(SKPaymentTransaction *)transaction
{
	
}

-(void)onPaymentTransactionFailed:(SKPaymentTransaction *)transaction
{
	NSError *error = transaction.error;
	if (error == nil) {
		logmsg(@"OnPaymentTransactionFailed internal error.");
		error = [NSError errorWithDomain:StarToolsErrorDomain code:-1 userInfo:nil];
	}
	
	Feedback *feedback = [_feedbacks objectForKey:kPurchaseFailedKey];
	[feedback respond:[BillingResponder buildPurchaseFailedResponse:error]];
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
	
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads
{
	
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
	
	logmsg(@"[Billing] Start succeded. Received product count: %u, existing product count: %u.",
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
	
	Feedback *feedback = [_feedbacks objectForKey:kLaunchSucceededKey];
	[feedback respond:[BillingResponder buildLaunchSuccessResponse:_products]];
	
	_state = kLaunchState_Launched;
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	Feedback *feedback = [_feedbacks objectForKey:kLaunchFailedKey];
	[feedback respond:[BillingResponder buildLaunchFailResponse:error]];
	
	_state = kLaunchState_NotLaunched;
}

-(void)requestDidFinish:(SKRequest *)request
{
	logmsg(@"Billing launch finished.");
}

#pragma mark - Feedbacks

-(void)registerFeedback:(Feedback *)feedback forKey:(NSString *)key
{
	[_feedbacks setObject:feedback forKey:key];
}

@end
