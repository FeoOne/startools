//
//  MessageHandler.h
//  StarTools
//
//  Created by Feo on 13/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (*MessageDelegate)(const char *message, const char *data);

FOUNDATION_EXPORT void RegisterMessageHandler(MessageDelegate delegate);

NS_ASSUME_NONNULL_END
