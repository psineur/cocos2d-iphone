//
//  CCPausedScheduler.m
//  iTraceur for Mac
//
//  Created by Stepan Generalov on 20.12.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import "CCPausedScheduler.h"


@implementation CCPausedScheduler

static CCScheduler *sharedPausedScheduler = nil;

+ (CCScheduler *)sharedScheduler
{
	if (!sharedPausedScheduler)
		sharedPausedScheduler = [[CCPausedScheduler alloc] init];
	
	return sharedPausedScheduler;
}

+(id)alloc
{
	NSAssert(sharedPausedScheduler == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedScheduler
{
	[sharedPausedScheduler release];
	sharedPausedScheduler = nil;
}

- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	
	[self unscheduleAllSelectors];
	
	sharedPausedScheduler = nil;
	
	[super dealloc];
}
@end