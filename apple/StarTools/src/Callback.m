//
//  Callback.m
//  StarTools
//
//  Created by Feo on 14/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Callback.h"

typedef void (*CallbackDelegate)(UnityAction action, const char *data);

static CallbackDelegate _callbackDelegate = NULL;

void RegisterCallbackDelegate(CallbackDelegate callbackDelegate)
{
	_callbackDelegate = callbackDelegate;
}

void SendCallbackDataToUnity(UnityAction callback, NSDictionary *data)
{
	if (callback == NULL || _callbackDelegate == NULL) {
		return;
	}
	
	__block NSString *string = nil;
	
	if (data != nil) {
		NSError *error = nil;
		NSData *json = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
		if (error == nil) {
			string = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
		} else {
			NSLog(@"SendCallbackDataToUnity: can't parse json. Error: %@", [error localizedDescription]);
		}
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		_callbackDelegate(callback, [string UTF8String]);
	});
}
