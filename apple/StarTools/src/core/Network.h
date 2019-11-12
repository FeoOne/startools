//
//  Network.h
//  StarTools
//
//  Created by Feo on 08/11/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Network : NSObject

-(void)startListen;
-(void)stopListen;

@end

NS_ASSUME_NONNULL_END
