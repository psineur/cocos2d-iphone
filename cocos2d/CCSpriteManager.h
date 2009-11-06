/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCNode.h"
#import "CCTextureAtlas.h"
#import "ccMacros.h"

#pragma mark CCSpriteManager

@class CCSprite;

/** CCSpriteManager is the object that draws all the CCSprite objects
 * that belongs to this Manager. Use 1 CCSpriteManager per TextureAtlas
*
 * Limitations:
 *  - The only object that is accepted as child is CCSprite
 *  - It's children are all Aliased or all Antialiased.
 * 
 * @since v0.7.1
 */
@interface CCSpriteManager : CCNode <CCNodeTexture>
{
	CCTextureAtlas *textureAtlas_;
	ccBlendFunc	blendFunc_;
}

/** returns the TextureAtlas that is used */
@property (nonatomic,readwrite,retain) CCTextureAtlas * textureAtlas;

/** conforms to CCNodeTexture protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

/** creates a CCSpriteManager with a texture2d */
+(id)spriteManagerWithTexture:(CCTexture2D *)tex;
/** creates a CCSpriteManager with a texture2d and capacity */
+(id)spriteManagerWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity;
/** creates a CCSpriteManager with a file image (.png, .jpeg, .pvr, etc).
 The file will be loaded using the TextureMgr.
 */
+(id)spriteManagerWithFile:(NSString*) fileImage;
/** creates a CCSpriteManager with a file image (.png, .jpeg, .pvr, etc) and capacity. 
 The file will be loaded using the TextureMgr.
*/
+(id)spriteManagerWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

/** initializes a CCSpriteManager with a texture2d and capacity */
-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity;
/** initializes a CCSpriteManager with a file image (.png, .jpeg, .pvr, etc).
 The file will be loaded using the TextureMgr.
 */
-(id)initWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;

-(NSUInteger)indexForNewChildAtZ:(int)z;
-(void) increaseAtlasCapacity;

/** creates an sprite with a rect in the CCSpriteManage.
 It's the same as:
   - create an standard CCSsprite
   - set the useAtlasRendering = YES
   - set the textureAtlas to the same texture Atlas as the CCSpriteManager
 */
-(CCSprite*) createSpriteWithRect:(CGRect)rect;

/** initializes a previously created sprite with a rect. This sprite will have the same texture as the SpriteManager
 It's the same as:
 - initialize an standard CCSsprite
 - set the useAtlasRendering = YES
 - set the textureAtlas to the same texture Atlas as the CCSpriteManager
 @since v0.9.0
*/ 
-(void) initSprite:(CCSprite*)sprite rect:(CGRect)rect;

/** removes a child given a certain index. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from a CCSpriteManager is very slow
 */
-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup;

/** removes a child given a reference. It will also cleanup the running actions depending on the cleanup parameter.
 @warning Removing a child from a CCSpriteManager is very slow
 */
-(void)removeChild: (CCSprite *)sprite cleanup:(BOOL)doCleanup;
@end