//
//  Feedback.m
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Prefix.h"

#import "Feedback.h"

@interface Feedback ()

@end

@implementation Feedback

+(instancetype)newWithManagedAction:(ManagedAction)action;
{
	return [[Feedback alloc] initWithManagedAction:action];
}

-(instancetype)initWithManagedAction:(ManagedAction)action
{
	if ((self = [super init])) {
		_action = action;
	}
	return self;
}

-(void)respond:(NSDictionary *)params
{
	if (_action == NULL) {
		logmsg(@"[Feedback] Can't respond with NULL action.");
		return;
	}
	
	__block NSString *json = nil;
	
	if (params != nil) {
		NSError *error = nil;
		NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
		if (error == nil) {
			json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		} else {
			logmsg("Can't respond. JSON serialization error: %@", error.localizedDescription);
		}
	}
	
	DEF_WEAK_SELF;
	dispatch_async(dispatch_get_main_queue(), ^{
		DEF_STRONG_SELF;
		if ([Feedback getFeedbackDelegate] != NULL) {
			[Feedback getFeedbackDelegate](strongSelf.action, (json != nil) ? [json cStringUsingEncoding:NSUTF8StringEncoding] : NULL);
		}
	});
}

#pragma mark - FeedbackDelegate

static FeedbackDelegate _feedbackDelegate = NULL;

+(FeedbackDelegate)getFeedbackDelegate
{
	@synchronized (self) {
		return _feedbackDelegate;
	}
}

+(void)setFeedbackDelegate:(FeedbackDelegate)feedbackDelegate
{
	@synchronized (self) {
		_feedbackDelegate = feedbackDelegate;
	}
}

@end
