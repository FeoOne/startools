//
//  ApplicationStateListener.h
//  StarTools
//
//  Created by Feo on 08/11/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APPLICATIONSTATELISTENER	[ApplicationStateListener sharedApplicationStateListener]

NS_ASSUME_NONNULL_BEGIN

@interface ApplicationStateListener : NSObject

-(instancetype)init;

+(instancetype)sharedApplicationStateListener;

@end

NS_ASSUME_NONNULL_END
