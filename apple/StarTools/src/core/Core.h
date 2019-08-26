//
//  Core.h
//  StarTools
//
//  Created by Feo on 15/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Prefix.h"
#import "Billing.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (*MessageCenterDelegate)(const char *message, const char *json);

@interface Core : NSObject

/*	Billing control.
 */
+(Billing *)billing;

/*	MessageCenter control.
 */
+(MessageCenterDelegate)getMessageCenterDelegate;
+(void)setMessageCenterDelegate:(MessageCenterDelegate)messageCenterDelegate;
+(void)sendMessageToManaged:(NSString *)message withParams:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
