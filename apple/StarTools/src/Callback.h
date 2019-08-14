//
//  Callback.h
//  StarTools
//
//  Created by Feo on 14/08/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef const void *UnityAction;

void SendCallbackDataToUnity(UnityAction callback, NSDictionary *data);

NS_ASSUME_NONNULL_END
