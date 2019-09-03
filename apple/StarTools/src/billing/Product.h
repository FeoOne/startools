//
//  Product.h
//  StarTools
//
//  Created by Feo on 02/09/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
	kConsumable = 1,
	kNonConsumable = 2,
	kSubscription = 4,
} ProductType;

@interface Product : NSObject

@property(nonatomic, readonly) NSString *identifier;
@property(nonatomic, readonly) ProductType type;

@property(nonatomic, retain) SKProduct *storeKitProduct;

-(instancetype)initWithIdentifier:(NSString *)identifier andType:(ProductType)type;

+(instancetype)productWithIdentifier:(NSString *)identifier andType:(ProductType)type;

@end

NS_ASSUME_NONNULL_END
