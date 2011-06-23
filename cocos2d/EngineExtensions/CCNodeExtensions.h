//
//  CCNodeExtensions.h
//  iTraceur - Parkour / Freerunning Platform Game
//
//  Created by Stepan Generalov on 16.11.10.
//  Copyright 2010-2011 Parkour Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCMenuAdvanced.h"
#import "CCMenuItemSpriteIndependent.h"



@interface CCActionManager (ExtensionsForiTraceur)

-(void) removeAllActionsByTag:(int) aTag target:(id)target;

@end


@interface CCNode (ExtensionsForiTraceur)
@property( readwrite) CGPoint anchorPointInPixels;

- (void) stopAllActionsByTag: (NSUInteger) aTag;
- (void) setAnchorPointInPixels: (CGPoint) newAcnhor;

@end

@interface CCParallaxNode (ExtensionsForiTraceur)

- (void) forcePositionUpdate;

@end


// TODO: Remove this class. Deprecated
// WARNING: this is old CCMenuItemSpriteIndependent that need a lot of support code
// for each menu item (positioning). Better CCMenuItemSPriteIndependent taken from
// cocoshop is available in CCMenuItemSpriteIndependent.h
//
// CCMenuItemSprite is CCMenuItemSprite that doesn't add normal, selected
// and disabled images as children. Instead of that its just retain them.
// So you can place images anyhow you want.
// 
// Note: content size will be set from normalImage_ on init in CCMenuItemSprite
//		CCMenuItemSpriteIndependentOld changes only the way of holding images
@interface CCMenuItemSpriteIndependentOld : CCMenuItemSprite
@end

@interface CCLayerScroll : CCLayer
{
	CCNode *_scrollingChild;
}

// node that will scroll inside CCLayerScroll
@property (readwrite, retain) CCNode* scrollingChild;


// don't know is it working
- (void) scrollUp;

// tries to make aNode visible through scrolling to it
- (void) ensureVisible: (CCNode *) aNode;


// might be usefull after changing CCLayerScroll's contentSize
- (void) fixScrollingChildPosition;

@end


// color will be changed instead of zooming the element
@interface CCMenuItemLabeliTraceur : CCMenuItemLabel
{
	ccColor3B _originalLabelColor;
	ccColor3B _selectedColor;
}
@property (readwrite, assign) ccColor3B selectedColor; 

- (void) selected;
- (void) unselected;

@end

// CCMenuItemSpriteIndependent without selected image - it just scales like CCMenuItemLabel
// when selected/unselected.
// With additional NSString property to distinguish different items.
@interface CCMenuItemSpriteSimple : CCMenuItemSpriteIndependent
{
	CGFloat originalScale_;
	NSString *name_;
}

@property(readwrite, copy)NSString *name;

+(id) itemFromSprite:(CCNode<CCRGBAProtocol>*)normalSprite target:(id)target selector:(SEL)selector;
-(id) initFromSprite:(CCNode<CCRGBAProtocol>*)normalSprite target:(id)target selector:(SEL)selector;

@end

@interface CCMenuPrioritized : CCMenu
{
	NSInteger _priority;
}
@property (readwrite, assign) NSInteger priority;
+ (id) menuWithPriority: (NSInteger) prior Items: (CCMenuItem *) firstItem, ... NS_REQUIRES_NIL_TERMINATION;
@end







