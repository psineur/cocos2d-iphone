-(CCAction*) runAction:(CCAction*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");
	
	[[CCPausedActionManager sharedManager] addAction:action target:self paused:!isRunning_];
	return action;
}

-(void) stopAllActions
{
	[[CCPausedActionManager sharedManager] removeAllActionsFromTarget:self];
}

-(void) stopAction: (CCAction*) action
{
	[[CCPausedActionManager sharedManager] removeAction:action];
}

-(void) stopActionByTag:(int)aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	[[CCPausedActionManager sharedManager] removeActionByTag:aTag target:self];
}

-(CCAction*) getActionByTag:(int) aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	
	return [[CCPausedActionManager sharedManager] getActionByTag:aTag target:self];
}

-(int) numberOfRunningActions
{
	return [[CCPausedActionManager sharedManager] numberOfRunningActionsInTarget:self];
}

-(void) scheduleUpdateWithPriority:(int)priority
{
	[[CCPausedScheduler sharedScheduler] scheduleUpdateForTarget:self priority:priority paused:!isRunning_];
}

-(void) unscheduleUpdate
{
	[[CCPausedScheduler sharedScheduler] unscheduleUpdateForTarget:self];
}

-(void) schedule:(SEL)selector interval:(ccTime)interval
{
	NSAssert( selector != nil, @"Argument must be non-nil");
	NSAssert( interval >=0, @"Arguemnt must be positive");
	
	[[CCPausedScheduler sharedScheduler] scheduleSelector:selector forTarget:self interval:interval paused:!isRunning_];
}

-(void) unschedule:(SEL)selector
{
	// explicit nil handling
	if (selector == nil)
		return;
	
	[[CCPausedScheduler sharedScheduler] unscheduleSelector:selector forTarget:self];
}

-(void) unscheduleAllSelectors
{
	[[CCPausedScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
}
- (void) resumeSchedulerAndActions
{
	[[CCPausedScheduler sharedScheduler] resumeTarget:self];
	
	[[CCPausedActionManager sharedManager] resumeTarget:self];
}

- (void) pauseSchedulerAndActions
{
	[[CCPausedScheduler sharedScheduler] pauseTarget:self];
	[[CCPausedActionManager sharedManager] pauseTarget:self];
}
