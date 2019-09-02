//
//  Facade.m
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Facade.h"

#pragma mark - MessageCenter

void StarTools_RegisterMessageCenterDelegate(MessageCenterDelegate delegate)
{
	logmsg(@"StarTools_RegisterMessageCenterDelegate(%p)", delegate);
	
	[Core setMessageCenterDelegate:delegate];
}

#pragma mark - Feedback

void StarTools_RegisterFeedbackDelegate(FeedbackDelegate delegate)
{
	logmsg(@"StarTools_RegisterFeedbackDelegate(%p)", delegate);
	
	[Feedback setFeedbackDelegate:delegate];
}

#pragma mark - Billing

void StarTools_Billing_RegisterLaunchSucceededFeedback(ManagedAction action)
{
	if (action != NULL) {
		[[Core billing] registerFeedback:[Feedback feedbackWithManagedAction:action] forKey:kLaunchSucceededKey];
	}
}

void StarTools_Billing_RegisterLaunchFailedFeedback(ManagedAction action)
{
	if (action != NULL) {
		[[Core billing] registerFeedback:[Feedback feedbackWithManagedAction:action] forKey:kLaunchFailedKey];
	}
}

void StarTools_Billing_RegisterPurchaseSucceededFeedback(ManagedAction action)
{
	if (action != NULL) {
		[[Core billing] registerFeedback:[Feedback feedbackWithManagedAction:action] forKey:kPurchaseSucceededKey];
	}
}

void StarTools_Billing_RegisterPurchaseFailedFeedback(ManagedAction action)
{
	if (action != NULL) {
		[[Core billing] registerFeedback:[Feedback feedbackWithManagedAction:action] forKey:kPurchaseFailedKey];
	}
}

void StarTools_Billing_RegisterPurchaseRestoredFeedback(ManagedAction action)
{
	
}

void StarTools_Billing_RegisterProduct(const char *identifier, int type)
{
	if (identifier != NULL) {
		[[Core billing] registerProductIdentifier:[NSString stringWithUTF8String:identifier] andType:type];
	}
}

void StarTools_Billing_Launch(void)
{
	[[Core billing] launch];
}

void StarTools_Billing_Purchase(const char *identifier)
{
	if (identifier != NULL) {
		[[Core billing] purchase:[NSString stringWithUTF8String:identifier]];
	}
}
