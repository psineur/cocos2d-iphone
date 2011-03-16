//
//  CCTextureCacheExtensions.h
//  itraceur
//
//  Created by Stepan Generalov on 16.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface  CCTextureCache (iTraceurDynamicTiles)

-(void) addImageFromAnotherThreadWithName: (NSString*) filename target:(id)target selector:(SEL)selector;

@end

@interface CCTexture2D (Extension)

- (void) setMipMapTexParameters;

@end

