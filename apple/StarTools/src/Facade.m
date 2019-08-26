//
//  Facade.m
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Facade.h"

#pragma mark - MessageCenter

void RegisterMessageCenterDelegate(MessageCenterDelegate delegate)
{
	[Core setMessageCenterDelegate:delegate];
}

#pragma mark - Feedback

void RegisterFeedbackDelegate(FeedbackDelegate delegate)
{
	[Feedback setFeedbackDelegate:delegate];
}

#pragma mark - Billing

void BillingRegisterProductIdentifier(const char *identifier)
{
	if (identifier != NULL) {
		[[Core billing] registerProductIdentifier:[NSString stringWithUTF8String:identifier]];
	}
}

void BillingStart(ManagedAction action)
{
	if (action != NULL) {
		[[Core billing] startWithFeedback:[[Feedback alloc] initWithUnityAction:action]];
	}
}
