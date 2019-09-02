//
//  BillingResponder.m
//  StarTools
//
//  Created by Feo on 02/09/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "BillingResponder.h"

/*	Launch json keys
 */
// shared
static const NSString * const kCodeKey = @"Code";
static const NSString * const kMessageKey = @"Message";
// launch success
static const NSString * const kProductsKey = @"Products";
// purchase fail
static const NSString * const kIsCancelledKey = @"IsCancelled";

/*	Product json keys
 */
static const NSString * const kProductIdentifierKey = @"Identifier";
static const NSString * const kProductLocalizedDescriptionKey = @"LocalizedDescription";
static const NSString * const kProductLocalizedTitleKey = @"LocalizedTitle";
static const NSString * const kProductLocalizedPriceKey = @"LocalizedPrice";
static const NSString * const kProductPriceKey = @"Price";

@implementation BillingResponder

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
	return @{ kCodeKey: @(error.code), kMessageKey: error.localizedDescription };
}



+(NSDictionary *)buildPurchaseFailedResponse:(NSError *)error
{
	BOOL isCancelled = error.code == SKErrorPaymentCancelled;
	return @{ kCodeKey: @(error.code),
			  kMessageKey: error.localizedDescription,
			  kIsCancelledKey: @(isCancelled)
			  };
}

@end
