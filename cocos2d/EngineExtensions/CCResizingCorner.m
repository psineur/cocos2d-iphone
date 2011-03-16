//
//  CCResizingCorner.m
//  iTraceur for Mac
//
//  Created by Stepan Generalov on 10.01.11.
//  Copyright 2011 Parkour Games. All rights reserved.
//

#import "CCResizingCorner.h"

NSString *const resizingCornerImageName	= @"resizingCorner.png";
@implementation CCResizingCorner

+ (id) resizingCorner
{
	CCSprite *result = [[[self alloc] initWithFile: resizingCornerImageName] autorelease];
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	result.anchorPoint = ccp (1, 0);
	result.position = ccp(size.width, 0);
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	if ( [(CCDirectorMac *)[CCDirector sharedDirector] isFullScreen] )
		result.visible = NO;
#endif
	
	return result;
}



@end
