//
//  FeedbackResponder.m
//  StarTools
//
//  Created by Feo on 02/09/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Prefix.h"

#import "FeedbackResponder.h"

/*	Launch json keys
 */
// shared
static const NSString * const kCodeKey = @"Code";
static const NSString * const kMessageKey = @"Message";
static const NSString * const kIdentifierKey = @"Identifier";
// launch success
static const NSString * const kProductsKey = @"Products";
// purchase succeeded
static const NSString * const kReceiptKey = @"Receipt";
static const NSString * const kCurrencyCodeKey = @"CurrencyCode";
static const NSString * const kPriceKey = @"Price";
// purchase fail
static const NSString * const kIsCancelledKey = @"IsCancelled";
// network state
static const NSString * const kIsConnected = @"IsConnected";

/*	Product json keys
 */
static const NSString * const kProductLocalizedDescriptionKey = @"LocalizedDescription";
static const NSString * const kProductLocalizedTitleKey = @"LocalizedTitle";
static const NSString * const kProductLocalizedPriceKey = @"LocalizedPrice";
static const NSString * const kProductPriceKey = @"Price";
static const NSString * const kProductCurrencyCodeKey = @"CurrencyCode";

@implementation FeedbackResponder

+(NSDictionary *)buildLaunchSuccessResponse:(NSDictionary<NSString *, Product *> *)products
{
	NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:products.count];
	for (NSString *key in products) {
		SKProduct *product = [products[key] storeKitProduct];
		
		NSNumberFormatter *formatter = [NSNumberFormatter new];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[formatter setLocale:product.priceLocale];
		NSString *localizedPrice = [formatter stringFromNumber:product.price];
		
		float price = [product.price floatValue];
		
		[models addObject:@{ kIdentifierKey: product.productIdentifier,
							 kProductLocalizedDescriptionKey: product.localizedDescription,
							 kProductLocalizedTitleKey: product.localizedTitle,
							 kProductLocalizedPriceKey: localizedPrice,
							 kProductCurrencyCodeKey: [product.priceLocale objectForKey:NSLocaleCurrencyCode],
							 kProductPriceKey: @(price)
							 }];
	}
	
	return @{ kProductsKey: models };
}

+(NSDictionary *)buildLaunchFailResponse:(NSError *)error
{
	return @{ kCodeKey: @(error.code), kMessageKey: error.localizedDescription };
}

+(NSDictionary *)buildPurchaseSucceededResponse:(SKPaymentTransaction *)transaction product:(Product *)product
{
    NSData *data = [NSData dataWithContentsOfURL:[NSBUNDLE appStoreReceiptURL]];
    
	return @{
        kIdentifierKey: transaction.payment.productIdentifier,
        kReceiptKey: [data base64EncodedStringWithOptions:0],
        kCurrencyCodeKey: [product.storeKitProduct.priceLocale objectForKey:NSLocaleCurrencyCode],
        kPriceKey: @([product.storeKitProduct.price floatValue])
    };[product.storeKitProduct.price floatValue]
}

+(NSDictionary *)buildPurchaseRestoredResponse:(SKPaymentTransaction *)transaction
{
	return @{ kIdentifierKey: transaction.payment.productIdentifier };
}

+(NSDictionary *)buildPurchaseFailedResponse:(NSError *)error
{
	BOOL isCancelled = error.code == SKErrorPaymentCancelled;
	return @{ kCodeKey: @(error.code),
			  kMessageKey: error.localizedDescription,
			  kIsCancelledKey: @(isCancelled)
			  };
}

+(NSDictionary *)buildNetworkStateChangedResponse:(BOOL)isConnected
{
	return @{ kIsConnected: @(isConnected) };
}

@end
