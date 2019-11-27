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
#import "NetworkReachability.h"

#import "Network.h"

@interface Network ()
@property (nonatomic, strong) Reachability *reachability;
-(void)respond:(BOOL)isConnected;
@end

@implementation Network

-(instancetype)init
{
    if ((self = [super init])) {
        _reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
        
        DEF_WEAK_SELF;
        
        [_reachability setReachableBlock:^(Reachability *reachability) {
            DEF_STRONG_SELF;
            [strongSelf respond:YES];
        }];
        
        [_reachability setUnreachableBlock:^(Reachability *reachability) {
            DEF_STRONG_SELF;
            [strongSelf respond:NO];
        }];
    }
    return self;
}

-(void)startListen
{
    [_reachability startNotifier];
}

-(void)stopListen
{
    [_reachability stopNotifier];
}

-(void)respond:(BOOL)isConnected
{
    Feedback *feedback = [[Core feedbackHelper] getFeedback:@(kFeedbackKey_NetworkStateChanged)];
    if (feedback != nil) {
        [feedback respond:[FeedbackResponder buildNetworkStateChangedResponse:isConnected]];
    } else {
        logmsg(@"Can't respond 'networkActivityIndicatorVisible'. Feedback not set.");
    }
}

@end
