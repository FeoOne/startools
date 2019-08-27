//
//  Billing.m
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Prefix.h"

#import "Billing.h"

/*	Launch feedback keys
 */
static const NSString * const kSuccessFeedbackKey = @"success";
static const NSString * const kFailFeedbackKey = @"fail";

/*	Launch json keys
 */
// success
static const NSString * const kProductsKey = @"Products";
// fail
static const NSString * const kMessageKey = @"Message";

/*	Product json keys
 */
static const NSString * const kProductIdentifierKey = @"Identifier";
static const NSString * const kProductLocalizedDescriptionKey = @"LocalizedDescription";
static const NSString * const kProductLocalizedTitleKey = @"LocalizedTitle";
static const NSString * const kProductLocalizedPriceKey = @"LocalizedPrice";
static const NSString * const kProductPriceKey = @"Price";

@interface Billing () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
}

@property(strong, nonatomic) NSMutableSet<NSString *> *identifiers;
@property(strong, nonatomic) NSDictionary<NSString *, SKProduct *> *products;

@property(strong, nonatomic) NSMapTable<SKRequest *, NSDictionary *> *startFeedbacks;

+(NSDictionary *)buildLaunchSuccessResponse:(NSDictionary<NSString *, SKProduct *> *)products;
+(NSDictionary *)buildLaunchFailResponse:(NSError *)error;

@end

@implementation Billing

#pragma mark - Setup

-(instancetype)init
{
	if ((self = [super init])) {
		_identifiers = [NSMutableSet new];
		_startFeedbacks = [NSMapTable new];
		
		[SKPAYMENTQUEUE addTransactionObserver:self];
	}
	return self;
}

#pragma mark - Public

-(void)registerProductIdentifier:(NSString *)identifier
{
	[_identifiers addObject:identifier];
	
	logmsg("[Billing] Added product identifier '%@'.", identifier);
}

-(void)launchWithSuccessFeedback:(Feedback *)successFeedback andFailFeedback:(Feedback *)failFeedback
{
	DEF_WEAK_SELF;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		DEF_STRONG_SELF;
		
		logmsg("[Billing] Launch initiated...");
		
		SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:strongSelf.identifiers];
		[strongSelf.startFeedbacks setObject:@{ kSuccessFeedbackKey: successFeedback, kFailFeedbackKey: failFeedback } forKey:request];
		[request setDelegate:strongSelf];
		[request start];
	});
}

#pragma mark - Private



#pragma mark - SKPaymentTransactionObserver

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
	
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
	NSDictionary *feedbacks = [_startFeedbacks objectForKey:request];
	if (feedbacks != nil) {
		NSInteger count = response.products.count;
		
		logmsg(@"[Billing] Start succeded. Product count: %ld.", count);
		
		NSMutableDictionary<NSString *, SKProduct *> *products = [[NSMutableDictionary alloc] initWithCapacity:count];
		for (SKProduct *product in response.products) {
			[products setObject:product forKey:product.productIdentifier];
		}
		
		_products = [[NSDictionary alloc] initWithDictionary:products];
		
		[feedbacks[kSuccessFeedbackKey] respond:[[self class] buildLaunchSuccessResponse:_products]];
	} else {
		logmsg(@"[Billing] Success start response with undefined feedbacks.");
	}
}

-(void)requestDidFinish:(SKRequest *)request
{
	[_startFeedbacks removeObjectForKey:request]; // important to forget request
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	NSDictionary *feedbacks = [_startFeedbacks objectForKey:request];
	if (feedbacks != nil) {
		[feedbacks[kFailFeedbackKey] respond:[[self class] buildLaunchFailResponse:error]];
	}
}

#pragma mark - Response Building

+(NSDictionary *)buildLaunchSuccessResponse:(NSDictionary<NSString *, SKProduct *> *)products
{
	NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:products.count];
	for (NSString *key in products) {
		SKProduct *product = products[key];
		
		NSNumberFormatter *formatter = [NSNumberFormatter new];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[formatter setLocale:product.priceLocale];
		NSString *localizedPrice = [formatter stringFromNumber:product.price];
		
		float price = [product.price floatValue];
		
		[models addObject:@{ kProductIdentifierKey: product.productIdentifier,
							 kProductLocalizedDescriptionKey: product.localizedDescription,
							 kProductLocalizedTitleKey: product.localizedTitle,
							 kProductLocalizedPriceKey: localizedPrice,
							 kProductPriceKey: @(price)
							 }];
	}
	
	return @{ kProductsKey: models };
}

+(NSDictionary *)buildLaunchFailResponse:(NSError *)error
{
	return @{ kMessageKey: error.localizedDescription };
}

@end
