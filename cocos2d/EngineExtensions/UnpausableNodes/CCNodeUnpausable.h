//
//  CCNodeUnpausable.h

//  itraceur
//
//  Created by Stepan Generalov on 16.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//To make any cocosnode unpausable (that will run through CCPausedScheduler and CCPausedActionManager)
// just add following line in node implementation:
// #include "CCNodeUnpausableMutation.inc"

// CCPausedScheduler is CCScheduler subclass, that steps even if CCDirector is paused
// CCPausedActionManager is CCActionManager subclass, that use CCPausedScheduler instead of CCScheduler

// Changed cocos2d files are:
//		CCActionManager.h
//		CCActionManager.m
//		CCScheduler.h
//		CCScheduler.m
//		CCDirector.m
//		CCDirectorIOS.m
//		CCDirectorMac.m
//
// You can always search for these changes by "psi:" tag

@interface CCNodeUnpausable : CCNode
@end

@interface CCLayerUnpausable : CCLayer
@end

@interface CCSpriteUnpausable : CCSprite 
@end

@interface CCColorLayerUnpausable : CCLayerColor
@end

@interface CCLayerColorUnpausable : CCColorLayerUnpausable
@end


@interface CCMenuUnpausable : CCMenu
@end

@interface CCMenuItemSpriteUnpausable : CCMenuItemSprite
@end