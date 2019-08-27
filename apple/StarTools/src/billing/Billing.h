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

@interface Billing : NSObject

-(instancetype)init;

-(void)registerProductIdentifier:(NSString *)identifier;
-(void)launchWithSuccessFeedback:(Feedback *)successFeedback andFailFeedback:(Feedback *)failFeedback;

@end

NS_ASSUME_NONNULL_END
