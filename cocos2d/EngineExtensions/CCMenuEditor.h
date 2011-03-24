//
//  CCMenuEditor.h
//  iTraceur for Mac
//
//  Created by Stepan Generalov on 23.12.10.
//  Copyright 2010 Parkour Games. All rights reserved.
//

#import "cocos2d.h"



@interface CCMenuEditor : NSObject 
{
	NSArray *_elementsArray;
}

#pragma mark Interface

+ (id) menuEditorWithPropertyListName: (NSString *) propertyListName;

- (id) initWithPropertyListName: (NSString *) propertyListName;

- (CGPoint) positionForElementWithName: (NSString *) imageName;

#pragma mark Old Interface
+ (NSArray *) loadArrayFromPropertyListWithName: (NSString *) propertyListName;

+ (CGPoint) positionForElementWithName: (NSString *) imageName 
							 fromArray:  (NSArray  *) anArray;

@end
