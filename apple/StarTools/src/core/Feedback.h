//
//  Feedback.h
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef const void *ManagedAction;

typedef void (*FeedbackDelegate)(ManagedAction action, const char *data);

@interface Feedback : NSObject

@property(nonatomic, readonly) ManagedAction action;

-(instancetype)initWithManagedAction:(ManagedAction)action;
-(void)respond:(nullable NSDictionary *)params;

+(instancetype)feedbackWithManagedAction:(ManagedAction)action;

+(FeedbackDelegate)getFeedbackDelegate;
+(void)setFeedbackDelegate:(FeedbackDelegate)feedbackDelegate;

@end

NS_ASSUME_NONNULL_END
