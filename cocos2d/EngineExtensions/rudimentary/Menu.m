/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "Menu.h"
#import "CCDirector.h"
#import "CGPointExtension.h"

enum {
	kDefaultPadding =  5,
};

@interface Menu (Private)
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
// returns touched menu item, if any
-(MenuItem *) itemForTouch: (UITouch *) touch idx: (int*) idx;
#endif
@end

@implementation Menu

@synthesize opacity;

- (id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"MenuInit"
								reason:@"Use initWithItems instead"
								userInfo:nil];
	@throw myException;
}

+(id) menuWithItems: (MenuItem*) item, ...
{
	va_list args;
	va_start(args,item);
	
	//TODO: throw out old Menu/MenuItem system
	id s = [[[self alloc] initWithItems: item vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithItems: (MenuItem*) item vaList: (va_list) args
{
	if( !(self=[super init]) )
		return nil;
	
	// menu in the center of the screen
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	// XXX: in v0.7, winSize should return the visible size
	// XXX: so the bar calculation should be done there
	CGRect r = [[UIApplication sharedApplication] statusBarFrame];
	//if([[CCDirector sharedDirector] landscape])
	//	s.height -= r.size.width;
	//else
	    s.height -= r.size.height;
	

	[self setIsTouchEnabled: YES];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	[self setIsMouseEnabled: YES];
	[self setIsKeyboardEnabled:YES];
#endif
	
	
	position_ = ccp(s.width/2, s.height/2);
	selectedItem = -1;
	
	int z=0;
	
	if (item) {
		[self addChild: item z:z];
		MenuItem *i = va_arg(args, MenuItem*);
		while(i) {
			z++;
			[self addChild: i z:z];
			i = va_arg(args, MenuItem*);
		}
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

/*
 * override add:
 */
-(void) addChild:(MenuItem*)child z:(int)z tag:(int) aTag
{
	NSAssert( [child isKindOfClass:[MenuItem class]], @"Menu only supports MenuItem objects as children");
	[super addChild:child z:z tag:aTag];
}

#pragma mark Menu - Events Touch 
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	int idx;
	MenuItem *item = [self itemForTouch:touch idx:&idx];

	if( item ) {
		[item selected];
		selectedItem = idx;
		return;
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	int idx;
	MenuItem *item = [self itemForTouch:touch idx:&idx];
	
	if( item ) {
		[item unselected];
		[item activate];
		return;

	} else if( selectedItem != -1 ) {
		[[children_ objectAtIndex:selectedItem] unselected];
		selectedItem = -1;
		
		// don't return kEventHandled here, since we are not handling it!
	}
	return;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	int idx;
	MenuItem *item = [self itemForTouch:touch idx:&idx];
	
	// "mouse" draged inside a button
	if( item ) {
		if( idx != selectedItem ) {
			if( selectedItem != -1 )
				[[children_ objectAtIndex:selectedItem] unselected];
			[item selected];
			selectedItem = idx;
			return;
		}

	// "mouse" draged outside the selected button
	} else {
		if( selectedItem != -1 ) {
			[[children_ objectAtIndex:selectedItem] unselected];
			selectedItem = -1;
			
			// don't return kEventHandled here, since we are not handling it!
		}
	}
	
	return;
}
#endif

#pragma mark Menu - Opacity Protocol

- (void) setColor:(ccColor3B)color
{
}

- (ccColor3B) color
{
	return ccWHITE;
}

/** Override synthesized setOpacity to recurse items */
- (void) setOpacity:(GLubyte)newOpacity
{
	opacity = newOpacity;
	for(CCNode <CCRGBAProtocol> * item in children_)
		[item setOpacity:opacity];
}

#pragma mark Menu - Private

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(MenuItem *) itemForTouch: (UITouch *) touch idx: (int*) idx;
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	
	int i=0;
	for( MenuItem* item in children_ ) {
		CGPoint local = [item convertToNodeSpace:touchLocation];

		CGRect r = [item rect];
		r.origin = CGPointZero;
		
		if( CGRectContainsPoint( r, local ) ) {
			*idx = i;
			return item;
		}
		
		i++;
	}
	return nil;
}
#endif



@end
