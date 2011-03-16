//
//  AtlasLoader.m
//  itraceur
//
//  Created by Stepan Generalov on 13.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import "AtlasLoader.h"


@implementation AtlasLoader

@synthesize frames;
@synthesize texture;


/// Creates loader and loads texture to it immideatily with files:
/// anAtlasName + ".atlas.plist" for frames plist
/// anAtlasName + ".atlas.png" for texture
+(id) atlasLoaderWithAtlasName: (NSString *) anAtlasName
{
    // create loader with plist
    NSString *path = [ [NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.atlas", anAtlasName] 
                                                      ofType:@"plist" ];
    AtlasLoader *ldr = [ self atlasLoaderWithFile:path ];
    
    //load texture
    path = [ [NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.atlas", anAtlasName] 
                                            ofType:@"png" ];    
    [ldr loadTextureWithFile: path];
    
    return ldr;
}

+(id) atlasLoaderWithFile: (NSString *) filePlist
{
    return [[[self alloc] initWithFile:filePlist] autorelease];
}

/** inits and atlasLoader instance */
-(id) initWithFile: (NSString *) filePlist
{
    if ( self = [super init] )
    { 
        texture = nil;
        
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        //tmp dict for plist
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: filePlist ];
        //out mutable dict for frames with rigth capacity
        frames = [[ [NSMutableDictionary alloc] initWithCapacity: [ dict count] ] retain];
        
        //read data
        for ( id key in dict )
        {
            NSDictionary *props = [dict valueForKey: key];
            NSNumber *x = [props valueForKey:@"x"];
            NSNumber *y = [props valueForKey:@"y"];
            NSNumber *w = [props valueForKey:@"w"];
            NSNumber *h = [props valueForKey:@"h"];
            //NSNumber *offsetX = [props valueForKey:@"offsetX"];
            //NSNumber *offsetY = [props valueForKey:@"offsetY"];
            
            CGRect rect = CGRectMake( (CGFloat)[x intValue], (CGFloat)[y intValue], (CGFloat)[w intValue], (CGFloat)[h intValue]);
            //CGPoint off = CGPointMake( (CGFloat)[offsetX intValue],(CGFloat)[offsetY intValue]);
			
			
            CCSpriteFrame *frame = [ [ CCSpriteFrame alloc] initWithTexture: texture 
															   rectInPixels: rect 
																	rotated: NO 
																	 offset: ccp(0,0)//< was cpv( 22, 33)
															   originalSize: rect.size//< was CGSizeMake(128, 128)  
									];
            //frame.loaderTag = [self tag];
            [frames setObject: frame forKey: key];
            [frame release]; //< don't wanna do this in dealloc dude
        }
        
        //cleanUp - only NSMutableArray frame and all frames in it are non-autorelease objects
        [pool release]; 
        
    }
    return self;
}

// creates new manager
-( CCSpriteBatchNode *) manager
{
    if (!texture)
        return nil;
    
    CCSpriteBatchNode *m = [ CCSpriteBatchNode batchNodeWithTexture: texture capacity:[frames count] ];
    return m;
}



/** returns AtlasAnimation with frames begining from [animationName]1.[ext] to [animationName]count.[ext]
 *ext can be nil - it means no extension, count can be 0 - result will be nil, animationName must not be nil
 * if frame with that name doesn't exists - it will be skiped*/
- (CCAnimation *) prepareAnimationWithName: (NSString *) animationName framesCount: (NSUInteger) count ofType: (NSString *) ext delay: (ccTime) delay
{
    if (!count)
        return nil;
	
	NSAssert(animationName, @"AtlasLoader prepareAnimation - argument animationName must not be nil!");
    
	
	// Prepare Formatted String
    NSMutableString *formatString = [NSMutableString stringWithString: animationName];
    [formatString appendString:@"%d"];
    
    if ( ext )
    {
        [formatString appendString:@"."]; //< Pikachu with one big ear, NYAAAAA XD
        [formatString appendString: ext];
    }
	
	// Create Array of Frames Names
	NSMutableArray *array = [NSMutableArray arrayWithCapacity: count];    
    for (int i = 1; i <= count; ++i )
    {
        NSString *frameString = [NSString stringWithFormat:formatString, i];
		[array addObject: frameString ];
        
    }
	
	// Create and Return Animation
    return [ self animationWithFramesNames: array delay: delay ];
}

- (CCAnimation *) animationWithFramesNames: (NSArray *) framesStrings delay: (ccTime) aDelay
{
	NSMutableArray *framesArray = [ NSMutableArray arrayWithCapacity: [framesStrings count] ];
	
	for (NSString *frameName in framesStrings)
	{
		CCSpriteFrame *frame = [frames valueForKey: frameName];
		if (frame)
			[framesArray addObject: frame];
	}
	
	return [CCAnimation animationWithFrames: framesArray delay: aDelay];
}


/** changes texture file to fileImage, after calling this method you can access AtlasManager
 * you can use one coordinates.plist with many textures:
 * if you changes texture with this method, old AtlasManager will be released once and AtlasLoader could no more give it
 * to you wih manager property - it will return new one*/
-(void) loadTextureWithFile: (NSString *) fileImage
{
    //changing to another texture?
    [texture release];    
    
    texture = [ [[CCTextureCache sharedTextureCache] addImage:fileImage] retain];
	
	for (NSString *key in frames)
	{
		CCSpriteFrame *frame = [frames objectForKey: key];
		frame.texture = texture;
	}
}

-(void) dealloc
{    
    [texture release];    
    [frames release];    
    [super dealloc];
}

@end
