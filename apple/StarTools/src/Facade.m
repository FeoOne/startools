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
	[Core setMessageCenterDelegate:delegate];
}

#pragma mark - Feedback

void StarTools_RegisterFeedbackDelegate(FeedbackDelegate delegate)
{
	[Feedback setFeedbackDelegate:delegate];
}

#pragma mark - Billing

void StarTools_Billing_RegisterProductIdentifier(const char *identifier)
{
	if (identifier != NULL) {
		[[Core billing] registerProductIdentifier:[NSString stringWithUTF8String:identifier]];
	}
}

void StarTools_Billing_Launch(ManagedAction onSuccess, ManagedAction onFail)
{
	[[Core billing] launchWithSuccessFeedback:[Feedback newWithManagedAction:onSuccess] andFailFeedback:[Feedback newWithManagedAction:onFail]];
}
