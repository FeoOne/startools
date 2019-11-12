//
//  FeedbackHelper.m
//  StarTools
//
//  Created by Feo on 08/11/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import "Prefix.h"

#import "FeedbackHelper.h"

@interface FeedbackHelper ()

@property(strong, nonatomic) NSMutableDictionary<NSNumber *, Feedback *> *feedbacks;

@end

@implementation FeedbackHelper

#pragma mark - Setup

-(instancetype)init
{
	if ((self = [super init])) {
		_feedbacks = [NSMutableDictionary new];
	}
	return self;
}

#pragma mark - Feedback

-(void)registerFeedback:(Feedback *)feedback forKey:(NSNumber *)key
{
	@synchronized (self) {
		logmsg(@"Registering feedback for key: %@.", key);
		[_feedbacks setObject:feedback forKey:key];
	}
}

-(Feedback *)getFeedback:(NSNumber *)key
{
	return [_feedbacks objectForKey:key];
}

@end
