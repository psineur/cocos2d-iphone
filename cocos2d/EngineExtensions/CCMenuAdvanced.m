//
//  CCMenuAdvanced.m
//  Cocos2D Extenstions for iTraceur
//
//  Created by Stepan Generalov on 27.02.11.
//  Copyright 2011 Parkour Games. All rights reserved.
//

#import "CCMenuAdvanced.h"


@implementation NSString (UnicharExtensions)

+ (NSString *) stringWithUnichar: (unichar) anUnichar
{
	return [[[NSString alloc] initWithCharacters:&anUnichar length:1] autorelease];
}

- (unichar) unicharFromFirstCharacter: (NSString *) aString
{
	if ([aString length])
		return [aString characterAtIndex:0];
	return 0;
}

@end


@interface CCMenu (Private) 

-(CCMenuItem *) itemForTouch: (UITouch *) touch;

@end


@implementation CCMenuAdvanced
@synthesize boundaryRect = boundaryRect_;
@synthesize minimumTouchLengthToSlide = minimumTouchLengthToSlide_;
@synthesize priority = priority_;


-(id) initWithItems: (CCMenuItem*) item vaList: (va_list) args
{
	if (self = [super initWithItems:item vaList:args])
	{
		selectedItemNumber_ = -1;
		self.boundaryRect = CGRectNull;
		self.minimumTouchLengthToSlide = 30.0f;
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
		[self setIsKeyboardEnabled:YES];
#endif
	}
	return self;
}

- (void) dealloc
{
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	self.escapeDelegate = nil;
#endif
	[super dealloc];
}

#pragma mark Advanced Menu - Priority
-(NSInteger) mouseDelegatePriority
{
	return priority_;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self 
													 priority:[self mouseDelegatePriority] 
											  swallowsTouches: YES ];
}
#endif

#pragma mark Advanced Menu - Selecting/Activating Items

- (void) selectNextMenuItem
{
	if ([children_ count] < 2)
		return;
	
	selectedItemNumber_++;
	
	// borders
	if (selectedItemNumber_ >= (int)[children_ count])
		selectedItemNumber_ = 0;
	if (selectedItemNumber_ < 0)
		selectedItemNumber_ = [children_ count] - 1;
	
	// select selected
	int i = 0;
	for (CCMenuItem *item in children_)
	{
		[item unselected];
		if ( i == selectedItemNumber_ )
			[item selected];
		++i;
	}
}

- (void) selectPrevMenuItem
{
	if ([children_ count] < 2)
		return;
	
	selectedItemNumber_--;
	
	// borders
	if (selectedItemNumber_ >= (int)[children_ count])
		selectedItemNumber_ = 0;
	if (selectedItemNumber_ < 0)
		selectedItemNumber_ = [children_ count] - 1;
	
	// select selected
	int i = 0;
	for (CCMenuItem *item in children_)
	{
		if ( i == selectedItemNumber_ )
			[item selected];
		else 
			[item unselected];
		
		++i;
	}
}

- (void) activateSelectedItem
{
	if (selectedItemNumber_ < 0)
		return;
	
	CCMenuItem *item = [children_ objectAtIndex: selectedItemNumber_];
	[item unselected];
	[item activate];
	
}

#pragma mark Advanced Menu - Alignment
// differences from std impl:
//		* 1 auto setContentSize 
//		* 2 each item.x = width / 2
//		* 3 item starts from top, not from center on y
//		* [MAC] binds keyboard keys for verticall taking care about direction
-(void) alignItemsVerticallyWithPadding:(float)padding bottomToTop: (BOOL) bottomToTop
{
	float height = -padding;
	float width = 0;
	
	// calculate and set contentSize,
	CCMenuItem *item;
	CCARRAY_FOREACH(children_, item)
	{
		height += item.contentSize.height * item.scaleY + padding;
		width = MAX(item.contentSize.width * item.scaleX, width);
	}
	[self setContentSize: CGSizeMake(width, height)];
	
	// allign items
	float y = 0;
	if (! bottomToTop)
		y = height;
	
	CCARRAY_FOREACH(children_, item) {
		CGSize itemSize = item.contentSize;
	    [item setPosition:ccp(width / 2.0f, y - itemSize.height * item.scaleY / 2.0f)];
		
		if (bottomToTop)
			y += itemSize.height * item.scaleY + padding;
		else 
			y -= itemSize.height * item.scaleY + padding;
	}
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	if (bottomToTop)
	{
		self.nextItemButtonBind = NSUpArrowFunctionKey;
		self.prevItemButtonBind = NSDownArrowFunctionKey;
	}
	else 
	{
		self.nextItemButtonBind = NSDownArrowFunctionKey;
		self.prevItemButtonBind = NSUpArrowFunctionKey;
	}
#endif
}

// differences from std impl:
//		* 1 auto setContentSize 
//		* 2 each item.y = height / 2
//		* items start from zero - i dunno why
//		* supports both directions
//		* [MAC] binds keyboard keys for horizontal taking care about direction
-(void) alignItemsHorizontallyWithPadding:(float)padding leftToRight: (BOOL) leftToRight
{
	float width = -padding;
	float height = 0;
	
	// calculate and set content size
	CCMenuItem *item;
	CCARRAY_FOREACH(children_, item)
	{
		width += item.contentSize.width * item.scaleX + padding;
		height = MAX(item.contentSize.height * item.scaleY, height);
	}
	[self setContentSize: CGSizeMake(width, height)];
	
	float x = 0;
	if ( !leftToRight )
		x = width;
	
	// align items
	CCARRAY_FOREACH(children_, item)
	{
		CGSize itemSize = item.contentSize;
		[item setPosition:ccp(x + itemSize.width * item.scaleX / 2.0f, height / 2.0f)];
		
		if (leftToRight)
			x += itemSize.width * item.scaleX + padding;
		else
			x -= itemSize.width * item.scaleX + padding;
	}
	
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	if (leftToRight)
	{
		self.nextItemButtonBind = NSRightArrowFunctionKey;
		self.prevItemButtonBind = NSLeftArrowFunctionKey;
	}
	else 
	{
		self.nextItemButtonBind = NSLeftArrowFunctionKey;
		self.prevItemButtonBind = NSRightArrowFunctionKey;
	}
#endif
}

// TODO: add columns and rows alignment methods

-(void) alignItemsHorizontallyWithPadding:(float)padding
{
	[self alignItemsHorizontallyWithPadding: padding leftToRight: YES];
}

-(void) alignItemsVerticallyWithPadding:(float)padding
{
	[self alignItemsVerticallyWithPadding: padding bottomToTop: YES];
}

#pragma mark Advanced Menu - Keyboard Controls

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
- (BOOL) ccKeyDown:(NSEvent *)event
{
	unichar enterKeyBinding = 13;
	unichar escapeKeyBinding = 0x1b;
	unichar upKeyBinding = [self prevItemButtonBind];
	unichar downKeyBinding = [self nextItemButtonBind];
	
	if (! self.visible)
		return NO;
	
	NSString *keyCharacters = [event charactersIgnoringModifiers];
	
	// ESCAPE
	if ( [keyCharacters rangeOfString:[NSString stringWithUnichar: escapeKeyBinding]].location != NSNotFound)
	{
		// do not process holding esc key
		if ([event isARepeat])
			return NO;
		
		if (self.escapeDelegate)
		{
			[self.escapeDelegate unselected];
			[self.escapeDelegate activate];
			
			return YES;
		}
		else 
			return NO;
	}
	
	// NEXT
	if ( [keyCharacters rangeOfString:[NSString stringWithUnichar: downKeyBinding]].location != NSNotFound )
	{
		[self selectNextMenuItem];
		return YES;
	}
	
	// PREV
	if ( [keyCharacters rangeOfString:[NSString stringWithUnichar: upKeyBinding]].location != NSNotFound)
	{
		[self selectPrevMenuItem];
		return YES;
	}
	
	// ENTER
	if ( [keyCharacters rangeOfString:[NSString stringWithUnichar: enterKeyBinding]].location != NSNotFound)
	{
		[self activateSelectedItem];
		return YES;
	}	
	
	return NO;
}

@synthesize escapeDelegate = escapeDelegate_;
@synthesize prevItemButtonBind = prevItemButtonBind_;
@synthesize nextItemButtonBind = nextItemButtonBind_;

#endif

#pragma mark Advanced Menu - Scrolling

- (void) fixPosition
{	
	if ( CGRectIsNull( boundaryRect_) || CGRectIsInfinite(boundaryRect_) )
		return;
	
#define CLAMP(x,y,z) MIN(MAX(x,y),z)
	
	// get right top corner coords
	CGRect rect = [self boundingBox];	
	CGPoint rightTopCorner = ccp(rect.origin.x + rect.size.width, 
								 rect.origin.y + rect.size.height);
	CGPoint originalRightTopCorner = rightTopCorner;
	CGSize s = rect.size;
	
	// reposition right top corner to stay in boundary
	CGFloat leftBoundary = boundaryRect_.origin.x + boundaryRect_.size.width;
	CGFloat rightBoundary = boundaryRect_.origin.x + MAX(s.width, boundaryRect_.size.width);
	CGFloat bottomBoundary = boundaryRect_.origin.y + boundaryRect_.size.height;
	CGFloat topBoundary = boundaryRect_.origin.y + MAX(s.height,boundaryRect_.size.height);

	rightTopCorner = ccp( CLAMP(rightTopCorner.x,leftBoundary,rightBoundary), 
						 CLAMP(rightTopCorner.y,bottomBoundary,topBoundary));
	
	// calculate and add position delta
	CGPoint delta = ccpSub(rightTopCorner, originalRightTopCorner);
	self.position = ccpAdd(self.position, delta);		
	
#undef CLAMP
	
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

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{	
	if( state_ != kCCMenuStateWaiting || !visible_ )
		return NO;
	
	curTouchLength_ = 0; //< every new touch should reset previous touch length
	
	selectedItem_ = [self itemForTouch:touch];
	[selectedItem_ selected];
	
	if( selectedItem_ ) {
		state_ = kCCMenuStateTrackingTouch;
		return YES;
	}
	
	// start slide even if touch began outside of menuitems, but inside menu rect
	if ( !CGRectIsNull(boundaryRect_) && [self isTouchForMe: touch] ){
		state_ = kCCMenuStateTrackingTouch;
		return YES;
	}
	
	return NO;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");
	
	[selectedItem_ unselected];
	[selectedItem_ activate];
	
	state_ = kCCMenuStateWaiting;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");
	
	[selectedItem_ unselected];
	
	state_ = kCCMenuStateWaiting;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");
	
	CCMenuItem *currentItem = [self itemForTouch:touch];
	
	if (currentItem != selectedItem_) {
		[selectedItem_ unselected];
		selectedItem_ = currentItem;
		[selectedItem_ selected];
	}
	
	// scrolling is allowed only with non-zero boundaryRect
	if (!CGRectIsNull(boundaryRect_))
	{	
		// get touch move delta 
		CGPoint point = [touch locationInView: [touch view]];
		CGPoint prevPoint = [ touch previousLocationInView: [touch view] ];	
		point =  [ [CCDirector sharedDirector] convertToGL: point ];
		prevPoint =  [ [CCDirector sharedDirector] convertToGL: prevPoint ];
		CGPoint delta = ccpSub(point, prevPoint);
		
		curTouchLength_ += ccpLength( delta ); 
		
		if (curTouchLength_ >= self.minimumTouchLengthToSlide)
		{
			[selectedItem_ unselected];
			selectedItem_ = nil;
			
			// add delta
			CGPoint newPosition = ccpAdd(self.position, delta );	
			self.position = newPosition;
			
			// stay in externalBorders
			[self fixPosition];
		}
	}
}


#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccScrollWheel:(NSEvent *)theEvent
{
	CGPoint delta = ccp( - [theEvent deltaX], - [theEvent deltaY] );
	
	// fix scrolling speed if we are scaled
	delta = ccp(delta.x / self.scaleX, delta.y / self.scaleY);
	
	// add delta
	CGPoint newPosition = ccpAdd(_scrollingChild.position, delta );	
	self.position = newPosition;
	
	// stay in externalBorders
	[self fixPosition];
	
	return NO;
}

#endif
@end

