//
//  Facade.h
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#ifndef Facade_h
#define Facade_h

#import "Core.h"
#import "Feedback.h"

/*	MessageCenter.
 */
FOUNDATION_EXPORT void StarTools_RegisterMessageCenterDelegate(MessageCenterDelegate delegate);

/*	Feedback.
 */
FOUNDATION_EXPORT void StarTools_RegisterFeedbackDelegate(FeedbackDelegate delegate);

/*	Billing.
 */
FOUNDATION_EXPORT void StarTools_Billing_RegisterLaunchSucceededFeedback(ManagedAction action);
FOUNDATION_EXPORT void StarTools_Billing_RegisterLaunchFailedFeedback(ManagedAction action);
FOUNDATION_EXPORT void StarTools_Billing_RegisterPurchaseSucceededFeedback(ManagedAction action);
FOUNDATION_EXPORT void StarTools_Billing_RegisterPurchaseFailedFeedback(ManagedAction action);
FOUNDATION_EXPORT void StarTools_Billing_RegisterPurchaseRestoredFeedback(ManagedAction action);

FOUNDATION_EXPORT void StarTools_Billing_RegisterProduct(const char *identifier, int type);
FOUNDATION_EXPORT void StarTools_Billing_Launch(void);
FOUNDATION_EXPORT void StarTools_Billing_Purchase(const char *identifier);

#endif /* Facade_h */
