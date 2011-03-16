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

#import "cocos2d.h"
#import "MenuItem.h"
#import "CCNodeExtensions.h"


enum {
	kCurrentItem = 0xc0c05001,
};

enum {
	kZoomActionTag = 0xc0c05002,
};



#pragma mark -
#pragma mark MenuItem

@implementation MenuItem

@synthesize opacity;

-(id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"MenuItemInit"
								reason:@"Init not supported. Use InitFromString"
								userInfo:nil];
	@throw myException;	
}

+(id) itemWithTarget:(id) r selector:(SEL) s
{
	return [[[self alloc] initWithTarget:r selector:s] autorelease];
}

-(id) initWithTarget:(id) rec selector:(SEL) cb
{
	if(!(self=[super init]) )
		return nil;
	
	NSMethodSignature * sig = nil;
	
	if( rec && cb ) {
		sig = [[rec class] instanceMethodSignatureForSelector:cb];
		
		invocation = nil;
		invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setTarget:rec];
		[invocation setSelector:cb];
		[invocation setArgument:&self atIndex:2];
		[invocation retain];
	}
    
	isEnabled = YES;
	opacity = 255;
	
	return self;
}

-(void) dealloc
{
	[invocation release];
	[super dealloc];
}

-(void) selected
{
	NSAssert(1,@"MenuItem.selected must be overriden");
}

-(void) unselected
{
	NSAssert(1,@"MenuItem.unselected must be overriden");
}

-(void) activate
{
	if(isEnabled)
        [invocation invoke];
}

-(void) setIsEnabled: (BOOL)enabled
{
    isEnabled = enabled;
}

-(BOOL) isEnabled
{
    return isEnabled;
}

-(CGRect) rect
{
	NSAssert(1,@"MenuItem.rect must be overriden");

	return CGRectNull;
}

-(CGSize) contentSize
{
	NSAssert(1,@"MenuItem.contentSize must be overriden");
	return CGSizeMake(0,0);
}


-(void) setColor:(ccColor3B)color
{
	//[normalImage setColor: color];
//	[selectedImage setColor: color];
//	[disabledImage setColor: color];
}

-(ccColor3B) color
{
	return ccWHITE;
}

@end

#pragma mark MenuItemImage

@implementation MenuItemImage
-(void) setColor:(ccColor3B)color
{
	[normalImage setColor: color];
	[selectedImage setColor: color];
	[disabledImage setColor: color];
}

-(ccColor3B) color
{
	return [normalImage color];
}

@synthesize selectedImage, normalImage, disabledImage;

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2
{
	return [self itemFromNormalImage:value selectedImage:value2 disabledImage: nil target:nil selector:nil];
}

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) t selector:(SEL) s
{
	return [self itemFromNormalImage:value selectedImage:value2 disabledImage: nil target:t selector:s];
}

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage: (NSString*) value3
{
	return [[[self alloc] initFromNormalImage:value selectedImage:value2 disabledImage:value3 target:nil selector:nil] autorelease];
}

+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage: (NSString*) value3 target:(id) t selector:(SEL) s
{
	return [[[self alloc] initFromNormalImage:value selectedImage:value2 disabledImage:value3 target:t selector:s] autorelease];
}

-(id) initFromNormalImage: (NSString*) normalI selectedImage:(NSString*)selectedI disabledImage: (NSString*) disabledI target:(id) t selector:(SEL) sel
{
	if( !(self=[super initWithTarget:t selector:sel]) )
		return nil;

	normalImage = [[CCSprite spriteWithFile:normalI] retain];
	selectedImage = [[CCSprite spriteWithFile:selectedI] retain];
    
	if(disabledI == nil)
		disabledImage = nil;
	else
		disabledImage = [[CCSprite spriteWithFile:disabledI] retain];
  
	[normalImage setOpacity:opacity];
	[selectedImage setOpacity:opacity];
	[disabledImage setOpacity:opacity];
	
	CGSize s = [normalImage contentSize];
	self.anchorPointInPixels = ccp( s.width/2, s.height/2 );

	return self;
}

-(void) dealloc
{
	[normalImage release];
	[selectedImage release];
	[disabledImage release];
	
	normalImage = selectedImage = disabledImage = nil; 

	[super dealloc];
}

-(void) selected
{
	selected = YES;
}

-(void) unselected
{
	selected = NO;
}

- (BOOL) isSelected
{
    return selected;
}

-(CGRect) rect
{
	CGSize s = [normalImage contentSize];
	
	CGRect r = CGRectMake( position_.x - s.width/2, position_.y-s.height/2, s.width, s.height);
	return r;
}

-(CGSize) contentSize
{
	return [normalImage contentSize];
}

-(void) draw
{
	if(isEnabled) {
		if( selected )
			[selectedImage draw];
		else
			[normalImage draw];

	} else {
		if(disabledImage != nil)
			[disabledImage draw];
		
		// disabled image was not provided
		else
			[normalImage draw];
	}
}

- (void) setOpacity: (GLubyte)newOpacity
{
	opacity = newOpacity;
	[normalImage setOpacity:opacity];
	[selectedImage setOpacity:opacity];
	[disabledImage setOpacity:opacity];
}

@end


#pragma mark MenuItemAtlasImage

@implementation MenuItemAtlasImage

@synthesize selectedImage, normalImage, disabledImage;
@dynamic position;
@dynamic scaleX, scaleY;

- (CGPoint) position
{
    return [super position];
}

- (void) setPosition: (CGPoint) newPosition
{
    [super setPosition: newPosition];
    
    normalImage.position = newPosition;
    selectedImage.position = newPosition;
    disabledImage.position = newPosition;
}

- (float) scaleX
{
    return [super scaleX];
}

- (void) setScaleX: (float) x
{
    [super setScaleX: x];
    
    normalImage.scaleX = x;
    selectedImage.scaleX = x;
    disabledImage.scaleX = x;
}

- (float) scaleY
{
    return [super scaleY];
}

- (void) setScaleY: (float) y
{
    [super setScaleY: y];
    
    normalImage.scaleY = y;
    selectedImage.scaleY = y;
    disabledImage.scaleY = y;
}


+(id) itemFromNormalSprite: (CCSprite*)value selectedSprite:(CCSprite*) value2
{
	return [self itemFromNormalSprite:value selectedSprite:value2 disabledSprite: nil target:nil selector:nil];
}

+(id) itemFromNormalSprite: (CCSprite*)value selectedSprite:(CCSprite*) value2 target:(id) t selector:(SEL) s
{
	return [self itemFromNormalSprite:value selectedSprite:value2 disabledSprite: nil target:t selector:s];
}

+(id) itemFromNormalSprite: (CCSprite*)value selectedSprite:(CCSprite*) value2 disabledSprite: (CCSprite*) value3
{
	return [[[self alloc] initFromNormalSprite:value selectedSprite:value2 disabledSprite:value3 target:nil selector:nil] autorelease];
}

+(id) itemFromNormalSprite: (CCSprite*)value selectedSprite:(CCSprite*) value2 disabledSprite: (CCSprite*) value3 target:(id) t selector:(SEL) s
{
	return [[[self alloc] initFromNormalSprite:value selectedSprite:value2 disabledSprite:value3 target:t selector:s] autorelease];
}

-(id) initFromNormalSprite: (CCSprite*) normalI selectedSprite:(CCSprite*)selectedI disabledSprite: (CCSprite*) disabledI target:(id) t selector:(SEL) sel
{
	if( !(self=[super initWithTarget:t selector:sel]) )
		return nil;
    
	normalImage = [ normalI retain];
	selectedImage = [ selectedI retain];
    
    _forceRect = NO;
    
	if(disabledI == nil)
		disabledImage = nil;
	else
		disabledImage = [disabledI retain];
    
	[normalImage setOpacity:opacity];
	[selectedImage setOpacity:opacity];
	[disabledImage setOpacity:opacity];
    
    
    selected = NO;
    [selectedImage setVisible: NO];
    [disabledImage setVisible: NO];
    [normalImage setVisible: YES];
	
	CGSize s = [normalImage contentSize];
	anchorPoint_ = ccp( s.width/2, s.height/2 );
    
	return self;
}

-(void) dealloc
{
	[normalImage release];
	[selectedImage release];
	[disabledImage release];
    
	[super dealloc];
}

-(void) selected
{
	selected = YES;    
    
    if(isEnabled) {
		if( selected )
        {
            [ normalImage setVisible: NO ];
            [ selectedImage setVisible: YES ];
            [ disabledImage setVisible: NO ];
        }
		else
        {
			[ normalImage setVisible: YES ];
            [ selectedImage setVisible: NO ];
            [ disabledImage setVisible: NO ];
        }
        
	} else {
		if(disabledImage != nil)
        {
			[ normalImage setVisible: NO ];
            [ selectedImage setVisible: NO ];
            [ disabledImage setVisible: YES ];
        }
		else
        {
			[ normalImage setVisible: YES ];
            [ selectedImage setVisible: NO ];
            [ disabledImage setVisible: NO ];
        }
	}
}

-(void) unselected
{
	selected = NO;
    if(isEnabled) {
		if( selected )
        {
            [ normalImage setVisible: NO ];            
            [ disabledImage setVisible: NO ];
            [ selectedImage setVisible: YES ];
        }
		else
        {
            [ selectedImage setVisible: NO ];
            [ disabledImage setVisible: NO ];
            [ normalImage setVisible: YES ];
        }
        
	} else {
		if(disabledImage != nil)
        {
			[ normalImage setVisible: NO ];
            [ selectedImage setVisible: NO ];
            [ disabledImage setVisible: YES ];
        }
		else
        {
            [ selectedImage setVisible: NO ];
            [ disabledImage setVisible: NO ];
            [ normalImage setVisible: YES ];
        }
	}
}

- (BOOL) isSelected
{
    return selected;
}

- (void) forceRect: (CGRect) aRect
{
    _forceRect = YES;
    _forcedRect = aRect;
}

- (void) unForceRect 
{
    _forceRect = NO;
}

-(CGRect) rect
{
    if ( _forceRect )
    {
        return _forcedRect;
    }
    
	CGSize s = [normalImage contentSize];
	
	CGRect r = CGRectMake( position_.x - s.width/2, position_.y-s.height/2, s.width, s.height);
	return r;
}

-(CGSize) contentSize
{    
	return [normalImage contentSize];
}

-(void) draw
{
	//if(isEnabled) {
//		if( selected )
//			[selectedImage draw];
//		else
//			[normalImage draw];
//        
//	} else {
//		if(disabledImage != nil)
//			[disabledImage draw];
//		
//		// disabled image was not provided
//		else
//			[normalImage draw];
//	}
}

- (void) setOpacity: (GLubyte)newOpacity
{
	opacity = newOpacity;
	[normalImage setOpacity:opacity];
	[selectedImage setOpacity:opacity];
	[disabledImage setOpacity:opacity];
}

@end
