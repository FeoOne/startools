//
//  FeedbackResponder.h
//  StarTools
//
//  Created by Feo on 02/09/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Product.h"

NS_ASSUME_NONNULL_BEGIN

@interface FeedbackResponder : NSObject

+(NSDictionary *)buildLaunchSuccessResponse:(NSDictionary<NSString *, Product *> *)products;
+(NSDictionary *)buildLaunchFailResponse:(NSError *)error;
+(NSDictionary *)buildPurchaseSucceededResponse:(SKPaymentTransaction *)transaction product:(Product *)product;
+(NSDictionary *)buildPurchaseRestoredResponse:(SKPaymentTransaction *)transaction;
+(NSDictionary *)buildPurchaseFailedResponse:(NSError *)error;

+(NSDictionary *)buildNetworkStateChangedResponse:(BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END
