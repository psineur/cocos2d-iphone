//
//  DynamicTiledLevelNode.h
//	Node, that holds tiles, that are loaded/unloaded dynamically.
//	Makes possible to hold large level images.
//
//  iTraceur - Parkour / Freerunning Parkour Game
//
//  Created by Stepan Generalov on 4/5/10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import "cocos2d.h"

// OptimizedCocosNode that also holds some Sprites (non-atlas) dynamicaly
// LIMITATIONS: scale not supported, CCCamera not supported, 
//  transitions other than simple positioning also unsupported 
@interface DynamicTiledLevelNode : CCNode
{	
	// ==== Init Info ====
	CGSize _screenRectToLoadedRectExtension; 
	//< sets how much more tiles we should load in comare with visible tiles
	
	// ==== Load Zones Rects ====
	CGRect _screenRect, _loadedRect;
	
	// ==== Children ====
	NSMutableArray *_dynamicChildren;
	NSMutableArray *_levelTextures; //< holds textures if PRELOAD_ALL_TILES used
	
	// ==== Tile Loading Mechanism =====
	NSThread *_tilesLoadThread;
	BOOL _tilesLoadThreadIsSleeping; //< status of loading tiles thread to know when to unload textures
	BOOL _significantPositionChange; //< if YES - tiles load will be forced
	
}
@property(retain) NSThread *tilesLoadThread;


+ (id) nodeWithScreenRectExtension: (CGSize) rectExtension;
- (id) initWithScreenRectExtension: (CGSize) rectExtension;

- (void) prepareTilesWithFile: (NSString *) plistFile;

-(void) loadTilesInRect: (CGRect) loadRect;

@end


/// Static Sprite Node for handling Sprite, which can be dynamically load and unload textures from memory if needed
/// handles one sprite(non atlas) only
@interface UnloadableSpriteNode : CCNode
{	
	//initial info
	NSString *_imageName;
	CGRect _activeRect;
	
	// sprite used to render content if they are loaded	
	CCSprite *_sprite;
}
@property(retain) CCSprite *sprite;
@property(copy) NSString *imageName;

- (id) initWithImage: (NSString *) anImage forRect: (CGRect) aRect;

- (CGRect) boundingBox;

- (void) load;
- (void) unload;

@end
