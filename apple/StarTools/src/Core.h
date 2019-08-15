//
//  Core.h
//  StarTools
//
//  Created by Feo on 15/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (*MessageCenterDelegate)(const char *message, const char *data);

@interface Core : NSObject

+(MessageCenterDelegate)getMessageCenterDelegate;
+(void)setMessageCenterDelegate:(MessageCenterDelegate)messageCenterDelegate;

@end

NS_ASSUME_NONNULL_END
