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

#pragma mark -

@implementation Core

#pragma mark - Billing

+(Billing *)billing
{
	static Billing *_billing;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_billing = [[Billing alloc] init];
	});
	
	return _billing;
}

#pragma mark - MessageCenter

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

+(void)sendMessageToManaged:(NSString *)message withParams:(nullable NSDictionary *)params
{
	__block NSString *_message = [[NSString alloc] initWithString:message];
	__block NSString *_json = nil;
	if (params != nil) {
		NSError *error = nil;
		NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
		if (error == nil) {
			_json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		} else {
			logmsg("Can't send message to managed. JSON serialization error: %@", error.localizedDescription);
		}
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([Core getMessageCenterDelegate] != NULL) {
			[Core getMessageCenterDelegate]([_message UTF8String], (_json != nil) ? [_json UTF8String] : NULL);
		}
	});
}

@end
