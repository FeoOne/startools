//
//  Core.m
//  StarTools
//
//  Created by Feo on 15/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Core.h"

@interface Core ()
@end

#pragma mark - core

FOUNDATION_EXPORT void RegisterMessageCenterDelegate(MessageCenterDelegate delegate)
{
	[Core setMessageCenterDelegate:delegate];
}

#pragma mark - implementation

@implementation Core

#pragma mark - private

#pragma mark - public

static MessageCenterDelegate _messageCenterDelegate = NULL;

+(MessageCenterDelegate)getMessageCenterDelegate
{
	@synchronized (self) {
		return _messageCenterDelegate;
	}
}

+(void)setMessageCenterDelegate:(MessageCenterDelegate)messageCenterDelegate
{
	@synchronized (self) {
		_messageCenterDelegate = messageCenterDelegate;
	}
}

@end
