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


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	#import <UIKit/UIKit.h>
#endif

#import "CCNode.h"

@class Label;
@class LabelAtlas;
@class Sprite;
@class CCSprite;

#define kItemSize 32

/** Menu Item base class
 */
@interface MenuItem : CCNode <CCRGBAProtocol>
{
	NSInvocation *invocation;
	BOOL isEnabled;
	GLubyte opacity;
}

/** Opacity property. Conforms to CocosNodeOpacity protocol */
@property (readwrite,assign) GLubyte opacity;

/** Creates a menu item with a target/selector */
+(id) itemWithTarget:(id) r selector:(SEL) s;

/** Initializes a menu item with a target/selector */
-(id) initWithTarget:(id) r selector:(SEL) s;

/** Returns the outside box */
-(CGRect) rect;

/** Activate the item */
-(void) activate;

/** The item was selected (not activated), similar to "mouse-over" */
-(void) selected;

/** The item was unselected */
-(void) unselected;

/** Enable or disabled the MenuItem */
-(void) setIsEnabled: (BOOL)enabled;
/** Returns whether or not the MenuItem is enabled */
-(BOOL) isEnabled;

/** Returns the size in pixels of the texture.
 * Conforms to the CocosNodeSize protocol
 */
-(CGSize) contentSize;
@end


/** A MenuItemImage */
@interface MenuItemImage : MenuItem
{
	BOOL selected;
	CCSprite *normalImage, *selectedImage, *disabledImage;
}

/// Sprite (image) that is displayed when the MenuItem is not selected
@property (readonly) CCSprite *normalImage;
/// Sprite (image) that is displayed when the MenuItem is selected
@property (readonly) CCSprite *selectedImage;
/// Sprite (image) that is displayed when the MenuItem is disabled
@property (readonly) CCSprite *disabledImage;

/** creates a menu item with a normal and selected image*/
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2;
/** creates a menu item with a normal and selected image with target/selector */
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s;
/** creates a menu item with a normal,selected  and disabled image with target/selector */
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;
/** initializes a menu item with a normal, selected  and disabled image with target/selector */
-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;

- (BOOL) isSelected;

@end


/** A MenuItemCCSprite */
@interface MenuItemAtlasImage : MenuItem
{
	BOOL selected;
	CCSprite *normalImage, *selectedImage, *disabledImage;
    
    BOOL _forceRect;
    CGRect _forcedRect; 
}

/// Sprite (image) that is displayed when the MenuItem is not selected
@property (readonly) CCSprite *normalImage;
/// Sprite (image) that is displayed when the MenuItem is selected
@property (readonly) CCSprite *selectedImage;
/// Sprite (image) that is displayed when the MenuItem is disabled
@property (readonly) CCSprite *disabledImage;

/** creates a menu item with a normal and selected image*/
+(id) itemFromNormalSprite: (CCSprite*)value selectedSprite:(CCSprite*) value2;
/** creates a menu item with a normal and selected image with target/selector */
+(id) itemFromNormalSprite: (CCSprite*)value selectedSprite:(CCSprite*) value2 target:(id) r selector:(SEL) s;
/** creates a menu item with a normal,selected  and disabled image with target/selector */
+(id) itemFromNormalSprite: (CCSprite*)value selectedSprite:(CCSprite*) value2 disabledSprite:(CCSprite*) value3 target:(id) r selector:(SEL) s;
/** initializes a menu item with a normal, selected  and disabled image with target/selector */
-(id) initFromNormalSprite: (CCSprite*) value selectedSprite:(CCSprite*)value2 disabledSprite:(CCSprite*) value3 target:(id) r selector:(SEL) s;


// use aRect insted of normal image bounds
- (void) forceRect: (CGRect) aRect;
// change back to use normal image bounds
- (void) unForceRect;

- (BOOL) isSelected;

@end
