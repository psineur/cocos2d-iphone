/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
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



#import "CCActionInterval.h"
#import "CCActionInstant.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCAnimation.h"
#import "CCNode.h"
#import "Support/CGPointExtension.h"
#import "AutoMagicCoding/NSObject+AutoMagicCoding.h"

//
// IntervalAction
//
#pragma mark -
#pragma mark IntervalAction
@implementation CCActionInterval

@synthesize elapsed = elapsed_;

-(id) init
{
	NSAssert(NO, @"IntervalActionInit: Init not supported. Use InitWithDuration");
	[self release];
	return nil;
}

+(id) actionWithDuration: (ccTime) d
{
	return [[[self alloc] initWithDuration:d ] autorelease];
}

-(id) initWithDuration: (ccTime) d
{
	if( (self=[super init]) ) {
		duration_ = d;
		
		// prevent division by 0
		// This comparison could be in step:, but it might decrease the performance
		// by 3% in heavy based action games.
		if( duration_ == 0 )
			duration_ = FLT_EPSILON;
		elapsed_ = 0;
		firstTick_ = YES;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] ];
	return copy;
}

- (BOOL) isDone
{
	return (elapsed_ >= duration_);
}

-(void) step: (ccTime) dt
{
	if( firstTick_ ) {
		firstTick_ = NO;
		elapsed_ = 0;
	} else
		elapsed_ += dt;

	[self update: MIN(1, elapsed_/MAX(duration_,FLT_EPSILON))];
}

-(void)startOrContinueWithTarget:(id)target
{
    started_ = YES;
	originalTarget_ = target_ = target;
    
    if (!firstTick_)
    {
        [self continueWithTarget: target];
    }
    else
    {
        [self startWithTarget:target];
    }
}

- (void) stop
{
    firstTick_ = YES;
    elapsed_ = 0;
    [super stop];
}

- (CCActionInterval*) reverse
{
	NSAssert(NO, @"CCIntervalAction: reverse not implemented.");
	return nil;
}

#pragma mark CCIntervalAction - AutoMagicCoding Support

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"firstTick_",
             @"elapsed_",
             nil]];
}

@end

//
// Sequence
//
#pragma mark -
#pragma mark Sequence

@interface CCSequence ()

@property (nonatomic, readwrite, retain) CCFiniteTimeAction *actionOne;
@property (nonatomic, readwrite, retain) CCFiniteTimeAction *actionTwo;
@property (nonatomic, readwrite, assign) int last;

@end

@implementation CCSequence
+(id) actions: (CCFiniteTimeAction*) action1, ...
{
	va_list params;
	va_start(params,action1);
	
	CCFiniteTimeAction *now;
	CCFiniteTimeAction *prev = action1;
	
	while( action1 ) {
		now = va_arg(params,CCFiniteTimeAction*);
		if ( now )
			prev = [self actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

+(id) actionsWithArray: (NSArray*) actions
{
	CCFiniteTimeAction *prev = [actions objectAtIndex:0];
	
	for (NSUInteger i = 1; i < [actions count]; i++)
		prev = [self actionOne:prev two:[actions objectAtIndex:i]];
	
	return prev;
}

+(id) actionOne: (CCFiniteTimeAction*) one two: (CCFiniteTimeAction*) two
{	
	return [[[self alloc] initOne:one two:two ] autorelease];
}

-(id) initOne: (CCFiniteTimeAction*) one two: (CCFiniteTimeAction*) two
{
	NSAssert( one!=nil && two!=nil, @"Sequence: arguments must be non-nil");
	NSAssert( one!=actions_[0] && one!=actions_[1], @"Sequence: re-init using the same parameters is not supported");
	NSAssert( two!=actions_[1] && two!=actions_[0], @"Sequence: re-init using the same parameters is not supported");
		
	ccTime d = [one duration] + [two duration];
	
	if( (self=[super initWithDuration: d]) ) {

		// XXX: Supports re-init without leaking. Fails if one==one_ || two==two_
		[actions_[0] release];
		[actions_[1] release];

		actions_[0] = [one retain];
		actions_[1] = [two retain];
	}
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initOne:[[actions_[0] copy] autorelease] two:[[actions_[1] copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[actions_[0] release];
	[actions_[1] release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];	
	split_ = [actions_[0] duration] / MAX(duration_, FLT_EPSILON);
	last_ = -1;
}

-(void) stop
{
	[actions_[0] stop];
	[actions_[1] stop];
	[super stop];
}

-(void) update: (ccTime) t
{
	int found = 0;
	ccTime new_t = 0.0f;
	
	if( t >= split_ ) {
		found = 1;
		if ( split_ == 1 )
			new_t = 1;
		else
			new_t = (t-split_) / (1 - split_ );
	} else {
		found = 0;
		if( split_ != 0 )
			new_t = t / split_;
		else
			new_t = 1;
	}
	
	if (last_ == -1 && found==1)	{
		[actions_[0] startOrContinueWithTarget:target_];
        if ([actions_[0] isKindOfClass:[CCActionInterval class]])
        {
            [actions_[0] setValue:[NSNumber numberWithBool: NO] forKey:@"firstTick_"];
        }
		[actions_[0] update:1.0f];
		[actions_[0] stop];
	}
    
	if (last_ != found ) {
		if( last_ != -1 ) {
            if ([actions_[last_] isKindOfClass:[CCActionInterval class]])
            {
                [actions_[last_] setValue:[NSNumber numberWithBool: NO] forKey:@"firstTick_"];
            }
			[actions_[last_] update: 1.0f];
			[actions_[last_] stop];
		}
		[actions_[found] startOrContinueWithTarget:target_];
	}
    
    if ([actions_[found] isKindOfClass:[CCActionInterval class]])
    {
        [actions_[found] setValue:[NSNumber numberWithBool: NO] forKey:@"firstTick_"];
    }
	[actions_[found] update: new_t];
	last_ = found;
}

- (CCActionInterval *) reverse
{
	return [[self class] actionOne: [actions_[1] reverse] two: [actions_[0] reverse ] ];
}

#pragma mark CCSequence - AutoMagicCoding Support

@dynamic actionOne, actionTwo;
@synthesize last = last_;

- (CCAction *) actionOne
{
    return actions_[0];
}

- (void) setActionOne:(CCFiniteTimeAction *)actionOne
{
    if (actions_[0] != actionOne)
    {
        [actions_[0] release];
        actions_[0] = [actionOne retain];
    }
}

- (CCAction *) actionTwo
{
    return actions_[1];
}

- (void) setActionTwo:(CCFiniteTimeAction *)actionTwo
{
    if (actions_[1] != actionTwo)
    {
        [actions_[1] release];
        actions_[1] = [actionTwo retain];
    }
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:
             @"actionOne",
             @"actionTwo",
             @"last",
             nil]];
}

-(void) continueWithTarget:(id)aTarget
{	
    // Init split & last same as when starting.
	split_ = [actions_[0] duration] / MAX(duration_, FLT_EPSILON);
    
    // Start last active action if it was already started when saving.
    if (last_ >= 0)
    {
        if ([actions_[last_] isKindOfClass:[CCActionInterval class]])
        {
            [actions_[last_] setValue:[NSNumber numberWithBool: NO] forKey:@"firstTick_"];
        }
        [actions_[last_] startOrContinueWithTarget:aTarget];
    }
}

@end

//
// Repeat
//
#pragma mark -
#pragma mark CCRepeat
@implementation CCRepeat
@synthesize innerAction=innerAction_;

+(id) actionWithAction:(CCFiniteTimeAction*)action times:(NSUInteger)times
{
	return [[[self alloc] initWithAction:action times:times] autorelease];
}

-(id) initWithAction:(CCFiniteTimeAction*)action times:(NSUInteger)times
{
	ccTime d = [action duration] * times;
	
	if( (self=[super initWithDuration: d ]) ) {
		times_ = times;
		self.innerAction = action;
		isActionInstant_ = ([action isKindOfClass:[CCActionInstant class]]) ? YES : NO;
		
		//a instant action needs to be executed one time less in the update method since it uses startWithTarget to execute the action
		if (isActionInstant_) times_ -=1;
		total_ = 0;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[[innerAction_ copy] autorelease] times:times_];
	return copy;
}

-(void) dealloc
{
	[innerAction_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	total_ = 0;
	nextDt_ = [innerAction_ duration]/duration_;
	[super startWithTarget:aTarget];
	[innerAction_ startOrContinueWithTarget:aTarget];
}

-(void) stop
{    
    [innerAction_ stop];
	[super stop];
}


// issue #80. Instead of hooking step:, hook update: since it can be called by any 
// container action like Repeat, Sequence, AccelDeccel, etc..
-(void) update:(ccTime) dt
{
	if (dt >= nextDt_) 
	{
		while (dt > nextDt_ && total_ < times_) 
		{
			
			[innerAction_ update:1.0f];
			total_++;
			
			[innerAction_ stop];
			[innerAction_ startOrContinueWithTarget:target_]; 
			nextDt_ += [innerAction_ duration]/duration_;
		}
		
		//don't set a instantaction back or update it, it has no use because it has no duration
		if (!isActionInstant_)
		{
			if (total_ == times_)
			{	
				[innerAction_ update:0];
				[innerAction_ stop];
			}//issue #390 prevent jerk, use right update
			else 
			{	
				[innerAction_ update:dt - (nextDt_ - innerAction_.duration/duration_)]; 
			}
		}
	}
	else 
	{
		[innerAction_ update:fmodf(dt * times_,1.0f)];
	}
}

-(BOOL) isDone
{
	return ( total_ == times_ );
}

- (CCActionInterval *) reverse
{
	return [[self class] actionWithAction:[innerAction_ reverse] times:times_];
}

#pragma mark CCRepeat - AutoMagicCoding Support

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"times_",
             @"total_",
             @"nextDt_",
             @"innerAction",
             nil]];
}

-(void) continueWithTarget:(id)aTarget
{	
    isActionInstant_ = [innerAction_ isKindOfClass:[CCActionInstant class]];
    
    if (elapsed_ && [innerAction_ isKindOfClass:[CCActionInterval class]])
    {
        [innerAction_ setValue:[NSNumber numberWithBool: NO] forKey:@"firstTick_"];
    }
    
    [innerAction_ startOrContinueWithTarget:aTarget];
}



@end

//
// Spawn
//
#pragma mark -
#pragma mark Spawn

@interface CCSpawn ()

@property(nonatomic, readwrite, retain) CCFiniteTimeAction *one;
@property(nonatomic, readwrite, retain) CCFiniteTimeAction *two;

@end

@implementation CCSpawn
+(id) actions: (CCFiniteTimeAction*) action1, ...
{
	va_list params;
	va_start(params,action1);
	
	CCFiniteTimeAction *now;
	CCFiniteTimeAction *prev = action1;
	
	while( action1 ) {
		now = va_arg(params,CCFiniteTimeAction*);
		if ( now )
			prev = [self actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

+(id) actionsWithArray: (NSArray*) actions
{
	CCFiniteTimeAction *prev = [actions objectAtIndex:0];
	
	for (NSUInteger i = 1; i < [actions count]; i++)
		prev = [self actionOne:prev two:[actions objectAtIndex:i]];
	
	return prev;
}

+(id) actionOne: (CCFiniteTimeAction*) one two: (CCFiniteTimeAction*) two
{	
	return [[[self alloc] initOne:one two:two ] autorelease];
}

-(id) initOne: (CCFiniteTimeAction*) one two: (CCFiniteTimeAction*) two
{
	NSAssert( one!=nil && two!=nil, @"Spawn: arguments must be non-nil");
	NSAssert( one!=one_ && one!=two_, @"Spawn: reinit using same parameters is not supported");
	NSAssert( two!=two_ && two!=one_, @"Spawn: reinit using same parameters is not supported");

	ccTime d1 = [one duration];
	ccTime d2 = [two duration];	
	
	if( (self=[super initWithDuration: MAX(d1,d2)] ) ) {

		// XXX: Supports re-init without leaking. Fails if one==one_ || two==two_
		[one_ release];
		[two_ release];

		one_ = one;
		two_ = two;

		if( d1 > d2 )
			two_ = [CCSequence actionOne:two two:[CCDelayTime actionWithDuration: (d1-d2)] ];
		else if( d1 < d2)
			one_ = [CCSequence actionOne:one two: [CCDelayTime actionWithDuration: (d2-d1)] ];
		
		[one_ retain];
		[two_ retain];
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initOne: [[one_ copy] autorelease] two: [[two_ copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[one_ release];
	[two_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[one_ startOrContinueWithTarget:target_];
	[two_ startOrContinueWithTarget:target_];
}

-(void) stop
{
	[one_ stop];
	[two_ stop];
	[super stop];
}

-(void) update: (ccTime) t
{
	[one_ update:t];
	[two_ update:t];
}

- (CCActionInterval *) reverse
{
	return [[self class] actionOne: [one_ reverse] two: [two_ reverse ] ];
}

#pragma mark CCSpawn - AutoMagicCoding Support

@synthesize one = one_;
@synthesize two = two_;

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:
             @"one",
             @"two",
             nil]];
}

-(void) continueWithTarget:(id)aTarget
{	
    // Set one_.firstTick_ & two.firstTick_ to YES to force them to use 
    // -continueWithTarget: instead of -startWithTarget: in -startOrContinueWithTarget.
    if ([one_ isKindOfClass:[CCActionInterval class]])
    {
        [one_ setValue:[NSNumber numberWithBool: firstTick_] forKey:@"firstTick_"];
    }
    
    if ([two_ isKindOfClass:[CCActionInterval class]])
    {
        [two_ setValue:[NSNumber numberWithBool: firstTick_] forKey:@"firstTick_"];
    }    
    
    // Continue.
    [one_ startOrContinueWithTarget:target_];
	[two_ startOrContinueWithTarget:target_];
}

@end

//
// RotateTo
//
#pragma mark -
#pragma mark RotateTo

@implementation CCRotateTo
+(id) actionWithDuration: (ccTime) t angle:(float) a
{	
	return [[[self alloc] initWithDuration:t angle:a ] autorelease];
}

-(id) initWithDuration: (ccTime) t angle:(float) a
{
	if( (self=[super initWithDuration: t]) )
		dstAngle_ = a;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] angle:dstAngle_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	
	startAngle_ = [target_ rotation];
	if (startAngle_ > 0)
		startAngle_ = fmodf(startAngle_, 360.0f);
	else
		startAngle_ = fmodf(startAngle_, -360.0f);
	
	diffAngle_ =dstAngle_ - startAngle_;
	if (diffAngle_ > 180)
		diffAngle_ -= 360;
	if (diffAngle_ < -180)
		diffAngle_ += 360;
}
-(void) update: (ccTime) t
{
	[target_ setRotation: startAngle_ + diffAngle_ * t];
}

#pragma mark CCRotateTo - AutoMagicCoding Support

-(void) continueWithTarget:(id)target
{
    
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"dstAngle_",
             @"startAngle_",
             @"diffAngle_",
             nil]
            ];
}

@end


//
// RotateBy
//
#pragma mark -
#pragma mark RotateBy

@implementation CCRotateBy
+(id) actionWithDuration: (ccTime) t angle:(float) a
{	
	return [[[self alloc] initWithDuration:t angle:a ] autorelease];
}

-(id) initWithDuration: (ccTime) t angle:(float) a
{
	if( (self=[super initWithDuration: t]) )
		angle_ = a;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] angle: angle_];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	startAngle_ = [target_ rotation];
}

-(void) update: (ccTime) t
{	
	// XXX: shall I add % 360
	[target_ setRotation: (startAngle_ +angle_ * t )];
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ angle:-angle_];
}

#pragma mark CCRotateBy - AutoMagicCoding Support

-(void) continueWithTarget:(id)target
{
    
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"angle_",
             @"startAngle_",
             nil]
            ];
}

@end

//
// MoveTo
//
#pragma mark -
#pragma mark MoveTo

@interface CCMoveTo()

@property(nonatomic, readwrite, assign) CGPoint endPosition;
@property(nonatomic, readwrite, assign) CGPoint startPosition;
@property(nonatomic, readwrite, assign) CGPoint delta;

@end

@implementation CCMoveTo
+(id) actionWithDuration: (ccTime) t position: (CGPoint) p
{	
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p
{
	if( (self=[super initWithDuration: t]) )
		endPosition_ = p;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: endPosition_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startPosition_ = [(CCNode*)target_ position];
	delta_ = ccpSub( endPosition_, startPosition_ );
}

-(void) update: (ccTime) t
{	
	[target_ setPosition: ccp( (startPosition_.x + delta_.x * t ), (startPosition_.y + delta_.y * t ) )];
}

#pragma mark CCMoveTo - AutoMagicCoding Support

@synthesize endPosition = endPosition_;
@synthesize startPosition = startPosition_;
@synthesize delta = delta_;

-(void) continueWithTarget:(id)target
{
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"endPosition",
             @"startPosition",
             @"delta",
             nil]
            ];
}

@end

//
// MoveBy
//
#pragma mark -
#pragma mark MoveBy

@implementation CCMoveBy
+(id) actionWithDuration: (ccTime) t position: (CGPoint) p
{	
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p
{
	if( (self=[super initWithDuration: t]) )
		delta_ = p;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: delta_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	CGPoint dTmp = delta_;
	[super startWithTarget:aTarget];
	delta_ = dTmp;
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ position:ccp( -delta_.x, -delta_.y)];
}
@end


//
// SkewTo
//
#pragma mark -
#pragma mark SkewTo

@implementation CCSkewTo
+(id) actionWithDuration:(ccTime)t skewX:(float)sx skewY:(float)sy 
{
	return [[[self alloc] initWithDuration: t skewX:sx skewY:sy] autorelease];
}

-(id) initWithDuration:(ccTime)t skewX:(float)sx skewY:(float)sy 
{
	if( (self=[super initWithDuration:t]) ) {	
		endSkewX_ = sx;
		endSkewY_ = sy;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] skewX:endSkewX_ skewY:endSkewY_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	
	startSkewX_ = [target_ skewX];
	
	if (startSkewX_ > 0)
		startSkewX_ = fmodf(startSkewX_, 180.0f);
	else
		startSkewX_ = fmodf(startSkewX_, -180.0f);
	
	deltaX_ = endSkewX_ - startSkewX_;
	
	if ( deltaX_ > 180 ) {
		deltaX_ -= 360;
	}
	if ( deltaX_ < -180 ) {
		deltaX_ += 360;
	}
	
	startSkewY_ = [target_ skewY];
		
	if (startSkewY_ > 0)
		startSkewY_ = fmodf(startSkewY_, 360.0f);
	else
		startSkewY_ = fmodf(startSkewY_, -360.0f);
	
	deltaY_ = endSkewY_ - startSkewY_;
	
	if ( deltaY_ > 180 ) {
		deltaY_ -= 360;
	}
	if ( deltaY_ < -180 ) {
		deltaY_ += 360;
	}
}

-(void) update: (ccTime) t
{
	[target_ setSkewX: (startSkewX_ + deltaX_ * t ) ];
	[target_ setSkewY: (startSkewY_ + deltaY_ * t ) ];
}

#pragma mark CCSkewTo - AutoMagicCoding

-(void)continueWithTarget:(id)target
{
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"skewX_",
             @"skewY_",
             @"startSkewX_",
             @"startSkewY_",
             @"endSkewX_",
             @"endSkewY_",
             @"deltaX_",
             @"deltaY_",
             nil]];
}

@end

//
// CCSkewBy
//
@implementation CCSkewBy

-(id) initWithDuration:(ccTime)t skewX:(float)deltaSkewX skewY:(float)deltaSkewY
{
	if( (self=[super initWithDuration:t skewX:deltaSkewX skewY:deltaSkewY]) ) {	
		skewX_ = deltaSkewX;
		skewY_ = deltaSkewY;
	}
	return self;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	deltaX_ = skewX_;
	deltaY_ = skewY_;
	endSkewX_ = startSkewX_ + deltaX_;
	endSkewY_ = startSkewY_ + deltaY_;
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ skewX:-skewX_ skewY:-skewY_];
}
@end


//
// JumpBy
//
#pragma mark -
#pragma mark JumpBy

@interface CCJumpBy ()

@property(nonatomic,readwrite,assign) CGPoint startPosition;
@property(nonatomic,readwrite,assign) CGPoint delta;

@end

@implementation CCJumpBy
+(id) actionWithDuration: (ccTime) t position: (CGPoint) pos height: (ccTime) h jumps:(NSUInteger)j
{
	return [[[self alloc] initWithDuration: t position: pos height: h jumps:j] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) pos height: (ccTime) h jumps:(NSUInteger)j
{
	if( (self=[super initWithDuration:t]) ) {
		delta_ = pos;
		height_ = h;
		jumps_ = j;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] position:delta_ height:height_ jumps:jumps_];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	startPosition_ = [(CCNode*)target_ position];
}

-(void) update: (ccTime) t
{
	// Sin jump. Less realistic
//	ccTime y = height * fabsf( sinf(t * (CGFloat)M_PI * jumps ) );
//	y += delta.y * t;
//	ccTime x = delta.x * t;
//	[target setPosition: ccp( startPosition.x + x, startPosition.y + y )];	
	
	// parabolic jump (since v0.8.2)
	ccTime frac = fmodf( t * jumps_, 1.0f );
	ccTime y = height_ * 4 * frac * (1 - frac);
	y += delta_.y * t;
	ccTime x = delta_.x * t;
	[target_ setPosition: ccp( startPosition_.x + x, startPosition_.y + y )];
	
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ position: ccp(-delta_.x,-delta_.y) height:height_ jumps:jumps_];
}

#pragma mark CCJumpBy - AutoMagicCoding

@synthesize startPosition = startPosition_;
@synthesize delta = delta_;

-(void)continueWithTarget:(id)target
{
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"startPosition",
             @"delta",
             @"height_",
             @"jumps_",
             nil]];
}

@end

//
// JumpTo
//
#pragma mark -
#pragma mark JumpTo

@implementation CCJumpTo
-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	delta_ = ccp( delta_.x - startPosition_.x, delta_.y - startPosition_.y );
}
@end


#pragma mark -
#pragma mark BezierBy

@interface CCBezierBy ()

@property (nonatomic, readwrite, assign) CGPoint startPosition;
@property (nonatomic, readwrite, assign) CGPoint endPosition;
@property (nonatomic, readwrite, assign) CGPoint controlPoint_1;
@property (nonatomic, readwrite, assign) CGPoint controlPoint_2;

@end

// Bezier cubic formula:
//	((1 - t) + t)3 = 1 
// Expands to… 
//   (1 - t)3 + 3t(1-t)2 + 3t2(1 - t) + t3 = 1 
static inline float bezierat( float a, float b, float c, float d, ccTime t )
{
	return (powf(1-t,3) * a + 
			3*t*(powf(1-t,2))*b + 
			3*powf(t,2)*(1-t)*c +
			powf(t,3)*d );
}

//
// BezierBy
//
@implementation CCBezierBy
+(id) actionWithDuration: (ccTime) t bezier:(ccBezierConfig) c
{	
	return [[[self alloc] initWithDuration:t bezier:c ] autorelease];
}

-(id) initWithDuration: (ccTime) t bezier:(ccBezierConfig) c
{
	if( (self=[super initWithDuration: t]) ) {
		config_ = c;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] bezier:config_];
    return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	startPosition_ = [(CCNode*)target_ position];
}

-(void) update: (ccTime) t
{
	float xa = 0;
	float xb = config_.controlPoint_1.x;
	float xc = config_.controlPoint_2.x;
	float xd = config_.endPosition.x;
	
	float ya = 0;
	float yb = config_.controlPoint_1.y;
	float yc = config_.controlPoint_2.y;
	float yd = config_.endPosition.y;
	
	float x = bezierat(xa, xb, xc, xd, t);
	float y = bezierat(ya, yb, yc, yd, t);
	[target_ setPosition:  ccpAdd( startPosition_, ccp(x,y))];
}

- (CCActionInterval*) reverse
{
	ccBezierConfig r;

	r.endPosition	 = ccpNeg(config_.endPosition);
	r.controlPoint_1 = ccpAdd(config_.controlPoint_2, ccpNeg(config_.endPosition));
	r.controlPoint_2 = ccpAdd(config_.controlPoint_1, ccpNeg(config_.endPosition));
	
	CCBezierBy *action = [[self class] actionWithDuration:[self duration] bezier:r];
	return action;
}

#pragma mark CCBezierBy - AutoMagicCoding Support

@synthesize startPosition = startPosition_;
@dynamic endPosition;
@dynamic controlPoint_1;
@dynamic controlPoint_2;

- (CGPoint) endPosition
{
    return config_.endPosition;
}

- (void) setEndPosition:(CGPoint)endPosition
{
    config_.endPosition = endPosition;
}

- (CGPoint) controlPoint_1
{
    return config_.controlPoint_1;
}

- (void) setControlPoint_1:(CGPoint)point
{
    config_.controlPoint_1 = point;
}

- (CGPoint) controlPoint_2
{
    return config_.controlPoint_2;
}

- (void) setControlPoint_2:(CGPoint)point
{
    config_.controlPoint_2 = point;
}

- (void) continueWithTarget:(id)target
{
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"startPosition",
             @"endPosition",
             @"controlPoint_1",
             @"controlPoint_2",
             nil]];
}


@end

//
// BezierTo
//
#pragma mark -
#pragma mark BezierTo
@implementation CCBezierTo
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	config_.controlPoint_1 = ccpSub(config_.controlPoint_1, startPosition_);
	config_.controlPoint_2 = ccpSub(config_.controlPoint_2, startPosition_);
	config_.endPosition = ccpSub(config_.endPosition, startPosition_);
}
@end


//
// ScaleTo
//
#pragma mark -
#pragma mark ScaleTo
@implementation CCScaleTo
+(id) actionWithDuration: (ccTime) t scale:(float) s
{
	return [[[self alloc] initWithDuration: t scale:s] autorelease];
}

-(id) initWithDuration: (ccTime) t scale:(float) s
{
	if( (self=[super initWithDuration: t]) ) {
		endScaleX_ = s;
		endScaleY_ = s;
	}
	return self;
}

+(id) actionWithDuration: (ccTime) t scaleX:(float)sx scaleY:(float)sy 
{
	return [[[self alloc] initWithDuration: t scaleX:sx scaleY:sy] autorelease];
}

-(id) initWithDuration: (ccTime) t scaleX:(float)sx scaleY:(float)sy
{
	if( (self=[super initWithDuration: t]) ) {	
		endScaleX_ = sx;
		endScaleY_ = sy;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] scaleX:endScaleX_ scaleY:endScaleY_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startScaleX_ = [target_ scaleX];
	startScaleY_ = [target_ scaleY];
	deltaX_ = endScaleX_ - startScaleX_;
	deltaY_ = endScaleY_ - startScaleY_;
}

-(void) update: (ccTime) t
{
	[target_ setScaleX: (startScaleX_ + deltaX_ * t ) ];
	[target_ setScaleY: (startScaleY_ + deltaY_ * t ) ];
}

#pragma mark CCScaleTo - AutoMagicCoding

-(void)continueWithTarget:(id)target
{
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"startScaleX_",
             @"startScaleY_",
             @"deltaX_",
             @"deltaY_",
             @"endScaleX_",
             @"endScaleY_",
             nil]];
}

@end

//
// ScaleBy
//
#pragma mark -
#pragma mark ScaleBy
@implementation CCScaleBy
-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	deltaX_ = startScaleX_ * endScaleX_ - startScaleX_;
	deltaY_ = startScaleY_ * endScaleY_ - startScaleY_;
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ scaleX:1/endScaleX_ scaleY:1/endScaleY_];
}
@end

//
// Blink
//
#pragma mark -
#pragma mark Blink
@implementation CCBlink
+(id) actionWithDuration: (ccTime) t blinks: (NSUInteger) b
{
	return [[[ self alloc] initWithDuration: t blinks: b] autorelease];
}

-(id) initWithDuration: (ccTime) t blinks: (NSUInteger) b
{
	if( (self=[super initWithDuration: t] ) )
		times_ = b;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] blinks: times_];
	return copy;
}

-(void) update: (ccTime) t
{
	if( ! [self isDone] ) {
		ccTime slice = 1.0f / times_;
		ccTime m = fmodf(t, slice);
		[target_ setVisible: (m > slice/2) ? YES : NO];
	}
}

-(CCActionInterval*) reverse
{
	// return 'self'
	return [[self class] actionWithDuration:duration_ blinks: times_];
}

#pragma mark CCBlink - AutoMagicCoding Support

- (void)continueWithTarget:(id)target
{
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"times_",
             nil]];
}



@end

//
// FadeIn
//
#pragma mark -
#pragma mark FadeIn
@implementation CCFadeIn
-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>) target_ setOpacity: 255 *t];
}

-(CCActionInterval*) reverse
{
	return [CCFadeOut actionWithDuration:duration_];
}

#pragma mark CCFadeIn - AutoMagicCoding Support

- (void)continueWithTarget:(id)target
{
}

@end

//
// FadeOut
//
#pragma mark -
#pragma mark FadeOut
@implementation CCFadeOut
-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>) target_ setOpacity: 255 *(1-t)];
}

-(CCActionInterval*) reverse
{
	return [CCFadeIn actionWithDuration:duration_];
}

#pragma mark CCFadeOut - AutoMagicCoding Support

- (void)continueWithTarget:(id)target
{
}

@end

//
// FadeTo
//
#pragma mark -
#pragma mark FadeTo
@implementation CCFadeTo
+(id) actionWithDuration: (ccTime) t opacity: (GLubyte) o
{
	return [[[ self alloc] initWithDuration: t opacity: o] autorelease];
}

-(id) initWithDuration: (ccTime) t opacity: (GLubyte) o
{
	if( (self=[super initWithDuration: t] ) )
		toOpacity_ = o;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] opacity:toOpacity_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	fromOpacity_ = [(id<CCRGBAProtocol>)target_ opacity];
}

-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>)target_ setOpacity:fromOpacity_ + ( toOpacity_ - fromOpacity_ ) * t];
}

#pragma mark CCFadeTo - AutoMagicCoding Support

- (void)continueWithTarget:(id)target
{
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"toOpacity_",
             @"fromOpacity_",
             nil]];
}

@end

//
// TintTo
//
#pragma mark -
#pragma mark TintTo

@interface CCTintTo ()

@property(nonatomic, readwrite, assign) ccColor3B to;
@property(nonatomic, readwrite, assign) ccColor3B from;

@end

@implementation CCTintTo
+(id) actionWithDuration:(ccTime)t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b
{
	return [[(CCTintTo*)[ self alloc] initWithDuration:t red:r green:g blue:b] autorelease];
}

-(id) initWithDuration: (ccTime) t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b
{
	if( (self=[super initWithDuration:t] ) )
		to_ = ccc3(r,g,b);
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [(CCTintTo*)[[self class] allocWithZone: zone] initWithDuration:[self duration] red:to_.r green:to_.g blue:to_.b];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	from_ = [tn color];
}

-(void) update: (ccTime) t
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	[tn setColor:ccc3(from_.r + (to_.r - from_.r) * t, from_.g + (to_.g - from_.g) * t, from_.b + (to_.b - from_.b) * t)];
}

#pragma mark CCTintTo - AutoMagicCoding Support

@synthesize to = to_;
@synthesize from = from_;

- (void)continueWithTarget:(id)target
{
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"to",
             @"from",
             nil]];
}

- (NSString *) AMCEncodeStructWithValue: (NSValue *) structValue withName: (NSString *) structName
{
    if ([structName isEqualToString: @"_ccColor3B"]
        || [structName isEqualToString: @"ccColor3B"])
    {
        ccColor3B color;
        [structValue getValue: &color];
        return NSStringFromCCColor3B(color);
    }
    else
        return [super AMCEncodeStructWithValue:structValue withName:structName];
}

- (NSValue *) AMCDecodeStructFromString: (NSString *)value withName: (NSString *) structName
{
    if ([structName isEqualToString: @"_ccColor3B"]
        || [structName isEqualToString: @"ccColor3B"])
    {
        ccColor3B color = ccColor3BFromNSString(value);
        
        return [NSValue valueWithBytes: &color objCType: @encode(ccColor3B) ];
    }
    else
        return [super AMCDecodeStructFromString:value withName:structName];
}

@end

//
// TintBy
//
#pragma mark -
#pragma mark TintBy
@implementation CCTintBy
+(id) actionWithDuration:(ccTime)t red:(GLshort)r green:(GLshort)g blue:(GLshort)b
{
	return [[(CCTintBy*)[ self alloc] initWithDuration:t red:r green:g blue:b] autorelease];
}

-(id) initWithDuration:(ccTime)t red:(GLshort)r green:(GLshort)g blue:(GLshort)b
{
	if( (self=[super initWithDuration: t] ) ) {
		deltaR_ = r;
		deltaG_ = g;
		deltaB_ = b;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return[(CCTintBy*)[[self class] allocWithZone: zone] initWithDuration: [self duration] red:deltaR_ green:deltaG_ blue:deltaB_];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	ccColor3B color = [tn color];
	fromR_ = color.r;
	fromG_ = color.g;
	fromB_ = color.b;
}

-(void) update: (ccTime) t
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	[tn setColor:ccc3( fromR_ + deltaR_ * t, fromG_ + deltaG_ * t, fromB_ + deltaB_ * t)];
}

- (CCActionInterval*) reverse
{
	return [CCTintBy actionWithDuration:duration_ red:-deltaR_ green:-deltaG_ blue:-deltaB_];
}

#pragma mark CCTintBy - AutoMagicCoding Support

- (void)continueWithTarget:(id)target
{
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"deltaR_",
             @"deltaG_",
             @"deltaB_",
             @"fromR_",
             @"fromG_",
             @"fromB_",
             nil]];
}

@end

//
// DelayTime
//
#pragma mark -
#pragma mark DelayTime
@implementation CCDelayTime
-(void) update: (ccTime) t
{
	return;
}

-(id)reverse
{
	return [[self class] actionWithDuration:duration_];
}

-(void)continueWithTarget:(id)target
{
}

@end

//
// ReverseTime
//
#pragma mark -
#pragma mark ReverseTime
@implementation CCReverseTime
+(id) actionWithAction: (CCFiniteTimeAction*) action
{
	// casting to prevent warnings
	CCReverseTime *a = [super alloc];
	return [[a initWithAction:action] autorelease];
}

-(id) initWithAction: (CCFiniteTimeAction*) action
{
	NSAssert(action != nil, @"CCReverseTime: action should not be nil");
	NSAssert(action != other_, @"CCReverseTime: re-init doesn't support using the same arguments");

	if( (self=[super initWithDuration: [action duration]]) ) {
		// Don't leak if action is reused
		[other_ release];
		other_ = [action retain];
	}
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithAction:[[other_ copy] autorelease] ];
}

-(void) dealloc
{
	[other_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[other_ startOrContinueWithTarget:target_];
}

-(void) stop
{
	[other_ stop];
	[super stop];
}

-(void) update:(ccTime)t
{
    if ([other_ isKindOfClass:[CCActionInterval class]])
    {
        [other_ setValue:[NSNumber numberWithBool: NO] forKey:@"firstTick_"];
    }
	[other_ update:1-t];
}

-(CCActionInterval*) reverse
{
	return [[other_ copy] autorelease];
}

- (void)continueWithTarget:(id)target
{
    [other_ startOrContinueWithTarget:target_];
}

- (AMCFieldType) AMCFieldTypeForValueWithKey:(NSString *)aKey
{
    if ( [aKey isEqualToString:@"other_"] )
    {
        return kAMCFieldTypeCustomObject;
    }
    else
        return [super AMCFieldTypeForValueWithKey:aKey];
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"other_",
             nil]];
}

@end

//
// Animate
//

#pragma mark -
#pragma mark Animate

@interface CCAnimate ()

@property (nonatomic, readwrite, retain) id origFrame;

@end

@implementation CCAnimate

@synthesize animation = animation_;

+(id) actionWithAnimation: (CCAnimation*)anim
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:YES] autorelease];
}

+(id) actionWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL)b
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:b] autorelease];
}

+(id) actionWithDuration:(ccTime)duration animation: (CCAnimation*)anim restoreOriginalFrame:(BOOL)b
{
	return [[[self alloc] initWithDuration:duration animation:anim restoreOriginalFrame:b] autorelease];
}

-(id) initWithAnimation: (CCAnimation*)anim
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	return [self initWithAnimation:anim restoreOriginalFrame:YES];
}

-(id) initWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");

	if( (self=[super initWithDuration: [[anim frames] count] * [anim delay]]) ) {

		restoreOriginalFrame_ = b;
		self.animation = anim;
	}
	return self;
}

-(id) initWithDuration:(ccTime)aDuration animation: (CCAnimation*)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	
	if( (self=[super initWithDuration:aDuration] ) ) {
		
		restoreOriginalFrame_ = b;
		self.animation = anim;
	}
	return self;
}


-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithDuration:duration_ animation:animation_ restoreOriginalFrame:restoreOriginalFrame_];
}

-(void) dealloc
{
	self.animation = nil;
	self.origFrame = nil;
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	CCSprite *sprite = target_;

    self.origFrame = nil;

	if( restoreOriginalFrame_ )
		self.origFrame = [sprite displayedFrame];
}

-(void) stop
{
	if( restoreOriginalFrame_ ) {
		CCSprite *sprite = target_;
		[sprite setDisplayFrame:self.origFrame];
	}
	
	[super stop];
}

-(void) update: (ccTime) t
{
	NSArray *frames = [animation_ frames];
	NSUInteger numberOfFrames = [frames count];
	
	NSUInteger idx = t * numberOfFrames;

	if( idx >= numberOfFrames )
		idx = numberOfFrames -1;
	
	CCSprite *sprite = target_;
	if (! [sprite isFrameDisplayed: [frames objectAtIndex: idx]] )
		[sprite setDisplayFrame: [frames objectAtIndex:idx]];
}

- (CCActionInterval *) reverse
{
	NSArray *oldArray = [animation_ frames];
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[oldArray count]];
    NSEnumerator *enumerator = [oldArray reverseObjectEnumerator];
    for (id element in enumerator)
        [newArray addObject:[[element copy] autorelease]];
	
	CCAnimation *newAnim = [CCAnimation animationWithFrames:newArray delay:animation_.delay];
	return [[self class] actionWithDuration:duration_ animation:newAnim restoreOriginalFrame:restoreOriginalFrame_];
}

#pragma mark CCAnimate - AutoMagicCoding Support

@synthesize origFrame = _origFrame;

- (void)continueWithTarget:(id)target
{
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [[super AMCKeysForDictionaryRepresentation] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects: 
             @"animation",
             @"origFrame",
             @"restoreOriginalFrame_",
             nil]];
}

@end
