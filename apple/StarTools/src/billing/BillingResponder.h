//
//  BillingResponder.h
//  StarTools
//
//  Created by Feo on 02/09/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Product.h"

NS_ASSUME_NONNULL_BEGIN

@interface BillingResponder : NSObject

+(NSDictionary *)buildLaunchSuccessResponse:(NSDictionary<NSString *, Product *> *)products;
+(NSDictionary *)buildLaunchFailResponse:(NSError *)error;

+(NSDictionary *)buildPurchaseFailedResponse:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
