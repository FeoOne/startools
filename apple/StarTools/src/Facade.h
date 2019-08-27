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
FOUNDATION_EXPORT void StarTools_Billing_RegisterProductIdentifier(const char *identifier);
FOUNDATION_EXPORT void StarTools_Billing_Launch(ManagedAction onSuccess, ManagedAction onFail);

#endif /* Facade_h */
