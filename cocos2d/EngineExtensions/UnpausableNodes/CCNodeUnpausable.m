//
//  CCPausedScheduler.m
//  itraceur
//
//  Created by Stepan Generalov on 16.11.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import "CCNodeUnpausable.h"
#import "CCPausedScheduler.h"
#import "CCPausedActionManager.h"


#pragma mark Unpausable Nodes

@implementation  CCNodeUnpausable
#include "CCNodeUnpausableMutation.inc"
@end


@implementation CCLayerUnpausable
#include "CCNodeUnpausableMutation.inc"
@end


@implementation CCSpriteUnpausable
#include "CCNodeUnpausableMutation.inc"
@end


@implementation  CCColorLayerUnpausable
#include "CCNodeUnpausableMutation.inc"
@end

@implementation CCLayerColorUnpausable
@end




@implementation  CCMenuUnpausable
#include "CCNodeUnpausableMutation.inc"
@end

@implementation  CCMenuItemSpriteUnpausable
#include "CCNodeUnpausableMutation.inc"
@end
