/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "ccMacros.h"
#import "CCAnimation.h"
#import "CCSpriteFrame.h"
#import "CCTexture2D.h"
#import "CCTextureCache.h"
#import "CCAnimationCache.h"
#import "AutoMagicCoding/NSObject+AutoMagicCoding.h"

@implementation CCAnimation
@synthesize name = name_, delay = delay_, frames = frames_;

+(id) animation
{
	return [[[self alloc] init] autorelease];
}

+(id) animationWithFrames:(NSArray*)frames
{
	return [[[self alloc] initWithFrames:frames] autorelease];
}

+(id) animationWithFrames:(NSArray*)frames delay:(float)delay
{
	return [[[self alloc] initWithFrames:frames delay:delay] autorelease];
}

-(id) init
{
	return [self initWithFrames:nil delay:0];
}

-(id) initWithFrames:(NSArray*)frames
{
	return [self initWithFrames:frames delay:0];
}

-(id) initWithFrames:(NSArray*)array delay:(float)delay
{
	if( (self=[super init]) ) {
		
		delay_ = delay;
		self.frames = [NSMutableArray arrayWithArray:array];
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | name = %@, frames=%@, delay:%f>", [self class], self,
            name_,
			frames_,
			delay_
			];
}

-(void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@",self);
	[name_ release];
	[frames_ release];
	[super dealloc];
}

-(void) addFrame:(CCSpriteFrame*)frame
{
	[frames_ addObject:frame];
}

-(void) addFrameWithFilename:(NSString*)filename
{
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:filename];
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect];
	[frames_ addObject:frame];
}

-(void) addFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect];
	[frames_ addObject:frame];
}

- (BOOL) isEqual:(id)object
{
    CCAnimation *other = (CCAnimation *) object;
    if (![other isKindOfClass:[CCAnimation class]])
        return NO;
    
    if (self.name != other.name)
        return NO;
    
    if (self.delay != other.delay)
        return NO;
    
    NSUInteger framesCount = [self.frames count];
    if (framesCount != [other.frames count])
        return NO;
    
    for (NSUInteger i = 0; i < framesCount; ++i)
    {
        CCSpriteFrame *myFrame = [self.frames objectAtIndex: i];
        CCSpriteFrame *otherFrame = [other.frames objectAtIndex: i];
        
        if (![myFrame isEqual:otherFrame])
            return NO;
    }
    
    return YES;
}

#pragma mark CCAnimation - AutoMagicCoding Support

+ (BOOL) AMCEnabled
{
    return YES;
}

- (id) initWithDictionaryRepresentation: (NSDictionary *) aDict
{
    // Get name of loading animation.
    NSString *name = [aDict objectForKey:@"name"];
    if ([name isKindOfClass:[NSString class]])
    {
        // Find existing animation with same name.
        CCAnimation *existingAnimationWithSameName = [[CCAnimationCache sharedAnimationCache] animationByName: name];
        if (existingAnimationWithSameName)
        {
            // On debug - warn developer if existing & loading animations with same names arent equal.
#if COCOS2D_DEBUG 
            
            if ( (self = [super initWithDictionaryRepresentation: aDict]) )
            {
                if (![self isEqual: existingAnimationWithSameName])
                {
                    CCLOG(@"WARNING: Loading animation \"%@\" isn't equal to existing animation with same name in CCAnimationCache. Ignoring new one and using cached version! New = %@ Cached = %@", self.name, self, existingAnimationWithSameName);
                }
            }
#endif
            
            // Return existing animation.
            [self release];
            return [existingAnimationWithSameName retain]; 
            //< init must return NSObject with +1 refCount.
        }
        else // Create new and save it in AnimationCache
        {
            self = [super initWithDictionaryRepresentation: aDict];
            if (self)
            {
                [[CCAnimationCache sharedAnimationCache] addAnimation:self name:self.name];
            }
            
            return self;
        }
    }
    
    // Noname animation - simply create new.
    return [super initWithDictionaryRepresentation: aDict];
}

@end
