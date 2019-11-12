//
//  Prefix.h
//  StarTools
//
//  Created by Feo on 26/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#ifndef Prefix_h
#define Prefix_h

#define DEF_WEAK_SELF			__typeof(self) __weak weakSelf = self
#define DEF_STRONG_SELF			__typeof(self) strongSelf = weakSelf

#define SKPAYMENTQUEUE			[SKPaymentQueue defaultQueue]
#define NSNOTIFICATIONCENTER	[NSNotificationCenter defaultCenter]

#ifndef NDEBUG
#	define logmsg(format, ...)	NSLog(@"[StarTools] " format, ##__VA_ARGS__)
#else
#	define logmsg(format, ...)
#endif

#endif /* Prefix_h */
