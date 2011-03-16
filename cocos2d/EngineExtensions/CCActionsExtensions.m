//
//  CCAnimateAdvanced.m
//  itraceur
//
//  Created by Stepan Generalov on 13.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import "CCActionsExtensions.h"
#import "CCNodeExtensions.h"



@implementation CCAnimateAdvanced

@dynamic spriteAnchor;
- (CGPoint) spriteAnchor
{
	return spriteAnchor;
}

- (void) setSpriteAnchor: (CGPoint) newAnchor
{
	spriteAnchor = newAnchor;
	changeSpriteAnchor = YES;
}

@dynamic scaleX, scaleY;

- ( CGFloat ) scaleX
{
    return scaleX;
}

- ( CGFloat ) scaleY
{
    return scaleY;
}

- ( void ) setScaleX: (CGFloat) newScaleX
{
    changeSpriteScaleX = YES;
    
    scaleX = newScaleX;
}

- ( void ) setScaleY: (CGFloat) newScaleY
{
    changeSpriteScaleY = YES;
    
    scaleY = newScaleY;
}

@dynamic positionX, positionY;

- ( CGFloat ) positionX
{
    return positionX;
}

- ( CGFloat ) positionY
{
    return positionY;
}

- ( void ) setPositionX: (CGFloat) newPositionX
{
    changeSpritePositionX = YES;
    
    positionX = newPositionX;
}

- ( void ) setPositionY: (CGFloat) newPositionY
{
    changeSpritePositionY = YES;
    
    positionY = newPositionY;
}

#pragma mark Own Init 
+(id) actionWithAnimation:(CCAnimation*) anim restoreOriginalFrame:(BOOL)b spriteAnchor: (CGPoint ) anAnchor
{
	return [[[self alloc] initWithAnimation: anim restoreOriginalFrame: b spriteAnchor: anAnchor ] autorelease];
}

// my init
-(id) initWithAnimation:(CCAnimation *) anim restoreOriginalFrame:(BOOL)b spriteAnchor: (CGPoint ) anAnchor
{
    if (self = [self initWithAnimation: anim restoreOriginalFrame:b ])
    {
        spriteAnchor = anAnchor;
        changeSpriteAnchor = YES;
    }
    return self;
}

#pragma mark Overriden CCAnimate Stuff
#pragma mark Designated Inits 
-(id) initWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	
	if (self = [super initWithAnimation: anim restoreOriginalFrame: b])
	{
		changeSpriteAnchor = NO;
        changeSpriteScaleX = NO;
        changeSpriteScaleY = NO;
		changeSpritePositionX = NO;
		changeSpritePositionY = NO;
	}
	return self;
}

// designated initializer
-(id) initWithDuration:(ccTime)aDuration animation: (CCAnimation*)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	
	if( (self=[super initWithDuration: aDuration animation:anim restoreOriginalFrame:b] ) ) 
	{
		changeSpriteAnchor = NO;
        changeSpriteScaleX = NO;
        changeSpriteScaleY = NO;
		changeSpritePositionX = NO;
		changeSpritePositionY = NO;
	}
	return self;
}


// use another init or add properties
-(id) copyWithZone: (NSZone*) zone
{
	CCAnimateAdvanced *result = nil;
	
	result =
		[[[self class] allocWithZone: zone] initWithDuration:duration_ 
												   animation:animation_ 
										restoreOriginalFrame:restoreOriginalFrame];
	
	if (changeSpriteAnchor)
		result.spriteAnchor = spriteAnchor;
	
	if (changeSpriteScaleX)
		result.scaleX = scaleX;
	if (changeSpriteScaleY)
		result.scaleY = scaleY;
	
	if (changeSpritePositionX)
		result.positionX = positionX;
	if (changeSpritePositionY)
		result.positionY = positionY;
	
	return result;
}

- (CCActionInterval *) reverse
{
	NSArray *oldArray = [animation_ frames];
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[oldArray count]];
    NSEnumerator *enumerator = [oldArray reverseObjectEnumerator];
    for (id element in enumerator) {
        [newArray addObject:[[element copy] autorelease]];
    }
	
	CCAnimation *newAnim = [CCAnimation animationWithFrames:newArray delay:animation_.delay];
	CCAnimateAdvanced *result =	[[self class] actionWithDuration:duration_ 
													   animation:newAnim 
											restoreOriginalFrame:restoreOriginalFrame];
	
	if (changeSpriteAnchor)
		result.spriteAnchor = spriteAnchor;
	
	if (changeSpriteScaleX)
		result.scaleX = scaleX;
	if (changeSpriteScaleY)
		result.scaleY = scaleY;
	
	if (changeSpritePositionX)
		result.positionX = positionX;
	if (changeSpritePositionY)
		result.positionY = positionY;
	
	return result;
}

#pragma mark Internal Work

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	
	firstUpdate = YES;
}

-(void) stop
{
	[super stop];
	
	if( restoreOriginalFrame ) 
    {
		CCSprite *sprite = target_;
        
        sprite.anchorPoint = prevSpriteAnchor;
        sprite.scaleX = prevScale.x;
        sprite.scaleY = prevScale.y;
        
        sprite.position = prevPosition;
	}
	
	stoped = YES;
}

-(void) update: (ccTime) t
{
	
	if (stoped)
		return;
	
	CCSprite *sprite = target_;
	
	
		if ( firstUpdate )
        {
			

            prevSpriteAnchor = sprite.anchorPoint;
			prevScale.x = sprite.scaleX;
            prevScale.y = sprite.scaleY;
            prevPosition.x = sprite.position.x;
            prevPosition.y = sprite.position.y;
            
//            if ( changeSpriteAnchor ) 
//            {
//                sprite.anchorPoint = spriteAnchor;
//            }          
            
            if ( changeSpriteScaleX )
            {                
                sprite.scaleX = scaleX;
            }
            
            if ( changeSpriteScaleY )
            {                
                sprite.scaleY = scaleY;
            }
            
            
            CGPoint position = sprite.position;
            if ( changeSpritePositionX )
                position.x = positionX;            
            if ( changeSpritePositionY )
                position.y = positionY;
            sprite.position = position;
			
            firstUpdate = NO;
        }
	
	[super update: t];
	
	if ( changeSpriteAnchor ) 
	{
		sprite.anchorPointInPixels = spriteAnchor;
	}   
}

- (void) cancelChangingSpriteAnchor
{
	changeSpriteAnchor = NO;
}



@end


@implementation CCMoveTo (Extension)

- (CGPoint) endPosition
{
	return endPosition;
}

@end

