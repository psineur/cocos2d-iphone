//
//  CCNodeExtensions.m
//  itraceur
//
//  Created by Stepan Generalov on 16.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import "CCNodeExtensions.h"
#import "cocos2d.h"
#import "chipmunk.h"

@interface CCActionManager (Private)

-(void) removeActionAtIndex:(NSUInteger)index hashElement:(tHashElement*)element;

@end


@implementation CCActionManager (ExtensionsForiTraceur)

-(void) removeAllActionsByTag:(int) aTag target:(id)target
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	NSAssert( target != nil, @"Target should be ! nil");
	
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);
	
	if( element ) {
		NSUInteger limit = element->actions->num;
		for( NSUInteger i = 0; i < limit; i++) {
			CCAction *a = element->actions->arr[i];
			
			if( a.tag == aTag && [a originalTarget]==target)
				[self removeActionAtIndex:i hashElement:element];
		}
		//		CCLOG(@"cocos2d: removeActionByTag: Action not found!");
	} else {
		//		CCLOG(@"cocos2d: removeActionByTag: Target not found!");
	}
}

@end

@implementation CCNode (ExtensionsForiTraceur)

- (void) stopAllActionsByTag: (NSUInteger) aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	[[CCActionManager sharedManager] removeAllActionsByTag:aTag target:self];
}

@dynamic anchorPointInPixels;

- (CGPoint) anchorPointInPixels
{
	return anchorPointInPixels_;
}

- (void) setAnchorPointInPixels: (CGPoint) newAcnhor
{
		if( ! CGPointEqualToPoint(newAcnhor, anchorPointInPixels_) ) 
		{
			anchorPointInPixels_ = newAcnhor;
			anchorPoint_ = ccp( newAcnhor.x / contentSizeInPixels_.width , 
							   newAcnhor.y / contentSizeInPixels_.height );
			
			isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
			isTransformGLDirty_ = YES;
#endif		
		}
}

@end

@implementation CCParallaxNode (ExtensionsForiTraceur)

- (void) forcePositionUpdate
{
	lastPosition = ccp(lastPosition.y * 1024, lastPosition.x * 1024);
}

@end

@implementation CCMenuItemSpriteIndependent


-(void) setNormalImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != normalImage_ ) {
		//
		[normalImage_ release];
		
		//image.anchorPoint = ccp(0,0);
		image.visible = YES;
		
		//[self removeChild:normalImage_ cleanup:YES];
		//[self addChild:image];
		
		//normalImage_ = image;
		normalImage_ = [image retain];
	}
}

-(void) setSelectedImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != selectedImage_ ) {
		//
		[selectedImage_ release];
		
		//image.anchorPoint = ccp(0,0);
		image.visible = NO;
		
		//[self removeChild:selectedImage_ cleanup:YES];
		//[self addChild:image];
		
		//selectedImage_ = image;
		selectedImage_ = [image retain];
	}
}

-(void) setDisabledImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != disabledImage_ ) {
		//
		[disabledImage_ release];
		
		//image.anchorPoint = ccp(0,0);
		image.visible = NO;
		
		//[self removeChild:disabledImage_ cleanup:YES];
		//[self addChild:image];
		
		//disabledImage_ = image;
		disabledImage_ = [image retain];
	}
}


- (void) dealloc
{
	[normalImage_ release];
	[selectedImage_ release];
	[disabledImage_ release];	
	
	[super dealloc];
}

@end




@implementation CCLayerScroll

@dynamic scrollingChild;


- (CCNode *) scrollingChild
{
	return _scrollingChild;
}

- (void) setScrollingChild:(CCNode *) newScrollingChild
{
	if ( _scrollingChild )
		[self removeChild:_scrollingChild cleanup:YES];
	
	//retain property impl
	[_scrollingChild release];
	_scrollingChild = [newScrollingChild retain];
	
	//add child
	if ( _scrollingChild )
		[self addChild:_scrollingChild];
	
	[self fixScrollingChildPosition];
}

- (id) init
{
	if (self = [super init])
	{
#if __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
		self.isMouseEnabled = YES;
#endif

		self.isRelativeAnchorPoint = YES;
		
	}
	
	return self;
}

- (void) dealloc
{
	self.scrollingChild = nil;
	
	[super dealloc];
}

- (void) scrollUp
{
	_scrollingChild.position = ccp(_scrollingChild.position.x, - INFINITY);
}

- (void) fixScrollingChildPosition
{
	// 1 Do not let scrolling child cross self's rect
	_scrollingChild.anchorPoint = ccp(1,1);
	
	CGPoint p = _scrollingChild.position;
	CGSize s = _scrollingChild.contentSize;
	
	if ( p.y < self.contentSize.height)
		p.y = self.contentSize.height;
	
	if (p.y - s.height > 0)
		p.y = s.height;
	
	if ( p.x < self.contentSize.width)
		p.x = self.contentSize.width;
	
	if (p.x - s.width > 0)
		p.x = s.width;
	
	// 2 If scrollingChild rect is smaller than self's - position it at top
	if (s.height < self.contentSize.height)
		p.y = self.contentSize.height;
	
	// x positioning isn't good enough =(
	
	_scrollingChild.position = p;
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED

// returns YES if touch is inside our boundingBox
-(BOOL) isTouchForMe:(UITouch *) touch
{
	CGPoint point = [touch locationInView: [touch view]];
	CGPoint locationInParent = [parent_ convertToNodeSpace: point];
	
	CGPoint prevPoint = [touch previousLocationInView: [touch view]];
	CGPoint prevLocationInParent = [parent_ convertToNodeSpace: prevPoint];
	
    return ( CGRectContainsPoint([self boundingBox], locationInParent)
		  || CGRectContainsPoint([self boundingBox], prevLocationInParent) );
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if ( ! [self isTouchForMe:touch] )
		return;
	
	// get touch move delta 
    CGPoint point = [touch locationInView: [touch view]];
    CGPoint prevPoint = [ touch previousLocationInView: [touch view] ];	
	CGPoint delta = ccpSub(prevPoint, point);	
	
	
	// fix scrolling speed if we are scaled
	delta = ccp(delta.x / self.scaleX, delta.y / self.scaleY);
	CGPoint newPosition = ccpAdd(_scrollingChild.position, delta );
	
	_scrollingChild.position = newPosition;
	
	[self fixScrollingChildPosition];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccScrollWheel:(NSEvent *)theEvent
{
	CGPoint delta = ccp( - [theEvent deltaX], - [theEvent deltaY] );
	delta = ccp(delta.x / self.scaleX, delta.y / self.scaleY);
	CGPoint newPosition = ccpAdd(_scrollingChild.position, delta );
	
	_scrollingChild.position = newPosition;
	
	[self fixScrollingChildPosition];
	
	return NO;
}

#endif





// DELAYED
//TODO: if using keyboard to pick a MenuItem and we need to scroll the CCLayerScroll to show this item - do it
- (void) ensureVisible:(CCNode *)aNode
{
	// we thing that aNode is a child of _scrollingChild and we must position it right way
	//, so aNode will be in our rect
	
}

@end


@implementation CCMenuItemLabeliTraceur

@synthesize selectedColor = _selectedColor;

-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector
{
	if (self = [super initWithLabel: label target: target selector: selector])
	{
		self.selectedColor = ccc3(0x7C, 0x0, 0x19);
	}
	
	return self;
}

- (void) setLabel:(CCNode <CCLabelProtocol,CCRGBAProtocol>*) newLabel
{
	[super setLabel: newLabel];
	_originalLabelColor = [newLabel color];
}

-(void) selected
{
	// subclass to change the default action
	if(isEnabled_) {	
		//[super selected];
		isSelected_ = YES;

		[self.label setColor: self.selectedColor];
	}
}

-(void) unselected
{
	// subclass to change the default action
	if(isEnabled_) {
		//[super unselected];
		isSelected_ = NO;
		
		[self.label setColor: _originalLabelColor];
	}
}

@end




@implementation CCMenuPrioritized

@synthesize priority = _priority;

+ (id) menuWithPriority: (NSInteger) prior Items: (CCMenuItem *) item, ...
{
	va_list args;
	va_start(args,item);
	
	id s = [[[self alloc] initWithItems: item vaList:args] autorelease];
	[s setPriority: prior];
	
	va_end(args);
	return s;
}

-(NSInteger) mouseDelegatePriority
{
	return _priority;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self 
													 priority:[self mouseDelegatePriority] 
											  swallowsTouches: YES ];
}
#endif
@end

