/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */
#import "MenuItem.h"
#import "CCLayer.h"

/** A Menu
 * 
 * Features and Limitation:
 *  - You can add MenuItem objects in runtime using addChild:
 *  - But the only accecpted children are MenuItem objects
 */
@interface Menu : CCLayer <CCRGBAProtocol>
{
	int selectedItem;
	GLubyte opacity;
}

/** creates a menu with it's items */
+ (id) menuWithItems: (MenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;

/** initializes a menu with it's items */
- (id) initWithItems: (MenuItem*) item vaList: (va_list) args;

@property (readwrite,assign) GLubyte opacity;

@end
