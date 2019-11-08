//
//  FeedbackHelper.h
//  StarTools
//
//  Created by Feo on 08/11/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Feedback.h"

typedef enum {
	kFeedbackKey_LaunchSucceeded = 0,
	kFeedbackKey_LaunchFailed = 1,
	kFeedbackKey_PurchaseSucceeded = 2,
	kFeedbackKey_PurchaseRestored = 3,
	kFeedbackKey_PurchaseFailed = 4,
	kFeedbackKey_NetworkStateChanged = 5,
} FeedbackKey;

NS_ASSUME_NONNULL_BEGIN

@interface FeedbackHelper : NSObject

@end

NS_ASSUME_NONNULL_END
