//
//  CCPausedActionManager.m
//  iTraceur for Mac
//
//  Created by Stepan Generalov on 20.12.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import "CCPausedActionManager.h"

static CCActionManager *sharedPausedManager_ = nil;
@implementation  CCPausedActionManager
+ (CCActionManager *)sharedManager
{
	if (!sharedPausedManager_)
		sharedPausedManager_ = [[self alloc] init];
	
	return sharedPausedManager_;
}

+(id)alloc
{
	NSAssert(sharedPausedManager_ == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedManager
{
	[[CCPausedScheduler sharedScheduler] unscheduleUpdateForTarget:self];
	[sharedPausedManager_ release];
	sharedPausedManager_ = nil;
}

-(id) init
{
	if ((self=[super init]) ) {
		[[CCPausedScheduler sharedScheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
		targets = NULL;
	}
	
	return self;
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);
	
	[self removeAllActions];
	
	sharedPausedManager_ = nil;
	
	[super dealloc];
}

@end

