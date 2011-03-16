//
//  CCNodeExtensions.h
//  itraceur
//
//  Created by Stepan Generalov on 16.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCMenuAdvanced.h"



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


// CCMenuItemSprite is CCMenuItemSprite that doesn't add normal, selected
// and disabled images as children. Instead of that its just retain them.
// So you can place images anyhow you want.
// 
// Note: content size will be set from normalImage_ on init in CCMenuItemSprite
//		CCMenuItemSpriteIndependent changes only the way of holding images
@interface CCMenuItemSpriteIndependent : CCMenuItemSprite
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

@interface CCMenuPrioritized : CCMenu
{
	NSInteger _priority;
}
@property (readwrite, assign) NSInteger priority;
+ (id) menuWithPriority: (NSInteger) prior Items: (CCMenuItem *) firstItem, ... NS_REQUIRES_NIL_TERMINATION;
@end







