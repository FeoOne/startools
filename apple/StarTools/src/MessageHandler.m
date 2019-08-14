//
//  MessageHandler.m
//  StarTools
//
//  Created by Feo on 13/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "MessageHandler.h"

static MessageDelegate _messageDelegate = NULL;

void RegisterMessageHandler(MessageDelegate delegate)
{
	_messageDelegate = delegate;
}

void SendMessageToUnity(NSString *message, NSString *data)
{
	__block NSString *_message = [[NSString alloc] initWithString:message];
	__block NSString *_data = [[NSString alloc] initWithString:data];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_messageDelegate != NULL) {
			_messageDelegate([_message UTF8String], [_data UTF8String]);
		}
	});
}
