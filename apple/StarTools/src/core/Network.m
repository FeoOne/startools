//
//  Network.m
//  StarTools
//
//  Created by Feo on 08/11/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core.h"
#import "FeedbackResponder.h"

#import "Network.h"

@implementation Network

-(void)startListen
{
	[[UIApplication sharedApplication] addObserver:self forKeyPath:@"networkActivityIndicatorVisible" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)stopListen
{
	[[UIApplication sharedApplication] removeObserver:self forKeyPath:@"networkActivityIndicatorVisible"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"networkActivityIndicatorVisible"]) {
        logmsg(@"Network activity indicator change!");
		
        BOOL active = [UIApplication sharedApplication].networkActivityIndicatorVisible;
		
		Feedback *feedback = [[Core feedbackHelper] getFeedback:@(kFeedbackKey_NetworkStateChanged)];
		if (feedback != nil) {
			[feedback respond:[FeedbackResponder buildNetworkStateChangedResponse:active]];
		} else {
			logmsg(@"Can't respond 'networkActivityIndicatorVisible'. Feedback not set.");
		}
    }
}

@end
