//
//  Billing.h
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Billing : NSObject

-(instancetype)init;

-(void)registerProductIdentifier:(NSString *)identifier andType:(NSInteger)type;
-(void)launch;
-(void)purchase:(NSString *)identifier;
-(void)restorePurchases;
-(BOOL)canMakePayments;

-(void)registerFeedback:(Feedback *)feedback forKey:(NSNumber *)key;

@end

NS_ASSUME_NONNULL_END
