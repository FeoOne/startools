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
FOUNDATION_EXPORT void StarTools_Billing_RegisterFeedback(int32_t key, ManagedAction action);

FOUNDATION_EXPORT void StarTools_Billing_RegisterProduct(const char *identifier, int32_t type);
FOUNDATION_EXPORT void StarTools_Billing_Launch(void);
FOUNDATION_EXPORT void StarTools_Billing_Purchase(const char *identifier);
FOUNDATION_EXPORT void StarTools_Billing_RestorePurchases(void);
FOUNDATION_EXPORT bool StarTools_Billing_CanMakePurchases(void);

#endif /* Facade_h */
