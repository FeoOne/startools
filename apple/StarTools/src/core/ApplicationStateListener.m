//
//  ApplicationStateListener.m
//  StarTools
//
//  Created by Feo on 08/11/2019.
//  Copyright © 2019 FeoSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Core.h"

#import "ApplicationStateListener.h"

@interface ApplicationStateListener ()
@end

@implementation ApplicationStateListener

#pragma mark - Setup

-(instancetype)init
{
	if ((self = [super init])) {
		[NSNOTIFICATIONCENTER addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
		[NSNOTIFICATIONCENTER addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
		
		logmsg(@"ApplicationStateListener instantiated.");
	}
	return self;
}

-(void)dealloc
{
	[NSNOTIFICATIONCENTER removeObserver:self];
}

#pragma mark - AppDelegateListener

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	[[Core network] startListen];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
	[[Core network] stopListen];
}

#pragma mark - Singleton

static ApplicationStateListener *_instance = NULL;

__attribute__((constructor))
static void initialize_instance()
{
	_instance = [[ApplicationStateListener alloc] init];
}

+(instancetype)sharedApplicationStateListener
{
	return _instance;
}

@end
