//
//  Billing.h
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "Feedback.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kLaunchSucceededKey;
extern NSString * const kLaunchFailedKey;
extern NSString * const kPurchaseSucceededKey;
extern NSString * const kPurchaseFailedKey;
extern NSString * const kPurchaseRestoredKey;

@interface Billing : NSObject

-(instancetype)init;

-(void)registerProductIdentifier:(NSString *)identifier andType:(NSInteger)type;
-(void)launch;
-(void)purchase:(NSString *)identifier;
-(BOOL)canMakePayments;

-(void)registerFeedback:(Feedback *)feedback forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
