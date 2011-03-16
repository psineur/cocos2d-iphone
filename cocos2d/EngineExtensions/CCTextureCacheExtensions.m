//
//  CCTextureCacheExtensions.m
//  itraceur
//
//  Created by Stepan Generalov on 16.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import "CCTextureCacheExtensions.h"


@interface CCAsyncObject : NSObject
{
	SEL			selector_;
	id			target_;
	id			data_;
}
@property	(readwrite,assign)	SEL			selector;
@property	(readwrite,retain)	id			target;
@property	(readwrite,retain)	id			data;
@end

@interface CCTextureCache (CCAsyncObject)

-(void) addImageWithAsyncObject:(CCAsyncObject*)async;

@end



@implementation CCTextureCache (iTraceurDynamicTiles)

-(void) addImageFromAnotherThreadWithName: (NSString*) filename target:(id)target selector:(SEL)selector
{
	NSAssert(filename != nil, @"TextureCache: fileimage MUST not be nill");
	
	// load here async 
	
	CCAsyncObject *asyncObject = [[ CCAsyncObject alloc] init];
	asyncObject.selector = selector;
	asyncObject.target = target;
	asyncObject.data = filename;
	
	
	[self addImageWithAsyncObject: asyncObject];
	[asyncObject release];
}

@end

@implementation CCTexture2D (Extension)

- (void) setMipMapTexParameters
{
	//use mip map only on Mac - with enough VRAM
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
	[self generateMipmap];
	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };	
	[self setTexParameters:&texParams];
#endif
}

@end
