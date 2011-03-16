//
//  CCAnimateAdvanced.h
//  itraceur
//
//  Created by Stepan Generalov on 13.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCAnimateAdvanced : CCAnimate 
{
	//Advanced Additions:
	BOOL stoped; //< don't let Animate update sprite's frame after action is stoped
	
	
    // autoTransformChange functionality
    BOOL    firstUpdate; ///< after first update() call turns to NO
    BOOL    changeSpriteAnchor;    
    
    CGPoint spriteAnchor; ///< new sprite anchor
    CGPoint prevSpriteAnchor; ///< previous sprite acnhor to set if restoreOriginalFrame = YES
    
    // auto scale change on first update
    BOOL changeSpriteScaleX;
    BOOL changeSpriteScaleY;
    CGFloat scaleX;
    CGFloat scaleY;  
    CGPoint prevScale;
    
    // auto position change on first update
    BOOL changeSpritePositionX;
    BOOL changeSpritePositionY;
    CGFloat positionX;
    CGFloat positionY;  
    CGPoint prevPosition;

}

@property (readwrite, assign) CGPoint spriteAnchor;
@property (readwrite, assign) CGFloat scaleX;
@property (readwrite, assign) CGFloat scaleY;
@property (readwrite, assign) CGFloat positionX;
@property (readwrite, assign) CGFloat positionY;

+(id) actionWithAnimation:(CCAnimation*) anim restoreOriginalFrame:(BOOL)b spriteAnchor: (CGPoint ) anAnchor;
-(id) initWithAnimation:(CCAnimation *) anim restoreOriginalFrame:(BOOL)b spriteAnchor: (CGPoint ) anAnchor;

- (void) cancelChangingSpriteAnchor;

@end

@interface CCMoveTo (Extension)

- (CGPoint) endPosition;

@end



