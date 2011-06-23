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







