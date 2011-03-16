//
//  AtlasLoader.h
//  itraceur
//
//  Created by Stepan Generalov on 13.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"



/** AtlasLoader is designed to easily import AtlasSpriteFrames from Texture Atlas Creator
 * Texture Atlas Creator imports 2 files: Texture.png and Coordinates Plist
 * Texture.png is atlas image
 * Coordinates.plist is property list of each frame:
 *  - position of top-left frame's corner
 *  - size of frame
 *  - offset from non-croped frame center to croped ( if crop enabled this value is nonZero )
 *
 * One AtlasLoader loads one pair of atlas texture and coordinates
 * manager property returns AtlasSpriteManager prepared for use with AtlasSpriteFrames returned in NSDictionary from
 * frames property. All frames and manager have the same loaderTag.
 * 
 * Advanced features:
 * automatic animation extraction. So if you have frames with keys i.e. run1.png, run2.png, run3.png, run4.png then
 * you could use prepareAnimationWithName: @"run" framesCount: 4 ofType: @"png" delay: 1 / 4.0f
 *
 * How-to Use:
 * create atlasLoader from plist file, then load texture to AtlasSpriteManager to create it with right capacity and
 * you can use it with frames.
 *
 * 
 * if you use "Crop Image" feature then set sprites autoCenter to true and use only centered sprite Anchor
 * however if this isn't good for you - you can pack AtlasSprite in Sprite with position in center and use any transformAnchor you need
 * or use MultiAtlasSprite
 * 
 */
@interface AtlasLoader : NSObject
{
    // loaded texture
    CCTexture2D *texture;
    
    //frames from coordinates.plist
    NSMutableDictionary *frames;
}

/** returns an internal NSMutableDict of frames as NSDict */
@property (readonly) NSDictionary *frames;

@property (readonly) CCTexture2D *texture;


/** creates atlasLoader from atlas name only, automativally loads texture for it. So if plist is like "foo.atlas.plist" then atlas name will be
 "foo" and png will be "foo.atlas.png"
 */
+(id) atlasLoaderWithAtlasName: (NSString *) anAtlasName;

/** creates an atlasLoader from coordinates.plist file and initiates all it's frames - so you can seek through 
 NSDictionary with source frames filenames as keys and frames as values*/
+(id) atlasLoaderWithFile: (NSString *) filePlist;

/** inits and atlasLoader instance */
-(id) initWithFile: (NSString *) filePlist;

/** loads texture from image file */
-(void) loadTextureWithFile: (NSString *) fileImage;

// creates associated by lTag manager for loader
- (CCSpriteBatchNode *) manager;

/** Autoanimator for atlas base on filename and count. Filenameformat = "[animationName]I(suffix), where I is NSUinteger from 1 to count" */
- (CCAnimation *) prepareAnimationWithName: (NSString *) animationName framesCount: (NSUInteger) count ofType: (NSString *) ext delay: (ccTime) delay;


- (CCAnimation *) animationWithFramesNames: (NSArray *) framesStrings delay: (ccTime) aDelay;

@end

