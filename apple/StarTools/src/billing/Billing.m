//
//  Billing.m
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Prefix.h"

#import "Billing.h"

#define logmsg_(format, ...)	logmsg("[Billing] " format, ##__VA_ARGS__)

@interface Billing () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
}

@property(strong, nonatomic) NSMutableSet<NSString *> *identifiers;
@property(strong, nonatomic) NSMutableDictionary<NSString *, SKProduct *> *products;
@property(strong, nonatomic) NSMapTable<SKRequest *, Feedback *> *startRequests;

@end

@implementation Billing

#pragma mark - Setup

-(instancetype)init
{
	if ((self = [super init])) {
		_identifiers = [NSMutableSet new];
		_startRequests = [NSMapTable new];
		
		[SKPAYMENTQUEUE addTransactionObserver:self];
	}
	return self;
}

#pragma mark - Public

-(void)registerProductIdentifier:(NSString *)identifier
{
	[_identifiers addObject:identifier];
	
	logmsg_("Added identifier '%@'.", identifier);
}

-(void)startWithFeedback:(Feedback *)feedback
{
	logmsg("Starting billing...");
	
	DEF_WEAK_SELF;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		DEF_STRONG_SELF;
		SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:strongSelf.identifiers];
		[strongSelf.startRequests setObject:feedback forKey:request];
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
	Feedback *feedback = [_startRequests objectForKey:request];
	if (feedback != nil) {
		// todo: implement
		[_startRequests removeObjectForKey:request];
	}
}

-(void)requestDidFinish:(SKRequest *)request
{
	// todo: understand why and for what
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	Feedback *feedback = [_startRequests objectForKey:request];
	if (feedback != nil) {
		[feedback respond:@{@"Success": @(NO),
							@"Error": error.localizedDescription,
							@"Products": @{},
							}];
		[_startRequests removeObjectForKey:request];
	}
}

@end
