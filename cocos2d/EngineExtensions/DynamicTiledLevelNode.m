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

#import "DynamicTiledLevelNode.h"
#import "CCTextureCacheExtensions.h"


// PRELOAD_ALL_TILES
// if 1 - tiles will be preloaded and their textures will be retained
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
	#define PRELOAD_ALL_TILES 1
#elif defined(__IPHONE_OS_VERSION_MAX_ALLOWED)
	#define PRELOAD_ALL_TILES 0
#endif

// DYNAMIC_THREADED_TILE_LOAD
// if 1 - tiles will load from another thread, 
//    0 - will load dynamically from main CCDirector thread with possible freezes
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
	#define DYNAMIC_THREADED_TILE_LOAD 0
#elif defined(__IPHONE_OS_VERSION_MAX_ALLOWED)
	#define DYNAMIC_THREADED_TILE_LOAD 1
#endif




#pragma mark Dynamic Tiles Nodes


@interface DynamicTiledLevelNode (Private)

- (void) updateLoadRects;
- (void) updateTiles;

@end

@implementation  DynamicTiledLevelNode
@synthesize tilesLoadThread = _tilesLoadThread;
@dynamic position;


- (void) setPosition:(CGPoint) newPosition
{
	CGFloat significantPositionDelta = MIN(_screenRectToLoadedRectExtension.width, 
										   _screenRectToLoadedRectExtension.height) / 2.0f;
	
	if ( ccpLength(ccpSub(newPosition, [self position])) > significantPositionDelta )
		_significantPositionChange = YES;
	
	[super setPosition: newPosition];
}


+ (id) nodeWithScreenRectExtension: (CGSize) rectExtension
{
	return [ [self alloc] initWithScreenRectExtension: rectExtension ];
}

- (id) initWithScreenRectExtension: (CGSize) rectExtension
{
	if (self = [super init])
	{		
		_screenRect = _loadedRect = CGRectZero;
		
		_dynamicChildren = nil;
		
		_screenRectToLoadedRectExtension = rectExtension;
	}
	return self;
}



- (void) dealloc
{
	[_levelTextures release];
	[_dynamicChildren release];
	
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[super dealloc];
}




- (void) onEnter
{
	[super onEnter];
	
#if DYNAMIC_THREADED_TILE_LOAD
	//создать поток загрузки необходимых тайлов
	self.tilesLoadThread = [[NSThread alloc] initWithTarget: self
												   selector: @selector(updateTiles:)
													 object: nil];
	[_tilesLoadThread release];
	
	_tilesLoadThreadIsSleeping = NO;
	[_tilesLoadThread start];
#endif
}

- (void) onExit
{	
	//выключить поток загрузки необходимых тайлов
	[_tilesLoadThread cancel];
	self.tilesLoadThread = nil;
		
	[super onExit];
}

-(void) visit
{	
	[self updateLoadRects];
	
#if DYNAMIC_THREADED_TILE_LOAD
	//nothing
#else
	[self updateTiles];
#endif
	[super visit];	
	
#define ITRACEUR_DYNAMICTILEDLEVELNODE_REMOVEUNUSEDTEXTURES_RARE_STEPS 3
	static int i = ITRACEUR_DYNAMICTILEDLEVELNODE_REMOVEUNUSEDTEXTURES_RARE_STEPS;
	if (--i <= 0)
	{
		i = ITRACEUR_DYNAMICTILEDLEVELNODE_REMOVEUNUSEDTEXTURES_RARE_STEPS;
		if (_tilesLoadThreadIsSleeping)
			[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	}
}



- (void) updateLoadRects
{
	// get screen rect
	_screenRect.origin = [self convertToNodeSpace: CGPointMake(0, 0 )];
	_screenRect.size = [[CCDirector sharedDirector] winSize];
	
	// get level's must-be-loaded-part rect
	_loadedRect = CGRectMake(_screenRect.origin.x - _screenRectToLoadedRectExtension.width,
								   _screenRect.origin.y - _screenRectToLoadedRectExtension.height,
								   _screenRect.size.width + 2.0f * _screenRectToLoadedRectExtension.width,
								   _screenRect.size.height + 2.0f * _screenRectToLoadedRectExtension.height);
	
	// avoid tiles blinking
	if (_significantPositionChange)
	{
		[self updateTiles];
		_significantPositionChange = NO;
	}
}


// new update tiles for threaded use
- (void) updateTiles: (NSObject *) notUsed
{	
	while( ![[NSThread currentThread] isCancelled] ) 
	{
		
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		
		_tilesLoadThreadIsSleeping = NO;//< removeUnusedTextures only when sleeping - to disable deadLocks
		
		//[self updateTiles];
		for (UnloadableSpriteNode *child in _dynamicChildren)
			if (  0 == ( CGRectIntersection([child boundingBox], _loadedRect).size.width )  )
				[child unload];
			else 
				[child load];
		//< 0 == size.width must be faster than CGRectIsEmpty
		
		
		_tilesLoadThreadIsSleeping = YES; //< removeUnusedTextures only when sleeping - to disable deadLocks
		[NSThread sleepForTimeInterval: 0.03  ]; //< 60 FPS run, update at 30 fps should be ok 
		
		[pool release];
	}
}

- (void) updateTiles
{	
	//load loadedRect tiles and unload tiles that are not in loadedRect
	for (UnloadableSpriteNode *child in _dynamicChildren)
		if (  0 == ( CGRectIntersection([child boundingBox], _loadedRect).size.width )  )
		{
#if PRELOAD_ALL_TILES
			// do not unload any tiles
#else
			[child unload];
#endif
		}
		else 
			[child load];
	//< 0 == size.width must be faster than CGRectIsEmpty	
}

-(void) loadTilesInRect: (CGRect) loadRect
{
	for (UnloadableSpriteNode *child in _dynamicChildren)
		if (  0 != ( CGRectIntersection([child boundingBox], loadRect).size.width )  )
			[child load];
}




// загружает динамические спрайты - очень удобно
// для размера массива и отдельных детишек
- (void) prepareTilesWithFile: (NSString *) plistFile
{
    // load plist with sprites propertys
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    NSArray *arr = [NSArray arrayWithContentsOfFile: plistFile ];
    
    if ( !arr )
    {
        CCLOGERROR(@"DynamicTiledNode#prepareSpritesWithFile: %@ failed - cant load array ", plistFile);
		[pool release];
        return;
    }
	
	_dynamicChildren = [[NSMutableArray arrayWithCapacity: [arr count]] retain];
    
	//read data and create nodes and add them
    for ( NSDictionary *dict in arr )
    {		
        // All properties of Dictionary
        NSString *spriteName = [ dict valueForKey: @"spriteName"  ];
        NSNumber  *x = [ dict valueForKey: @"x" ];
        NSNumber  *y = [ dict valueForKey: @"y" ];
        NSNumber  *width = [dict valueForKey: @"width"];
        NSNumber  *height = [dict valueForKey: @"height"];
		NSNumber *tileScaleX = [ dict valueForKey: @"scaleX" ];
		NSNumber *tileScaleY = [ dict valueForKey: @"scaleY" ];
		
		
				
		// if there's no such file - don't create tile from it
		NSString *resourcesDirectoryPath = [ [NSBundle mainBundle] resourcePath ];  	
		NSString *filePath = [resourcesDirectoryPath stringByAppendingPathComponent: spriteName];
		
		if ( ! [[NSFileManager defaultManager] fileExistsAtPath: filePath] )
			continue;
        
		// Position & Scalex floats
        CGPoint tilePosition;
        tilePosition.x = (CGFloat)[x intValue];
        tilePosition.y = (CGFloat)[y intValue]; 	
        CGFloat scaleXFloat = (CGFloat)[tileScaleX intValue]; 
        CGFloat scaleYFloat = (CGFloat)[tileScaleY intValue];
        
		
		// Create Tile
		CGRect tileRect = CGRectMake( tilePosition.x, tilePosition.y, (CGFloat)[width intValue], (CGFloat)[height intValue]);		
		UnloadableSpriteNode *tile = [ [UnloadableSpriteNode alloc] initWithImage: spriteName 
																		  forRect: tileRect];
		
		// Set it's Flip
		tile.scaleX = scaleXFloat;
		if (scaleYFloat)
			tile.scaleY = scaleYFloat;		
		 
		// Add CCNode
		[self addChild: tile];		
		
		// remember it in Dynamic Children		                                                               
        [_dynamicChildren addObject: tile ];
		[tile release];        
        
		
    } //< for dict in arr
	
#if PRELOAD_ALL_TILES
	_levelTextures = [[NSMutableArray arrayWithCapacity: [_dynamicChildren count]] retain];
	for (UnloadableSpriteNode *child in _dynamicChildren)
	{
		[child load];
		CCSprite *sprite = [child sprite];
		CCTexture2D *tex = sprite.texture;
		if (tex)
			[_levelTextures addObject: tex];
	}
#endif
	
    [pool release];
} 



@end


@interface UnloadableSpriteNode ( Private )

- (void) load;
- (void) unload;
- (void) loadedTexture: (CCTexture2D *) aTex;

@end


@implementation UnloadableSpriteNode

#pragma mark Properties
@synthesize sprite = _sprite;
@synthesize imageName = _imageName;

#pragma mark Init 

- (id) initWithImage: (NSString *) anImage forRect: (CGRect) aRect
{
	if (self = [super init])
	{
		self.imageName = anImage;
		
		_activeRect = aRect;
		
		self.anchorPoint = ccp(0,0);
		self.position = aRect.origin;
	}
	return self;
}

#pragma mark CocosNode


// small visit for only one sprite
-(void) visit
{
	// quick return if not visible
	if (!visible_)
		return;
	
	glPushMatrix();
	
	[self transform];
	
	[self.sprite visit];
		
	
	glPopMatrix();
}

- (CGRect) boundingBox
{
	return _activeRect;
}

- (void) dealloc
{
	self.sprite = nil;	
	self.imageName = nil;
	
	[super dealloc];
}

#pragma mark Load/Unload 

- (void) loadedTexture: (CCTexture2D *) aTex
{
	
	[aTex setAntiAliasTexParameters];
	//[aTex setMipMapTexParameters];
	
	
	//create sprite, position it and at to self
	self.sprite = [[ [CCSprite alloc] initWithTexture: aTex] autorelease];
	self.sprite.anchorPoint = ccp(0,0);
	self.sprite.position = ccp(0,0);
	
	// fill our activeRect fully with sprite (stretch if needed)
	self.sprite.scaleX = _activeRect.size.width / [self.sprite contentSize].width;
	self.sprite.scaleY = _activeRect.size.height / [self.sprite contentSize].height;
}

- (void) unload
{
	self.sprite = nil;
}


- (void) load
{
	if (self.sprite)
		return; //< already loaded
	
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];

	
	if ([NSThread currentThread] != [[CCDirector sharedDirector] runningThread] )
	{
		// _cmd called in other thread - load safely 
		[  [CCTextureCache sharedTextureCache] addImageFromAnotherThreadWithName: _imageName 
																		  target: self 
																		selector: @selector(loadedTexture:) ];		
	}
	else 
	{
		// _cmd called in cocos thread - load now
		[self loadedTexture: [[CCTextureCache sharedTextureCache] addImage: _imageName ] ];
	}

}

@end


@interface NSRectObject : NSObject
{
	CGRect _rect;
}
@property(readonly) CGRect rect;

+ (id) rectWithRect: (CGRect) aRect;
- (id) initWithRect: (CGRect) aRect;


@end

@implementation NSRectObject
@synthesize rect = _rect;

+ (id) rectWithRect: (CGRect) aRect
{
	return [[[self alloc] initWithRect: aRect ] autorelease ];
}

- (id) initWithRect: (CGRect) aRect
{
	if (self = [super init])
	{
		
		_rect = aRect;
	}
	
	return self;
}

@end
